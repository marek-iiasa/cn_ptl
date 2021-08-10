* Tiny test example

VARIABLES
    x1
    x2
    x3
;

EQUATIONS
    cons1
;
x2.lo = 0;
x3.lo = 0;

cons1..   x1 + x2 + x3 =l= 30 ;
OPTION LP = BDMLP ;

* mc-file name defined as the mca-arg on the cmd line
$If set mcma $INCLUDE %mcma%
$If set mcma $GOTO post_solve

MODEL simple / all / ;

SOLVE simple using LP maximize x1 ;

$LABEL post_solve

* OUTPUT
FILE model_output / "model.txt" / ;

* options for output format
model_output.lw = 0 ;
model_output.sw = 0 ;
* numeric field width
model_output.nw = 12 ;
* scientific notation
model_output.nr = 2 ;
* number of decimals
model_output.nd = 4 ;
* page control
model_output.pc = 2 ;

PUT model_output ;

* File Header contains name of scenario and execution date and time
model_output.pc = 2 ;
PUT system.title/ system.date, ' ', system.time/ ;

* data output mode for csv-type file
model_output.pc = 5 ;

PUT model_output ;


PUT / 'core model vars'/ ;

put 'x1' ;
put x1.l /;
put 'x2' ;
put x2.l /;
put 'x3' ;
put x3.l /;
