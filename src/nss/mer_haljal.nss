#include "inc_merchant"
#include "inc_loot"

void main()
{
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
    int nMax = d3(2);
    for (i = 0; i < nMax; i++)
    {
        GenerateTierItem(0, 0, OBJECT_SELF, "Melee", 4, TRUE);
    }

    nMax = d3(2);
    for (i = 0; i < nMax; i++)
    {
        GenerateTierItem(0, 0, OBJECT_SELF, "Armor", 4, TRUE);
    }

    nMax = d4(3);
    for (i = 0; i < nMax; i++)
    {
        GenerateTierItem(0, 0, OBJECT_SELF, "Armor", 2, TRUE);
    }

    nMax = d4(3);
    for (i = 0; i < nMax; i++)
    {
        GenerateTierItem(0, 0, OBJECT_SELF, "Melee", 2, TRUE);
    }


    nMax = d2();
    for (i = 0; i < nMax; i++)
    {
        GenerateTierItem(0, 0, OBJECT_SELF, "Armor", 5, TRUE);
    }

    nMax = d2();
    for (i = 0; i < nMax; i++)
    {
        GenerateTierItem(0, 0, OBJECT_SELF, "Melee", 5, TRUE);
    }

    int nItems = d6(10);
    for (i = 0; i < nItems; i++)
    {
        GenerateTierItem(4, 10, OBJECT_SELF);
    }

    nMax = d3(4);
    for (i = 0; i < nMax; i++)
    {
        GenerateTierItem(0, 0, OBJECT_SELF, "", 3, TRUE);
    }

    nMax = d3(3);
    for (i = 0; i < nMax; i++)
    {
        GenerateTierItem(0, 0, OBJECT_SELF, "", 4, TRUE);
    }

    nMax = d2(2);
    for (i = 0; i < nMax; i++)
    {
        GenerateTierItem(0, 0, OBJECT_SELF, "", 5, TRUE);
    }
}
