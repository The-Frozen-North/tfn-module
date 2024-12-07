#include "inc_loot"

void main()
{
    int nItems = d10(5);
    int iStore;
    for (iStore = 0; iStore < nItems; iStore++)
    {
        SelectLootItemFromACREqualLootTypeOdds(OBJECT_SELF, 10, LOOT_TYPE_ANY);
    }

    int i;
    if (d20() == 1)
    {
        SelectLootItemFixedTier(OBJECT_SELF, 5, LOOT_TYPE_ARMOR, 0);
    }
    if (d20() == 1)
    {
        SelectLootItemFixedTier(OBJECT_SELF, 5, LOOT_TYPE_WEAPON_MELEE, 0);
    }
    if (d20() == 1)
    {
        SelectLootItemFixedTier(OBJECT_SELF, 5, LOOT_TYPE_APPAREL, 0);
    }

    if (d10() == 1)
    {
        SelectLootItemFixedTier(OBJECT_SELF, 4, LOOT_TYPE_ARMOR, 0);
    }
    if (d10() == 1)
    {
        SelectLootItemFixedTier(OBJECT_SELF, 4, LOOT_TYPE_WEAPON_MELEE, 0);
    }
    if (d10() == 1)
    {
        SelectLootItemFixedTier(OBJECT_SELF, 4, LOOT_TYPE_APPAREL, 0);
    }


    SetEventScript(OBJECT_SELF, EVENT_SCRIPT_STORE_ON_OPEN, "");
}
