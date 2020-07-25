#include "1_inc_merchant"

void main()
{
    ApplyEWRAndInfiniteItems(OBJECT_SELF);

    CopyChest(OBJECT_SELF, "_RangeCommonT1NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_RangeUncommonT1NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_RangeRareT1NonUnique", 256, "", TRUE);

    CopyChest(OBJECT_SELF, "_MeleeCommonT1NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeUncommonT1NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeRareT1NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeCommonT2NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeUncommonT2NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeCommonT3NonUnique", 256, "", TRUE);

    CopyChest(OBJECT_SELF, "_ArmorCommonT1NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ArmorUncommoT1NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ArmorRareT1NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ArmorCommonT2NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ArmorUncommonT2NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ArmorRareT2NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ArmorCommonT3NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ArmorUncommonT3NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ArmorRareT3NonUnique", 256, "", TRUE);
}
