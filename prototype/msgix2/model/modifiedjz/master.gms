$EOLCOM #

$setglobal in data/parama.nsc.gdx;

$INCLUDE MESSAGE/model_setup.gms
$INCLUDE model_mca.gms
*$INCLUDE MESSAGE/model_solve.gms
 year(year_all) = no ;
    year(year_all)$( model_horizon(year_all) ) = yes ;

$If set mcma $INCLUDE %mcma%
$If set mcma $GOTO post_solve

Model MC_lp / all / ;

*$ontext       
        put_utility 'log' /'+++ Minimize CO2_CUM variable. +++ ' ;
        Solve MC_lp using LP minimizing CO2_CUM ;
        Display CO2_CUM.l ;
        Display COST_CUM.l ;
*$offtext

$ontext
        put_utility 'log' /'+++ Minimize COST_CUM variable. +++ ' ;
        Solve MC_lp using LP minimizing COST_CUM ;
        Display CO2_CUM.l ;
        Display COST_CUM.l ;
$offtext        


       
       put_utility 'log' /'+++ After the Solve +++ ' ;
       
$LABEL post_solve
* include MESSAGE GAMS-internal reporting
$INCLUDE MESSAGE/reporting.gms

* dump all input data, processed data and results to a gdx file

execute_unload "%out%"

put_utility 'log' / /"+++ End of MCMA - MESSAGEix run +++ " ;
*------------------------------------------------------------*
* end of file - have a nice day!                             *
*----------------------------------------------------------- *