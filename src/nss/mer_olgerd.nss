#include "inc_loot"

void main()
{
    int nItems = d20(20);
    int i;
    for (i = 0; i < nItems; i++)
    {
        GenerateTierItem(4, 10, OBJECT_SELF);
    }
}
