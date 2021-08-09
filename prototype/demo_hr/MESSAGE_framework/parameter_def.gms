***
* .. _parameter_def:
*
* Parameter definition
* ====================
* | This page is generated from the auto-documentation
* | in ``MESSAGE_framework/parameter_def.gms``.
*
* This file contains the definition of all parameters used in |MESSAGEix|.
* References and comments relating the notation to `MESSAGE V` are included
* here for easier reference between the model versions.
* Functionality and notation of `MESSAGE V`, which is not included in |MESSAGEix|, is marked as :strike:`name`.
*
* Note that in |MESSAGEix|, all parameters are understood as yearly values, not as per (multi-year) period.
* This allows additional flexibility when changing the resolution of the model horizon (i.e., the set ``year_all``),
* but it requires the introduction of additional multipliers in the mathematical formulation.
* Parameter definition written *italics* are such auxiliary parameters,
* and they are computed during the pre-processing stage in GAMS.
***

***
* General parameters in the |MESSAGEix| implementation
* ----------------------------------------------------
*
* .. list-table::
*    :widths: 20 20 60
*    :header-rows: 1
*
*    * - Parameter name
*      - Index dimensions
*      - Explanatory comments
*    * - duration_period
*      - ``year``
*      - duration of one multi-year period (in number of years) [#year_auto]_
*    * - duration_time
*      - ``time``
*      - duration of sub-annual time slices (relative to 1) [#duration_time_year]_
*    * - interestrate
*      - ``year``
*      -
*    * - *discountfactor*
*      - ``year``
*      -  cumulative discount factor over period duration [#df_auto]_
*
* .. [#year_auto] The values for this parameter are computed automatically when creating a datastructure
*    using the ixMP interface. In |MESSAGEix|, the key of an element in set ``year`` identifies *the last year*
*    of the period, i.e., the period '2010' comprises the years :math:`[2006, .. ,2010]`.
*
* .. [#duration_time_year] The element 'year' in the set of subannual time slices ``time`` has the value of 1.
*    This value is assigned by default when creating a new datastructure based on the ``MESSAGE`` scheme.
*
* .. [#df_auto] This parameter is computed during the GAMS execution.
***

Parameters
* general parameters
    duration_period(year_all)      duration of one multi-year period (in years)
    duration_time(time)            duration of one time slice (relative to 1)
    duration_period_sum(year_all,year_all2)  number of years between two periods ('year_all' must precede 'year_all2')
    duration_time_rel(time,time2)  relative duration of subannual time period ('time2' relative to parent 'time')
    interestrate(year_all)         interest rate (to compute discount factor)
    discountfactor(*)              cumulative discount facor
;

***
* Parameters of the `Resources` section
* -------------------------------------
*
* .. list-table::
*    :widths: 20 55 25
*    :header-rows: 1
*
*    * - Parameter name
*      - Index dimensions
*      - Name in `MESSAGE V`
*    * - resource_volume
*      - ``node`` | ``commodity`` | ``grade``
*      - volume
*    * - resource_cost
*      - ``node`` | ``commodity`` | ``grade`` | ``year``
*      - cost
*    * - resource_remaining
*      - ``node`` | ``commodity`` | ``grade`` | ``year``
*      - resrem
*    * - bound_extraction_up
*      - ``node`` | ``commodity`` | ``level`` | ``year``
*      - uplim
*    * - commodity_stock [#stock]_
*      - ``node`` | ``commodity`` | ``level`` | ``year``
*      - energyforms:
*    * - historical_extraction [#hist_ref]_
*      - ``node`` | ``commodity`` | ``grade`` | ``year``
*      -
*    * - ref_extraction [#hist_ref]_
*      - ``node`` | ``commodity`` | ``grade`` | ``year``
*      -
*
* .. [#stock] This parameter is more general than the implementation in `MESSAGE V` to allow (exogenous) additions
*    to the commodity stock over the model horizon, e.g., precipitation that replenishes the water table.
*
* .. [#hist_ref] Historical and reference values; these are used for parametrising
*    the vintage structure of existing capacity and dynamic constraints.
*
* The `MESSAGE V` parameter ``byrex`` (extraction in the base year) is superseded
* by the parameters ``historical_extraction`` and ``ref_extraction`` in the implementation of |MESSAGEix|.
***

Parameter
* resource and commodity parameters
    resource_volume(node,commodity,grade)               volume of resources in-situ at start of the model horizon
    resource_cost(node,commodity,grade,year_all)        extraction costs for resource
    resource_remaining(node,commodity,grade,year_all)   maximum extraction relative to remaining resources (by year)
    bound_extraction_up(node,commodity,grade,year_all)  upper bound on extraction of resources by grade
    commodity_stock(node,commodity,level,year_all)      exogenous (initial) quantity of commodity in stock
* historical and reference values
    historical_extraction(node,commodity,grade,year_all)    historical extraction
    ref_extraction(node,commodity,grade,year_all)           reference value of extraction
;

***
* Parameters of the `Demand` section
* ----------------------------------
*
* .. list-table::
*    :widths: 20 55 25
*    :header-rows: 1
*
*    * - Parameter name
*      - Index dimensions
*      - Name in `MESSAGE V`
*    * - demand (``demand_fixed``) [#demand]_
*      - ``node`` | ``commodity`` | ``level`` | ``year`` | ``time``
*      - demand:
*    * - peak_load_factor [#peakload]_
*      - ``node`` | ``commodity`` | ``year``
*      -
*    * - load_flex_factor [#flex]_
*      - ``node`` | ``commodity`` | ``level`` | ``year``
*      -
*
* .. [#demand] The parameter ``demand`` in a `MESSAGE`-scheme datastructure is translated
*    to the parameter ``demand_fixed`` in the MESSAGE implementation in GAMS. The variable ``DEMAND`` is introduced
*    as an auxiliary reporting variable; it equals ``demand_fixed`` in a `MESSAGE`-standalone run and reports
*    the final demand including the price response in an iterative `MESSAGE-MACRO` solution.
*
* .. [#peakload] The parameters ``peak_load_factor`` and ``reliability_factor`` are based on the formulation proposed
*    by Sullivan et al., 2013 :cite:`sullivan_VRE_2013`. It is used in Equation ``FIRM_CAPACITY_CONSTRAINT``.
*
* .. [#flex] The parameters ``load_flex_factor`` and ``tec_flex_factor`` are based on the formulation proposed
*    by Sullivan et al., 2013 :cite:`sullivan_VRE_2013` and extended by Johnson et al., 2016 :cite:`johnson_VRE_2016`.
*    It is used in Equation ``OPERATING_RESERVE_CONSTRAINT``.
***

Parameter
    demand_fixed(node,commodity,level,year_all,time) exogenous demand levels
    peak_load_factor(node,commodity,year_all)       maximum peak load factor for reliability constraint of firm capacity
    load_flex_factor(node,commodity,level,year_all) contribution of load towards operation flexibility constraint
;

***
* Parameters of the `Technology` section
* --------------------------------------
*
* Exogenous drivers and auxiliary counters implemented as `'variables'` in `MESSAGE V`
* are merged with technologies in |MESSAGEix|.
*
* Input/output mapping, costs and engineering specifications
* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
*
* .. list-table::
*    :widths: 20 55 25
*    :header-rows: 1
*
*    * - Parameter name
*      - Index names
*      - Name in `MESSAGE V`
*    * - input [#tecvintage]_
*      - ``node_loc`` | ``tec`` | ``year_vtg`` | ``year_act`` | ``mode`` |
*        ``node_origin`` | ``commodity`` | ``level`` | ``time`` | ``time_origin``
*      - :strike:`minp`, inp
*    * - output [#tecvintage]_
*      - ``node_loc`` | ``tec`` | ``year_vtg`` | ``year_act`` | ``mode`` |
*        ``node_dest`` | ``commodity`` | ``level`` | ``time`` | ``time_dest``
*      - :strike:`moutp`, outp
*    * - inv_cost [#tecvintage]_
*      - ``node_loc`` | ``tec`` | ``year_vtg``
*      - inv
*    * - fix_cost [#tecvintage]_
*      - ``node_loc`` | ``tec`` | ``year_vtg`` | ``year_act``
*      - fom
*    * - var_cost [#tecvintage]_
*      - ``node_loc`` | ``tec`` | ``year_vtg`` | ``year_act`` | ``mode`` | ``time``
*      - vom / cost [#pseudotec]_
*    * - levelized_cost [#levelizedcost]_
*      - ``node_loc`` | ``tec`` | ``year_vtg`` | ``time``
*      - vom
*    * - construction_time
*      - ``node_loc`` | ``tec`` | ``year_vtg``
*      - ctime
*    * - technical_lifetime
*      - ``node_loc`` | ``tec`` | ``year_vtg``
*      - pll
*    * - capacity_factor [#tecvintage]_
*      - ``node_loc`` | ``tec`` | ``year_vtg`` | ``year_act`` | ``time``
*      - plf
*    * - operation_factor [#tecvintage]_
*      - ``node_loc`` | ``tec`` | ``year_vtg`` | ``year_act``
*      - optm
*    * - min_utilization_factor [#tecvintage]_
*      - ``node_loc`` | ``tec`` | ``year_vtg`` | ``year_act``
*      - minutil
*    * - reliability_factor [#peakload]_
*      - ``node_loc`` | ``tec`` | ``year_vtg`` | ``year_act`` | ``commodity``
*      -
*    * - tec_flex_factor [#flex]_
*      - ``node_loc`` | ``tec`` | ``year_vtg`` | ``year_act`` | ``mode``
*      -
*    * - emission_factor
*      - ``node_loc`` | ``tec`` | ``year_vtg`` | ``mode`` | ``emission``
*      -
*
* .. [#tecvintage] In contrast to `MESSAGE V`, the cost parameters and technical specifications are indexed over both
*    the year of construction (vintage) and the year of operation (actual).
*    This allows to represent changing technology characteristics depending on the age of the plant.
*
* .. [#pseudotec] These are parameters related to the `'variables'` section in `MESSAGE V`.
*
* .. [#levelizedcost] The parameter ``levelized_cost`` is computed in the GAMS pre-processing under the assumption of
*    full capacity utilization until the end of the economic lifetime (using parameter ``economic_lifetime``,
*    which is not necessarily equal to the parameter ``technical_lifetime``).
*
* .. [#construction] The construction time only has an effect on the investment costs; in |MESSAGEix|,
*    each unit of new-built capacity is available instantaneously at the beginning of the model period.
*
* The representation of the nuclear-fuel cycle in `MESSAGE V` (parameters ``corin``, ``corout``, ``prel``)
* are not yet implemented in |MESSAGEix|.
***

Parameters
* technology input-output mapping and costs parameters
    input(node,tec,vintage,year_all,mode,node,commodity,level,time,time)  relative share of input per unit of activity
    output(node,tec,vintage,year_all,mode,node,commodity,level,time,time) relative share of output per unit of activity
    inv_cost(node,tec,year_all)                         investment costs (per unit of new capacity)
    fix_cost(node,tec,vintage,year_all)                 fixed costs per year (per unit of capacity maintained)
    var_cost(node,tec,vintage,year_all,mode,time)       variable costs of operation (per unit of capacity maintained)
    levelized_cost(node,tec,year_all,time)              levelized costs (per unit of new capacity)

* engineering parameters
    construction_time(node,tec,vintage)                     duration of construction of new capacity (in years)
    technical_lifetime(node,tec,vintage)                    maximum technical lifetime (from year of construction)
    capacity_factor(node,tec,vintage,year_all,time)         capacity factor by subannual time slice
    operation_factor(node,tec,vintage,year_all)             yearly total operation factor
    min_utilization_factor(node,tec,vintage,year_all)       yearly minimum utilization factor
    reliability_factor(node,tec,vintage,year_all,commodity) contribution towards reliability constraint of firm capacity
    tec_flex_factor(node,tec,vintage,year_all,mode)         contribution towards operation flexibility constraint
    emission_factor(node,tec,year_all,mode,emission)        emission intensity of activity
;

***
* Bounds on capacity and activity
* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
*
* The following parameters specify upper and lower bounds on new capacity, total installed capacity, and activity.
* In contrast to `MESSAGE V`, there is no option to fix a decision variable (i.e., the identifier ``fx``) -
* in |MESSAGEix|, both upper and lower bound have to be assigned explicitly.
*
* .. list-table::
*    :widths: 20 55 25
*    :header-rows: 1
*
*    * - Parameter name
*      - Index names
*      - Name in `MESSAGE V`
*    * - bound_new_capacity_up
*      - ``node_loc`` | ``tec`` | ``year_vtg``
*      - bdc up/:strike:`fx`
*    * - bound_new_capacity_lo
*      - ``node_loc`` | ``tec`` | ``year_vtg``
*      - bdc lo/:strike:`fx`
*    * - bound_total_capacity_up
*      - ``node_loc`` | ``tec`` | ``year_act``
*      - bdi up/:strike:`fx`
*    * - bound_total_capacity_lo
*      - ``node_loc`` | ``tec`` | ``year_act``
*      - bdi lo/:strike:`fx`
*    * - bound_activity_up
*      - ``node_loc`` | ``tec`` | ``year_act`` | ``mode`` | ``time``
*      - bda up/:strike:`fx` / upper [#pseudotec]_
*    * - bound_activity_lo
*      - ``node_loc`` | ``tec`` | ``year_act`` | ``mode`` | ``time``
*      - bda lo/:strike:`fx` / lower [#pseudotec]_
*
* The bounds on activity are implemented as the aggregate over all vintages in a specific period
* (cf. Equation ``ACTIVITY_BOUND_UP`` and ``ACTIVITY_BOUND_LO``).
***

Parameters
    bound_new_capacity_up(node,tec,year_all)         upper bound on new capacity
    bound_new_capacity_lo(node,tec,year_all)         lower bound on new capacity
    bound_total_capacity_up(node,tec,year_all)       upper bound on total installed capacity
    bound_total_capacity_lo(node,tec,year_all)       lower bound on total installed capacity
    bound_activity_up(node,tec,year_all,mode,time)   upper bound on activity (aggregated over all vintages)
    bound_activity_lo(node,tec,year_all,mode,time)   lower bound on activity
;

***
* Dynamic constraints on capacity and activity
* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
*
* The following parameters specify constraints on the growth of new capacity and activity, i.e., market penetration.
* In contrast to `MESSAGE V`, there is no option to fix a decision variable (i.e., the identifier ``fx``) -
* in |MESSAGEix|, both upper and lower bound have to be assigned explicitly.
*
* .. list-table::
*    :widths: 20 55 25
*    :header-rows: 1
*
*    * - Parameter name
*      - Index names
*      - Name in `MESSAGE V`
*    * - initial_new_capacity_up
*      - ``node_loc`` | ``tec`` | ``year_vtg``
*      - mpc up (1st)
*    * - growth_new_capacity_up [#mpx_rebase]_
*      - ``node_loc`` | ``tec`` | ``year_vtg``
*      - mpc up (2nd)
*    * - soft_new_capacity_up [#mpx_rebase]_
*      - ``node_loc`` | ``tec`` | ``year_vtg``
*      - :strike:`free.mps`
*    * - initial_new_capacity_lo
*      - ``node_loc`` | ``tec`` | ``year_vtg``
*      - mpc lo (1st)
*    * - growth_new_capacity_lo [#mpx_rebase]_
*      - ``node_loc`` | ``tec_actual`` | ``year_vtg``
*      - mpc lo (2nd)
*    * - soft_new_capacity_lo [#mpx_rebase]_
*      - ``node_loc`` | ``tec`` | ``year_vtg``
*      - :strike:`free.mps`
*    * - initial_activity_up [#mpa]_
*      - ``node_loc`` | ``tec`` | ``year_act`` | ``time``
*      - mpa up (1st)
*    * - growth_activity_up [#mpx_rebase]_ [#mpa]_
*      - ``node_loc`` | ``tec`` | ``year_act`` | ``time``
*      - mpa up (2nd)
*    * - soft_activity_up [#mpx_rebase]_
*      - ``node_loc`` | ``tec`` | ``year_act`` | ``time``
*      - :strike:`free.mps`
*    * - initial_activity_lo [#mpa]_
*      - ``node_loc`` | ``tec`` | ``year_act`` | ``time``
*      - mpa lo (1st)
*    * - growth_activity_lo [#mpx_rebase]_ [#mpa]_
*      - ``node_loc`` | ``tec`` | ``year_act`` | ``time``
*      - mpa lo (2nd)
*    * - soft_activity_lo [#mpx_rebase]_
*      - ``node_loc`` | ``tec`` | ``year_act`` | ``time``
*      - :strike:`free.mps`
*
* .. [#mpx_rebase] All parameters related to the dynamic constraints are understood as the bound on the rate
*    of growth/decrease, not as in percentage points and not as (1+growth rate). This notation harmonizes the
*    convention of parameters ``mpc/mpa`` and those specified in ``free.mps`` in `MESSAGE V`.
*
* .. [#mpa] In contrast to `MESSAGE V`, the dynamic constraints are not indexed over modes
*    in the |MESSAGEix| implementation. Instead, the dynamic constraints operate on the aggregate activity
*    of a technology and are not distinguished by vintage.
***

Parameters
    initial_new_capacity_up(node,tec,year_all)     dynamic upper bound on new capacity (fixed initial term)
    growth_new_capacity_up(node,tec,year_all)      dynamic upper bound on new capacity (growth rate)
    soft_new_capacity_up(node,tec,year_all)        soft relaxation of dynamic upper bound on new capacity (growth rate)

    initial_new_capacity_lo(node,tec,year_all)     dynamic lower bound on new capacity (fixed initial term)
    growth_new_capacity_lo(node,tec,year_all)      dynamic lower bound on new capacity (growth rate)
    soft_new_capacity_lo(node,tec,year_all)        soft relaxation of dynamic lower bound on new capacity (growth rate)

    initial_activity_up(node,tec,year_all,time)    dynamic upper bound on activity (fixed initial term)
    growth_activity_up(node,tec,year_all,time)     dynamic upper bound on activity (growth rate)
    soft_activity_up(node,tec,year_all,time)       soft relaxation of dynamic upper bound on activity (growth rate)

    initial_activity_lo(node,tec,year_all,time)    dynamic lower bound on activity (fixed initial term)
    growth_activity_lo(node,tec,year_all,time)     dynamic lower bound on activity (growth rate)
    soft_activity_lo(node,tec,year_all,time)       soft relaxation of dynamic lower bound on activity (growth rate)
;

***
* Cost parameters for 'soft' relaxations of dynamic constraints
* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
*
* The implementation of |MESSAGEix| includes the functionality for 'soft' relaxations of dynamic constraints on
* new-built capacity and activity (see Keppo and Strubegger, 2010 :cite:`keppo_short_2010`).
* Refer to equations ``
*
* .. list-table::
*    :widths: 20 80
*    :header-rows: 1
*
*    * - Parameter name
*      - Index names
*    * - abs_cost_new_capacity_soft_up
*      - ``node_loc`` | ``tec`` | ``year_vtg``
*    * - abs_cost_new_capacity_soft_lo
*      - ``node_loc`` | ``tec`` | ``year_vtg``
*    * - level_cost_new_capacity_soft_up
*      - ``node_loc`` | ``tec`` | ``year_vtg``
*    * - level_cost_new_capacity_soft_lo
*      - ``node_loc`` | ``tec`` | ``year_vtg``
*    * - abs_cost_activity_soft_up
*      - ``node_loc`` | ``tec`` | ``year_act`` | ``time``
*    * - abs_cost_activity_soft_lo
*      - ``node_loc`` | ``tec`` | ``year_act`` | ``time``
*    * - level_cost_activity_soft_up
*      - ``node_loc`` | ``tec`` | ``year_act`` | ``time``
*    * - level_cost_activity_soft_lo
*      - ``node_loc`` | ``tec`` | ``year_act`` | ``time``
*
* As part of the migration from `MESSAGE V` to |MESSAGEix|,
* the values for these parameters were imported directly from the ``free.mps`` file.
***

Parameters
    abs_cost_new_capacity_soft_up(node,tec,year_all) absolute cost of dynamic new capacity constraint relaxation (upwards)
    abs_cost_new_capacity_soft_lo(node,tec,year_all) absolute cost of dynamic new capacity constraint relaxation (downwards)
    level_cost_new_capacity_soft_up(node,tec,year_all) levelized cost multiplier of dynamic new capacity constraint relaxation (upwards)
    level_cost_new_capacity_soft_lo(node,tec,year_all) levelized cost multiplier of dynamic new capacity constraint relaxation (downwards)

    abs_cost_activity_soft_up(node,tec,year_all,time)  absolute cost of dynamic activity constraint relaxation (upwards)
    abs_cost_activity_soft_lo(node,tec,year_all,time)  absolute cost of dynamic activity constraint relaxation (downwards)
    level_cost_activity_soft_up(node,tec,year_all,time) levelized cost multiplier of dynamic activity constraint relaxation (upwards)
    level_cost_activity_soft_lo(node,tec,year_all,time) levelized cost multiplier of dynamic activity constraint relaxation (downwards)
;


***
* Historical and reference values
* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
*
* Historical data on new capacity and activity levels is included in the |MESSAGEix| model for
* correct accounting of the vintage portfolio and a seamless implementation of dynamic constraints from
* historical years to model periods.
*
* .. list-table::
*    :widths: 20 80
*    :header-rows: 1
*
*    * - Parameter name
*      - Index names
*    * - historical_new_capacity [#hist_ref]_ [#hisc]_
*      - ``node_loc`` | ``tec`` | ``year_vtg``
*    * - historical_activity [#hist_ref]_
*      - ``node_loc`` | ``tec`` | ``year_act`` | ``mode`` | ``time``
*    * - ref_new_capacity [#hist_ref]_
*      - ``node_loc`` | ``tec`` | ``year_vtg``
*    * - ref_activity [#hist_ref]_
*      - ``node_loc`` | ``tec`` | ``year_act`` | ``mode`` | ``time``
*
* .. [#hisc] The `MESSAGE V` parameter ``hisc`` (historical new capacity) is superseded
*    by the parameter ``historical_new_capacity`` in |MESSAGEix|.
***

Parameters
    historical_new_capacity(node,tec,year_all)           historical new capacity
    historical_activity(node,tec,year_all,mode,time)     historical acitivity
    ref_new_capacity(node,tec,year_all)                  reference new capacity levels
    ref_activity(node,tec,year_all,mode,time)            reference activity levels
;

***
* Auxiliary investment cost parameters and multipliers
* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
*
***

Parameters
    construction_time_factor(node,tec,year_all) scaling factor to account for construction time of new capacity
    remaining_capacity(node,tec,year_all,year_all) scaling factor to account for remaining capacity in period
    end_of_horizon_factor(node,tec,year_all)    multiplier for value of investment at end of model horizon
    beyond_horizon_lifetime(node,tec,year_all)  remaining technical lifetime at the end of model horizon
    beyond_horizon_factor(node,tec,year_all)    discount factor of remaining lifetime beyond model horizon
;

*----------------------------------------------------------------------------------------------------------------------*
* Emissions                                                                                                            *
*----------------------------------------------------------------------------------------------------------------------*

***
* Parameters of the `Emission` section
* ------------------------------------
*
* The implementation of |MESSAGEix| includes a flexible and versatile accounting of emissions across different
* categories and species, with the option to define upper bounds and taxes on various (aggregates of) emissions
* and pollutants), (sets of) technologies, and (sets of) years.
*
* .. list-table::
*    :widths: 20 80
*    :header-rows: 1
*
*    * - Parameter name
*      - Index dimensions
*    * - emission_scaling [#em_scaling]_
*      - ``type_emission`` | ``emission``
*    * - bound_emission
*      - ``node`` | ``type_emission`` | ``type_tec`` | ``type_year``
*    * - tax_emission
*      - ``node`` | ``type_emission`` | ``type_tec`` | ``type_year``
*
* .. [#em_scaling] The parameters 'emission_scaling' allows to efficiently aggregate different emissions/pollutants
*    and set bounds or taxes on various categories.
***

Parameters
    emission_scaling(type_emission,emission)                scaling factor to harmonize bounds or taxes across tpes
    bound_emission(node,type_emission,type_tec,type_year)   upper bound on emissions
    tax_emission(node,type_emission,type_tec,year_all)      emission tax
;

*----------------------------------------------------------------------------------------------------------------------*
* User-defined generic relations                                                                                       *
*----------------------------------------------------------------------------------------------------------------------*

***
* Parameters of the `Relations` section
* -------------------------------------
*
* The user-defined relations implemented in `MESSAGE V` are included in |MESSAGEix| for legacy reasons.
* This section is intended to be phased out - all new features should be implemented as specific new mathematical
* formulations and associated sets & parameters, following the example of the section on emission representation above.
*
* .. list-table::
*    :widths: 20 55 25
*    :header-rows: 1
*
*    * - Parameter name
*      - Index dimensions
*      - Name in `MESSAGE V`
*    * - relation_upper
*      - ``relation`` | ``node_rel`` | ``year_rel``
*      - :strike:`rhs up`
*    * - relation_lower
*      - ``relation`` | ``node_rel`` | ``year_rel``
*      - :strike:`rhs lo`/:strike:`range` [#rhs_range]
*    * - relation_lower
*      - ``relation`` | ``node_rel`` | ``year_rel``
*      - lower_bound
*    * - relation_new_capacity
*      - ``relation`` | ``node_rel`` | ``year_rel`` | ``tec``
*      - con_c
*    * - relation_total_capacity
*      - ``relation`` | ``node_rel`` | ``year_rel`` | ``tec``
*      - con_a:tin/tic
*    * - relation_activity
*      - ``relation`` | ``node_rel`` | ``year_rel`` | ``node_loc`` | ``tec`` | ``year_act`` | ``mode``
*      - con_a
*
* .. [#rhs_range] In `MESSAGE V`, the ``range`` value is substracted from the `rhs up` value
*    to yield the lower bound of the relation.
***

Parameters
    relation_upper(relation,node,year_all)    upper bound of generic relation
    relation_lower(relation,node,year_all)    lower bound of generic relation
    relation_cost(relation,node,year_all)     cost of investment and activities included in generic relation
    relation_new_capacity(relation,node,year_all,tec)   new capacity factor (multiplier) of generic relation
    relation_total_capacity(relation,node,year_all,tec) total capacity factor (multiplier) of generic relation
    relation_activity(relation,node,year_all,node,tec,year_all,mode) activity factor (multiplier) of generic relation
;

*----------------------------------------------------------------------------------------------------------------------*
* Fixed variable values                                                                                                *
*----------------------------------------------------------------------------------------------------------------------*

***
* Fixed variable values
* ---------------------
*
* The following parameters allow to set variable values to a specific value.
* The value is usually taken from a solution of another model instance
* (e.g., scenarios where a shock sets in later to mimick imperfect foresight).
* This feature is equivalent to "slicing" in `MESSAGE V`.
*
* The fixed values do not override any upper or lower bounds that may be defined, so fixing variables to values
* outside will yield an infeasible model.
***

Parameters
    fixed_extraction(node,commodity,grade,year_all)     fixed extraction level
    fixed_stock(node,commodity,level,year_all)          fixed stock level
    fixed_new_capacity(node,tec,year_all)               fixed new-built capacity
    fixed_capacity(node,tec,vintage,year_all)           fixed maintained capacity
    fixed_activity(node,tec,vintage,year_all,mode,time) fixed activity level
;

* Note that the 'STOCK_CHANGE' variable is determined implicitly by the 'STOCK' variable
* and therefore does not need to be explicitly fixed.

*----------------------------------------------------------------------------------------------------------------------*
* Auxiliary reporting parameters                                                                                     *
*----------------------------------------------------------------------------------------------------------------------*

Parameters
    trade_cost(node, year_all)                          net of commodity import costs and commodity export revenues by node and year
    import_cost(node, commodity, year_all)              import costs by commodity and node and year
    export_cost(node, commodity, year_all)              export revenues by commodity and node and year
;

*----------------------------------------------------------------------------------------------------------------------*
* Auxiliary variables for workflow                                                                                     *
*----------------------------------------------------------------------------------------------------------------------*

Parameters
    ctr               counter parameter for loops
    status(*,*)       model solution status parameter for log writing
;

