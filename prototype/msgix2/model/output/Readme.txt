Here the output gdx files shall be located. For the initial tests by JZ (with
scaled data only) two files are expected:
- cost_jz1.gdx  : results of minimization of COST_CUM
- co2_jz1.gdx  : results of minimization of CO2_CUM

Additionally the values of criteria should be added to the payoff.txt file
(initial version created).

In this file should values of criteria are stored.
Each row shall contain the run id (same as the corresponding gdx root-name,
and values of two objectives.

Two sets of solutions are stored in this dir: for scaled and unscaled parameters,
respectively.
Each set contains solutions for selfish optimization (cost_xxx and co2_xxx, respectively).

For scaled parameters
- cost_jz1.gdx  : results of minimization of COST_CUM (by JZ)
- co2_jz1.gdx  : results of minimization of CO2_CUM
- cost_mm1.gdx  : results of minimization of COST_CUM (by MM)
- co2_mm1.gdx  : results of minimization of CO2_CUM

For unscaled parameters (only by MM)
- unsc_cost_mm1.gdx  : results of minimization of COST_CUM (by MM)
- unsc_co2_mm1.gdx  : results of minimization of CO2_CUM

The criteria values (stored also in payoff.txt) of selfish optimizations differ
by only scaling by 1e+6, and are as follows:

Scaled parameters
id         COST_CUM    CO2_CUM
cost_jz1   91.348515    1748.452076
cost_mm1   91.3485      1748.45
co2_jz1   112.954216    116.689623
co2_mm1   112.954       116.69

Not-scaled parameters
id         COST_CUM    CO2_CUM
cost_mm1  9.134851E+7    1.748452E+9
co2_mm1   1.129542E+8    1.166896E+8

