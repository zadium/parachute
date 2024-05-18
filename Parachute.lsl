/**
    @name: Parachute
    @description:

    @author:
        Jeff Heaton (Encog Dod in SL)
        Boomer Waverider
        MatieuBC Noel
        Lilim Daemon
        Zai Dium

    @version: 6.1
    @updated: "2024-05-17 23:46:10"
    @revision: 573
    @localfile: ?defaultpath\Parachute\?@name.lsl
    @license: MIT
    @resources
        https://sketchfab.com/3d-models/set-of-map-pin-dc052c20722643bbaeff00ba4eacf02b#download
        https://www.101soundboards.com/sounds/27005592-parachute-opening-2-options-cord-pull-skydive-parasend-parashoot-at-2create
*/

//* script to implement Parachute

//* From the book:
//* Scripting Recipes for Second Life
//* by Jeff Heaton (Encog Dod in SL)
//* ISBN: 160439000X
//* Copyright 2007 by Heaton Research, Inc.
//
//* This script may be freely copied and modified so long as this header remains unmodified.
//* For more information about this book visit the following web site:
//
//* http://www.heatonresearch.com/articles/series/22/

//* Script upgraded by MatieuBC Noel since July 28 2008
//* hop://discoverygrid.net:8002/ElvenHeart/894/894/3000

//* Mods by Boomer Waverider / June / 2011
//* Mods by Boomer Waverider / July / 2021

/** Changes 04-2023
    Lilim: Change messages command from "D" to "deploy", i dont like short messages
    Lilim: Use one channel to communicate
    Lilim: Show status feed back from back-back, do not show green hud until confirm from chute
    Lilim: 3 State of Hud, Off, Ready/Deply, Opened
    Lilim: Removed hide show scripts inside linked prims
    Lilim: Falling send confirm to open if Hud button in ready state
    Lilim: If Falling but Hud not read, it open after 5 seconds of fall
    Lilim: If avatar back to fly, chute will hide and back to default state
    Lilim: Remove a state and keep only 2
    Lilim: Add Turbo, db click on Up
    Lilim: Add wind apply power too
    Lilim: Remove text
    Lilim: Fix region say to chan 0
    Lilim: Add FallDistance
    Zai Dium: Rez Pin on land pos
    Zai Dium: Add Target comm
    Zai Dium: Add Show distance on Pin
    Zai Dium: Added new parachute mesh
*/

//* Settings
float AutoOpenHighHight = 400;    //* meter over ground to auto open chute, set to zero to disable it
float AutoOpenLowHeight = 20; //* Do not open before this height

float FallDistance = 20;  //* Distance fall in meters before skydive, set to 0 to disable it
//* Or
float FallTime = 0.0;    //* time in seconds before skydive, set to 0 to disable it

float MinHeight = 25;  //* minimum height started from open chute, to rez pin map and send score

float Exceeds = 5.5; //* fall speed limit
float WindFactor = 1; //* increase wind power
float Turbo = 20; //* forward speed when dblclick on up key
float X_Thrust = 20.0;   //* thrust to move forward / backward  17.0, 25
float Y_vel = 0.0;
float Z_vel = 34.0;    //* upward thrust to slow descent // 45

//* Sounds
string chute_opens_sound = "parachute opening";  // parachute opening sound
//* Animations
string skydive_anim = "SkyDive";   //* pose when sky-diving
string steering_anim = "Steering";     //* pose when 'steering'

//* Script
float dist;          //* distance from ground
float mass;        //* mass of object

float X_vel;

float fall_start_height = 0; //* the height when chute deployed
float fall_start_time = 0; //* the time when chute deployed
float deploy_start_height = 0; //* the height when chute deployed

integer channel_number = 0;       //* HUD > Back-pack comm channel

