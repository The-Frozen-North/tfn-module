#include "1_inc_loot"

// This script should only be used on a personal loot object.
void main()
{
    object oPC = GetLastDisturbed();
    object oLootContainer = GetObjectByUUID(GetLocalString(OBJECT_SELF, "loot_parent_uuid"));

    DecrementLootAndDestroyIfEmpty(oPC, oLootContainer, OBJECT_SELF);
}
