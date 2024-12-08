#include "inc_loot"

void main()
{
    object oItem = SelectLootItemFixedTier(OBJECT_SELF, 4, LOOT_TYPE_WEAPON_MELEE, 0);
    SetIdentified(oItem, TRUE);
}
