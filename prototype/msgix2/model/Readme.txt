IMPORTANT NOTE:
If ANY file from the original distribution needs to be modified, then first
(before modifications) make a copy of the original file to xxx_org.gms (where
xxx is the root-name of the original file).

The files used in Summer-2021 that should be used/adapted for the current version.
Original files should be kept in the summer21 dir.
- model_mca.gms should contain all model extensions for MCMA
- master_old.gms contains pieces of the old master file (i.e., the file executed
  by gams called from the cmd-line). Please see comments in this file with
  suggestions how to make the new master.gms

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
After slight modifications of master.gms and model_mca.gms the two selfish
optimizations (of CO2_CUM and COST_CUM) provided the same results when run
by Jinyang (in Dec, 2021) and Marek (in Jan, 2022). The corresponding gdx files
are in output dir, together with the payoff-table in payoff.txt.

All needed files are packed in cn_ptl_v2.zip stored in ..../prototype/gams_run2
