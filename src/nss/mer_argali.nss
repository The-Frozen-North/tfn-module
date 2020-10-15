#include "inc_merchant"
#include "inc_loot"

void main()
{
    CopyChest(OBJECT_SELF, "_ApparelCommonT1", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ApparelCommonT2", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ApparelCommonT3", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ApparelUncommonT1", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ApparelUncommonT2", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ApparelUncommonT3", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ApparelRareT1", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ApparelRareT2", 256, "", TRUE);
    CopyChest(OBJECT_SELF, "_ApparelRareT3", 256, "", TRUE);

    int i;
    int nMax = d3(3);
    for (i = 0; i < nMax; i++)
    {
        GenerateTierItem(0, 0, OBJECT_SELF, "Apparel", 4, TRUE);
    }

    nMax = d3();
    for (i = 0; i < nMax; i++)
    {
        GenerateTierItem(0, 0, OBJECT_SELF, "Apparel", 5, TRUE);
    }

    nMax = d4(2);
    for (i = 0; i < nMax; i++)
    {
        GenerateTierItem(0, 0, OBJECT_SELF, "Apparel", 3, TRUE);
    }

    nMax = d6(3);
    for (i = 0; i < nMax; i++)
    {
        GenerateTierItem(0, 0, OBJECT_SELF, "Apparel", 2, TRUE);
    }
}
