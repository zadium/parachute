/**
    @name: SmokeBurst
    @author: Zai Daemon
    @version: 1.3
    @updated: "2024-05-18 22:46:20"
    @revision: 455
    @localfile: ?defaultpath\Parachute\?@name.lsl
    @license: MIT
    @description: will make tail of smoke behind engine, without lose any space, it use speed of object, 1/speed to brust particles
*/
//* settings

integer Ribbon = FALSE; //* smoke or ribbon
integer AutoStop = FALSE; //* stop particles when no speed, speed = 0

float BurstFactor = 10; //* increase it to brust more

float Size = 0.5;
float EndSize = 1;
float Angle = 0.01; //* cone of smoke you can make it 0
float Age = 8;
integer Count = 3;

//******************************

integer on = FALSE;
vector color = < 0.9, 0.9, 0.9 >;

float part_last_speed = 0;
float part_last_burst = 0;

float burst;
float speed;
float part_speed;

integer channel_number = -2341;       //* HUD > Back-pack channel

integer getchannel()
{
    return (((integer)("0x"+llGetSubString((string)llGetOwner(),-8,-1)) & 0x3FFFFFFF) ^ 0xBFFFFFFF ) + 152;
}

smokeNow()
{
    llParticleSystem([
       PSYS_PART_FLAGS,
            PSYS_PART_INTERP_COLOR_MASK
            | PSYS_PART_FOLLOW_VELOCITY_MASK
            | PSYS_PART_INTERP_SCALE_MASK
            | PSYS_PART_EMISSIVE_MASK
            | PSYS_PART_WIND_MASK
            //| PSYS_PART_RIBBON_MASK
            ,
        PSYS_SRC_PATTERN,             PSYS_SRC_PATTERN_ANGLE_CONE,
        //PSYS_SRC_TEXTURE, llGetInventoryName(INVENTORY_TEXTURE, 0),
        //PSYS_SRC_OMEGA,<0,-0.203125,0>,

        PSYS_SRC_BURST_RATE,        burst,
        PSYS_SRC_BURST_PART_COUNT,  Count,

        PSYS_SRC_ANGLE_BEGIN,       -Angle*DEG_TO_RAD,
        PSYS_SRC_ANGLE_END,         Angle*DEG_TO_RAD,

        PSYS_PART_START_COLOR,      color,
        PSYS_PART_END_COLOR,        color,

        PSYS_PART_START_SCALE,      <Size, Size, 0>,
        PSYS_PART_END_SCALE,        <EndSize, EndSize, 0>,

        PSYS_SRC_BURST_SPEED_MIN, part_speed,
        PSYS_SRC_BURST_SPEED_MAX, part_speed,

        PSYS_SRC_BURST_RADIUS,      0.1,
        PSYS_SRC_MAX_AGE,           0,
        PSYS_SRC_ACCEL,             <0.0, 0.0, 0.0>,

        PSYS_PART_MAX_AGE,          Age,

        PSYS_PART_START_GLOW,       0.0,
        PSYS_PART_END_GLOW,         0.0,

        PSYS_PART_START_ALPHA,      0.4,
        PSYS_PART_END_ALPHA,        0.2

    ]);
}

