$Title China steel energy efficiency


Set
         i    technology
;

Parameters
            opt     output
            mar     potential application rate
            benefit unit profit per unit output
            inv     investment cost per unit output
            sf      fuel saving
            sco2    co2 emissions saving
            sso2    so2 emissions saving
            snox    nox emissions saving
            spm     pm emissions saving
;

$gdxin steel.gdx
$load  i,mar,opt,inv,benefit,sf,sco2,sso2,snox,spm
$gdxin

Variables
         x(i)     application rate
         zinv     total investment
         zbenefit total benefit
         zfs      total fuel saving
         zco2     total co2 saving
         zso2     total so2 saving
         znox     total nox saving
         zpm      total pm saving
;

Positive Variable x
;

Equations
         eq_benefit define objective fuction of total benefit
         apprate(i) define application rate limits
         eq_inv     total investment
         eq_fuel    amount of fuel saving
         eq_co2     amount of co2 saving
         eq_so2     amount of so2 saving
         eq_nox     amount of nox saving
         eq_pm      amount of pm saving
;

eq_benefit  ..      zbenefit =e= sum(i, x(i)*opt(i)*benefit(i)) ;

eq_inv ..   zinv =e= sum(i, x(i)*opt(i)*inv(i)) ;
eq_fuel ..  zfs  =e= sum(i, x(i)*opt(i)*sf(i)) ;
eq_co2 ..   zco2  =e= sum(i, x(i)*opt(i)*sco2(i)) ;
eq_so2 ..   zso2  =e= sum(i, x(i)*opt(i)*sso2(i)) ;
eq_nox ..   znox  =e= sum(i, x(i)*opt(i)*snox(i)) ;
eq_pm ..    zpm   =e= sum(i, x(i)*opt(i)*spm(i)) ;

apprate(i)  ..  x(i) =l= mar(i)  ;



* mc-file name defined as the mca-arg on the cmd line
$If set mcma $INCLUDE %mcma%
$If set mcma $GOTO post_solve


Model steel /all/
;

Solve steel using lp maximizing zbenefit
;


$LABEL post_solve

Display x.l, zbenefit.l, zfs.l, zco2.l, zso2.l, znox.l, zpm.l
;


FILE model_output / "Chinasteel_output.txt" / ;

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

*PUT system.title/ system.date, ' ', system.time/
*;

* data output mode for csv-type file
model_output.pc = 5 ;

PUT model_output ;


PUT / 'Technology, ,Application_rate'/ ;

LOOP(i,  PUT i.tl,  x.L(i) / )
;

$ontext


Display i,p,ps,mar, opt,cost,target
;

Display
         i, mar, opt,cost, fs,co2s,so2s,noxs,pms
;

Scalars
         tfs     fuel saving target      / 5000/
         tco2    co2 saving target       /12000/
         tso2    so2 saving target       /2500/
         tnox    nox saving target       /2300/
         tpm     pm saving target        /1500/
;

Equations
         cf      constraint on fuel saving
         cco2    constraint on co2 saving
         cso2    constraint on so2 saving
         cnox    constraint on nox saving
         cpm     constraint on pm saving
;
cf  ..   zfs =g= tfs     ;
cco2 ..  zco2 =g= tco2   ;
cso2 ..  zso2 =g= tso2   ;
cnox ..  znox =g= tnox   ;
cpm  ..  zpm  =g= tpm    ;


$offtext


