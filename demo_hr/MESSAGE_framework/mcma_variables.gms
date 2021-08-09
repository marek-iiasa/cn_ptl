***
* MCMA mathematical formulation
* =====================================
* | This page is generated from the auto-documentation mark-up
* | in ``MESSAGE_framework/mcma_variables.gms``.
*
***


*----------------------------------------------------------------------------------------------------------------------*
* Variable definitions                                                                                                 *
*----------------------------------------------------------------------------------------------------------------------*

***
* Decision variables
* ^^^^^^^^^^^^^^^^^^
* ============================================= ========================================================================
* Variable                                      Explanatory text
* ============================================= ========================================================================
* :math:`CUMCOST \in \mathbb{R}`                cumulative total discounted system costs
* :math:`CUMGHG \in \mathbb{R}`                 cumulative total GHG emissions
* :math:`CUMWATER \in \mathbb{R}`               cumulative total water consumption
* ============================================= ========================================================================
*
***


*----------------------------------------------------------------------------------------------------------------------*
* equation definitions                                                                                                 *
*----------------------------------------------------------------------------------------------------------------------*

Equations
    COST_CUMULATIVE                       summation of cumulative total discounted system costs
    EMISSION_CUMULATIVE                   summation of cumulative total GHG emissions
    WATER_CUMULATIVE                      summation of cumulative total water consumption
;

*----------------------------------------------------------------------------------------------------------------------*
* variable definitions                                                                                                 *
*----------------------------------------------------------------------------------------------------------------------*

Variables
         CUMCOST
         CUMGHG
         CUMWATER
;

*----------------------------------------------------------------------------------------------------------------------*
* equation statements                                                                                                  *
*----------------------------------------------------------------------------------------------------------------------*

***
* total discounted system cost
* ------------------
*
* Equation COST\_CUMULATIVE
* """"""""""""""""""
*
* The equation aggregates total discuounted system costs
*
* .. math::
*    CUMCOST = \sum_{n,y \in Y^{M}} discountfactor_{y} \cdot COST\_NODAL_{n,y}
*
***

COST_CUMULATIVE..
    CUMCOST =E=
    sum((node,year), discountfactor(year) * COST_NODAL(node, year))
;

