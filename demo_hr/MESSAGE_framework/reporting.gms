***
* Standard output reports
* =======================
* This page is generated from the auto-documentation in ``MESSAGE_framework/reporting.gms``.
*
* This part of the code contains the definitions and scripts for a number of standard output reports.
* These default reports will be created after every MESSAGE run.
***

Parameter
    report_total_costs(*,*,*)
    report_system_costs(*,*,*)
    report_emission_costs(*,*,*)
    report_relation_costs(*,*,*)
    report_resource_extraction(*,*,*,*)
    report_quantity(*,*,*,*)
    report_demand_shadow_price(*,*,*,*)
    report_new_capacity(*,*,*)
    report_total_capacity(*,*,*)
    report_activity(*,*,*,*)
    report_relation(*,*,*)
    report_emissions(*,*,*,*)
;

** compute the systems costs per node/technology/year **
report_system_costs(node,tec,year)$( map_tec(node,tec,year) ) =
* investment, fixed and variable costs for all technologies
    ( inv_cost(node,tec,year) * construction_time_factor(node,tec,year)
        * end_of_horizon_factor(node,tec,year) * CAP_NEW.l(node,tec,year)
        + sum(vintage$( map_tec_lifetime(node,tec,vintage,year) ),
            fix_cost(node,tec,vintage,year) * CAP.l(node,tec,vintage,year) ) )$( inv_tec(tec) )
    + sum((vintage,mode,time)$( map_tec_lifetime(node,tec,vintage,year) AND map_tec_act(node,tec,year,mode,time) ),
        var_cost(node,tec,vintage,year,mode,time) * ACT.l(node,tec,vintage,year,mode,time) )
* additional cost terms (penalty) for relaxation of 'soft' dynamic new capacity constraints
    + sum((mode,time)$map_tec_act(node,tec,year,mode,time),
            ( ( abs_cost_new_capacity_soft_up(node,tec,year)
                + level_cost_new_capacity_soft_up(node,tec,year) * inv_cost(node,tec,year)
                ) * CAP_NEW_UP.l(node,tec,year) )$( soft_new_capacity_up(node,tec,year) )
            + ( ( abs_cost_new_capacity_soft_lo(node,tec,year)
                + level_cost_new_capacity_soft_lo(node,tec,year) * inv_cost(node,tec,year)
                ) * CAP_NEW_LO.l(node,tec,year) )$( soft_new_capacity_lo(node,tec,year) )
            )$( inv_tec(tec) )
* additional cost terms (penalty) for relaxation of 'soft' dynamic activity constraints
    + sum(time$( map_tec_time(node,tec,year,time) ),
            ( ( abs_cost_activity_soft_up(node,tec,year,time)
                + level_cost_activity_soft_up(node,tec,year,time) * levelized_cost(node,tec,year,time)
                ) * ACT_UP.l(node,tec,year,time) )$( soft_activity_up(node,tec,year,time) )
            + ( ( abs_cost_activity_soft_lo(node,tec,year,time)
                + level_cost_activity_soft_lo(node,tec,year,time)  * levelized_cost(node,tec,year,time)
                ) * ACT_LO.l(node,tec,year,time) )$( soft_activity_lo(node,tec,year,time) )
            ) ;

report_system_costs(node,'all',year) = sum(tec, report_system_costs(node,tec,year) ) ;

** emission taxes (by parent node, type of technology, type of year and type of emission) **
report_emission_costs(node,year,tec) =
    sum((type_tec,type_emission,location,mode,time,emission)$( tax_emission(node,type_emission,type_tec,year)
            AND map_node(node,location) AND cat_tec(type_tec,tec) AND map_tec_act(location,tec,year,mode,time) ) ,
        emission_scaling(type_emission,emission) * emission_factor(location,tec,year,mode,emission)
        * tax_emission(node,type_emission,type_tec,year)
        * sum(vintage$( map_tec_lifetime(node,tec,vintage,year) ), ACT.l(location,tec,vintage,year,mode,time) ) ) ;

report_emission_costs(node,'all',year) = sum(tec, report_emission_costs(node,tec,year) ) ;

** TO DO: include marginals from emission bounds

**  compute cost terms associated with generic constraints (user-defined relations in MESSAGE V) **
report_relation_costs(node,tec,year) =
    sum(relation,
        relation_cost(relation,node,year)
            * ( ( relation_new_capacity(relation,node,year,tec) * CAP_NEW.l(node,tec,year)
                  + relation_total_capacity(relation,node,year,tec)
                    * sum(vintage$( map_tec_lifetime(node,tec,vintage,year) ), CAP.l(node,tec,vintage,year) )
                )$( inv_tec(tec) )
                + sum((location,year2,mode,time)$( map_tec_act(location,tec,year2,mode,time) ),
                    relation_activity(relation,node,year,location,tec,year2,mode)
                    * sum(vintage$( map_tec_lifetime(location,tec,vintage,year2) ),
                        ACT.l(location,tec,vintage,year2,mode,time) ) ) ) ) ;

report_relation_costs(node,'all',year) = sum(tec, report_relation_costs(node,tec,year) );

** compute total costs(system costs + emission costs + relation costs) **
report_total_costs(node,'all',year) =
    report_system_costs(node,'all',year)
    + report_emission_costs(node,'all',year)
    + report_relation_costs(node,'all',year)
;

** report on resource extraction by grade **
report_resource_extraction(node,commodity,grade,historical) =
    sum(location$( map_node(node,location) ), historical_extraction(location,commodity,grade,historical) ) ;

