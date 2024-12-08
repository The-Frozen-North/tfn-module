#include "inc_itemevent"

void main()
{
    if (GetCurrentItemEventType() == ITEM_EVENT_ACTIVATED)
    {
        if (GetCurrentHitPoints() * 2 < GetMaxHitPoints())
        {
            int bFound = 0;
            effect eTest = GetFirstEffect(OBJECT_SELF);
            while (GetIsEffectValid(eTest))
            {
                if (GetEffectTag(eTest) == "shld_bguard")
                {
                    bFound = 1;
                    break;
                }
                eTest = GetNextEffect(OBJECT_SELF);
            }
            if (!bFound)
            {
                effect eLink = EffectAbilityIncrease(ABILITY_STRENGTH, 2);
                eLink = EffectLinkEffects(eLink, EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE));
                eLink = TagEffect(eLink, "shld_bguard");
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, OBJECT_SELF, 6.0);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_STARBURST_RED), OBJECT_SELF);
            }
        }
    }
}
