#include "inc_loot"

void main()
{
    object oItem = SelectLootItemFixedTier(OBJECT_SELF, 3, LOOT_TYPE_ARMOR, 0);
    SetIdentified(oItem, TRUE);
}
