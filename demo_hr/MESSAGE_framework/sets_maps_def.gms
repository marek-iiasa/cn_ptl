***
* .. _sets_maps_def:
*
* Sets and mappings definition
* =============================
* | This page is generated from the auto-documentation
* | in ``MESSAGE_framework/sets_maps_def.gms``.
*
* This file contains the definition of all sets and mappings used in |MESSAGEix|,
* the GAMS implementation of the Integrated Assessment Model MESSAGE.
* References and comments relating the notation to `MESSAGE V` are included for legacy reasons.
*
* Notation of `MESSAGE V`, which is not included in |MESSAGEix|, is marked as :strike:`name`.
* It is included here for easier reference between the model versions.
***

* indices to mapping sets will always be in the following order:
* lvl_spatial,lvl_temporal,
* node_location,tec,year_actual,year_vintage,mode,commodity,level,grade,node_od,emission,time(actual),time(source/origin)

* allows sets to be empty
$ONEMPTY

*----------------------------------------------------------------------------------------------------------------------*
* Set definitions                                                                                                      *
*----------------------------------------------------------------------------------------------------------------------*

***
* Sets in the |MESSAGEix| implementation
* --------------------------------------
*
* .. list-table::
*    :widths: 25 15 60
*    :header-rows: 1
*
*    * - Set name
*      - Notation
*      - Explanatory comments
*    * - node [#node]_
*      - :math:`n \in N`
*      - regions, countries, grid cells
*    * - :strike:`region`
*      -
*      -
*    * - commodity
*      - :math:`c \in C`
*      - resources, electricity, water, land availability, etc.
*    * - level
*      - :math:`l \in L`
*      - primary, secondary, ... , useful
*    * - grade
*      - :math:`g \in G`
*      - grades of raw materials in extraction & mining sector
*    * - tec
*      - :math:`t \in T`
*      - this set is called ``technology`` in the ixMP interface
*    * - :strike:`variables` [#variable]_
*      -
*      -
*    * - mode
*      - :math:`m \in M`
*      - modes of operation
*    * - emission
*      - :math:`e \in E`
*      - greenhouse gases, pollutants, etc.
*    * - year_all [#year_all]_
*      -
*      - set of years (over entire model horizon) - this set is called ``year`` in the ixMP interface
*    * - year (year_all)
*      - :math:`y \in Y`
*      - years included in a model instance (for myopic or rolling-horizon optimization)
*    * - time [#time]_
*      - :math:`h \in H`
*      - subannual time periods (seasons, days, hours)
*    * - relation [#relations]_
*      - :math:`r \in R`
*      - set of generic user-defined relations (included as legacy from `MESSAGE V`)
*    * - lvl_spatial
*      -
*      - set of spatial hierarchy levels (global, region, country, grid cell)
*    * - lvl_temporal
*      -
*      - set of temporal hierarchy levels (year, season, day, hour)
*
* .. [#node] The set ``node`` includes spatial units across all levels of spatial disaggregation
*    (global, regions, countries, basins, grid cells). This set replaces the notion of ``regions`` in `MESSAGE V`.
*    The hierarchical mapping is implemented via the mapping set ``map_spatial_hierarchy``. This set always
*    includes an element 'World'.
*
* .. [#variable] The ``variables`` in `MESSAGE V` are merged with the set ``tec`` .
*
* .. [#year_all] In the |MESSAGEix| implementation in GAMS, the set ``year_all`` denotes the "superset"
*    of the entire horizon (historical and projection), and the set ``year`` is a dynamic subset of ``year_all``.
*    This facilitates an efficient implementation of the (optional) recursive-dynamic solution approach.
*    In the ``MESSAGE`` scheme in the ixMP framework, the set of all periods is called ``year`` for shorter notation.
*    The specification of the model horizon is implemented using mapping sets (see set ``type_year``).
*
* .. [#time] The set ``time`` collects all sub-annual temporal units across all levels of temporal disaggregation.
*    This set always includes an element 'year', and the duration is 1 (:math:`duration\_time_{'year'} = 1`).
*
* .. [#relations] The generic formulation of user-defined constraints (``relations`` in `MESSAGE V`) is currently
*    implemented in |MESSAGEix| for backward compatibility. Over time, it will be replaced by specific new constraints
*    in the GAMS implementation of |MESSAGEix|, see for example the new formulations of the emissions.
***

Sets
    node            world - regions - countries - grid cells
    commodity       resources - electricity - water - land availability - etc.
    level           level ( primary - secondary - ... - useful )
    sector          sectors (for integration with MACRO)
    grade           grades of extraction of raw materials
    tec             technologies
    mode            modes of operation
    emission        greenhouse gases - pollutants - etc.
    year_all        years (over entire model horizon)
    year (year_all) years included in a model instance (for myopic or rolling-horizon optimization)
    time            subannual time periods (seasons - days - hours)
    relation        generic user-defined relations (included as legacy from MESSAGE V)
    lvl_spatial     hierarchical levels of spatial resolution
    lvl_temporal    hierarchical levels of temporal resolution
;

* definition of aliases
Alias(node,location);
Alias(node,subnode);
Alias(node,node2);
Alias(node,node3);
Alias(tec,tec2);
Alias(commodity,commodity2);
Alias(emission,emission2);
Alias(year_all,vintage);
Alias(year_all,year_all2);
Alias(year_all,year_all3);
Alias(year,year2);
Alias(year,year3);
Alias(time,time2);
Alias(time,time_act);
Alias(time,time_od);

*----------------------------------------------------------------------------------------------------------------------*
* Category types and mappings                                                                                                       *
*----------------------------------------------------------------------------------------------------------------------*

***
* Category types and mappings
* ---------------------------
*
* .. list-table::
*    :widths: 25 15 60
*    :header-rows: 1
*
*    * - Set name
*      - Notation
*      - Explanatory comments
*    * - level_resource (level) [#level_res]_
*      - :math:`l \in L^R \subseteq L`
*      - levels related to `fossil resources` representation
*    * - type_node [#type_node]_
*      - :math:`\widehat{n} \in \widehat{N}`
*      - Category types for nodes
*    * - cat_node (type_node,node)
*      - :math:`n \in N(\widehat{n})`
*      - Category mapping between node types and nodes
*    * - type_tec [#type_tec]_
*      - :math:`\widehat{t} \in \widehat{T}`
*      - Category types for technologies
*    * - cat_tec (type_tec,tec)
*      - :math:`t \in T(\widehat{t})`
*      - Category mapping between tec types and technologies
*    * - inv_tec (tec) [#inv_tec]_
*      - :math:`t \in T^{INV} \subseteq T`
*      - Specific subset of investment technologies
*    * - type_emission [#type_tec]_
*      - :math:`\widehat{e} \in \widehat{E}`
*      - Category types for emissions (greenhouse gases, pollutants, etc.)
*    * - cat_emission (type_emission,emission)
*      - :math:`e \in E(\widehat{e})`
*      - Category mapping between emission types and emissions
*
* .. [#level_res] The constraint ``EXTRACTION_EQUIVALENCE`` is active only for the levels included in this set,
*    and the constraint ``COMMODITY_BALANCE`` is deactivated for these levels.
*
* .. [#type_node] The element 'economy' is added by default as part of the ``MESSAGE`` scheme in the ixMP framework.
*
* .. [#type_tec] The element 'all' (and the associated mapping to all technologies in set ``cat_tec``)
*    and the element 'investment' are added by default as part of the ``MESSAGE`` scheme in the ixMP framework.
*
* .. [#inv_tec] The auxiliary set ``inv_tec`` (subset of ``technology``) is a short-hand notation for all technologies
*    mapped to the type 'investment'. This activates the investment cost part in the objective function and the
*    constraints for all technologies where investment decisions are relevant.
***

* category types and mappings
Sets
    level_resource (level)                  subset of 'level' to mark all levels related to make hfossil resources
    type_node                               types of nodes
    cat_node(type_node,node)                mapping of nodes to respective categories
    type_tec                                types of technologies
    cat_tec(type_tec,tec)                   mapping of technologies to respective categories
    inv_tec(tec)                            technologies that have explicit investment and capacity decision variables
    type_year                               types of year aggregations
    cat_year(type_year,year_all)            mapping of years to respective categories
    type_emission                           types of emission aggregations
    cat_emission(type_emission,emission)    mapping of emissions to respective categories
;

*----------------------------------------------------------------------------------------------------------------------*
* Mapping sets                                                                                                         *
*----------------------------------------------------------------------------------------------------------------------*

***
* Mappings sets
* -------------
*
* .. list-table::
*    :widths: 25 15 60
*    :header-rows: 1
*
*    * - Set name
*      - Notation
*      - Explanatory comments
*    * - map_node(node,location)
*      -
*      - mapping of nodes across hierarchy levels (location is in node)
***

Sets
    map_node(node,location)                     mapping of nodes across hierarchy levels (location is in node)
    map_time(time,time2)                        mapping of time periods across hierarchy levels (time2 is in time)

    map_resource(node,commodity,grade,year_all)  mapping of resources and grades to node over time
    map_commodity(node,commodity,level,year_all,time)    mapping of commodity-level to node and time
    map_stocks(node,commodity,level,year_all)    mapping of commodity-level to node and time

    map_tec(node,tec,year_all)                   mapping of technology to node and years
    map_tec_time(node,tec,year_all,time)         mapping of technology to temporal dissagregation (time)
    map_tec_mode(node,tec,year_all,mode)         mapping of technology to modes
    map_tec_act(node,tec,year_all,mode,time)     mapping of technology to modes AND temporal dissagregation

    map_spatial_hierarchy(lvl_spatial,node,node)    mapping of spatial resolution to nodes (last index is 'parent')
    map_temporal_hierarchy(lvl_temporal,time,time)  mapping of temporal resolution to time (last index is 'parent')

    map_relation(relation,node,year_all)             mapping of generic relations to nodes and years
;

* additional sets created in GAMS to make notation more concise
Sets
    map_tec_lifetime(node,tec,year_all,year_all2)  mapping of technologies to periods within technical lifetime ('year_all' is vintage)
;

*----------------------------------------------------------------------------------------------------------------------*
* Mapping sets (flags) for bounds                                                                                             *
*----------------------------------------------------------------------------------------------------------------------*

***
* Mapping sets (flags) for bounds
* -------------------------------
*
* There are a number of mappings sets created automatically when exporting a ``MESSAGE`` scheme from the ixMP framework,
* and they are used as 'flags' whether a constraint is active.
* The names of these sets follow the format ``is_<constraint>_<dir>``.
*
* Such mapping sets are necessary because GAMS does not distinguish between 0 and 'no value assigned',
* i.e., it cannot differentiate between a bound of 0 and 'no bound assigned'.
***

Sets
    is_bound_extraction_up(node,commodity,grade,year_all) flag whether upper bound exists for extraction of commodity
    is_bound_new_capacity_up(node,tec,year_all)      flag whether upper bound exists for new capacity
    is_bound_new_capacity_lo(node,tec,year_all)      flag whether lower bound exists for new capacity
    is_bound_total_capacity_up(node,tec,year_all)    flag whether upper bound exists for total installed capacity
    is_bound_total_capacity_lo(node,tec,year_all)    flag whether lower bound exists for total installed capacity
    is_bound_activity_up(node,tec,year_all,mode,time) flag whether upper bound exists for a technology activity
*   is_bound_activity_lo(node,tec,year_all,mode,time) flag whether lower bound exists for a technology activity
* this last flag is not required because the lower bound defaults to zero unless explicitly specified otherwise

    is_dynamic_new_capacity_up(node,tec,year_all)    flag whether upper dynamic constraint exists for new capacity (investment)
    is_dynamic_new_capacity_lo(node,tec,year_all)    flag whether lower dynamic constraint exists for new capacity (investment)
    is_dynamic_activity_up(node,tec,year_all,time)   flag whether upper dynamic constraint exists for a technology (activity)
    is_dynamic_activity_lo(node,tec,year_all,time)   flag whether lower dynamic constraint exists for a technology (activity)

    is_bound_emission(node,type_emission,type_tec,type_year) flag whether emissions bound exists

    is_relation_upper(relation,node,year_all)        flag whether upper bounds exists for generic relation
    is_relation_lower(relation,node,year_all)        flag whether lower bounds exists for generic relation
;

*----------------------------------------------------------------------------------------------------------------------*
* Mapping sets (flags) for fixed variables                                                                                    *
*----------------------------------------------------------------------------------------------------------------------*

***
* Mapping sets (flags) for fixed variables
* ----------------------------------------
*
* Similar to the mapping sets for bounds, there are mapping sets to indicate whether decision variables are pre-defined
* to a specific value, usually taken from a solution of another model instance
* (e.g., scenarios where a shock sets in. later to mimick imperfect foresight).
* This feature is equivalent to "slicing" in `MESSAGE V`.
* The names of these sets follow the format ``is_fixed_<variable>``.
***

Sets
    is_fixed_extraction(node,commodity,grade,year_all)     flag whether extraction variable is fixed
    is_fixed_stock(node,commodity,level,year_all)          flag whether stock variable is fixed
    is_fixed_new_capacity(node,tec,year_all)               flag whether new capacity variable is fixed
    is_fixed_capacity(node,tec,vintage,year_all)           flag whether maintained capacity variable is fixed
    is_fixed_activity(node,tec,vintage,year_all,mode,time) flag whether activity variable is fixed
;

