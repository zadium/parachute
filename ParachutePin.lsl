/**
    @name: ParachutePin
    @description:
    @author: Zai Dium

    @version: 2.1
    @updated: "2024-05-18 17:33:26"
    @revision: 460
    @localfile: ?defaultpath\Parachute\?@name.lsl
    @license: MIT
*/

float dieTime = 10;//* in minutes

init()
{
    llSetPrimitiveParams([PRIM_PHANTOM, TRUE]);
}

default
{
    state_entry()
    {
        llSetPrimitiveParams([PRIM_PHANTOM, TRUE]);
        llSetText("", <1,1,1>, 1);
        llTargetOmega(ZERO_VECTOR, 0, 0);
    }

    on_rez(integer number)
    {
        llTargetOmega(llRot2Up(llGetLocalRot()), PI, 1.0);
        if (number>0)
        {
            init();
            llSetTimerEvent(dieTime * 60);
        }
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
        }
    }

}
