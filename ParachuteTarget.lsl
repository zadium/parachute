/**
    @name: ParachuteTarget
    @description:
    @author: Zai Dium

    @version: 6.1
    @updated: "2024-05-16 02:29:23"
    @revision: 459
    @localfile: ?defaultpath\Parachute\?@name.lsl
    @license: MIT
*/

//*
integer channel_number = 0;

integer getTargetChannel()
{
    return -1001;
}

default
{
    state_entry()
    {
        channel_number = getTargetChannel();
        llListen(channel_number, "", NULL_KEY, "");
    }

    listen(integer channel, string name, key id, string message)
    {
        list params = llParseStringKeepNulls(message,[";"],[""]);
        string cmd = llList2String(params, 0);
        params = llDeleteSubList(params, 0, 0);
        if (cmd == "parachute_ping")
        {
            llRegionSayTo(id, channel_number, "parachute_pong");
        }
    }

}
