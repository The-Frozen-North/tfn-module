#include "inc_merchant"

void main()
{
    ApplyEWRAndInfiniteItems(OBJECT_SELF);

    CopyChest(OBJECT_SELF, "_MeleeCommonT1NonUnique", BASE_ITEM_DAGGER, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeCommonT2NonUnique", BASE_ITEM_DAGGER, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeCommonT3NonUnique", BASE_ITEM_DAGGER, "", TRUE);

    CopyChest(OBJECT_SELF, "_MeleeCommonT1NonUnique", BASE_ITEM_SHORTSWORD, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeCommonT2NonUnique", BASE_ITEM_SHORTSWORD, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeCommonT3NonUnique", BASE_ITEM_SHORTSWORD, "", TRUE);

    CopyChest(OBJECT_SELF, "_RangeCommonT1NonUnique", BASE_ITEM_SHORTBOW, "", TRUE);
    CopyChest(OBJECT_SELF, "_RangeCommonT3NonUnique", BASE_ITEM_SHORTBOW, "", TRUE);

    CopyChest(OBJECT_SELF, "_RangeUncommonT1NonUnique", BASE_ITEM_LIGHTCROSSBOW, "", TRUE);

    CopyChest(OBJECT_SELF, "_RangeRareT1NonUnique", BASE_ITEM_SLING, "", TRUE);
}