*----------------------------------------------------------------------------------------------------------------------*
***
* GHG Emissions section
* ----------------
*
* emission variable assignment
* ^^^^^^^^^^^^^^^^^^^
*
* Equation EMISSION_CUMULATIVE
* """"""""""""""""""""""""""""
* This equation aggregates GHG emissions across all nodes and time. In case multiple periods are included,
* the variable :math:`cumghg` is scaled to represent average annual emissions.
*
*   .. math::
*      CUMGHG \eq
*      \sum_{n,\widehat{e},\widehat{t},\widehat{y}}
*      \left(
*      \frac{
*          \sum_{\substack{n^L \in N(n), e \in E(\widehat{e}) \\ t \in T(\widehat{t}), y \in Y(\widehat{y}) \\ m,h }}
*          duration^Y_{y} \cdot emission\_scaling_{\widehat{e},e}
*          \cdot emission\_factor_{n^L,t,y,m,e} \cdot
*             & \bigg( \sum_{y^V \leq y,m} ACT_{n,t,y^V,y,m,h}
*                         + \sum_{m} historical\_activity_{n,t,y,m,h} \bigg)
*      { \sum_{y' \in Y(\widehat{y})} duration^Y_{y'} }
*      \right)
*
***

EMISSION_CUMULATIVE..
    CUMGHG =E=
    sum( (node,type_emission,type_tec,type_year) $ (SAMEAS(type_emission, 'GHGs') AND SAMEAS(type_year,'cumulative')),
         sum( (location,tec,year_all2,mode,time,emission)$( map_node(node,location) AND cat_tec(type_tec,tec)
                 AND cat_year(type_year,year_all2) AND cat_emission(type_emission,emission)
                 AND map_tec_act(location,tec,year_all2,mode,time) ) ,
             duration_period(year_all2)
             * emission_scaling(type_emission,emission) * emission_factor(location,tec,year_all2,mode,emission)
             * ( sum(vintage$( map_tec_lifetime(location,tec,vintage,year_all2) AND year(year_all2) ),
                 ACT(location,tec,vintage,year_all2,mode,time) )
             + historical_activity(location,tec,year_all2,mode,time)
                 )
             )
         / sum(year_all2$( cat_year(type_year,year_all2) ), duration_period(year_all2) )
       )
;
*----------------------------------------------------------------------------------------------------------------------*
***
* Water section
* ----------------
*
* water variable assignment
* ^^^^^^^^^^^^^^^^^^^
*
* Equation WATER_CUMULATIVE
* """"""""""""""""""""""""""""
* This equation aggregates water consumption across all nodes and time. In case multiple periods are included,
* the variable :math:`cumwater` is scaled to represent average annual water consumption.
*
*   .. math::
*      CUMWATER \eq
*      \sum_{n,\widehat{e},\widehat{t},\widehat{y}}
*      \left(
*      \frac{
*          \sum_{\substack{n^L \in N(n), e \in E(\widehat{e}) \\ t \in T(\widehat{t}), y \in Y(\widehat{y}) \\ m,h }}
*          duration^Y_{y} \cdot emission\_scaling_{\widehat{e},e}
*          \cdot emission\_factor_{n^L,t,y,m,e} \cdot
*             & \bigg( \sum_{y^V \leq y,m} ACT_{n,t,y^V,y,m,h}
*                         + \sum_{m} historical\_activity_{n,t,y,m,h} \bigg)
*      { \sum_{y' \in Y(\widehat{y})} duration^Y_{y'} }
*      \right)
*
***

WATER_CUMULATIVE..
    CUMWATER =E=
    sum( (node,type_emission,type_tec,type_year) $ (SAMEAS(type_emission, 'water') AND SAMEAS(type_year,'cumulative')),
         sum( (location,tec,year_all2,mode,time,emission)$( map_node(node,location) AND cat_tec(type_tec,tec)
                 AND cat_year(type_year,year_all2) AND cat_emission(type_emission,emission)
                 AND map_tec_act(location,tec,year_all2,mode,time) ) ,
             duration_period(year_all2)
             * emission_scaling(type_emission,emission) * emission_factor(location,tec,year_all2,mode,emission)
             * ( sum(vintage$( map_tec_lifetime(location,tec,vintage,year_all2) AND year(year_all2) ),
                 ACT(location,tec,vintage,year_all2,mode,time) )
             + historical_activity(location,tec,year_all2,mode,time)
                 )
             )
         / sum(year_all2$( cat_year(type_year,year_all2) ), duration_period(year_all2) )
       )
;

*----------------------------------------------------------------------------------------------------------------------*
* set model's time horizon                                                                                                      *
*----------------------------------------------------------------------------------------------------------------------*

***
* Perfect-foresight model
* ~~~~~~~~~~~~~~~~~~~~~~~
* For the perfect foresight version of MESSAGE, include all years in the model horizon and solve the entire model.
*
***

* reset year in case it was set by MACRO to include the base year before
    year(year_all) = no ;
* include all model periods in the optimization horizon (excluding historical periods prior to 'first_period')
    year(year_all)$( model_horizon(year_all) ) = yes ; #

*----------------------------------------------------------------------------------------------------------------------*
* (dummy) model statements for testing                                                                                                     *
*----------------------------------------------------------------------------------------------------------------------*

* In the MCMA model setup, the actual MODEL statement is generated dynamically by the webtool.

Model MCMA_LP / all / ;

MCMA_LP.holdfixed = 1 ;
MCMA_LP.optfile = 1 ;
MCMA_LP.optcr = 0 ;



