#include "inc_loot"

void main()
{
    object oItem = GenerateTierItem(0, 0, OBJECT_SELF, "Apparel", 2);
    SetIdentified(oItem, TRUE);
}