ribbonNow()
{
    llParticleSystem([
       PSYS_PART_FLAGS,
            PSYS_PART_INTERP_COLOR_MASK
            | PSYS_PART_FOLLOW_VELOCITY_MASK
            | PSYS_PART_INTERP_SCALE_MASK
            | PSYS_PART_EMISSIVE_MASK
            | PSYS_PART_WIND_MASK
            | PSYS_PART_RIBBON_MASK
            ,
        PSYS_SRC_PATTERN,           PSYS_SRC_PATTERN_ANGLE_CONE,
        PSYS_SRC_TEXTURE, llGetInventoryName(INVENTORY_TEXTURE, 0),
        PSYS_SRC_OMEGA,<0.2,0,0>,

        PSYS_SRC_BURST_RATE,        burst,
        PSYS_SRC_BURST_PART_COUNT,  Count,

        PSYS_SRC_ANGLE_BEGIN,       -Angle*DEG_TO_RAD,
        PSYS_SRC_ANGLE_END,         Angle*DEG_TO_RAD,

        PSYS_PART_START_COLOR,      color,
        PSYS_PART_END_COLOR,        color,

        PSYS_PART_START_SCALE,      <Size, Size, 0>,
        PSYS_PART_END_SCALE,        <EndSize, EndSize, 0>,

        PSYS_SRC_BURST_SPEED_MIN, part_speed,
        PSYS_SRC_BURST_SPEED_MAX, part_speed,

        PSYS_SRC_BURST_RADIUS,      Size / 4,
        PSYS_SRC_MAX_AGE,           0,
        PSYS_SRC_ACCEL,             <0.0, 0.0, 0.0>,

        PSYS_PART_MAX_AGE,          Age,

        PSYS_PART_START_GLOW,       0.0,
        PSYS_PART_END_GLOW,         0.0,

        PSYS_PART_START_ALPHA,      0.8,
        PSYS_PART_END_ALPHA,        0.5
    ]);
}

burstNow()
{

    burst = 0.1;
    speed = llVecMag(llGetVel()); //* meter per seconds
    part_speed = 0; //* speed of smoke behind, if speed 0 we will increase it to emulate engine startup

    if (speed==0) //* standby, not moving
    {
        if (AutoStop)
        {
            llParticleSystem([]);
            return;
        }
        else
        {
            speed = 1;
            part_speed = 0.5;
        }
    }

    burst = (1/speed) / BurstFactor;

    if (burst<0.01)
        burst = 0.01;

    burst = llRound(burst*100.0)/100.0;

    if ((part_last_speed != part_speed) || (part_last_burst != burst))
    {
        part_last_speed = part_speed;
        part_last_burst = burst;
        if (Ribbon)
            ribbonNow();
        else
            smokeNow();
    }
}

float time = 0.5;

toggle()
{
    part_last_speed = 0;
    part_last_burst = 0;
    color = llGetColor(ALL_SIDES);
    on = !on;
    if (on)
    {
        llSetTimerEvent(time);
        burstNow();
        llRegionSayTo(llGetOwner(), channel_number, "smoke:is_on"); //* sent to smoke
    }
    else
    {
        llSetTimerEvent(0);
        llParticleSystem([]);  // end smoke
        llRegionSayTo(llGetOwner(), channel_number, "smoke:is_off"); //* sent to smoke
    }
}

default
{
    state_entry()
    {
        channel_number = getchannel();
        llParticleSystem([]);
    }

    on_rez(integer number)
    {
        llResetScript();
    }

    touch_start(integer num_detected)
    {
        if (llDetectedKey(0) == llGetOwner())
            toggle();
    }

    timer()
    {
        burstNow();
    }

    link_message(integer sender_num, integer num, string message, key id)
    {
        list params = llParseString2List(message,[";"],[""]);
        string cmd = llList2String(params,0);
        params = llDeleteSubList(params, 0, 0);
        if (cmd == "ribbon:on")
            Ribbon = TRUE;
        else if (cmd == "ribbon:off")
            Ribbon = FALSE;
        else if (cmd == "smoke:toggle")
        {
            toggle();
        }
        else if (cmd == "smoke:on")
        {
            part_last_speed = 0;
            part_last_burst = 0;
            color = llGetColor(ALL_SIDES);
            on = TRUE;
            burstNow();
            llSetTimerEvent(time);
        }
        else if (cmd == "smoke:off")
        {
            part_last_speed = 0;
            part_last_burst = 0;
            color = llGetColor(ALL_SIDES);
            on = FALSE;
            llSetTimerEvent(0);
            llParticleSystem([]);  // end smoke
        }
    }
}
