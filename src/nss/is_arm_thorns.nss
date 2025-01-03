#include "x2_inc_itemprop"
#include "inc_itemevent"

void main()
{
    if (GetCurrentItemEventType() == ITEM_EVENT_ACTIVATED)
    {
        object oTarget = GetSpellTargetObject();
        object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTarget);
        if (!GetIsObjectValid(oWeapon) || IPGetIsMeleeWeapon(oWeapon))
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_FLAME_S), oTarget);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d4(), DAMAGE_TYPE_FIRE), oTarget);
        }
    }
}
