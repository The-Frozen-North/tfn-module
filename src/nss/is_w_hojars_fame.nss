#include "inc_itemevent"

// Hojar's Fame Handaxe
// 25% chance for 1d8 fire damage
void main()
{
    if (GetCurrentItemEventType() == ITEM_EVENT_ACTIVATED)
    {
        object oTarget = GetSpellTargetObject();
        if (GetIsObjectValid(oTarget))
        {
            if (Random(100) < 25)
            {
                effect eDmg = EffectLinkEffects(
                    EffectVisualEffect(VFX_IMP_FLAME_S),
                    EffectDamage(d8(), DAMAGE_TYPE_FIRE)
                );
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eDmg, oTarget);
            }
        }
    }
}
