
*----------------------------------------------------------------------------------------------------------------------*
* load sets and parameters from dataset gdx                                                                            *
*----------------------------------------------------------------------------------------------------------------------*

put_utility 'log' /"+++ Importing data from 'data/MSGdata_%data%.gdx'... +++ " ;

* all sets and general parameters from the gdx file
$GDXIN 'data/MSGdata_%data%.gdx'
$LOAD node, tec=technology, mode, commodity, level, grade, emission, year_all=year, time, relation
$LOAD level_resource
$LOAD lvl_spatial, lvl_temporal, map_spatial_hierarchy, map_temporal_hierarchy
$LOAD map_node, map_time, map_commodity, map_resource, map_stocks, map_tec, map_tec_time, map_tec_mode, map_relation
$LOAD type_tec, cat_tec, type_year, cat_year, type_emission, cat_emission
$GDXIN

Execute_load 'data/MSGdata_%data%.gdx'
* general parameters
duration_period, duration_time, interestrate,
* resources parameters
resource_volume, resource_cost, is_bound_extraction_up, bound_extraction_up, resource_remaining,
* technology technical-engineering parameters and economic costs
input, output, construction_time, technical_lifetime
capacity_factor, operation_factor, min_utilization_factor, inv_cost, fix_cost, var_cost,
* upper and lower bounds on new capacity investment, total installed capacity and activity (including mapping sets)
is_bound_new_capacity_up, is_bound_new_capacity_lo, bound_new_capacity_up, bound_new_capacity_lo,
is_bound_total_capacity_up, is_bound_total_capacity_lo, bound_total_capacity_up, bound_total_capacity_lo,
is_bound_activity_up, bound_activity_up, bound_activity_lo,
* dynamic constraints on new capacity investment and activity of technologies
is_dynamic_new_capacity_up, initial_new_capacity_up, growth_new_capacity_up,
is_dynamic_new_capacity_lo, initial_new_capacity_lo, growth_new_capacity_lo,
is_dynamic_activity_up, initial_activity_up, growth_activity_up,
is_dynamic_activity_lo, initial_activity_lo, growth_activity_lo,
* parameters for soft relaxation of dynamic constraints
abs_cost_new_capacity_soft_up, abs_cost_new_capacity_soft_lo, level_cost_new_capacity_soft_up, level_cost_new_capacity_soft_lo,
abs_cost_activity_soft_up, abs_cost_activity_soft_lo, level_cost_activity_soft_up, level_cost_activity_soft_lo,
soft_new_capacity_up, soft_new_capacity_lo, soft_activity_up, soft_activity_lo,
* historical & reference values of new capacity investment, activity and extraction
historical_new_capacity, historical_activity, historical_extraction, ref_new_capacity, ref_activity, ref_extraction,
* emission factors, bounds and taxes on emissions (including mapping sets)
emission_factor, emission_scaling, is_bound_emission, bound_emission, tax_emission,
* parameters for generic relations (legacy from MESSAGE V)
is_relation_upper, is_relation_lower, relation_upper, relation_lower,
relation_cost, relation_total_capacity, relation_new_capacity, relation_activity,
* energy stocks
commodity_stock,
* demand parameters
demand_fixed=demand
* fixing variables to pre-specified values
is_fixed_extraction, is_fixed_stock, is_fixed_new_capacity, is_fixed_capacity, is_fixed_activity
fixed_extraction, fixed_stock, fixed_new_capacity, fixed_capacity, fixed_activity
;

* assignment of parameters that don't yet exist in the database platform framework
peak_load_factor(node,commodity,year_all) = 0 ;
load_flex_factor(node,commodity,level,year_all) = 0 ;
tec_flex_factor(node,tec,vintage,year_all,mode) = 0 ;
reliability_factor(node,tec,year_all,year_all,commodity) = 0 ;

*----------------------------------------------------------------------------------------------------------------------*
* assignment and computation of MESSAGE-specific auxiliary parameters                                                  *
*----------------------------------------------------------------------------------------------------------------------*

* get assignment of auxiliary parameter for period mappings and duration
$INCLUDE includes/period_parameter_assignment.gms

* compute auxiliary parameters for relative duration of subannual time periods
duration_time_rel(time,time2)$( map_time(time,time2) ) = duration_time(time2) / duration_time(time) ;

** mapping and other stuff for technologies **

* get the subset of all technologies that have investment and capacity
inv_tec(tec)$( cat_tec("investment",tec) ) = yes ;

* assign an additional mapping set for technologies to nodes, modes and subannual time slices (for shorter reference)
map_tec_act(node,tec,year_all,mode,time)$( map_tec_time(node,tec,year_all,time) AND
   map_tec_mode(node,tec,year_all,mode) ) = yes ;

