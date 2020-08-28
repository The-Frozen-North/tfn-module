#include "inc_loot"

void main()
{
    int nItems = d20(10);
    int i;
    for (i = 0; i < nItems; i++)
    {
        GenerateTierItem(9, 6, OBJECT_SELF);
    }

    int nMax = d3(4);
    for (i = 0; i < nMax; i++)
    {
        GenerateTierItem(0, 0, OBJECT_SELF, "", 3, TRUE);
    }

    nMax = d2(3);
    for (i = 0; i < nMax; i++)
    {
        GenerateTierItem(0, 0, OBJECT_SELF, "", 4, TRUE);
    }

    nMax = d2();
    for (i = 0; i < nMax; i++)
    {
        GenerateTierItem(0, 0, OBJECT_SELF, "", 5, TRUE);
    }
}
