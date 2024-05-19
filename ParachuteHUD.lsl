/**
    @name: ParachuteHUD
    @description:

    @author: --- Unkown, Lilim, Zai
    @version: 5.15
    @updated: "2024-05-19 17:55:08"
    @revision: 169
    @localfile: ?defaultpath\Parachute\?@name.lsl
    @license: MIT
*/

/** Changes 04-2023
    Lilim: Change messages command from "D" to "deploy", i dont like short messages
    Lilim: Use one channel to communicate
    Lilim: Show status feed back from back-back, do not show green hud until confirm from chute
*/

integer channel_number = -2341;       //* HUD > Back-pack channel

float dist;       //* distance above ground
vector velocity;     //* vertical velocity
integer opened = FALSE;
integer deploy = FALSE;

integer parachute_face = 0;
integer smoke_face = 1;

// formats a float variable with specified no. of digits after decimal
string FormatDecimal(float number, integer precision)
{
    float roundingValue = llPow(10, -precision) * 0.5;
    float rounded;


    if (number < 0) rounded = number - roundingValue;     // handle negative numbers
    else            rounded = number + roundingValue;

    if (precision < 1)   // handle integer values
    {
        integer intRounding = (integer)llPow(10, -precision);
        rounded = (integer)rounded / intRounding * intRounding;
        precision = -1;   // don't truncate integer value
    }

    string strNumber = (string)rounded;
    return llGetSubString(strNumber, 0, llSubStringIndex(strNumber, ".") + precision);
}

integer calculateGroundDistance()
{
    vector pos = llGetPos();
    float ground = llGround(<0,0,0>);
    float distance = llRound(pos.z - ground -1.0);

    return (integer)distance;
}

update()
{
    if (opened)
    {
        llSetColor(< 0.14, 0.73, 0.17 >, parachute_face);   // change color back to yellow
        llSetPrimitiveParams( [ PRIM_GLOW, parachute_face,  0.3 ]);    // make HUD glow
    }
    else if (deploy)
    {
        llSetColor(< 0.99, 0.84, 0.36 >, parachute_face);    // change HUD color to green
        llSetPrimitiveParams( [ PRIM_GLOW, parachute_face,  0.0 ]);   // cancel glow
    }
    else
    {
        llSetColor(< 0.73, 0.16, 0.14 >, parachute_face);   // change color back to red
        llSetPrimitiveParams([PRIM_GLOW, parachute_face,  0.0 ]);   // cancel glow
    }
}

// ============================= start of main script =============================

integer getchannel()
{
    return (((integer)("0x"+llGetSubString((string)llGetOwner(),-8,-1)) & 0x3FFFFFFF) ^ 0xBFFFFFFF ) + 152;
}

default
{
    state_entry()
    {

        channel_number = getchannel();

        llListen( channel_number, "", NULL_KEY, "" );

        opened = FALSE;
        deploy = FALSE;
        update();
        llSetColor(< 1, 1, 1 >, smoke_face);

        llSetTimerEvent(0.2);     // set timer interval
    }

    on_rez(integer i )
    {
        llResetScript();
    }

    // event triggered when object is left-clicked
    touch_start(integer total_number)
    {
        integer face = llDetectedTouchFace(0);
        if (face == parachute_face)
        {
            if (opened)
            {
                deploy = FALSE;
                update();
                llRegionSayTo(llGetOwner(), channel_number, "close"); //* sent to close chute
            }
            else
            {
                if (deploy)
                {
                    deploy = FALSE;
                    update();
                    llRegionSayTo(llGetOwner(), channel_number, "close");
                }
                else
                {
                    deploy = TRUE;
                    update();
                    llRegionSayTo(llGetOwner(), channel_number, "deploy");
                }
            }
        }
        else if (face == smoke_face)
        {
            llRegionSayTo(llGetOwner(), channel_number, "smoke:toggle");
        }
    }

    listen( integer channel, string name, key id, string message )
    {

        if ( message == "reset" )    //* reset command from back-pack
        {
            opened = FALSE;
            deploy = FALSE;
            update();
        }
        else if ( message == "closed" )    //* chute is closed
        {
            opened = FALSE;
            update();
        }
        else if ( message == "opened" )    //* chute is opened from back-pack
        {
            opened = TRUE;
            update();
        }
        else if ( message == "fall" )    //* if avatar is falling we send deploy message
        {
            if (deploy)
                llRegionSayTo(llGetOwner(), channel_number, "deploy");
            update();
        }
        else if ( message == "smoke:is_on" )
        {
            llSetColor(< 0.73, 0.16, 0.14 >, smoke_face);
        }
        else if ( message == "smoke:is_off" )
        {
            llSetColor(< 1, 1, 1 >, smoke_face);
        }
    }

    timer()
    {
        velocity = llGetVel();    // get our current velocity
        // appears to work even though HUD is a screen attachment

        dist = calculateGroundDistance();    // check distance to ground

        // display vertical velocity & altitude above HUD
        llSetText("Velocity (m/s): " + FormatDecimal(velocity.z, 3) + "\n" +
            "Altitude (AGL): " + FormatDecimal(dist, 3), < 1, 1, 1 >, 1.0);
    }
}

