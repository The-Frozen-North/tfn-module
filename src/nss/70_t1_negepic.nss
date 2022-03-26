//::///////////////////////////////////////////////
//:: Epic Negative Energy Trap
//:: 70_t1_negepic
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
35d6 negative to non-undead, fort save vs DC 30 or drain -2d2 levels,
undeads are healed for 20d6 hitpoints
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch 1.70
//:: Created On: 03-04-2011
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

    // Undead are healed by Negative Energy.
    if(spellsIsRacialType(oTarget, RACIAL_TYPE_UNDEAD))
    {

        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(d6(20)), oTarget);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_HEALING_M), oTarget);
    }
    else
    {
        effect eNeg = SupernaturalEffect(EffectNegativeLevel(d2(2)));
        //Make a saving throw check
        if(!MySavingThrow(SAVING_THROW_FORT, oTarget, 30, SAVING_THROW_TYPE_TRAP))
        {
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eNeg, oTarget);
        }
        //Apply the VFX impact and effects
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d6(35), DAMAGE_TYPE_NEGATIVE), oTarget);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE), oTarget);
    }
}
