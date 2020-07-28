#include "1_inc_loot"

void main()
{
    int nItems = d12(10);
    int i;
    for (i = 0; i < nItems; i++)
    {
        GenerateTierItem(3, OBJECT_SELF);
    }
}
