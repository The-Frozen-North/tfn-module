#include "nwnx_creature"

void main()
{
    object oSling = CreateItemOnObject("nw_wbwsl001", OBJECT_SELF);
    SetDroppableFlag(oSling, FALSE);
    SetPickpocketableFlag(oSling, FALSE);
    NWNX_Creature_RunEquip(OBJECT_SELF, oSling, INVENTORY_SLOT_RIGHTHAND);

    object oBullets = CreateItemOnObject("nw_wambu001", OBJECT_SELF, d2(2));
    SetDroppableFlag(oBullets, FALSE);
    SetPickpocketableFlag(oBullets, FALSE);
    AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_BLUDGEONING, IP_CONST_DAMAGEBONUS_1d4), oBullets);
    NWNX_Creature_RunEquip(OBJECT_SELF, oBullets, INVENTORY_SLOT_BULLETS);
}
