#include "inc_loot"

void main()
{
    int nItems = d20(10);
    int i;
    for (i = 0; i < nItems; i++)
    {
        GenerateTierItem(6, 3, OBJECT_SELF);
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
}
