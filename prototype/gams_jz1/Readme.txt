This folder is dedicated for testing the cn_ptl model originally generated from
the message_ix framework, i.e., without any modifications necessary for the MCMA.
The model parameters shall be the same as used for the version prepared for MCMA.

The initial test shall minimize the OBJ (total cost) with the constraint (bound)
on the total CO2 emission.
The value of the bound should start with a slightly higher (e.g., 10%) value than
that obtained for min of OBJ and be sequentially reduced below (say also 10%) of
the value we got for min of the total CO2. See the results for analysis 945.

The folder shall contain:
- the complete (i.e., "stand-alone", i.e., runnable on another computer) set
  of the *gms and input *gdx files,
- run script(s),
- discussion of the results.

The tests shall be done by Jinyang.
