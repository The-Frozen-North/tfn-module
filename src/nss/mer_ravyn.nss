#include "inc_loot"

void main()
{
    int nItems = d20(10);
    int i;
    for (i = 0; i < nItems; i++)
    {
        GenerateTierItem(10, 10, OBJECT_SELF);
    }
    
    int bNonUnique;

    int nMax = d4(5);
    for (i = 0; i < nMax; i++)
    {
        bNonUnique = Random(100) >= PAWNSHOP_CHANCE_TO_ALLOW_UNIQUE;
        GenerateTierItem(0, 0, OBJECT_SELF, "", 3, bNonUnique);
    }

    nMax = d3(5);
    for (i = 0; i < nMax; i++)
    {
        bNonUnique = Random(100) >= PAWNSHOP_CHANCE_TO_ALLOW_UNIQUE;
        GenerateTierItem(0, 0, OBJECT_SELF, "", 4, bNonUnique);
    }

    for (i = 0; i < 7; i++)
    {
        if (Random(100) < STORE_RANDOM_T5_CHANCE)
        {
            bNonUnique = Random(100) >= PAWNSHOP_CHANCE_TO_ALLOW_UNIQUE;
            GenerateTierItem(0, 0, OBJECT_SELF, "", 5, bNonUnique);
        }
    }
}
