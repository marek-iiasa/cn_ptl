"""
Process selected (defined by the corresponding itr_lst list) MCMA solutions stored in a selected subdirectory
(its name corresponds to the MCMA analysis id) as gdx files, each named by the corresponding iteration id.
Extract values of selected variables for the technologies defined by tec list together with the corresponding
subset of indices defined by df_cols list, and store them in corresponding df (pandas dataframe).
The extracted values are either plotted or stored (in the data sub-dir) in csv files.

Currently,the following variables are processed: COST_CUM, CO2_CUM, ACT, CAP, CAP_NEW
"""
import gdxpds   # warning is displayed, if this is not the first import
import sys
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
# import pathlib
sns.set()   # default settings for seaborn plotting style

mk_csv = False      # if True only ACT csv is written
dir_dat = '985'    # scaled params, correct Pareto solutions
# dir_dat = '945'    # not scaled params, wrong Pareto solutions, i.e., some are dominated
fn_csv = dir_dat + '/act.csv'      # csv file with values of ACT from the itr_lst

zero_tol = 1e-6     # smaller Levels assumed to be equal to zero
#  tec = ['OTL', 'CTL', 'PTL', 'BTL']  # subset of technologies to be extracted
tec = ['OTL', 'PTL']  # subset of technologies to be extracted (ACT == 0 for CTL & BTL)
df_cols = ['tec', 'vintage', 'year_all', 'Level']  # subset of attributes/columns to be extracted
df_cols2 = ['tec', 'year_all', 'Level']  # CAP_NEW has no vintage attr.

#  data/solutions-dependent parameters
if dir_dat == '985':
    scal_co2_cost = 1.  # no need for scaling cost and CO2
    scal_act = 1.
    # itr_lst = [2303, 2333, 2322, 2302]    # two selfish, and two "in between"
    itr_lst = [2304]    # compromise solution
else:
    scal_co2_cost = 1.e-9  # scale cost and CO2
    scal_act = 1.e-9
    itr_lst = range(2121, 2144)
    # itr_lst = range(2121, 2124)     # 2124 replaced by 2122 for testing just 3 iters for testing
    # itr_lst = [2122, 2123, 2124, 2143, 2134, 2131, 2129]  # subset showing non-monotonicity of CO2

crit_lst = []   # list of criteria values (one triple for each iter)
dfs_act = []    # list of ACT dfs, each for one iter
dfs_cap = []    # list of CAP dfs, each for one iter
dfs_cap_new = []    # list of CAP_NEW dfs, each for one iter

entity_lst = ['ACT', 'CAP', 'CAP_NEW', 'CO2_CUM', 'COST_CUM']
n_entities = len(entity_lst)

#  main loop over iterations
for itr_id in itr_lst:
    i_found = 0
    gdx_file = dir_dat + '/' + str(itr_id) + '.gdx'
    dataframes = gdxpds.to_dataframes(gdx_file)  # each df contains one entity (ACT, COST_CUM, etc)

    # loop over df's of the gdx file until all found, store each entity in the corresponding dfs
    # (except of criteria [cost and CO2], which are stored in crit_lst).
    itr_cost = 0    # only for supress warning "can be not defined"
    itr_co2 = 0
    for symbol_name, df in dataframes.items():
        if i_found > n_entities:     # all needed (ACT, CAP, CO2_CUM, COST_CUM) found; break looking for.
            break
        if symbol_name in entity_lst:   # entity to be processed
            i_found += 1
            # print('processing :' + symbol_name)
        else:
            continue
        if symbol_name == 'ACT':
            # df_act1 = df.loc[df['tec'].isin(tec), df_cols]   # select only rows with techn in tec[]
            # only rows with techn in tec[] and non-zero values of Level
            df_act = df.loc[(df['tec'].isin(tec)) & (df['Level'] > zero_tol), df_cols]
            # print('Non-zero and all values of levels of considered technologies: ', str(len(df_act)), ', ',
            # str(len(df_act1)))
            df_act.insert(0, 'iter', str(itr_id))   # add column with the itr_id
            if mk_csv:
                if itr_id == itr_lst[0]:    # for the first iter: write csv header, initialize the csv file
                    df_act.to_csv(fn_csv, index=False, float_format='%.3e', mode='w')
                else:       # for subsequent iters: don't write header, add rows to those previously written
                    df_act.to_csv(fn_csv, index=False, float_format='%.3e', mode='a', header=False)
                # print("Selected columns and rows of {} stored in df_act.".format(symbol_name))
                print('Values of selected columns and rows of ACT of iter ' + str(itr_id) + ' added to act.csv file.')
            else:
                dfs_act.append(df_act)
        elif symbol_name == 'CAP':
            df_tmp = df.loc[(df['tec'].isin(tec)) & (df['Level'] > zero_tol), df_cols]
            df_tmp.insert(0, 'iter', str(itr_id))   # add column with the itr_id
            dfs_cap.append(df_tmp)
        elif symbol_name == 'CAP_NEW':
            df_tmp = df.loc[(df['tec'].isin(tec)) & (df['Level'] > zero_tol), df_cols2]
            df_tmp.insert(0, 'iter', str(itr_id))  # add column with the itr_id
            dfs_cap_new.append(df_tmp)
        elif symbol_name == 'CO2_CUM':
            itr_co2 = round(scal_co2_cost * df.iloc[0]['Level'], 3)
        elif symbol_name == 'COST_CUM':
            itr_cost = round(scal_co2_cost * df.iloc[0]['Level'], 3)

    # add criteria values to the list of values for all iterations
    crit_lst.append([str(itr_id), itr_co2, itr_cost])
    # print('itr ' + str(itr_id) + ': co2 = ' + str(itr_co2) + ', cost = ' + str(itr_cost))
    # print(crit_lst)

