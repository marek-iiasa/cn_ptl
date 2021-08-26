"""
Read the gdx files containg the solutions of the MCMA iterations defined by itr_lst list.
Extract the values of ACT variables (activity levels) for the technologies defined by tec list and
their values together with the corresponding subset of indices and values defined by df_cols list.
Store the extracted values with the add itr_id in the act.csv file.
The *gdx files and the act.csv file are located in the directory named 945 (the number indicates the MCMA
analysis_id to which all these iterations belong).
"""
import gdxpds
# import pandas as pd  not needed (probably imported with gdxpds)
# import pathlib

fn_csv = '945/act.csv'      # csv file with values of ACT from the itr_lst
itr_lst = range(2121, 2144)
for itr_id in itr_lst:
    gdx_file = '945/' + str(itr_id) + '.gdx'
    dataframes = gdxpds.to_dataframes(gdx_file)

    # extract subset of ACT (compound variable representiving activities) values
    df_cols = ['tec', 'vintage', 'year_all', 'Level']   # subset of attributes/columns to be extracted
    tec = ['OTL', 'CTL', 'PTL', 'BTL']      # subset of technologies to be extracted
    for symbol_name, df in dataframes.items():
        if symbol_name == 'ACT':
            df_act = df.loc[df['tec'].isin(tec), df_cols]
            df_act.insert(0, 'iter', str(itr_id))
            if itr_id == itr_lst[0]:    # for the first iter: write csv header, initialize the csv file
                df_act.to_csv(fn_csv, index=False, float_format='%.3e', mode='w')
            else:       # for subsequent iters: don't write header, add rows to those previously written
                df_act.to_csv(fn_csv, index=False, float_format='%.3e', mode='a', header=False)
            # print("Selected columns and rows of {} stored in df_act.".format(symbol_name))
            print('Values of selected columns and rows of ACT of iter ' + str(itr_id) + ' added to act.csv file.')
            break

print('Finished writing the act.csv file.')
