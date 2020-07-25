#include "1_inc_loot"

void main()
{
    int nItems = d12(20);
    int i;
    for (i = 0; i < nItems; i++)
    {
        GenerateTierItem(1, OBJECT_SELF);
    }
}
