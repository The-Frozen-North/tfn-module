#include "x2_inc_spellhook"
#include "inc_itemevent"

void main()
{
    if (GetCurrentItemEventType() == ITEM_EVENT_ACTIVATED)
    {
        // Spellhook sets the vars for dispel-on-unequip
        if (!X2PreSpellCastCode())
        {
            return;
        }
        effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
        eDur = EffectLinkEffects(eDur, EffectVisualEffect(VFX_DUR_GHOSTLY_VISAGE));
        eDur = EffectLinkEffects(eDur, EffectDamageReduction(10, DAMAGE_POWER_PLUS_ONE));
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, OBJECT_SELF, 30.0);
    }
}