* mapping of technology lifetime to all 'current' periods (for all non-investment technologies)
map_tec_lifetime(node,tec,year_all,year_all)$( map_tec(node,tec,year_all) ) = yes ;

* mapping of technology lifetime to all periods 'year_all' which are within the economic lifetime
* (if built in period 'vintage')
map_tec_lifetime(node,tec,vintage,year_all)$( map_tec(node,tec,vintage) AND map_tec(node,tec,year_all)
    AND map_period(vintage,year_all)
    AND duration_period_sum(vintage,year_all) < technical_lifetime(node,tec,vintage) ) = yes ;

* mapping of technology lifetime to all periods 'year_all' which were built prior to the beginning of the model horizon
map_tec_lifetime(node,tec,historical,year_all)$( map_tec(node,tec,year_all) AND map_period(historical,year_all)
    AND historical_new_capacity(node,tec,historical)
    AND duration_period_sum(historical,year_all)
        < sum(first_period, technical_lifetime(node,tec,first_period) ) ) = yes ;

* set the default capacity factor for technologies where no parameter value is provided in the input data
capacity_factor(node,tec,year_all2,year_all,time)$( map_tec_time(node,tec,year_all,time)
    AND map_tec_lifetime(node,tec,year_all2,year_all) AND NOT capacity_factor(node,tec,year_all2,year_all,time) ) = 1 ;

* assign the yearly average capacity factor (used in equation OPERATION_CONSTRAINT)
capacity_factor(node,tec,year_all2,year_all,'year') =
    sum(time$map_tec_time(node,tec,year_all,time), duration_time(time)
        * capacity_factor(node,tec,year_all2,year_all,time) ) ;

* set the default operation factor for technologies where no parameter value is provided in the input data
operation_factor(node,tec,year_all2,year_all)$( map_tec(node,tec,year_all)
    AND map_tec_lifetime(node,tec,year_all2,year_all) AND NOT operation_factor(node,tec,year_all2,year_all) ) = 1 ;

* set the emission scaling parameter to 1 if only one emission is included in a category
emission_scaling(type_emission,emission)$( cat_emission(type_emission,emission)
    AND sum(emission2$( cat_emission(type_emission,emission2) ), 1 ) <= 1 ) = 1 ;

*----------------------------------------------------------------------------------------------------------------------*
* sanity checks on the data set                                                                                        *
*----------------------------------------------------------------------------------------------------------------------*

Parameter check ;

* check whether all relevant technology/vintage/year combinations have positove input/output values assigned
*loop((node,tec,vintage,year_all)$( map_tec_lifetime(node,tec,vintage,year_all) ),
*    if ( sum( (mode,node2,commodity,level,time,time2),
*            input(node,tec,vintage,year_all,mode,node2,commodity,level,time,time2)
*            + output(node,tec,vintage,year_all,mode,node2,commodity,level,time,time2) ) eq 0 ,
*        put_utility 'log'/" Warning: No input or output not defined for '"node.tl:0"|"tec.tl:0"|"vintage.tl:0"|"year_all.tl:0"' !" ;
*    ) ;
*) ;

* check that the economic and technical lifetime are defined and consistent for all investment technologies
loop((node,inv_tec,model_horizon)$( map_tec(node,inv_tec,model_horizon) ),
    if ( technical_lifetime(node,inv_tec,model_horizon) < 1 ,
        put_utility 'log'/" Error: Technical lifetime not defined for '"node.tl:0"|"inv_tec.tl:0"|"model_horizon.tl:0"' !" ;
        check = 1 ;
    ) ;
) ;
if (check,
    abort "There is a problem with the defintion of economic or technical lifetime!" ;
) ;

* check for validity of temporal resolution
loop(lvl_temporal,
    loop(time2,
        check = 1$( sum( time$( map_temporal_hierarchy(lvl_temporal,time,time2) ),
            duration_time(time) ) ne duration_time(time2) ) ;
    ) ;
) ;
if (check,
    abort "There is a problem in the definition of the temporal resolution!" ;
);

* check that the resources-remaining parameter is in the interval (0,1]
loop( (node,commodity,grade,year_all)$( map_resource(node,commodity,grade,year_all)
        AND resource_remaining(node,commodity,grade,year_all) ),
    if( ( resource_remaining(node,commodity,grade,year_all) > 1
            or resource_remaining(node,commodity,grade,year_all) <= 0 ),
        put_utility 'log'/" Error: Inconsistent value of parameter 'resources_remaining' "
            "for '"node.tl:0"|"commodity.tl:0"|"grade.tl:0"|"year_all.tl:0 "' !" ;
        check = 1 ;
    ) ;
) ;
if (check,
    abort "There is a problem with the parameter 'resources_remaining'!" ;
) ;
