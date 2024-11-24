#include "inc_itemevent"
#include "nwnx_damage"

void main()
{
    string sEvent = GetCurrentItemEventType();
    object oItem = GetCurrentItemEventItem();
    //SendDebugMessage(sEvent);
    if (sEvent == ITEM_EVENT_EQUIP)
    {
        ItemEventSubscribe(ITEM_EVENT_WEARER_DAMAGED);
        //effect eAdd = EffectAbilityIncrease(ABILITY_DEXTERITY, 5);
        //eAdd = NWNX_Effect_SetEffectCreator(eAdd, oItem);
        //ApplyEffectToObject(DURATION_TYPE_EQUIPPED, eAdd, GetItemPossessor(oItem));
    }
    else if (sEvent == ITEM_EVENT_UNEQUIP)
    {
        RemoveAllTaggedEffects(GetItemPossessor(oItem), GetCurrentItemEventScript());
    }
    else if (sEvent == ITEM_EVENT_WEARER_DAMAGED)
    {
        object oOwner = GetItemPossessor(oItem);
        struct NWNX_Damage_DamageEventData damageData = NWNX_Damage_GetDamageEventData();
        int nDamageType = -1;
        int nHighestDamage = 0;
        if (damageData.iBludgeoning > nHighestDamage)
        {
            nHighestDamage = damageData.iBludgeoning;
            nDamageType = DAMAGE_TYPE_BLUDGEONING;
        }
        if (damageData.iSlash > nHighestDamage)
        {
            nHighestDamage = damageData.iSlash;
            nDamageType = DAMAGE_TYPE_SLASHING;
        }
        if (damageData.iPierce > nHighestDamage)
        {
            nHighestDamage = damageData.iPierce;
            nDamageType = DAMAGE_TYPE_PIERCING;
        }
        if (damageData.iBase > nHighestDamage)
        {
            nHighestDamage = damageData.iBase;
            nDamageType = GetDamageTypeOfLastUsedWeapon(damageData.oDamager);
        }
        if (nDamageType >= 0)
        {
            RemoveAllTaggedEffects(oOwner, GetCurrentItemEventScript());
            effect eNew = SupernaturalEffect(EffectDamageResistance(nDamageType, 1));
            SetEffectCreator(eNew, oItem);
            eNew = TagEffect(eNew, GetCurrentItemEventScript());
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eNew, oOwner, 60.0f);
        }
    }
    else if (sEvent == ITEM_EVENT_CUSTOM_PROPERTIES)
    {
        ItemEventAddCustomPropertyText("Damage Resistance: 1/- against the last physical damage type");
        //ItemEventAddCustomPropertyText("Test property 1. You're in " + GetName(GetArea(GetItemPossessor(oItem))));
        //ItemEventAddCustomPropertyText("Test property 2, which contains a new\nline. I want to see what it looks like.");
    }
}