string FormatDecimal(float number, integer precision)
{
    float roundingValue = llPow(10, -precision)*0.5;
    float rounded;
    if (number < 0) rounded = number - roundingValue;
    else            rounded = number + roundingValue;

    if (precision < 1) //* Rounding integer value
    {
        integer intRounding = (integer)llPow(10, -precision);
        rounded = (integer)rounded/intRounding*intRounding;
        precision = -1; //* Don't truncate integer value
    }

    string strNumber = (string)rounded;
    return llGetSubString(strNumber, 0, llSubStringIndex(strNumber, ".") + precision);
}

key targetID = NULL_KEY;
integer targetChannel = 0;

rezMapPin()
{
    vector v = llGetPos();
    list box = llGetBoundingBox(llGetOwner());
    vector vb = llList2Vector(box, 0);
    v.z = v.z + vb.z + 0.1;

    //v.z = llGround( ZERO_VECTOR );
    llRezObject("Pin", v, ZERO_VECTOR, ZERO_ROTATION, 1);
}

hideChute()
{
    integer i = llGetNumberOfPrims();
    while (i > 1)
    {
        if (llToLower(llGetLinkName(i) ) != "smokeburst")
            llSetLinkAlpha(i, 0, ALL_SIDES);
        i--;
    }
    //* send message to chute to close
    llMessageLinked( LINK_SET, 0, "close", NULL_KEY);
    llMessageLinked( LINK_SET, 0, "smoke:off", NULL_KEY);
    llRegionSay(channel_number, "closed");                 //* Send chute is closed
}

displayChute()
{
    integer i = llGetNumberOfPrims();
    while (i>1)
    {
        llSetLinkAlpha(i, 1, ALL_SIDES);
        i--;
    }
    //* send message to chute to open
    llMessageLinked(LINK_SET, 0,  "open", NULL_KEY );
    llMessageLinked(LINK_SET, 0,  "smoke:on", NULL_KEY);
    llRegionSay(channel_number, "opened");                 //* Send chute is opening
}

float calculateGroundDistance()
{
    vector pos = llGetPos();
    float ground = llGround(<0,0,0>);
    return (pos.z - ground);
}

//* set camera to look downwards
set_camera_view()
{
    llClearCameraParams();
    llSetCameraParams(
    [
        CAMERA_ACTIVE, TRUE,              //* TRUE = active (Dynamic cam mode), FALSE = inactive
        CAMERA_BEHINDNESS_ANGLE, 3.0,    //* (0 to 180) degrees         10.0
        CAMERA_BEHINDNESS_LAG, 0.0,       //* (0 to 3) seconds          0.3
        CAMERA_DISTANCE, 7.0,             //* how far camera wants to be from target.( 0.5 to 50 meters )
        //CAMERA_FOCUS, < 0.0,0.0,0.0 >,     //* camera focus (target position) in region coords.
        CAMERA_FOCUS_LAG, 0.1 ,             //* How much camera lags as it tries to aim towards target
        //* (0 to 3) seconds
        CAMERA_FOCUS_LOCKED, FALSE,           //* (TRUE or FALSE)
        CAMERA_FOCUS_OFFSET, < 0.0,0.0,0.0 >, //* camera focus position relative to the target
        // <-10,-10,-10> to <10,10,10> meters
        CAMERA_FOCUS_THRESHOLD, 0.4,          //* (0 to 4) meters   0.4
        CAMERA_PITCH, 45.0,                   //* angular amount camera aims straight ahead vs. down
        //* (-45 to 80) degrees          40.0
        //CAMERA_POSITION, <0.0,0.0,0.0>,      //* camera position in region coords.
        CAMERA_POSITION_LAG, 0.1,           //* How much camera lags as it moves towards 'ideal' position
        //* (0 to 3) seconds
        CAMERA_POSITION_LOCKED, FALSE,       //* (TRUE or FALSE)
        CAMERA_POSITION_THRESHOLD, 0.5       //* (0 to 4) meters   1.0
    ]);
}

float lastTime_fwd = 0;

//* ======================== start of main script ================================

integer getChannel()
{
    return (((integer)("0x"+llGetSubString((string)llGetOwner(),-8,-1)) & 0x3FFFFFFF) ^ 0xBFFFFFFF ) + 152;
}

