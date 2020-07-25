#include "1_inc_merchant"

void main()
{
    ApplyEWRAndInfiniteItems(OBJECT_SELF);

    CopyChest(OBJECT_SELF, "_MeleeCommonT1NonUnique", BASE_ITEM_LIGHTMACE, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeCommonT2NonUnique", BASE_ITEM_LIGHTMACE, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeCommonT3NonUnique", BASE_ITEM_LIGHTMACE, "", TRUE);

    CopyChest(OBJECT_SELF, "_MeleeCommonT1NonUnique", BASE_ITEM_QUARTERSTAFF, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeCommonT2NonUnique", BASE_ITEM_QUARTERSTAFF, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeCommonT3NonUnique", BASE_ITEM_QUARTERSTAFF, "", TRUE);

    CopyChest(OBJECT_SELF, "_MeleeUncommonT1NonUnique", BASE_ITEM_MORNINGSTAR, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeUncommonT2NonUnique", BASE_ITEM_MORNINGSTAR, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeUncommonT3NonUnique", BASE_ITEM_MORNINGSTAR, "", TRUE);

    CopyChest(OBJECT_SELF, "_RangeRareT1NonUnique", BASE_ITEM_SLING, "", TRUE);

    CopyChest(OBJECT_SELF, "_ArmorCommonT1NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ArmorUncommonT1NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ArmorRareT1NonUnique", 256, "", TRUE);

    CopyChest(OBJECT_SELF, "_ScrollsT1", 256, "Cleric", TRUE);
    CopyChest(OBJECT_SELF, "_ScrollsT2", 256, "Cleric", TRUE);
    CopyChest(OBJECT_SELF, "_ScrollsT3", 256, "Cleric", TRUE);
}
