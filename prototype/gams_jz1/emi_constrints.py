#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
import ixmp
import message_ix

from message_ix.util import make_df

get_ipython().run_line_magic('matplotlib', 'inline')
mp = ixmp.Platform()
model = 'PTL baseline'

base = message_ix.Scenario(mp, model='PTL baseline', scenario='baseline_xlsx')
scen = base.clone(model, 'emission_bound','introducing an upper bound on emissions',
                  keep_solution=False)
scen.check_out()
year_df = scen.vintage_and_active_years()
vintage_years, act_years = year_df['year_vtg'], year_df['year_act']
model_horizon = scen.set('year')
country = 'Chinese'


# In[2]:


# first we introduce the emission of CO2 and the emission category GHG
scen.add_set('emission', 'CO2')
scen.add_cat('emission', 'GHG', 'CO2')

# we now add CO2 emissions to the coal powerplant
#base_emissions = {
#    'node_loc': country,
#    'year_vtg': vintage_years,
#    'year_act': act_years,
#    'mode': 'standard',
#    'unit': 'tCO2/t',
#}

# adding new units to the model library (needed only once)
#mp.add_unit('tCO2/t')
#mp.add_unit('MtCO2')
#emissions = {
#    'OTL': ('CO2', 0.33), # units: tCO2/t 来源 孟宪玲，当代石油化工 1t原油对应 0.3 tCO2
#    'CTL':  ('CO2', 4.75), # units: tCO2/t 来源 Meiyu Guo 2018
#    'PTL':  ('CO2', 0.05),# units: tCO2/t
#    'BTL':  ('CO2', 0.18)# units: tCO2/t
#}
#for tec, (species, val) in emissions.items():
#    df = make_df(base_emissions, technology=tec, emission=species, value=val)
#    scen.add_par('emission_factor', df)


# In[3]:


scen.add_par('bound_emission', [country, 'GHG', 'all', 'cumulative'],
             value=21958144.85, unit='tCO2')#2303112663初值


# In[4]:


scen.commit(comment='introducing emissions and setting an upper bound')
scen.set_as_default()
scen.solve()


# In[5]:


scen.var('OBJ')['lvl']


# In[6]:


scen.var('ACT').to_csv('1.csv')


# In[7]:


from message_ix.reporting import Reporter
from message_ix.util.tutorial import prepare_plots

rep = Reporter.from_scenario(scen)
prepare_plots(rep)


# In[8]:


rep.set_filters(t=["CTL", "OTL","BTL","PTL"])
rep.get("plot activity")


# In[9]:


rep.get("plot capacity")


# In[10]:


rep.get("plot demand")


# In[11]:


rep.get("plot new capacity")


# In[12]:


mp.close_db()


# In[ ]:




