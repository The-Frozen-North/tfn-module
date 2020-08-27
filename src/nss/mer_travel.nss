#include "inc_loot"

void main()
{
    int nItems = d10(5);
    int iStore;
    for (iStore = 0; iStore < nItems; iStore++)
    {
        GenerateTierItem(10, 10, OBJECT_SELF);
    }

    SetEventScript(OBJECT_SELF, EVENT_SCRIPT_STORE_ON_OPEN, "");
}
