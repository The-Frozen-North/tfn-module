#include "inc_itemevent"
#include "nwnx_damage"
#include "x0_i0_match"

void main()
{
    string sEvent = GetCurrentItemEventType();
    object oItem = GetCurrentItemEventItem();
    if (sEvent == ITEM_EVENT_EQUIP)
    {
        ItemEventSubscribe(ITEM_EVENT_WEARER_ATTACKS);
    }
    else if (sEvent == ITEM_EVENT_WEARER_ATTACKS)
    {
        if (GetItemEventWeaponUsedForAttack() == oItem)
        {
            struct NWNX_Damage_AttackEventData data = NWNX_Damage_GetAttackEventData();
            if (data.iAttackResult == 1 || data.iAttackResult == 3 || data.iAttackResult == 5 || data.iAttackResult == 7)
            {
                if (GetRacialType(data.oTarget) != RACIAL_TYPE_UNDEAD)
                {
                    if (GetHasEffect(EFFECT_TYPE_DISEASE, data.oTarget))
                    {
                        int n = GetItemEventCritMultiplier();
                        // damage fields start at -1 if not present
                        if (data.iNegative < 0)
                            data.iNegative = 0;
                        while (n > 0)
                        {
                            data.iNegative += d4();
                            n--;
                        }
                        NWNX_Damage_SetAttackEventData(data);
                        IPSafeAddItemProperty(oItem, ItemPropertyVisualEffect(ITEM_VISUAL_EVIL), 6.0f);
                    }
                }
            }
        }
    }
    else if (sEvent == ITEM_EVENT_CUSTOM_PROPERTIES)
    {
        ItemEventAddCustomPropertyText("Damage Bonus vs Diseased: Negative Energy 1d4 Damage");
    }
}