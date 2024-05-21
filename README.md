# Parachute v2 (aja v7.x inworld)

Parashute mesh and OpenSIM/LSL script for skydriving, script is based on "Jeff Heaton" code and many others of modifications

I added Target and Pin where landed Target

![screenshot_01](https://github.com/zadium/parachute/assets/111429928/433823f8-b373-40d2-8005-d4345717cd79)

## Inworld usage

Go to the sky, fly, jump, after a few second you will do skydiving, click on the hud icon to open parachute, or wait till 400m for auto open
Press Up, Left, Right to control direction
Press double on Up key for push forward turbo speed

## Customize

* You can remove/unlink lower surface if you want simple parachute
* You can change color of each piece of top surface
* or select all face on top surface, change to texture you like
* You can change the logo on backpack/bag

### Smoke color

Just change color of prim of burst to change the color of smoke

# Mesh

Meshs licensed (CC BY-NC-SA 4.0)

# Scripts

## Parachute

Main script of Parachute
Based on "Jeff Heaton" script with many modification from others and me, names mentioned in the scripts

From the book:
Scripting Recipes for Second Life
by Jeff Heaton (Encog Dod in SL)
ISBN: 160439000X
Copyright 2007 by Heaton Research, Inc.

This script may be freely copied and modified so long as this header remains unmodified.
For more information about this book visit the following web site:

http://www.heatonresearch.com/articles/series/22/

## Parachute Target, HUD

my Scripts licensed (CC BY-NC-SA 4.0)

# Building

Export and Import from Belnder to Inworld

## Mesh

### Parachute

* Export Top surface as one file, without convex mesh if exists
* Create convex mish from top surface simple mish without Soldify modifier, Limit Disolve it as possible, then export it as file
* Import parachute mesh top, in physic import the convex mesh (thank you Modee), we will link it

* Export all others as one file, without Top Surface and Convex
* Unlink the backpack then link it all to it as root
* Name smoke object to SmokeBurst, this prevent from hiding
* Again make shure the bag is root prime
* Edit both surface Shininess texture to blank (White), change color of it to light gray, this will add little shinny to the surface
* Upload image rgba_25.png, assign it texture to surface sides
* Upload script Parachute.lsl into it
* Upload animations and sounds to it
* Copy **Pin** into Bag
* Take it, Attache it to Pelvis

### HUD

* Import it with Textures, no need to select physic, or select same dae file as physic file
* Upload script ParachuteHUD.lsl into it
* Upload textures, Parachute and Smoke
* Set Face 0  to Parachute texture, Face 1 to Smoke texture
* Attache it to Top Right, Edit it, move it to good corner we have text above leave space for it.

### Target

* Import it with Textures, use good physic shape, midium is good, we need to collide
* use LOD for all like above to see it from far
* Remove basic Texture, make it glow, light, shininss, colors as you like
* Upload script ParachuteTarget.lsl into to it
* Copy it
* Keep it on the groung

 ### Pin

* Remove basic Texture, make it glow, light, shininss as you like
* Phantom = True
* Make theat small sequare as transparent, it is for balance
* Upload script ParachutePin.lsl into to it
* Take it
* Copy it into you Parachute bag

## Animations

Import it, SkyDiving and Steering

* Priority = 3
* Loop = True
* Upload into parachute root (bag)

# Resource

https://www.101soundboards.com/sounds/27005592-parachute-opening-2-options-cord-pull-skydive-parasend-parashoot-at-2create
