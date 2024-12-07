#include "inc_loot"

void main()
{
    object oItem = SelectLootItemFixedTier(OBJECT_SELF, 2, LOOT_TYPE_APPAREL, 0);
    SetIdentified(oItem, TRUE);
}
