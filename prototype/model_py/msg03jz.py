"""
This code is based on the jupyter nb by Jinyang; info on cells was removed.
The code was modified by Marek to read data from a dedicated directory and from renamed (to use short names) files.
Code was also modified to conform to the PEP 8 (i.e., all pycharm warnings were addressed).
see the Readme.txt for more  info

The code reports two errors (on import ixmp and message+ix) but runs despite the reported errors.
Open issues:
- optimization finished OK; the results needs to be checked.
- post-processing reports two errors, both related to the gdx content
The console output is stored in log01.txt file.

NOTE: the GAMS files are located message_ix installation dependent dir. In Marek's iMac:
/Users/marek/anaconda3/envs/msg_env/lib/python3.9/site-packages/message_ix/model/
It would be good to ind out how to change this (default?) location.
"""

# the following two lines should not be needed in pycharm:
#   #!/usr/bin/env python
# # coding: utf-8

# import pandas as pd  (not needed yet)
# The following two imports result in errors ("No module named ixmp") but the code works despite the reported errors
import pathlib

import ixmp
import message_ix
from matplotlib import pyplot as plt
# the following commented because in pycharm it gives error
# get_ipython().run_line_magic('matplotlib', 'inline')

# Loading Modeling platform
mp = ixmp.Platform()
#  if the DB is locked then remove ~/.local/share/ixmp/localdb/default.lck

# Creating a new, empty scenario
scenario = message_ix.Scenario(mp, model='ptl', scenario='baseline_xlsx', version='new')

horizon = range(2020, 2051, 5)
scenario.add_horizon(year=list(horizon))    # the list cast added to avoid warning
# scenario.add_horizon(year=horizon)

node = 'Chinese'
scenario.add_spatial_sets({'country': node})
scenario.add_set("commodity", ["coal", "oil", "hydrogen", "CO2", "biomass", "gasoline", "diesel", "liquid"])
scenario.add_par("interestrate", horizon, value=0.06, unit='-')
scenario.add_set("level", ["primary", "secondary", "final", "useful"])
scenario.add_set('emission','CO2')
scenario.add_set('emission','GHG','CO2')
data_dir = 'C:/Users/zaoji/PTL - pycharm/'   # directory the data files
# data_dir = '../data/'   # directory the data files
scenario.read_excel(pathlib.Path(data_dir + 'demand.xlsx'), add_units=True, commit_steps=False)
# scenario.read_excel(data_dir + 'demand.xlsx', add_units=True, commit_steps=False)
print(scenario.idx_names('demand'))

scenario.add_set("technology", ['oil_exc', 'oil_import', 'coal_exc', 'renewable_hydrogen', 'CO2_capture',
                 'biomass_exc', 'OTL', 'CTL', 'PTL', 'BTL', 'Transportation'])
scenario.read_excel(pathlib.Path(data_dir + 'basic.xlsx'), add_units=True, commit_steps=False)
scenario.read_excel(pathlib.Path(data_dir + 'emission.xlsx'), add_units=True, commit_steps=False)
scenario.set('technology')
scenario.par('capacity_factor')
scenario.read_excel(pathlib.Path(data_dir + 'constraint.xlsx'), add_units=True, commit_steps=False)
scenario.read_excel(pathlib.Path(data_dir + 'historic.xlsx'), add_units=True, commit_steps=False)

mp.add_unit('CNY/t')
scenario.read_excel(pathlib.Path(data_dir + 'economic.xlsx'), add_units=True, commit_steps=False)

scenario.set_as_default()
scenario.solve()

# The following 3 cmds results in errors (probably because these scenarios are unknown on imac
# Objective value of the original 'baseline' scenario.
# base = message_ix.Scenario(mp, model='PTL model attempt', scenario='baseline')
# base.var('OBJ')['lvl']
# scenario.var('OBJ')['lvl']
from message_ix.reporting import Reporter
rep = Reporter.from_scenario(scenario)
from message_ix.util.tutorial import prepare_plots
prepare_plots(rep)
# Only show a subset of technologies in the follow plots;
rep.set_filters(t=["oil_exc", "oil_import"])
# Trigger the calculation and plotting
rep.get("plot activity")

# Only show a subset of technologies in the follow plots;
rep.set_filters(t=["OTL", "CTL","PTL","BTL"])

# Trigger the calculation and plotting
rep.get("plot activity")
rep.get("plot capacity")
plt.show()

mp.close_db()
