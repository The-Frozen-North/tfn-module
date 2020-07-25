#include "nw_i0_spells"
/*
Patch 1.71

- fixed knockdown duration (was instant)
- removed some redundant code
*/

void main()
{
    object oTarget = GetSpellTargetObject();
    effect eImpact = EffectVisualEffect(VFX_IMP_BIGBYS_FORCEFUL_HAND);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oTarget);
    int nDamage = Random(30) + 30;
    //ActionCastFakeSpellAtObject(SPELL_BIGBYS_FORCEFUL_HAND, oTarget);
    if (!MySavingThrow(SAVING_THROW_REFLEX, oTarget, 32, SAVING_THROW_TYPE_NONE))
    {
        effect eKnock = EffectKnockdown();
        int nDur = d6(1) + 1;
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnock, oTarget, RoundsToSeconds(nDur));
    }
    else // half damage and no knockdown
    {
        nDamage /= 2;
    }
    effect eDamage = EffectDamage(nDamage, DAMAGE_TYPE_BLUDGEONING);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oTarget);
}
