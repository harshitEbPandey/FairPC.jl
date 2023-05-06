import pandas as pd
from math import comb

def get_analysis(k_list):
    for k in k_list:
        df_nlat = pd.read_csv(f'{k}_csv', sep=', ',header=None, engine='python')
        df_nlat = df_nlat.transpose()
        
        df_lat = pd.read_csv(f'{k}_l_csv', sep=', ',header=None, engine='python')
        df_lat = df_lat.transpose()
        
        print(f'Mean of all EP with k on nonLatent PC= {k} = {df_nlat[0].mean()}')
        print(f'StdDev of all EP with k on nonLatent PC= {k} = {df_nlat[0].std()}')
        print(f'mean of all EP with k on FairPC = {k} = {df_lat[0].mean()}')
        print(f'StdDev of all EP with k on FairPC = {k} = {df_lat[0].std()}')
        
        instances = pd.read_csv(f'{k}_test.csv')
        # final_df['EP nlat'] = df_nlat[0]
        # final_df['EP fair'] = df_lat[0]

        vals = pd.DataFrame(columns=['instance','nlat mean','nlat stdDev', 'fair mean' , 'fair stdDev'],index=range(comb(7,k)))
        for idx in range(comb(7,k)):
            t1 = df_nlat.iloc[(35*idx):35*(idx+1)-1]
            t2 = df_lat.iloc[(35*idx):35*(idx+1)-1]
            vals.loc[idx] = [list(instances.iloc[(35*idx)][:]),t1[0].mean(),t1[0].std(),t2[0].mean(),t2[0].std()]

        display(vals)
        vals.to_csv(f'{k}_analysis.csv')

get_analysis([3,4,5])