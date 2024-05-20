# Parachute v2

Parashute mesh and OpenSIM/LSL script for skydriving, script is based on "Jeff Heaton" code and many others of modifications

I added Target and Pin where landed

## Inworld usage

Click double on arrow up for push turbo speed

## Customize

### Color

You can change color of each piece of top surface

### Texture

Select all face on top surface, change to texture you like

## Mesh License (CC BY-NC-SA 4.0)

# Scripts

Based on "Jeff Heaton" script with many modification from others and me, names mentioned in the scripts

From the book:
Scripting Recipes for Second Life
by Jeff Heaton (Encog Dod in SL)
ISBN: 160439000X
Copyright 2007 by Heaton Research, Inc.

This script may be freely copied and modified so long as this header remains unmodified.
For more information about this book visit the following web site:

http://www.heatonresearch.com/articles/series/22/

#### Parachute

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

#### HUD

* Import it with Textures, no need to select physic
* Upload script ParachuteHUD.lsl into it
* Upload textures, Parachute and Smoke
* Set Face 0  to Parachute texture, Face 1 to Smoke texture
* Attache it to Top Right, Edit it, move it to good corner we have text above leave space for it.

#### Target

* Import it with Textures, use good physic shape, midium is good, we need to collide
* use LOD for all like above to see it from far
* Remove basic Texture, make it glow, light, shininss, colors as you like
* Upload script ParachuteTarget.lsl into to it
* Copy it
* Keep it on the groung

#### Pin

* Remove basic Texture, make it glow, light, shininss as you like
* Phantom = True
* Make theat small sequare as transparent, it is for balance
* Upload script ParachutePin.lsl into to it
* Take it
* Copy it into you Parachute bag

You can remove/unlink lower surface if you want simple parachute

## Animation

Import it, SkyDiving and Steering

* Priority = 3
* Loop = True
* Upload into parachute root (bag)

## Resource

https://www.101soundboards.com/sounds/27005592-parachute-opening-2-options-cord-pull-skydive-parasend-parashoot-at-2create
