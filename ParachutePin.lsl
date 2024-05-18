/**
    @name: ParachutePin
    @description:
    @author: Zai Dium

    @version: 6.1
    @updated: "2024-05-16 02:31:47"
    @revision: 456
    @localfile: ?defaultpath\Parachute\?@name.lsl
    @license: MIT
*/

float dieTime = 10;//* in minutes

init()
{
}

default
{
    state_entry()
    {
        llTargetOmega(ZERO_VECTOR, 0, 0);
        llSetText("", <1,1,1>, 1);
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
