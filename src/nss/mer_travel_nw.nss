#include "inc_loot"

void main()
{
    int nItems = d10(1);
    int iStore;
    for (iStore = 0; iStore < nItems; iStore++)
    {
        SelectLootItemFromACREqualLootTypeOdds(OBJECT_SELF, 10, LOOT_TYPE_ANY);
    }

    nItems = d10(2);
    for (iStore = 0; iStore < nItems; iStore++)
    {
        SelectLootItemFromACREqualLootTypeOdds(OBJECT_SELF, 8, LOOT_TYPE_ANY);
    }

    int i;
    if (Random(100) < 2)
    {
        SelectLootItemFixedTier(OBJECT_SELF, 5, LOOT_TYPE_ARMOR, 0);
    }
    if (Random(100) < 2)
    {
        SelectLootItemFixedTier(OBJECT_SELF, 5, LOOT_TYPE_WEAPON_MELEE, 0);
    }
    if (Random(100) < 2)
    {
        SelectLootItemFixedTier(OBJECT_SELF, 5, LOOT_TYPE_APPAREL, 0);
    }

    if (Random(100) < 4)
    {
        SelectLootItemFixedTier(OBJECT_SELF, 4, LOOT_TYPE_ARMOR, 0);
    }
    if (Random(100) < 4)
    {
        SelectLootItemFixedTier(OBJECT_SELF, 4, LOOT_TYPE_WEAPON_MELEE, 0);
    }
    if (Random(100) < 4)
    {
        SelectLootItemFixedTier(OBJECT_SELF, 4, LOOT_TYPE_APPAREL, 0);
    }


    SetEventScript(OBJECT_SELF, EVENT_SCRIPT_STORE_ON_OPEN, "");
}
