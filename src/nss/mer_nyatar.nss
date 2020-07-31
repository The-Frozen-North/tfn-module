#include "inc_merchant"

void main()
{
    ApplyEWRAndInfiniteItems(OBJECT_SELF);

    CopyChest(OBJECT_SELF, "_MeleeCommonT1NonUnique", BASE_ITEM_CLUB, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeCommonT2NonUnique", BASE_ITEM_CLUB, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeCommonT3NonUnique", BASE_ITEM_CLUB, "", TRUE);

    CopyChest(OBJECT_SELF, "_MeleeCommonT1NonUnique", BASE_ITEM_QUARTERSTAFF, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeCommonT2NonUnique", BASE_ITEM_QUARTERSTAFF, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeCommonT3NonUnique", BASE_ITEM_QUARTERSTAFF, "", TRUE);

    CopyChest(OBJECT_SELF, "_MeleeUncommonT1NonUnique", BASE_ITEM_SHORTSPEAR, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeUncommonT2NonUnique", BASE_ITEM_SHORTSPEAR, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeUncommonT3NonUnique", BASE_ITEM_SHORTSPEAR, "", TRUE);

    CopyChest(OBJECT_SELF, "_MeleeRareT1NonUnique", BASE_ITEM_SCIMITAR, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeRareT2NonUnique", BASE_ITEM_SCIMITAR, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeRareT3NonUnique", BASE_ITEM_SCIMITAR, "", TRUE);

    CopyChest(OBJECT_SELF, "_MeleeRareT1NonUnique", BASE_ITEM_SICKLE, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeRareT2NonUnique", BASE_ITEM_SICKLE, "", TRUE);
    CopyChest(OBJECT_SELF, "_MeleeRareT3NonUnique", BASE_ITEM_SICKLE, "", TRUE);

    CopyChest(OBJECT_SELF, "_ArmorCommonT1NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ArmorCommonT2NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ArmorCommonT3NonUnique", 256, "", TRUE);

    CopyChest(OBJECT_SELF, "_ArmorUncommonT1NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ArmorUncommonT2NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ArmorUncommonT3NonUnique", 256, "", TRUE);

    CopyChest(OBJECT_SELF, "_ScrollsT1", 256, "Druid", TRUE);
    CopyChest(OBJECT_SELF, "_ScrollsT2", 256, "Druid", TRUE);
    CopyChest(OBJECT_SELF, "_ScrollsT3", 256, "Druid", TRUE);
}
