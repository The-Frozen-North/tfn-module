#include "nw_i0_spells"

// Spectre claw onhit: Level drains for 12h, and heals the spectre a bit
// per HD of the victim

void main()
{
    object oTarget = GetSpellTargetObject();
    int nSpellID = GetSpellId();

    if (!MySavingThrow(SAVING_THROW_FORT, oTarget, 14, SAVING_THROW_TYPE_NEGATIVE))
    {
        effect eVis = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);
        effect eDrain = EffectNegativeLevel(2);
        effect eLink = EffectLinkEffects(EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE), eDrain);
        int nHD = GetHitDice(oTarget);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, HoursToSeconds(12));
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(nHD), OBJECT_SELF);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY), OBJECT_SELF);
    }

}
