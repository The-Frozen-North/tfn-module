#include "inc_loot"

void main()
{
    int nItems = d20(20);
    int i;
    int bAllowUnique;
    
    for (i = 0; i < nItems; i++)
    {
        GenerateTierItem(4, 4, OBJECT_SELF);
    }

    int bNonUnique;

    int nMax = d4(4);
    for (i = 0; i < nMax; i++)
    {
        bNonUnique = d10() >= 3;
        GenerateTierItem(0, 0, OBJECT_SELF, "", 3, bNonUnique);
    }

    nMax = d3(3);
    for (i = 0; i < nMax; i++)
    {
        bNonUnique = d10() >= 3;
        GenerateTierItem(0, 0, OBJECT_SELF, "", 4, bNonUnique);
    }

    nMax = d2();
    for (i = 0; i < nMax; i++)
    {
        bNonUnique = d10() >= 3;
        GenerateTierItem(0, 0, OBJECT_SELF, "", 5, bNonUnique);
    }
}
