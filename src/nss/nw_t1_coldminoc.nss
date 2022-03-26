//::///////////////////////////////////////////////
//:: Minor Frost Trap
//:: NW_T1_ColdMinC
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Strikes the entering object with a blast of
    cold for 2d4 damage. Fortitude save to avoid
    being paralyzed for 1 round.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 16th , 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- fixed impact VFX, was fire
*/

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
    effect eDam = EffectDamage(d4(2), DAMAGE_TYPE_COLD);
    effect eParal = EffectParalyze();
    effect eVis = EffectVisualEffect(VFX_IMP_FROST_S);
    effect eFreeze = EffectVisualEffect(VFX_DUR_BLUR);
    effect eLink = EffectLinkEffects(eParal, eFreeze);

    if(!MySavingThrow(SAVING_THROW_FORT,oTarget, 12, SAVING_THROW_TYPE_TRAP))
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(1));
    }

    ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
}
