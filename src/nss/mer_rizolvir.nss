#include "inc_merchant"
#include "inc_loot"

void main()
{
    ApplyEWRAndInfiniteItems(OBJECT_SELF);

    CopyChest(OBJECT_SELF, "_RangeCommonT1NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_RangeCommonT2NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_RangeCommonT3NonUnique", 256, "", TRUE);
    //CopyChest(OBJECT_SELF, "_RangeCommonT4NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_RangeUncommonT2NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_RangeUncommonT3NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_RangeRareT2NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_RangeRareTTNonUnique", 256, "", TRUE);

    CopyChest(OBJECT_SELF, "_MeleeCommonT1NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeCommonT2NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeCommonT3NonUnique", 256, "", TRUE);
    //CopyChest(OBJECT_SELF, "_MeleeCommonT4NonUnique", 256, "", TRUE);

    CopyChest(OBJECT_SELF, "_MeleeUncommonT2NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeUncommonT3NonUnique", 256, "", TRUE);
    //CopyChest(OBJECT_SELF, "_MeleeUncommonT4NonUnique", 256, "", TRUE);

    CopyChest(OBJECT_SELF, "_MeleeRareT2NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeRareT3NonUnique", 256, "", TRUE);
    //CopyChest(OBJECT_SELF, "_MeleeRareT4NonUnique", 256, "", TRUE);

    int i;
    int nMax = d3(2);

    nMax = d4(3);
    for (i = 0; i < nMax; i++)
    {
        SelectLootItemFixedTier(OBJECT_SELF, 3, LOOT_TYPE_ARMOR, 0);
    }

    nMax = d4(3);
    for (i = 0; i < nMax; i++)
    {
        SelectLootItemFixedTier(OBJECT_SELF, 3, LOOT_TYPE_WEAPON_RANGE, 0);
    }
    
    nMax = d2(5);
    for (i = 0; i < nMax; i++)
    {
        SelectLootItemFixedTier(OBJECT_SELF, 4, LOOT_TYPE_ARMOR, 0);
    }

    nMax = d2(5);
    for (i = 0; i < nMax; i++)
    {
        SelectLootItemFixedTier(OBJECT_SELF, 4, LOOT_TYPE_WEAPON_MELEE, 0);
    }

    nMax = d2(3);
    for (i = 0; i < nMax; i++)
    {
        SelectLootItemFixedTier(OBJECT_SELF, 4, LOOT_TYPE_WEAPON_RANGE, 0);
    }


    for (i = 0; i < 7; i++)
    {
        if (Random(100) < STORE_RANDOM_T5_CHANCE)
        {
            SelectLootItemFixedTier(OBJECT_SELF, 5, LOOT_TYPE_ARMOR, 0);
        }
        if (Random(100) < STORE_RANDOM_T5_CHANCE)
        {
            SelectLootItemFixedTier(OBJECT_SELF, 5, LOOT_TYPE_WEAPON_MELEE, 0);
        }
        if (Random(100) < STORE_RANDOM_T5_CHANCE)
        {
            SelectLootItemFixedTier(OBJECT_SELF, 5, LOOT_TYPE_WEAPON_RANGE, 0);
        }
    }
}
