
*----------------------------------------------------------------------------------------------------------------------*
* load ixToolbox version number and check whether it matches the MESSAGEix version number                              *
*----------------------------------------------------------------------------------------------------------------------*

Parameter MESSAGE_ix_version(*);

$GDXIN 'data/MSGdata_%data%.gdx'
$LOAD MESSAGE_IX_version
$GDXIN

IF ( NOT ( MESSAGE_IX_version("major") = %VERSION_MAJOR% AND MESSAGE_IX_version("minor") = %VERSION_MINOR% ),
    put_utility 'log' / '***';
    put_utility 'log' / '*** Abort "The version number of MESSAGEix and the ixToolbox used for exporting to the gdx file do not match!"';
    put_utility 'log' / '***';
    abort "Incompatible versions of MESSAGEix and ixToolbox";
) ;
