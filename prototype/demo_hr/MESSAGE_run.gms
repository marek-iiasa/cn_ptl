$TITLE Integrated Assessment Model MESSAGE
$ONDOLLAR
$ONTEXT
This is the GAMS implementation of the integrated assessment and energy system model MESSAGE

For the most recent version of this code, please visit https://github.com/iiasa/message_ix
For additional documentation and explanations, please visit https://github.com/iiasa/message_doc

This project is intended to be made available under an open-source license in the future,
but for the time being, all rights are reserved. Please do not share or distribute without permission.

This code version is currently maintained by:
Daniel Huppmann, Volker Krey
@ Energy Program, International Institute for Applied Systems Analysis (IIASA), Laxenburg, Austria
http://www.iiasa.ac.at/message/
$OFFTEXT

* specify version number of MESSAGEix (make sure that this matches the version stated below in the documentation)
* !!! DO NOT CHANGE THESE VALUES MANUALLY !!!
* Changes have to be done by pulling the most recent version from the Github repository
$SETGLOBAL VERSION_MAJOR "1"
$SETGLOBAL VERSION_MINOR "0"

***
* Model run script
* ================
* | This page is generated from the auto-documentation 
* | in ``model/MESSAGE_run.gms``.
*
* This is |MESSAGEix| framework version 1.0. The version number must match the version number of the ixToolbox
* used for exporting data and importing results.
*
* This file contains the workflow of a standard MESSAGE run. It can be called:
*  - either through the file ``MESSAGE_master.gms``, where the datastructure name and other options
*    are stated explicitly, or
*  - directly from the command line, with the datastructure name and other options specific as command line parameters,
*    e.g. :literal:`gams MESSAGE_run.gms --data\=\"<name>\"`.
*
* The data file (in gdx format) must be located in the ``model/data`` folder
* and be named in the format ``MSGdata_<name>.gdx``. Upon completion of the GAMS execution,
* a results file ``MSGoutput_<name><comment>.gdx`` will be written to the folder ``model/output``.
* Here, ``<comment>`` is an additional identifier provided as a command line parameter
* (e.g., for keeping gdx dumps across different runs of the same data file).
***

* set # as end-of-line comment; all text after # is ignored
* (for proper display in GAMS IDE, this needs to be specified in the options, too)
$OFFEOLCOM
$EOLCOM #

*----------------------------------------------------------------------------------------------------------------------*
* sanity check of model run parameters, set defaults if not specified                                                  *
*----------------------------------------------------------------------------------------------------------------------*

* a datastructure name is mandatory to load the gdx file - abort the run if not specified or file does not exist
$IF NOT set data                        $ABORT "No datastructure specified for the MESSAGE model run!"
$IF NOT EXIST 'data/MSGdata_%data%.gdx' $ABORT "No file 'msgDS_%data%.gdx' exists in the 'data' folder!"