integer isFalling()
{
    if(
            !(llGetAgentInfo(llGetOwner()) & AGENT_IN_AIR) ||
            (llGetAgentInfo(llGetOwner()) & AGENT_FLYING) ||
            (llGetAgentInfo(llGetOwner()) & AGENT_ON_OBJECT) ||
            (llGetAgentInfo(llGetOwner()) & AGENT_SITTING)
    )
        return FALSE;
    else
        return TRUE;
}

integer isSkydiving = FALSE;

startSkydiving()
{
    llStopAnimation("falldown");      //* stop plummeting pose
    llStartAnimation(skydive_anim);   //* play sky-diving pose
    llRegionSay(channel_number, "fall");                 //* Send chute is falling, so maybe in deploy state, it send back to open
    isSkydiving = TRUE;
}

stopSkydiving()
{
    llStopAnimation(skydive_anim);          //* stop the sky-diving pose
    isSkydiving = FALSE;
}

float score_height = 0;

integer getTargetChannel()
{
    return -1001;
}

default
{
    state_entry()
    {
        channel_number = getChannel();
        hideChute();       //* hide chute canopy/straps

        llSetStatus(STATUS_PHYSICS, FALSE);   //* make non-physical
        llSetText("", < 1, 1, 1 >, 1.0);

        llPreloadSound( chute_opens_sound );
        llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION );

        llSetTimerEvent(0.3);              //* set timer interval

//        llStartAnimation(skydive_anim);   //* play sky-diving pose

        //* setup listen for chute deploy command from HUD
        llListen(channel_number, "", NULL_KEY, "" );

        //* setup listen for chute deploy command from owner in chat
        llListen( 0, "", llGetOwner(), "" );

    }

    on_rez(integer i)
    {
        channel_number = getChannel();
        llRegionSay(channel_number, "reset");                 //* Send chute is closed
        llOwnerSay(" Chute is securely attached, In free-fall");
        llResetScript();
    }

    //* event triggered when message is received on channel
    listen( integer channel, string name, key id, string message )
    {
        if(channel == 0)  //* if on chat channel
        {
            if (llGetOwner() == id)
            {
                message = llStringTrim(llToLower(message), STRING_TRIM);
                if (message == "smoke")
                    llMessageLinked(LINK_SET, 0, "smoke:on", NULL_KEY);
                else if (message == "smoke on")
                {
                    llMessageLinked(LINK_SET, 0, "smoke:on", NULL_KEY);
                }
                else if (message == "smoke off")
                {
                    llMessageLinked(LINK_SET, 0, "smoke:off", NULL_KEY );
                }
                else if (message == "ribbon on")
                    llMessageLinked(LINK_SET, 0, "ribbon:on", NULL_KEY );
                else if (message == "ribbon off")
                    llMessageLinked(LINK_SET, 0, "ribbon:off", NULL_KEY );
                else if((message == "open") || (message == "pull"))        //* command to open chute
                {
                    if (isFalling())
                    {
                        stopSkydiving();
                        state deployed;                       //* enter chute deployed state
                    }
                }
            }
        }
        else if(channel == channel_number)  //* if on HUD channel
        {
            if (llGetOwner() == llGetOwnerKey(id))
            {
                if (isFalling())
                {
                    if (message == "deploy" )      //* if chute deploy command received from HUD
                    {
                        stopSkydiving();
                        state deployed;                         //* enter chute deployed state
                    }
                }
            }
        }
    }

    //* event called at regular intervals
    timer()
    {
        dist = calculateGroundDistance();   //* check distance to ground

        if(
            !(llGetAgentInfo(llGetOwner()) & AGENT_IN_AIR) ||
               (llGetAgentInfo(llGetOwner()) & AGENT_FLYING) ||
               (llGetAgentInfo(llGetOwner()) & AGENT_ON_OBJECT) ||
               (llGetAgentInfo(llGetOwner()) & AGENT_SITTING))
        {
            stopSkydiving();
            fall_start_time = 0;
            fall_start_height = 0;
        }
        else
        {
            //llOwnerSay("falling: "+(string)fall_start_height+",FallDistance: "+(string)FallDistance+", dist: "+(string)dist);
            integer do_sky_diving = FALSE;
            if (!isSkydiving)
            {
                if (
                    ((fall_start_height>0) && (FallDistance > 0) && (fall_start_height - dist) > FallDistance)    //* fall after FallDistance to auto open
                       || ((fall_start_time>0) && (FallTime > 0) && (llGetTime() - fall_start_time) > FallTime)    //* fall after FallTime in seconds auto open
                   )
                {
                    do_sky_diving = TRUE;
                    fall_start_time = 0;
                    fall_start_height = 0;
                }
                else
                {
                    if (fall_start_time == 0)
                        fall_start_time = llGetTime();

                    if (fall_start_height == 0)
                        fall_start_height = dist;
                }
            }

            if (isSkydiving || do_sky_diving)
            {
                if (isSkydiving)
                {
                    if ((dist > AutoOpenLowHeight) && (AutoOpenHighHight>0) && (dist < AutoOpenHighHight))    //* auto open before this distance
                    {
                        stopSkydiving();           //* stop the sky-diving pose
                        state deployed;            //* auto-deploy chute
                    }
                }
                else
                    startSkydiving();
            }
        }
    }

    //* event triggered when chute is detached
    attach(key id)
    {
        if(id == NULL_KEY)
        {
            stopSkydiving();
        }
    }
}

