"""
This code is based on the jupyter nb by Jinyang, earlier modifications by Marek, and recent
extensions (of the reporting part) by Jinyang.
The code was modified by Marek to read data from a dedicated directory and from renamed (to use short names) files.
Code was also modified to conform to the PEP 8 (i.e., all pycharm warnings were addressed).
see the Readme.txt for more info.

The program combines 3 stages of single-criterion optimization (of the default OBJ objective):
1. generates the *gms and the input (parameters) gdx file; these files are located in the
    message_ix installation dependent dir. On iMac it is:
    /Users/marek/anaconda3/envs/msg_env/lib/python3.9/site-packages/message_ix/model/
    It would be good to ind out how to change this (default?) location.
2. solving the single-criterion optimization by cplex
3. reporting selected results.

The reporting part needs to explored and extended.
"""

# import pandas as pd  (not needed yet)
import pathlib
import ixmp
import message_ix
from matplotlib import pyplot as plt
from message_ix.reporting import Reporter
from message_ix.util.tutorial import prepare_plots

# location of the xlsx files with the model parameters
# NOTE: one should explore why the GitHub location does not work for Jinyang (it should work !)
# data_dir = 'C:/Users/zaoji/PTL - pycharm/'   # on PC
data_dir = '../data/'   # on GitHub and on iMac

# Load the modeling platform
mp = ixmp.Platform()
#  if the DB is locked then remove ~/.local/share/ixmp/localdb/default.lck file

# Create empty scenario
scenario = message_ix.Scenario(mp, model='ptl', scenario='test1', version='new')

horizon = range(2020, 2051, 5)
scenario.add_horizon(year=list(horizon))    # the list cast added to avoid warning

node = 'Chinese'  # change to: 'China' causes error
scenario.add_spatial_sets({'country': node})
scenario.add_set("commodity", ["coal", "oil", "hydrogen", "CO2", "biomass", "gasoline", "diesel", "liquid"])
scenario.add_par("interestrate", horizon, value=0.06, unit='-')
scenario.add_set("level", ["primary", "secondary", "final", "useful"])
scenario.add_set('emission', 'CO2')
scenario.add_set('emission', 'GHG', 'CO2')

scenario.read_excel(pathlib.Path(data_dir + 'demand.xlsx'), add_units=True, commit_steps=False)
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

# Single-criterion optimization (of OBJ) by Cplex
scenario.solve()

# Reporting
rep = Reporter.from_scenario(scenario)
prepare_plots(rep)
# Only show a subset of technologies in the follow plots;
rep.set_filters(t=["oil_exc", "oil_import"])
# Trigger the calculation and plotting
rep.get("plot activity")

# Only show a subset of technologies in the follow plots;
rep.set_filters(t=["OTL", "CTL", "PTL", "BTL"])

# Trigger the calculation and plotting
rep.get("plot activity")
rep.get("plot capacity")
plt.show()

mp.close_db()   # close the local db
