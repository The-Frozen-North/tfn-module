#include "1_inc_merchant"

void main()
{
    ApplyEWRAndInfiniteItems(OBJECT_SELF);

    CopyChest(OBJECT_SELF, "_ArmorRareT1", 256, "wizard", TRUE);
    CopyChest(OBJECT_SELF, "_ArmorRareT2", 256, "wizard", TRUE);

    CopyChest(OBJECT_SELF, "_PotionsT1", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_PotionsT2", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_PotionsT3", 256, "", TRUE);

    CopyChest(OBJECT_SELF, "_PotionsT1NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_PotionsT2NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_PotionsT3NonUnique", 256, "", TRUE);

    CopyChest(OBJECT_SELF, "_ScrollsT1", 256, "Wizard", TRUE);
    CopyChest(OBJECT_SELF, "_ScrollsT2", 256, "Wizard", TRUE);
    CopyChest(OBJECT_SELF, "_ScrollsT3", 256, "Wizard", TRUE);
}
