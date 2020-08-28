#include "inc_loot"

void main()
{
    int nItems = d20(20);
    int i;
    for (i = 0; i < nItems; i++)
    {
        GenerateTierItem(4, 10, OBJECT_SELF);
    }

    int nMax = d4(4);
    for (i = 0; i < nMax; i++)
    {
        GenerateTierItem(0, 0, OBJECT_SELF, "", 3, TRUE);
    }

    nMax = d3(3);
    for (i = 0; i < nMax; i++)
    {
        GenerateTierItem(0, 0, OBJECT_SELF, "", 4, TRUE);
    }

    nMax = d2(2);
    for (i = 0; i < nMax; i++)
    {
        GenerateTierItem(0, 0, OBJECT_SELF, "", 5, TRUE);
    }
}
