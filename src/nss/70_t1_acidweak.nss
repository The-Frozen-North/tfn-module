//::///////////////////////////////////////////////
//:: Weak Acid Blob
//:: 70_t1_acidweak
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
1d6 acid, reflex save vs DC 9 or paralysed for 1 round
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
    effect eLink = EffectLinkEffects(EffectParalyze(), EffectVisualEffect(VFX_DUR_PARALYZED));

    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d6(1), DAMAGE_TYPE_ACID), oTarget);
    //Make Reflex Save
    if(!MySavingThrow(SAVING_THROW_REFLEX, oTarget, 9, SAVING_THROW_TYPE_TRAP))
    {
        //Apply Hold
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(1));
    }

    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_ACID_S), oTarget);
}
