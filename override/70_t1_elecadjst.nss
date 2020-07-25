//::///////////////////////////////////////////////
//:: Adjustable Electrical Trap
//:: 70_t1_elecadjst
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
Adjustable aoe electrical trap. Reflex save versus damage, evasion is applicable.
After struck original target, trap will affect also number of secondary targets.

This trap can be adjusted by builder via variables on trap trigger. If you do not
set all required variables, the trap might not have work as intended, see detailed
variables list below (may differ per trap type)

--------------------------------------------------
|  Name     | Type | Value
--------------------------------------------------
| DC        | int  | desired DC to avoid damage, if unset, save won't be possible!
| DamageMin | int  | minimal damage done to target(s), if unset, 1 will be used,
|                  | if greater than maximum, damage will use minimum and will be fixed
| DamageMax | int  | maximal damage done to target(s), if unset, minimum will be used
|                  | note: if both DamageMin and DamageMax won't be set, no damage will be done!
| Secondary | int  | how many secondary targets will be affected, if unset, then noone
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch 1.70
//:: Created On: 03-04-2011
//:://////////////////////////////////////////////

#include "70_inc_spells"

void main()
{
    //1.72: fix for bug where traps are being triggered where they really aren't
    if(GetObjectType(OBJECT_SELF) == OBJECT_TYPE_TRIGGER && !GetIsInSubArea(GetEnteringObject()))
    {
        return;
    }
    //Declare major variables
    object oTarget = GetEnteringObject();
    location lTarget = GetLocation(oTarget);
    effect eDam, eLightning = EffectBeam(VFX_BEAM_LIGHTNING, oTarget, BODY_NODE_CHEST);
    effect eVis = EffectVisualEffect(VFX_IMP_LIGHTNING_S);
    int nDC = GetLocalInt(OBJECT_SELF,"DC");
    int minDamage = GetLocalInt(OBJECT_SELF,"DamageMin");
    int maxDamage = GetLocalInt(OBJECT_SELF,"DamageMax");
    if(minDamage+maxDamage < 1)
    {
        return;//wrong setting, do not waste the resources
    }
    int numSecondary = GetLocalInt(OBJECT_SELF,"Secondary");
    int nDamage;
    if(minDamage >= maxDamage)
    {
        nDamage = minDamage;//max unset or equal or lower than min, min will be used
    }
    else
    {
        if(minDamage < 1)//if min damage is not set
        {
            minDamage = 1;//lets set trap to do at least 1 damage
        }
        nDamage = minDamage+Random(maxDamage-minDamage+1);//get random value between min and max
    }
    if(nDC > 0)
    {
        nDamage = GetSavingThrowAdjustedDamage(nDamage, oTarget, nDC, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_TRAP);
    }
    if(nDamage > 0)
    {
        eDam = EffectDamage(nDamage, DAMAGE_TYPE_ELECTRICAL);//delay there is in order to show beam in case that damage is deadly for target and his corpse explodes
        DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
    }
    if(numSecondary < 1)
    {
        return;//no secondary targets set, end here
    }
    //secondary targets
    int nCount;
    object o2ndTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, lTarget);
    while (GetIsObjectValid(o2ndTarget) && nCount < numSecondary)
    {
        //check to see that the original target is not hit again.
        if(o2ndTarget != oTarget && !GetIsReactionTypeFriendly(oTarget))
        {
            if(minDamage >= maxDamage)
            {
                nDamage = minDamage;//max unset or equal or lower than min, min will be used
            }
            else
            {
                if(minDamage < 1)//if min damage is not set
                {
                    minDamage = 1;//lets set trap to do at least 1 damage
                }
                nDamage = minDamage+Random(maxDamage-minDamage+1);//get random value between min and max
            }
            if(nDC > 0)
            {
                nDamage = GetSavingThrowAdjustedDamage(nDamage, o2ndTarget, nDC, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_TRAP);
            }
            if(nDamage > 0)
            {
                eDam = EffectDamage(nDamage, DAMAGE_TYPE_ELECTRICAL);//delay there is in order to show beam in case that damage is deadly for target and his corpse explodes
                DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, o2ndTarget));
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, o2ndTarget);
            }

            //Connect the lightning stream from one target to another.
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLightning, o2ndTarget, 0.75);
            //Set the last target as the new start for the lightning stream
            eLightning = EffectBeam(VFX_BEAM_LIGHTNING, o2ndTarget, BODY_NODE_CHEST);
            //Increment the count
            nCount++;
        }
        //Get next target in the shape.
        o2ndTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, lTarget);
    }
}
