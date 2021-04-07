//::///////////////////////////////////////////////
//:: Adjustable Negative Trap
//:: 70_t1_negadjst
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
Adjustable single target negative trap. Fort save vs adjustable draining.
Note: undeads heals by a 50% intented damage instead.

This trap can be adjusted by builder via variables on trap trigger. If you do not
set all required variables, the trap might not have work as intended, see detailed
variables list below (may differ per trap type)

--------------------------------------------------
|  Name     | Type | Value
--------------------------------------------------
| DC        | int  | desired DC to avoid draining, if unset, save won't be possible!
| Drain     | int  | 1: strength, 2: dexterity, 3: constitution, 4: intelligence, 5: wisdom, 6: charisma, 10: level drain
| DrainNum  | int  | how many ability points or levels will be drained
|           |      | note: if either Drain or DrainNum won't be set, draining effect will be omitted!
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
#include "nw_i0_spells"

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
    int nDrain = GetLocalInt(OBJECT_SELF,"Drain");
    int nDrainNum = GetLocalInt(OBJECT_SELF,"DrainNum");
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
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(nDamage/2), oTarget);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_HEALING_M), oTarget);
        }
        else
        {
            //Apply Negative Damage
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_NEGATIVE), oTarget);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE), oTarget);
        }
    }
    if(nDrain > 0 && nDrainNum > 0 && (nDC < 1 || !MySavingThrow(SAVING_THROW_FORT, oTarget, nDC, SAVING_THROW_TYPE_TRAP)))
    {
        effect eNeg = nDrain == 10 ? EffectNegativeLevel(nDrainNum) : EffectAbilityDecrease(nDrain-1,nDrainNum);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(eNeg), oTarget);
    }
}
