#include "inc_merchant"
#include "inc_loot"

void main()
{
    CopyChest(OBJECT_SELF, "_ApparelCommonT1", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ApparelCommonT2", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ApparelCommonT3", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ApparelUncommonT1", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ApparelUncommonT2", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ApparelUncommonT3", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ApparelRareT1", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ApparelRareT2", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ApparelRareT3", 256, "", TRUE);

    int i;
    int nMax = d3(3);
    for (i = 0; i < nMax; i++)
    {
        SelectLootItemFixedTier(OBJECT_SELF, 4, LOOT_TYPE_APPAREL, 100);
    }

    for (i = 0; i < 4; i++)
    {
        if (Random(100) < STORE_RANDOM_T5_CHANCE)
        {
            SelectLootItemFixedTier(OBJECT_SELF, 5, LOOT_TYPE_APPAREL, 100);
        }
    }

    // She stocks all these items already?
    /*
    nMax = d4(3);
    for (i = 0; i < nMax; i++)
    {
        SelectLootItemFixedTier(OBJECT_SELF, 3, LOOT_TYPE_APPAREL, 100);
    }

    nMax = d6(3);
    for (i = 0; i < nMax; i++)
    {
        SelectLootItemFixedTier(OBJECT_SELF, 2, LOOT_TYPE_APPAREL, 100);
    }
    */
}
