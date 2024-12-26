#include "inc_itemevent"

// Celestial Fury (katana)
// 10% chance for 5d6 lightning damage
void main()
{
    if (GetCurrentItemEventType() == ITEM_EVENT_ACTIVATED)
    {
        object oTarget = GetSpellTargetObject();
        if (GetIsObjectValid(oTarget))
        {
            if (Random(100) < 10)
            {
                effect eDmg = EffectLinkEffects(
                    EffectVisualEffect(VFX_IMP_LIGHTNING_M),
                    EffectDamage(d6(5), DAMAGE_TYPE_ELECTRICAL)
                );
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eDmg, oTarget);
            }
        }
    }
}