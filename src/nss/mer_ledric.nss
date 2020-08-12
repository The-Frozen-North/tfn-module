#include "inc_merchant"

void main()
{
    ApplyEWRAndInfiniteItems(OBJECT_SELF);

    CopyChest(OBJECT_SELF, "_MeleeCommonT1NonUnique", BASE_ITEM_QUARTERSTAFF, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeCommonT2NonUnique", BASE_ITEM_QUARTERSTAFF, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeCommonT3NonUnique", BASE_ITEM_QUARTERSTAFF, "", TRUE);

    CopyChest(OBJECT_SELF, "_MeleeRareT1NonUnique", BASE_ITEM_KAMA, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeRareT2NonUnique", BASE_ITEM_KAMA, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeRareT3NonUnique", BASE_ITEM_KAMA, "", TRUE);

    CopyChest(OBJECT_SELF, "_RangeRareT1NonUnique", BASE_ITEM_SHURIKEN, "", TRUE);
    CopyChest(OBJECT_SELF, "_RangeRareT2NonUnique", BASE_ITEM_SHURIKEN, "", TRUE);
    CopyChest(OBJECT_SELF, "_RangeRareT3NonUnique", BASE_ITEM_SHURIKEN, "", TRUE);
}
