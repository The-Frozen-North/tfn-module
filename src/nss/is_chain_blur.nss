#include "x2_inc_spellhook"

void main()
{
    // Spellhook sets the vars for dispel-on-unequip
    if (!X2PreSpellCastCode())
    {
        return;
    }
    effect eDisplace = EffectConcealment(20);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    eDur = EffectLinkEffects(eDur, EffectVisualEffect(VFX_DUR_BLUR));
    eDisplace = EffectLinkEffects(eDisplace, eDur);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDisplace, OBJECT_SELF, 300.0);
}
