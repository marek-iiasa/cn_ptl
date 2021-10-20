#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
import ixmp
import message_ix

get_ipython().run_line_magic('matplotlib', 'inline')


# In[2]:


# Loading Modeling platform
mp = ixmp.Platform()


# In[3]:


# Creating a new, empty scenario
scenario = message_ix.Scenario(mp, model='PTL baseline', 
                               scenario='baseline_xlsx', version='new')


# In[4]:


horizon = range(2020,2051,5)
scenario.add_horizon(year=horizon)


# In[5]:


year_df = scenario.vintage_and_active_years()
vintage_years, act_years = year_df['year_vtg'], year_df['year_act']


# In[6]:


node = 'Chinese'
scenario.add_spatial_sets({'country': node})


# In[7]:


scenario.add_set("commodity", ["coal", "oil", "hydrogen","CO2","biomass","gasoline","diesel","liquid"])


# In[8]:


scenario.add_par("interestrate", horizon, value=0.06, unit='-')


# In[9]:


scenario.add_set("level", ["primary","secondary", "final", "useful"])


# In[10]:


scenario.add_set('emission', 'CO2')
scenario.add_cat('emission', 'GHG', 'CO2')


# In[ ]:





# In[11]:


from message_ix.util import make_df


# In[12]:


scenario.read_excel("PTL_baseline_demand.xlsx", add_units=True, commit_steps=False)


# In[13]:


print(scenario.idx_names('demand'))


# In[14]:


scenario.add_set("technology", ['oil_exc', 'oil_import', 'coal_exc', 'renewable_hydrogen','CO2_capture','biomass_exc','OTL','CTL','PTL','BTL','Transportation'])


# In[15]:


scenario.read_excel("PTL_baseline_technology_basic.xlsx", add_units=True, commit_steps=False)


# In[16]:


scenario.read_excel("emission.xlsx", add_units=True, commit_steps=False)


# In[17]:


scenario.check_out()


# # we now add CO2 emissions to the coal powerplant
# base_emissions = {
#     'node_loc': node,
#     'year_vtg': vintage_years,
#     'year_act': act_years,
#     'mode': 'standard',
#     'unit': 'tCO2/t',
# }
# 
# # adding new units to the model library (needed only once)
# mp.add_unit('tCO2/t')
# mp.add_unit('MtCO2')
# emissions = {
#     'OTL': ('CO2', 0.33), # units: tCO2/t 来源 孟宪玲，当代石油化工 1t原油对应 0.3 tCO2
#     'CTL':  ('CO2', 4.75), # units: tCO2/t 来源 Meiyu Guo 2018
#     'PTL':  ('CO2', 0.05),# units: tCO2/t
#     'BTL':  ('CO2', 0.18)# units: tCO2/t
# }
# for tec, (species, val) in emissions.items():
#     df = make_df(base_emissions, technology=tec, emission=species, value=val)
#     scenario.add_par('emission_factor', df)

# In[18]:


scenario.set('technology')


# In[19]:


scenario.par('capacity_factor')


# In[20]:


scenario.read_excel("PTL_baseline_technology_constraint.xlsx", add_units=True, commit_steps=False)


# In[21]:


scenario.read_excel("PTL_baseline_technology_historic.xlsx", add_units=True, commit_steps=False)


# In[22]:


mp.add_unit('CNY/t')  


# In[23]:


scenario.read_excel("PTL_baseline_technology_economic.xlsx", add_units=True, commit_steps=False)


# In[24]:


scenario.set_as_default()


# In[25]:


scenario.solve()


# In[26]:


# Objective value of the original 'baseline' scenario.
#base = message_ix.Scenario(mp, model='PTL model attempt', scenario='baseline')
#base.var('OBJ')['lvl']


# In[27]:


scenario.var('OBJ')['lvl']


# In[28]:


#mp.close_db()


# In[29]:


from message_ix.reporting import Reporter

rep = Reporter.from_scenario(scenario)


# In[30]:


from message_ix.util.tutorial import prepare_plots

prepare_plots(rep)


# In[31]:


# Only show a subset of technologies in the follow plots;
# e.g. exclude "bulb" and "grid"
rep.set_filters(t=["oil_exc", "oil_import"])

# Trigger the calculation and plotting
rep.get("plot activity")


# In[32]:


# Only show a subset of technologies in the follow plots;
# e.g. exclude "bulb" and "grid"
rep.set_filters(t=["OTL", "CTL","PTL","BTL"])

# Trigger the calculation and plotting
rep.get("plot activity")


# In[33]:


rep.get("plot capacity")


# In[34]:


scenario.var('ACT').to_csv('ptl_act.csv')


# In[35]:


mp.close_db()


# In[ ]:




