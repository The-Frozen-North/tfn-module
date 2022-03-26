//::///////////////////////////////////////////////
//:: Adjustable Acid Splash Trap
//:: 70_t1_splshadjst
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
Adjustable single target acid trap. Reflex save versus damage, evasion is applicable.

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
    int nDC = GetLocalInt(OBJECT_SELF,"DC");
    int minDamage = GetLocalInt(OBJECT_SELF,"DamageMin");
    int maxDamage = GetLocalInt(OBJECT_SELF,"DamageMax");
    if(minDamage+maxDamage < 1)
    {
        return;//wrong setting, do not waste the resources
    }
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
    //apply evasion
    nDamage = GetSavingThrowAdjustedDamage(nDamage, oTarget, nDC, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_TRAP, OBJECT_SELF);

    if(nDamage > 0)
    {
         ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_ACID), oTarget);
    }

    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_ACID_S), oTarget);
}
