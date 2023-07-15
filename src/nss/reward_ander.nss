#include "inc_loot"

void main()
{
    object oItem = GenerateTierItem(0, 0, OBJECT_SELF, "Melee", 4, TRUE);
    SetIdentified(oItem, TRUE);
}
