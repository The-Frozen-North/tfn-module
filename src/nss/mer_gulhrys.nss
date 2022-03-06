#include "inc_merchant"

void main()
{
    ApplyEWRAndInfiniteItems(OBJECT_SELF);

    CopyChest(OBJECT_SELF, "_PotionsT2", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_PotionsT3", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_PotionsT4", 256, "", TRUE);

    CopyChest(OBJECT_SELF, "_PotionsT2NonUnique", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_PotionsT3NonUnique", 256, "", TRUE);

    CopyChest(OBJECT_SELF, "_ScrollsT2", 256, "Wizard", TRUE);
    CopyChest(OBJECT_SELF, "_ScrollsT3", 256, "Wizard", TRUE);
    CopyChest(OBJECT_SELF, "_ScrollsT4", 256, "Wizard", TRUE);
}