if mk_csv:      # write the acr.csv and exit
    print('Finished writing the act.csv file.')
    sys.exit(0)

# continue with processing ACT values
df_cost_co2 = pd.DataFrame(crit_lst, columns=['itr', 'co2', 'cost'])
cost_co2 = df_cost_co2.sort_values(by='cost')
act_all = pd.concat(dfs_act, ignore_index=True)
cap_all = pd.concat(dfs_cap, ignore_index=True)
cap_new_all = pd.concat(dfs_cap_new, ignore_index=True)

print('\nValues of criteria (cost and CO2)')
print(cost_co2)

# cap slacks (capacity - activity)
cap_slack = cap_all
cap_slack['act_lev'] = act_all['Level']     # add activity Level col as act_lev
cap_slack['slack'] = cap_slack['Level'].sub(cap_slack['act_lev'], axis=0)  # difference between CAP and ACT
print('\nCapacities, activities, and slacks')
print(cap_slack)

print('\nNew capacities')
print(cap_new_all)

'''
print('act_all')
print(act_all)
print(act_all.info())
print('cap_all')
print(cap_all)
print('cap_new_all')
print(cap_new_all)

act_tmp = act_all.loc[(act_all['tec'] == 'OTL'), 'Level']
act_tmp2 = act_all.loc[(act_all['year_all'] == str(2025)), 'Level']
act_tmp3 = act_all.loc[(act_all['tec'] == 'OTL') & (act_all['year_all'] == str(2025)), 'Level']
sum_by_vintage = act_all.loc[(act_all['tec'] == 'OTL') & (act_all['year_all'] == str(2025)), 'Level'].sum()
print('act_tmp3')
print(act_tmp3)
print('Collected ACT values of all iters into act_all')
'''

periods = range(2020, 2055, 5)  # starting year of each of 5-yr period
for itr in itr_lst:
    itr_sum = 0.
    sum_by_vintage = 0.
    for techn in tec:
        for period in periods:
            sum_by_vintage = act_all.loc[(act_all['iter'] == str(itr)) & (act_all['tec'] == techn) &
                                         (act_all['year_all'] == str(period)), 'Level'].sum()
            sum_by_vintage *= scal_act
            sum_by_vintage = round(sum_by_vintage, 3)
            # print(str(itr) + ', ' + techn + ', ' + str(period) + ', ' + str(sum_by_vintage))
            itr_sum += sum_by_vintage
            itr_sum = round(itr_sum, 3)
    print('Sum of all activities of itr ' + str(itr) + ': ' + str(itr_sum))
print('Sums of ACT by vintage, calculated for each techn and period (to be stored in a df for charts).')

if len(itr_lst) < 2:      # don't make chart for only one itr
    print('Chart not generated for only one iteration.')
    sys.exit(0)

# plot CO2/cost trade-offs chart
fig1 = plt.figure(figsize=(10, 5))
locs, labels = plt.xticks()
plt.setp(labels, rotation=45)   # rotation does not work if these two lines follow ax/ax2
ax = sns.lineplot(data=cost_co2, x='itr', y='cost', color='red', label='cost')  # , ax=ax)
ax2 = ax.twinx()
# ax.grid(False)  # two grids are confusing
ax2.grid(axis='both', which='both')
sns.lineplot(data=cost_co2, x='itr', y='co2', color='green', label='CO2 emission', ax=ax2)
ax.set_title('Total cost vs total CO2 emission trade-offs for 23 MCMA iterations (sorted by increasing cost)')
ax.set_xlabel('Iteration id')
ax.set_ylabel('Total cost  (RMB * 10^{15})')
ax2.set_ylabel('Total CO2 emission (GTons)')
hand1, lab1 = ax.get_legend_handles_labels()
hand2, lab2 = ax2.get_legend_handles_labels()
ax.legend(loc='center right', handles=hand1+hand2, labels=lab1+lab2)
ax2.legend(loc='center right', handles=hand1+hand2, labels=lab1+lab2)   # overlap prevents aditional legend for 2nd plot

plt.show()
fig_name = dir_dat + '/cost_co2.png'
# fig1.savefig(fig_name)
# print('Figure stored in ' + fig_name)
print('Figure NOT stored in ' + fig_name)