report_resource_extraction(node,commodity,grade,year) =
    sum(location$( map_node(node,location) ), EXT.l(location,commodity,grade,year) ) ;
report_resource_extraction(node,commodity,grade,'cumulative') =
    sum((location,model_horizon)$( map_node(node,location) ),
        duration_period(model_horizon) * EXT.l(location,commodity,grade,model_horizon) ) ;
* the next line should be remove once an interactive report visualization is in place (DH, Oct 16, 2016)
report_resource_extraction(node,commodity,grade,'resource_in_place') =
    sum(location$( map_node(node,location) ), resource_volume(location,commodity,grade) ) ;
report_resource_extraction(node,commodity,grade,'remaining') =
    report_resource_extraction(node,commodity,grade,'resource_in_place')
    - report_resource_extraction(node,commodity,grade,'cumulative') ;

** collect report on quantities
report_quantity(node,historical,commodity,level) =
    sum((location,node2,tec,mode,time)$( map_node(node,location) ),
        input(location,tec,historical,historical,mode,node2,commodity,level,time,time)
        * historical_activity(location,tec,historical,mode,time) ) * 0.03154 ;

report_quantity(node,year,commodity,level) =
    sum((location,node2,tec,vintage,mode,time)$( map_node(node,location) ),
        input(location,tec,vintage,year,mode,node2,commodity,level,time,time)
        * ACT.l(location,tec,vintage,year,mode,time) ) * 0.03154 ; ;

** do simple time series reports on new capacity and activity **

* write the 'new capacity' into a specific reporting parameter
report_new_capacity(node,inv_tec,historical) =
    historical_new_capacity(node,inv_tec,historical) ;

report_new_capacity(node,inv_tec,year)$( map_tec(node,inv_tec,year) ) =
    CAP_NEW.l(node,inv_tec,year) ;

* write the 'total maintained capacity' into a specific reporting parameter
report_total_capacity(node,inv_tec,year)$( map_tec(node,inv_tec,year) ) =
    sum(vintage, CAP.l(node,inv_tec,vintage,year) ) ;

* write the total 'activity' (summed over all vintages)
report_activity(node,tec,year_all,"ref")$( map_tec(node,tec,year_all) ) =
    sum((mode,time), ref_activity(node,tec,year_all,mode,time) ) ;

report_activity(node,tec,historical,"actual")$( map_tec(node,tec,historical) ) =
    sum((mode,time), historical_activity(node,tec,historical,mode,time) ) ;

report_activity(node,tec,year,"actual")$( map_tec(node,tec,year) ) =
    sum((location,vintage,mode,time)$( map_node(node,location) ),
        ACT.l(location,tec,vintage,year,mode,time) ) ;

* compute the emissions per node/technology/year
report_emissions(node,type_year,type_emission,type_tec)$( sum(year_all$( cat_year(type_year,year_all) ), 1 ) ) =
    sum( (location,tec,year_all,mode,time,emission)$( map_node(node,location) AND cat_tec(type_tec,tec)
            AND cat_year(type_year,year_all) AND cat_emission(type_emission,emission)
            AND map_tec_act(location,tec,year_all,mode,time) ),
        duration_period(year_all)
        * emission_scaling(type_emission,emission) * emission_factor(location,tec,year_all,mode,emission)
        * ( sum(vintage$( map_tec_lifetime(location,tec,vintage,year_all) ),
                ACT.l(location,tec,vintage,year_all,mode,time) )
            + historical_activity(location,tec,year_all,mode,time)
          )
        )
      / sum(year_all$( cat_year(type_year,year_all) ), duration_period(year_all) ) ;

report_emissions(node,type_year,type_emission,tec)$( sum(year_all$( cat_year(type_year,year_all) ), 1 ) ) =
    sum( (location,year_all,mode,time,emission)$( map_node(node,location)
            AND cat_year(type_year,year_all) AND cat_emission(type_emission,emission)
            AND map_tec_act(location,tec,year_all,mode,time) ),
        duration_period(year_all)
        * emission_scaling(type_emission,emission) * emission_factor(location,tec,year_all,mode,emission)
        * ( sum(vintage$( map_tec_lifetime(location,tec,vintage,year_all) ),
                ACT.l(location,tec,vintage,year_all,mode,time) )
            + historical_activity(location,tec,year_all,mode,time)
          )
        )
      / sum(year_all$( cat_year(type_year,year_all) ), duration_period(year_all) ) ;

*----------------------------------------------------------------------------------------------------------------------*
* The following parts are quick-and-dirty reporting 'flags'

Set
    report_aux_bounds_up(node,tec,year_all,year_all2,mode,time)
    report_aux_bounds_lo(node,tec,year_all,year_all2,mode,time)
;

report_aux_bounds_up(node,tec,year_all,year_all2,mode,time) = no ;
report_aux_bounds_up(node,tec,year_all,year_all2,mode,time)$(
    map_tec_lifetime(node,tec,year_all,year_all2) AND map_tec_act(node,tec,year_all2,mode,time)
    AND ( ACT.l(node,tec,year_all,year_all2,mode,time) = %AUX_BOUND_VALUE%) ) = yes ;

report_aux_bounds_lo(node,tec,year_all,year_all2,mode,time) = no ;
report_aux_bounds_lo(node,tec,year_all,year_all2,mode,time)$(
    map_tec_lifetime(node,tec,year_all,year_all2) AND map_tec_act(node,tec,year_all2,mode,time)
    AND ( ACT.l(node,tec,year_all,year_all2,mode,time) = -%AUX_BOUND_VALUE% ) ) = yes ;