//* parachute is now deployed
state deployed
{
    state_entry()
    {
        llPlaySound(chute_opens_sound, 1.0);

        displayChute();

        llOwnerSay("Chute deployed");

        //mass = llGetMass();
        mass = llGetObjectMass(llGetOwner());

        llSetTimerEvent(0.2);

        llRequestPermissions(llGetOwner(),
            PERMISSION_TRIGGER_ANIMATION |
            PERMISSION_TAKE_CONTROLS |
            PERMISSION_CONTROL_CAMERA
        );

        llStopAnimation("falldown");
        llStopAnimation(skydive_anim);     //* stop the sky-diving pose
        llStartAnimation(steering_anim);   //* switch to 'using chute' pose now

        //* setup listen for owner in chat
        llListen( 0, "", llGetOwner(), "" );

        channel_number = getChannel();
        llListen(channel_number, "", NULL_KEY, "" );

        llSetStatus(STATUS_PHYSICS, TRUE);    //* make back-pack physical
        deploy_start_height = calculateGroundDistance();   //* save distance to ground

        targetChannel = getTargetChannel();
        llListen(targetChannel, "", NULL_KEY, "" );
        llRegionSay(targetChannel, "parachute_ping");
    }

    run_time_permissions(integer perm)
    {
        if (perm & (PERMISSION_TAKE_CONTROLS))
        {
            llTakeControls( CONTROL_FWD | CONTROL_BACK | CONTROL_RIGHT | CONTROL_LEFT |
                CONTROL_ROT_RIGHT | CONTROL_ROT_LEFT |
                CONTROL_ML_LBUTTON |CONTROL_LBUTTON,
                TRUE,     //* controls generate events
                TRUE);   //* controls do normal functions

            //llOwnerSay("Taking controls.");
        }

        if (perm & PERMISSION_CONTROL_CAMERA )
        {
            set_camera_view();   //* set dynamic camera to look downwards
        }
    }

    //* event triggered when message is received on channel
    listen( integer channel, string name, key id, string message )
    {
        if (channel == targetChannel)
        {
            if (message == "parachute_pong")
            {
                targetID = id;
            }
        }
        else if (llGetOwner()== llGetOwnerKey(id))
        {
            if((channel == 0) || (channel == channel_number))
            {
                if(message == "close")        //* command to close chute
                {
                    llStopAnimation(steering_anim);         //* stop the 'using chute' pose
                    hideChute();                          //* hide parachute
                    state default;                        //* back to falling state
                }
            }
        }
    }

    //* event triggered when a control key is pressed
    control(key id, integer level, integer edge)
    {
        vector angular_motor;

        if ((level & CONTROL_FWD) || (level & CONTROL_BACK))
        {

            if (edge & CONTROL_FWD)     //* if Fwd Arrow key
            {
                if ((Turbo>0) && (llGetTime() - lastTime_fwd)<1)
                {
                    X_vel = X_vel * Turbo;
                    lastTime_fwd = 0;
                    llOwnerSay("Turbo...");
                }
                else
                {
                    X_vel = X_Thrust;       //* move forward
                }
                lastTime_fwd = llGetTime();
            }
            else if (edge & CONTROL_BACK)    //* if Back Arrow key
                X_vel = -X_Thrust;      //* move backwards
        }
        else
        {
            X_vel = 0;     //* stop moving
        }

        if ((level & CONTROL_ROT_RIGHT) || (level & CONTROL_RIGHT))  //* if Right Arrow
        {
            angular_motor.z -= (PI/4);   //* turn right
        }

        if ((level & CONTROL_ROT_LEFT) || (level & CONTROL_LEFT))  //* if Left Arrow
        {
            angular_motor.z += (PI/4);  //* turn left
        }

        llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, angular_motor);
    }

    timer()
    {
        //* if avatar started flying again
        if( llGetAgentInfo(llGetOwner()) & AGENT_FLYING)
        {
            llStopAnimation(skydive_anim);          //* stop all poses
            llStopAnimation(steering_anim);

            state default;
        }

        //* if on the ground and not flying
        else if ( !(llGetAgentInfo(llGetOwner()) & AGENT_IN_AIR) &&
             !(llGetAgentInfo(llGetOwner()) & AGENT_FLYING) )
        {

            llStopAnimation(steering_anim);
            llStopAnimation(skydive_anim);

            llSetStatus(STATUS_PHYSICS, FALSE);    //* make non-physical
            llReleaseControls();
            llClearCameraParams();
            llSetTimerEvent(0.0);
            llRegionSay(channel_number, "reset");                 //* Send chute is closed

            float d = calculateGroundDistance();
            if ((targetID !=NULL_KEY) && ((deploy_start_height - d)> MinHeight))
            {
                score_height = (deploy_start_height - d);
                rezMapPin();
                //* object_rez with state to default
            }
            else
                state default;
        }
        else
        {
            //* otherwise continue controlled descent

            dist = calculateGroundDistance();   //* check distance to ground

            vector v = llGetVel();    //* get current velocity

            if( v.z < -Exceeds )      //* if vertical descent rate exceeds -5.5 m/sec
            {
                //* apply upward impulse force to slow descent
                //* also apply X component for steering chute
                //* (Y component may be handled by angular_motor)
                //* uses Regional axes (not Local)
                vector p = < X_vel, Y_vel, Z_vel > * llGetRot();
                vector w = (llWind(ZERO_VECTOR) * WindFactor);
                w.z = 0;
                llApplyImpulse(mass * (p + w), FALSE);
            }
        }
    }

    object_rez(key id)
    {
        string text = "Started Height: "+FormatDecimal(score_height, 2);
        if (targetID !=NULL_KEY)
        {
            vector pos1 = llList2Vector(llGetObjectDetails(targetID, [OBJECT_POS]), 0);
            vector pos2 = llGetRootPosition();

            float target_dist = llVecDist(pos2, pos1);
            text += "\nDistance: "+FormatDecimal(target_dist, 2);
        }
        //text += "\n"+llGetTimestamp();

        osMessageObject(id, text);
        state default;
    }

    //* event triggered if chute is detached
    attach(key id)
    {
        if(id == NULL_KEY)
        {
            llStopAnimation(steering_anim);
            llStopAnimation(skydive_anim);
            llRegionSay(channel_number, "reset");                 //* Send chute is closed
            state default;
        }
    }
}