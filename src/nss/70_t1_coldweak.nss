//::///////////////////////////////////////////////
//:: Weak Frost Trap
//:: 70_t1_coldweak
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
1d4 cold, fort save vs DC 8 or paralysed for 1 round
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch 1.70
//:: Created On: 03-04-2011
//:://////////////////////////////////////////////

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
    effect eLink = EffectLinkEffects(EffectParalyze(), EffectVisualEffect(VFX_DUR_BLUR));

    if(!MySavingThrow(SAVING_THROW_FORT, oTarget, 8, SAVING_THROW_TYPE_TRAP))
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(1));
    }

    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d4(1), DAMAGE_TYPE_COLD), oTarget);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_FROST_S), oTarget);
}
