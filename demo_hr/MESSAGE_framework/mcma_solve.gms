***
* Solve statement workflow
* ========================
* | This page is generated from the auto-documentation
* | in ``MESSAGE_framework/model_solve.gms``.
*
* This part of the code includes the perfect-foresight, myopic and rolling-horizon model solve statements
* including the required accounting of investment costs beyond the model horizon.
***

if (%foresight% = 0,
***
* Perfect-foresight model
* ~~~~~~~~~~~~~~~~~~~~~~~
* For the perfect foresight version of MESSAGE, include all years in the model horizon and solve the entire model.
*
* .. math::
*    \min_x OBJ = \sum_{y \in Y} OBJ_y(x_y)
***

* reset year in case it was set by MACRO to include the base year before
    year(year_all) = no ;
* include all model periods in the optimization horizon (excluding historical periods prior to 'first_period')
    year(year_all)$( model_horizon(year_all) ) = yes ; #

* write a status update to the log file, solve the model
    put_utility 'log' /'+++ Solve the perfect-foresight MCMA version of MESSAGEix +++ ' ;
    Solve MCMA_LP using LP minimizing CUMCOST ;

* write model status summary
    status('perfect_foresight','modelstat') = MCMA_LP.modelstat ;
    status('perfect_foresight','solvestat') = MCMA_LP.solvestat ;
    status('perfect_foresight','resUsd')    = MCMA_LP.resUsd ;
    status('perfect_foresight','objEst')    = MCMA_LP.objEst ;
    status('perfect_foresight','objVal')    = MCMA_LP.objVal ;

* write an error message if model did not solve to optimality
    if( NOT ( MCMA_LP.modelstat = 1 OR MCMA_LP.modelstat = 8 ),
        put_utility 'log' /'+++ MESSAGEix did not solve to optimality - run is aborted, no output produced! +++ ' ;
    ) ;

* assign auxiliary variables DEMAND and PRICE for integration with MACRO and reporting to the IX Modeling Platform
    DEMAND.l(node,commodity,level,year,time) = demand_fixed(node,commodity,level,year,time) ;
    PRICE_COMMODITY.l(node,commodity,level,year,time) = COMMODITY_BALANCE.m(node,commodity,level,year,time)
        / discountfactor(year) ;
    PRICE_EMISSION.l(location,emission,type_tec,year) =
        smax((node,type_emission,type_year)$( is_bound_emission(node,type_emission,type_tec,type_year)
                AND map_node(node,location) AND cat_emission(type_emission,emission) AND cat_year(type_year,year) ),
* TODO: include emission factor and emission scaling accounting!
            EMISSION_CONSTRAINT.m(node,type_emission,type_tec,type_year) / discountfactor(year) ) ;
PRICE_EMISSION.l(location,emission,type_tec,year)$( PRICE_EMISSION.l(location,emission,type_tec,year) = - inf ) = 0 ;


%AUX_BOUNDS% AUX_ACT_BOUND_LO(node,tec,year_all,year_all2,mode,time)$( ACT.l(node,tec,year_all,year_all2,mode,time) < 0 AND
%AUX_BOUNDS%    ACT.l(node,tec,year_all,year_all2,mode,time) = -%AUX_BOUND_VALUE% ) = yes ;
%AUX_BOUNDS% AUX_ACT_BOUND_UP(node,tec,year_all,year_all2,mode,time)$( ACT.l(node,tec,year_all,year_all2,mode,time) > 0 AND
%AUX_BOUNDS%    ACT.l(node,tec,year_all,year_all2,mode,time) = %AUX_BOUND_VALUE% ) = yes ;

) ; # end of if statement for the selection betwen perfect-foresight or recursive-dynamic model