** define the time horizon over which the model optimizes (perfect foresight, myopic or rolling horizon) **
* perfect foresight - 0 (assumed as default if not specified
* myopic optimization (period-by-period, recursive-dynamic without any foresight) - 1
* rolling horizon (period-by-period, recursive-dynamic with limited foresight - 'number of years of foresight'
$IF NOT set foresight   $SETGLOBAL foresight "0"

** set a comment and name extension for model report gdx file (e.g. run-specific info, calibration notes) - optional **
$IF NOT set comment     $SETGLOBAL comment ""

** specify optional additional calibration output **
$IF NOT set calibration $SETGLOBAL calibration ""
* mark with * to include detailed calibration information in outputs and get an extended GAMS listing (.lst) file

** debugging mode settings for support and assistance during model development and calibration **
* assume that all debugging options are deactivated by default
* mark as "*" to deactivate, mark as "" to activate

* set auxiliary upper and lower bounds on the actitivity variables to prevent unbounded models
$IF NOT set AUX_BOUNDS               $SETGLOBAL AUX_BOUNDS "*"
$IF NOT set AUX_BOUND_VALUE          $SETGLOBAL AUX_BOUND_VALUE "1e9"

* include relaxations for specific constraint blocks to identify infeasibilities during model development/calibration
* by adding 'slack' variables in the constraints and associated penalty factors in the objective function
$IF NOT set SLACK_COMMODITY_BALANCE  $SETGLOBAL SLACK_COMMODITY_BALANCE "*"

$IF NOT set SLACK_CAP_NEW_BOUND_UP   $SETGLOBAL SLACK_CAP_NEW_BOUND_UP "*"
$IF NOT set SLACK_CAP_NEW_BOUND_LO   $SETGLOBAL SLACK_CAP_NEW_BOUND_LO "*"
$IF NOT set SLACK_CAP_TOTAL_BOUND_UP $SETGLOBAL SLACK_CAP_TOTAL_BOUND_UP "*"
$IF NOT set SLACK_CAP_TOTAL_BOUND_LO $SETGLOBAL SLACK_CAP_TOTAL_BOUND_LO "*"
$IF NOT set SLACK_CAP_NEW_DYNAMIC_UP $SETGLOBAL SLACK_CAP_NEW_DYNAMIC_UP "*"
$IF NOT set SLACK_CAP_NEW_DYNAMIC_LO $SETGLOBAL SLACK_CAP_NEW_DYNAMIC_LO "*"

$IF NOT set SLACK_ACT_BOUND_UP       $SETGLOBAL SLACK_ACT_BOUND_UP "*"
$IF NOT set SLACK_ACT_BOUND_LO       $SETGLOBAL SLACK_ACT_BOUND_LO "*"
$IF NOT set SLACK_ACT_DYNAMIC_UP     $SETGLOBAL SLACK_ACT_DYNAMIC_UP "*"
$IF NOT set SLACK_ACT_DYNAMIC_LO     $SETGLOBAL SLACK_ACT_DYNAMIC_LO "*"

$IF NOT set SLACK_RELATION_BOUND_UP  $SETGLOBAL SLACK_RELATION_BOUND_UP "*"
$IF NOT set SLACK_RELATION_BOUND_LO  $SETGLOBAL SLACK_RELATION_BOUND_LO "*"


*----------------------------------------------------------------------------------------------------------------------*
* initialize sets, mappings, parameters, load data, do pre-processing                                                  *
*----------------------------------------------------------------------------------------------------------------------*

** load auxiliary settings from include file (solver options, resource/time limits, prefered solvers) **
* recommended only for advanced users
$INCLUDE MESSAGE_framework/auxiliary_settings.gms

* check that the version of MESSAGEix and the ixToolbox used for exporting the data to gdx match
$INCLUDE MESSAGE_framework/version_check.gms

** initialize sets, mappings, parameters
$INCLUDE MESSAGE_framework/sets_maps_def.gms
$INCLUDE MESSAGE_framework/parameter_def.gms

** load data from gdx, run processing scripts of auxiliary parameters
$INCLUDE MESSAGE_framework/data_load.gms

** compute auxiliary parameters for capacity and investment cost accounting
$INCLUDE MESSAGE_framework/scaling_investment_costs.gms

*----------------------------------------------------------------------------------------------------------------------*
* variable and equation definition, model declaration                                                                  *
*----------------------------------------------------------------------------------------------------------------------*

$INCLUDE MESSAGE_framework/model_core.gms

*----------------------------------------------------------------------------------------------------------------------*
* solve statements (including the loop for myopic or rolling-horizon optimization)                                     *
*----------------------------------------------------------------------------------------------------------------------*

$INCLUDE MESSAGE_framework/model_solve.gms

*----------------------------------------------------------------------------------------------------------------------*
* post-processing and export to gdx                                                                                    *
*----------------------------------------------------------------------------------------------------------------------*

$INCLUDE MESSAGE_framework/reporting.gms

* dump all input data, processed data and results to a gdx file (with additional comment as name extension if provided)
$IF NOT %comment%=="" $SETGLOBAL comment "_%comment%"
execute_unload "output/MSGoutput_%data%%comment%.gdx"

put_utility 'log' / /"+++ End of MESSAGEix (stand-alone) run - have a nice day! +++ " ;

*----------------------------------------------------------------------------------------------------------------------*
* end of file - have a nice day!                                                                                       *
*----------------------------------------------------------------------------------------------------------------------*

