#include "inc_loot"

void main()
{
    int nItems = d10(1);
    int iStore;
    for (iStore = 0; iStore < nItems; iStore++)
    {
        GenerateTierItem(10, 10, OBJECT_SELF);
    }

    nItems = d10(2);
    for (iStore = 0; iStore < nItems; iStore++)
    {
        GenerateTierItem(8, 8, OBJECT_SELF);
    }

    int i;
    if (Random(100) < 2)
    {
        GenerateTierItem(0, 0, OBJECT_SELF, "Armor", 5, TRUE);
    }
    if (Random(100) < 2)
    {
        GenerateTierItem(0, 0, OBJECT_SELF, "Melee", 5, TRUE);
    }
    if (Random(100) < 2)
    {
        GenerateTierItem(0, 0, OBJECT_SELF, "Apparel", 5, TRUE);
    }

    if (Random(100) < 4)
    {
        GenerateTierItem(0, 0, OBJECT_SELF, "Armor", 4, TRUE);
    }
    if (Random(100) < 4)
    {
        GenerateTierItem(0, 0, OBJECT_SELF, "Melee", 4, TRUE);
    }
    if (Random(100) < 4)
    {
        GenerateTierItem(0, 0, OBJECT_SELF, "Apparel", 4, TRUE);
    }


    SetEventScript(OBJECT_SELF, EVENT_SCRIPT_STORE_ON_OPEN, "");
}
