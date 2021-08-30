"""
Read the gdx files containg the solutions of the MCMA iterations defined by itr_lst list.
Extract the values of ACT variables (activity levels) for the technologies defined by tec list and
their values together with the corresponding subset of indices and values defined by df_cols list.
Store the extracted values with the add itr_id in the act.csv file.
The *gdx files and the act.csv file are located in the directory named 945 (the number indicates the MCMA
analysis_id to which all these iterations belong).
"""
import gdxpds   # warning is displayed, if this is not the first import
import sys
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
# import pathlib
sns.set()   # default settings for seaborn plotting style

mk_csv = False
fn_csv = '945/act.csv'      # csv file with values of ACT from the itr_lst
itr_lst = range(2121, 2144)
# itr_lst = range(2121, 2124)     # 2124 replaced by 2122 for testing just 3 iters for testing
# itr_lst = [2122, 2123, 2124, 2143, 2134, 2131, 2129]  # subset showing non-monotonicity of CO2
tec = ['OTL', 'CTL', 'PTL', 'BTL']  # subset of technologies to be extracted
small_dfs = []      # list of ACT dfs, each for one iter
itr_co2 = itr_cost = -1.
scal_co2_cost = 1.e-9   # scale cost and CO2
row_lst = []
for itr_id in itr_lst:
    i_found = 0
    gdx_file = '945/' + str(itr_id) + '.gdx'
    dataframes = gdxpds.to_dataframes(gdx_file)

    # extract subset of ACT (compound variable representiving activities) values
    df_cols = ['tec', 'vintage', 'year_all', 'Level']   # subset of attributes/columns to be extracted
    for symbol_name, df in dataframes.items():
        if symbol_name == 'ACT':
            i_found += 1
            df_act = df.loc[df['tec'].isin(tec), df_cols]   # select only rows with techn in tec[]
            df_act.insert(0, 'iter', str(itr_id))   # add column with the itr_id
            if mk_csv:
                if itr_id == itr_lst[0]:    # for the first iter: write csv header, initialize the csv file
                    df_act.to_csv(fn_csv, index=False, float_format='%.3e', mode='w')
                else:       # for subsequent iters: don't write header, add rows to those previously written
                    df_act.to_csv(fn_csv, index=False, float_format='%.3e', mode='a', header=False)
                # print("Selected columns and rows of {} stored in df_act.".format(symbol_name))
                print('Values of selected columns and rows of ACT of iter ' + str(itr_id) + ' added to act.csv file.')
            else:
                small_dfs.append(df_act)
        elif symbol_name == 'CO2_CUM':
            i_found += 1
            itr_co2 = round(scal_co2_cost * df.iloc[0]['Level'], 3)
        elif symbol_name == 'COST_CUM':
            i_found += 1
            itr_cost = round(scal_co2_cost * df.iloc[0]['Level'], 3)
        if i_found > 2:     # all needed symbols (ACT, CO2_CUM, COST_CIM) found; break looking for.
            break
    row_lst.append([str(itr_id), itr_co2, itr_cost])
    print('itr ' + str(itr_id) + ': co2 = ' + str(itr_co2) + ', cost = ' + str(itr_cost))
    # print(row_lst)


if mk_csv:      # write the acr.csv and exit
    print('Finished writing the act.csv file.')
    sys.exit(0)

# continue with processing ACT values
df_cost_co2 = pd.DataFrame(row_lst, columns=['itr', 'co2', 'cost'])
cost_co2 = df_cost_co2.sort_values(by='cost')
act_all = pd.concat(small_dfs, ignore_index=True)

# act_tmp = act_all.loc[(act_all['tec'] == 'OTL'), 'Level']
# act_tmp2 = act_all.loc[(act_all['year_all'] == str(2025)), 'Level']
# act_tmp3 = act_all.loc[(act_all['tec'] == 'OTL') & (act_all['year_all'] == str(2025)), 'Level']
# sum_by_vintage = act_all.loc[(act_all['tec'] == 'OTL') & (act_all['year_all'] == str(2025)), 'Level'].sum()
# print(act_tmp3)
print('Collected ACT values of all iters into act_all')

periods = range(2020, 2055, 5)  # starting year of each of 5-yr period
scal_act = 1.e-9
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
fig_name = '945/cost_co2.png'
# fig1.savefig(fig_name)
# print('Figure stored in ' + fig_name)
print('Figure NOT stored in ' + fig_name)
