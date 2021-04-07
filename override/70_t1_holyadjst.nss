//::///////////////////////////////////////////////
//:: Adjustable Holy Trap
//:: 70_t1_holyadjst
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
Adjustable single target holy trap. Just damage without save.
Note: undeads takes 50% more damage from this trap.

This trap can be adjusted by builder via variables on trap trigger. If you do not
set all required variables, the trap might not have work as intended, see detailed
variables list below (may differ per trap type)

--------------------------------------------------
|  Name     | Type | Value
--------------------------------------------------
| DamageMin | int  | minimal damage done to target(s), if unset, 1 will be used,
|                  | if greater than maximum, damage will use minimum and will be fixed
| DamageMax | int  | maximal damage done to target(s), if unset, minimum will be used
|                  | note: if both DamageMin and DamageMax won't be set, no damage will be done!
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch 1.70
//:: Created On: 11-11-2011
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
    int minDamage = GetLocalInt(OBJECT_SELF,"DamageMin");
    int maxDamage = GetLocalInt(OBJECT_SELF,"DamageMax");
    int nDamage;
    if(minDamage+maxDamage > 0)//if either min or max is set
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
        if(spellsIsRacialType(oTarget, RACIAL_TYPE_UNDEAD))//undeads should take more damage
        {
            nDamage+= nDamage/2;
        }
        //Apply Holy Damage
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_DIVINE), oTarget);
    }
    //Apply VFX Impact
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_SUNSTRIKE), oTarget);
}
