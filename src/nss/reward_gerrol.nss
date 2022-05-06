#include "inc_loot"

void main()
{
    object oItem = GenerateTierItem(0, 0, OBJECT_SELF, "Armor", 3, TRUE);
    SetIdentified(oItem, TRUE);
}
