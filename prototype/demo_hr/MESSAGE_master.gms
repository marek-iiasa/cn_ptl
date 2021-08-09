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

* set # as end-of-line comment; all text after # is ignored
* (for proper display in GAMS IDE, this needs to be specified in the options, too)
$EOLCOM #
* activate dollar commands on a global level
$ONGLOBAL

*----------------------------------------------------------------------------------------------------------------------*
* model setup, data set selection, scenario selection, other settings                                                  *
*----------------------------------------------------------------------------------------------------------------------*

** model (database/scenario/case) selection - this must match the name of the MSGdata_%%%.gdx data structure file **
$SETGLOBAL data "Austrian_energy_model_water_extension"

** define the time horizon over which the model optimizes (perfect foresight, myopic or rolling horizon) **
* perfect foresight - 0
* myopic optimization (period-by-period, recursive-dynamic without any foresight) - 1
* rolling horizon (period-by-period, recursive-dynamic with limited foresight - 'number of years of foresight'
$SETGLOBAL foresight "0"

** add a comment and name extension for model report files (e.g. run-specific info, calibration notes) - optional **
$SETGLOBAL comment ""

** specify optional calibration output **
$SETGLOBAL calibration ""
* mark as "*" to include detailed calibration information in outputs and get a longer listing file

*----------------------------------------------------------------------------------------------------------------------*
* debugging mode settings for support and assistance during model development and calibration                          *
*----------------------------------------------------------------------------------------------------------------------*
* mark as "*" to deactivate, mark as "" to activate

* set auxiliary upper/lower bounds on the actitivity variables to prevent unbounded rays during model development
$SETGLOBAL AUX_BOUNDS "*"
$SETGLOBAL AUX_BOUND_VALUE "1e9"

* include relaxations for specific constraint blocks to identify infeasibilities during model development/calibration
* by adding 'slack' variables in the constraints and associated penalty factors in the objective function
$SETGLOBAL SLACK_COMMODITY_BALANCE "*"

$SETGLOBAL SLACK_CAP_NEW_BOUND_UP "*"
$SETGLOBAL SLACK_CAP_NEW_BOUND_LO "*"
$SETGLOBAL SLACK_CAP_TOTAL_BOUND_UP "*"
$SETGLOBAL SLACK_CAP_TOTAL_BOUND_LO "*"
$SETGLOBAL SLACK_CAP_NEW_DYNAMIC_UP "*"
$SETGLOBAL SLACK_CAP_NEW_DYNAMIC_LO "*"

$SETGLOBAL SLACK_ACT_BOUND_UP "*"
$SETGLOBAL SLACK_ACT_BOUND_LO "*"
$SETGLOBAL SLACK_ACT_DYNAMIC_UP "*"
$SETGLOBAL SLACK_ACT_DYNAMIC_LO "*"

$SETGLOBAL SLACK_RELATION_BOUND_UP "*"
$SETGLOBAL SLACK_RELATION_BOUND_LO "*"

*----------------------------------------------------------------------------------------------------------------------*
* launch the MESSAGE run file with the settings as defined above                                                       *
*----------------------------------------------------------------------------------------------------------------------*

$INCLUDE MESSAGE_run.gms

*----------------------------------------------------------------------------------------------------------------------*
* end of file - have a nice day!                                                                                       *
*----------------------------------------------------------------------------------------------------------------------*
