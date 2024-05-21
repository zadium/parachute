/**
    @name: ParachutePin
    @description:
    @author: Zai Dium

    @version: 2.1
    @updated: "2024-05-21 17:02:26"
    @revision: 470
    @localfile: ?defaultpath\Parachute\?@name.lsl
    @license: MIT
*/

float dieTime = 10;//* in minutes

default
{
    state_entry()
    {
        llSetPrimitiveParams([PRIM_PHANTOM, TRUE, PRIM_TEMP_ON_REZ, FALSE]);
        llSetText("", <1,1,1>, 1);
        llTargetOmega(ZERO_VECTOR, 0, 0);
    }

    on_rez(integer number)
    {
        if (number > 0)
        {
            llSetPrimitiveParams([PRIM_PHANTOM, TRUE, PRIM_TEMP_ON_REZ, TRUE]);
            llTargetOmega(llRot2Up(llGetLocalRot()), PI, 1.0);
            llSetTimerEvent(dieTime * 60);
        }
        else
            llResetScript();
    }

    timer()
    {
        llDie();
    }

    dataserver( key queryid, string data )
    {
        if (queryid == osGetRezzingObject())
        {
            llSetText(llKey2Name(llGetOwner())+"\n"+data, <1,1,1>, 1);
            llSetTimerEvent(dieTime * 60);
        }
    }

}
