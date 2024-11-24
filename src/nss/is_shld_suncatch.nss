#include "x2_inc_itemprop"
#include "x0_i0_spells"
#include "inc_itemevent"

void main()
{
    if (GetCurrentItemEventType() == ITEM_EVENT_ACTIVATED)
    {
        if (Random(100) < 15)
        {
            object oTarget = GetSpellTargetObject();
            object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTarget);
            if (!GetIsObjectValid(oWeapon) || IPGetIsMeleeWeapon(oWeapon))
            {
                int nRoll = d4(1);
                int nDmg = GetSavingThrowAdjustedDamage(nRoll, oTarget, 14, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_FIRE);
                if (nDmg > 0)
                {
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_FLAME_S), oTarget);
                    DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDmg, DAMAGE_TYPE_FIRE), oTarget));
                    if (nRoll == nDmg)
                    {
                        effect eLink = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
                        eLink = EffectLinkEffects(eLink, EffectBlindness());
                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, 12.0);
                    }
                }
            }
        }
    }
}
