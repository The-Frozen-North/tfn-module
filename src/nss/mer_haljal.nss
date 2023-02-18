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
        GenerateTierItem(0, 0, OBJECT_SELF, "Melee", 4, TRUE);
    }

    nMax = d2(2);
    for (i = 0; i < nMax; i++)
    {
        GenerateTierItem(0, 0, OBJECT_SELF, "Armor", 4, TRUE);
    }
    
    nMax = d4(3);
    for (i = 0; i < nMax; i++)
    {
        GenerateTierItem(0, 0, OBJECT_SELF, "Armor", 3, TRUE);
    }

    nMax = d4(3);
    for (i = 0; i < nMax; i++)
    {
        GenerateTierItem(0, 0, OBJECT_SELF, "Melee", 3, TRUE);
    }

    for (i = 0; i < 4; i++)
    {
        if (Random(100) < STORE_RANDOM_T5_CHANCE)
        {
            GenerateTierItem(0, 0, OBJECT_SELF, "Armor", 5, TRUE);
        }
        if (Random(100) < STORE_RANDOM_T5_CHANCE)
        {
            GenerateTierItem(0, 0, OBJECT_SELF, "Melee", 5, TRUE);
        }
    }
    
    // PAWNSHOP portion
    int bNonUnique;

    int nItems = d20(10);
    for (i = 0; i < nItems; i++)
    {
        GenerateTierItem(6, 6, OBJECT_SELF);
    }

    nMax = d4(6);
    for (i = 0; i < nMax; i++)
    {
        bNonUnique = Random(100) >= PAWNSHOP_CHANCE_TO_ALLOW_UNIQUE;
        GenerateTierItem(0, 0, OBJECT_SELF, "", 3, bNonUnique);
    }

    nMax = d2(3);
    for (i = 0; i < nMax; i++)
    {
        bNonUnique = Random(100) >= PAWNSHOP_CHANCE_TO_ALLOW_UNIQUE;
        GenerateTierItem(0, 0, OBJECT_SELF, "", 4, bNonUnique);
    }

    for (i = 0; i < 5; i++)
    {
        if (Random(100) < STORE_RANDOM_T5_CHANCE)
        {
            bNonUnique = Random(100) >= PAWNSHOP_CHANCE_TO_ALLOW_UNIQUE;
            GenerateTierItem(0, 0, OBJECT_SELF, "", 5, bNonUnique);
        }
    }
}
