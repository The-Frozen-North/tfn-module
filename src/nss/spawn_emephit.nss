#include "nwnx_creature"

void main()
{
    object oShuriken = CreateItemOnObject("nw_wthsh001", OBJECT_SELF, d2(2));
    SetDroppableFlag(oShuriken, FALSE);
    SetPickpocketableFlag(oShuriken, FALSE);
    AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_BLUDGEONING, IP_CONST_DAMAGEBONUS_1d4), oShuriken);
    AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyExtraRangeDamageType(IP_CONST_DAMAGETYPE_BLUDGEONING), oShuriken);
    NWNX_Creature_RunEquip(OBJECT_SELF, oShuriken, INVENTORY_SLOT_RIGHTHAND);
}
