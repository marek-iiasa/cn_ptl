*----------------------------------------------------------------------------------------------------------------------*
* assignment and computation of auxiliary parameters                                                                   *
*----------------------------------------------------------------------------------------------------------------------*

* additional sets and parameters created in GAMS to make notation more concise for myopic/rolling-horizon optimization
Sets
    historical(year_all)             set of periods prior to the start of the model horizon
    model_horizon(year_all)          set of periods included in the model horizon
    macro_horizon(year_all)          set of periods included in the MACRO model horizon
    seq_period(year_all,year_all2)    mapping of one period ('year_all') to the next ('year_all2')
    map_period(year_all,year_all2)    mapping of one period ('year_all') to itself and all subsequent periods ('year_all2')
    first_period(year_all)           flag for first period in model horizon
    base_period(year_all)            flag for base year period in model horizon (period prior to first model period) - used in MACRO
    initialize_period(year_all)      flag for period in model horizon in which to initialize model parameters in (period prior to first model period) - used in MACRO
    last_period(year_all)            flag for last period in model horizon
;

Parameter
    duration_period_sum(year_all,year_all2) number of years between two periods ('year_all' must precede 'year_all2')
    duration_time_rel(time,time2)         relative duration of subannual time period ('time2' relative to parent 'time')
    elapsed_years(year_all)    elapsed years since the start of the model horizon (not including 'year_all' period)
    remaining_years(year_all)  remaining years until the end of the model horizon (including last period)
    year_order(year_all)       order for members of set 'year_all'
;

*----------------------------------------------------------------------------------------------------------------------*
* assignment auxiliary dynamic sets                                                                                    *
*----------------------------------------------------------------------------------------------------------------------*

** treatment of periods **

* sanity checks to ensure that not more than one period is assigned to the first- and lastyear categories
if ( sum(year_all$( cat_year("firstmodelyear",year_all) ), 1 ) > 1 ,
    abort "There is more than one period assigned as category 'firstmodelyear'!" ) ;
if ( sum(year_all$( cat_year("baseyear_macro",year_all) ), 1 ) > 1 ,
    abort "There is more than one period assigned as category 'baseyear_macro'!" ) ;
if ( sum(year_all$( cat_year("initializeyear_macro",year_all) ), 1 ) > 1 ,
    abort "There is more than one period assigned as category 'initializeyear_macro'!" ) ;

* sets (singleton) with first and last periods in model horizon (for easier reference)
first_period(year_all) = no ;
first_period(year_all)$( cat_year("firstmodelyear",year_all) ) = yes ;
base_period(year_all) = no ;
base_period(year_all)$( cat_year("baseyear_macro",year_all) ) = yes ;
initialize_period(year_all) = no ;
initialize_period(year_all)$( cat_year("initializeyear_macro",year_all) ) = yes ;
if ( sum(year_all$( cat_year("lastmodelyear",year_all) ), 1 ) = 1 ,
    last_period(year_all)$( cat_year("lastmodelyear",year_all) ) = yes;
else
    last_period(year_all)$( ORD(year_all) = CARD(year_all) ) = yes ;
) ;

* mapping of sequence of periods over the model horizon
seq_period(year_all,year_all2)$( ORD(year_all) + 1 = ORD(year_all2) ) = yes ;
map_period(year_all,year_all2)$( ORD(year_all) <= ORD(year_all2) ) = yes ;

* assign set of historical years (prior to model horizon) and the model horizon
historical(year_all)$( ORD(year_all) < sum(year_all2$cat_year("firstmodelyear",year_all2), ORD(year_all2) ) ) = yes ;
model_horizon(year_all) = no ;
model_horizon(year_all)$( ORD(year_all) >= sum(year_all2$first_period(year_all2), ORD(year_all2) )
    AND ORD(year_all) <= sum(year_all2$last_period(year_all2), ORD(year_all2) ) ) = yes ;
macro_horizon(year_all) = no ;
macro_horizon(year_all)$( ORD(year_all) > sum(year_all2$cat_year("baseyear_macro",year_all2), ORD(year_all2) )
    AND ORD(year_all) <= sum(year_all2$last_period(year_all2), ORD(year_all2) ) ) = yes ;

*----------------------------------------------------------------------------------------------------------------------*
* assignment of (cumulative) discount factors over time                                                                *
*----------------------------------------------------------------------------------------------------------------------*

* simple method to compute discount factor (but this approach implicitly assumes a constant interest rate)
*discountfactor(year_all) = POWER( 1 / ( 1+interestrate(year_all) ), sum(year_all2$( ORD(year_all2) < ORD(year_all) ),
*    duration_period(year_all2) ) ) ;

* compute per-year discount factor (using a recursive method) - set to 1 by default (interest rate = 0)
discountfactor(year_all) = 1 ;

* recursively compute the per-year discount factor
loop(year_all$( ORD(year_all) > 1 ),
    discountfactor(year_all) =
        sum(year_all2$( seq_period(year_all2,year_all) ), discountfactor(year_all2)
            * POWER( 1 / ( 1 + interestrate(year_all) ), duration_period(year_all) ) ) ;
) ;

* store the per-year discount factor for later use in the file 'MESSAGE_framework/scaling_investment_costs.gms'
discountfactor('last_year') = sum(last_period, discountfactor(last_period) ) ;

* multiply per-year discount factor by discounted period duration
discountfactor(year_all) =
    discountfactor(year_all) * (
* multiply the per-year discount factor by the geometric series of over the duration of the period
        ( ( 1 - POWER( 1 / ( 1 + interestrate(year_all) ), duration_period(year_all) ) )
            / ( 1 - 1 / ( 1 + interestrate(year_all) ) ) )$( interestrate(year_all) )
* if interest rate = 0, multiply by the number of years in that period
        + ( duration_period(year_all) )$( interestrate(year_all) eq 0 ) )
;

*----------------------------------------------------------------------------------------------------------------------*
* assignment of auxiliary parameters for duration of periods                                                           *
*----------------------------------------------------------------------------------------------------------------------*

* define order of set 'year_all' (to use as equivalent of ORD operator on the dynamic set year (subset of 'year_all') )
year_order(year_all) = ORD(year_all) ;

* auxiliary parameters for duration between periods (years) - not including the final period 'year_all2'
duration_period_sum(year_all,year_all2) =
    SUM(year_all3$( ORD(year_all) <= ORD(year_all3) AND ORD(year_all3) < ORD(year_all2) ) , duration_period(year_all3) ) ;

* auxiliary parameter for duration since the first year of the model horizon - not including the period 'year_all'
elapsed_years(year_all) = sum(first_period, duration_period_sum(first_period,year_all) ) ;

* auxiliary parameter for duration until the end of the model horizon - including the last period
remaining_years(year_all) = SUM(year_all2$( ORD(year_all) <= ORD(year_all2) ) , duration_period(year_all2) ) ;
