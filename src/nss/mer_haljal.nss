#include "inc_merchant"
#include "inc_loot"

void main()
{
    // BLACKSMITH portion
    ApplyEWRAndInfiniteItems(OBJECT_SELF);

    CopyChest(OBJECT_SELF, "_RangeCommonT1NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_RangeCommonT2NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_RangeUncommonT1NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_RangeRareT1NonUnique", 256, "", TRUE);

    CopyChest(OBJECT_SELF, "_MeleeCommonT1NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeCommonT2NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeCommonT3NonUnique", 256, "", TRUE);

    CopyChest(OBJECT_SELF, "_MeleeUncommonT1NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeUncommonT2NonUnique", 256, "", TRUE);

    CopyChest(OBJECT_SELF, "_MeleeRareT1NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeRareT2NonUnique", 256, "", TRUE);

    CopyChest(OBJECT_SELF, "_ArmorCommonT1NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ArmorUncommonT1NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ArmorRareT1NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ArmorCommonT2NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ArmorUncommonT2NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ArmorRareT2NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ArmorCommonT3NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ArmorUncommonT3NonUnique", 256, "", TRUE);

    int i;
    int nMax = d2(2);
    for (i = 0; i < nMax; i++)
    {
        SelectLootItemFixedTier(OBJECT_SELF, 4, LOOT_TYPE_WEAPON_MELEE, 0);
    }

    nMax = d2(2);
    for (i = 0; i < nMax; i++)
    {
        SelectLootItemFixedTier(OBJECT_SELF, 4, LOOT_TYPE_ARMOR, 0);
    }
    
    nMax = d4(3);
    for (i = 0; i < nMax; i++)
    {
        SelectLootItemFixedTier(OBJECT_SELF, 4, LOOT_TYPE_ARMOR, 0);
    }

    nMax = d4(3);
    for (i = 0; i < nMax; i++)
    {
        SelectLootItemFixedTier(OBJECT_SELF, 3, LOOT_TYPE_WEAPON_MELEE, 0);
    }

    for (i = 0; i < 4; i++)
    {
        if (Random(100) < STORE_RANDOM_T5_CHANCE)
        {
            SelectLootItemFixedTier(OBJECT_SELF, 5, LOOT_TYPE_ARMOR, 0);
        }
        if (Random(100) < STORE_RANDOM_T5_CHANCE)
        {
            SelectLootItemFixedTier(OBJECT_SELF, 5, LOOT_TYPE_WEAPON_MELEE, 0);
        }
    }
    
    // PAWNSHOP portion
    int bNonUnique;

    int nItems = d20(10);
    for (i = 0; i < nItems; i++)
    {
        SelectLootItemFromACREqualLootTypeOdds(OBJECT_SELF, 7, LOOT_TYPE_ANY);
    }

    nMax = d4(6);
    for (i = 0; i < nMax; i++)
    {
        SelectLootItemFixedTierEqualLootTypeOdds(OBJECT_SELF, 3, LOOT_TYPE_ANY, PAWNSHOP_CHANCE_TO_ALLOW_UNIQUE);
    }

    nMax = d2(3);
    for (i = 0; i < nMax; i++)
    {
        SelectLootItemFixedTierEqualLootTypeOdds(OBJECT_SELF, 4, LOOT_TYPE_ANY, PAWNSHOP_CHANCE_TO_ALLOW_UNIQUE);
    }

    for (i = 0; i < 5; i++)
    {
        if (Random(100) < STORE_RANDOM_T5_CHANCE)
        {
            SelectLootItemFixedTierEqualLootTypeOdds(OBJECT_SELF, 5, LOOT_TYPE_ANY, PAWNSHOP_CHANCE_TO_ALLOW_UNIQUE);
        }
    }
}
