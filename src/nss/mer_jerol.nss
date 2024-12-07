#include "inc_merchant"
#include "inc_loot"

void main()
{
    ApplyEWRAndInfiniteItems(OBJECT_SELF);

    CopyChest(OBJECT_SELF, "_RangeCommonT1NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_RangeUncommonT1NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_RangeRareT1NonUnique", 256, "", TRUE);

    CopyChest(OBJECT_SELF, "_RangeCommonT2NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_RangeUncommonT2NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_RangeRareT2NonUnique", 256, "", TRUE);

    CopyChest(OBJECT_SELF, "_RangeCommonT3NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_RangeUncommonT3NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_RangeRareT3NonUnique", 256, "", TRUE);

    int i;
    int nMax = d2(2);
    for (i = 0; i < nMax; i++)
    {
        SelectLootItemFixedTier(OBJECT_SELF, 5, LOOT_TYPE_WEAPON_RANGE, 0);
    }

    for (i = 0; i < 3; i++)
    {
        if (Random(100) < STORE_RANDOM_T5_CHANCE)
        {
            SelectLootItemFixedTier(OBJECT_SELF, 5, LOOT_TYPE_WEAPON_RANGE, 0);
        }
    }

    // These are all copied anyway
    /*
    nMax = d4(3);
    for (i = 0; i < nMax; i++)
    {
        SelectLootItemFixedTier(OBJECT_SELF, 3, LOOT_TYPE_WEAPON_RANGE, 0);
    }

    nMax = d6(4);
    for (i = 0; i < nMax; i++)
    {
        SelectLootItemFixedTier(OBJECT_SELF, 2, LOOT_TYPE_WEAPON_RANGE, 0);
    }
    */
}
