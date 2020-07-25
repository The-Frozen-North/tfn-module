#include "1_inc_loot"

void main()
{
    object oPC = GetLastOpenedBy();
    object oLootContainer = GetObjectByUUID(GetLocalString(OBJECT_SELF, "loot_parent_uuid"));

    DecrementLootAndDestroyIfEmpty(oPC, oLootContainer, OBJECT_SELF);

    AssignCommand(oLootContainer, ActionPlayAnimation(ANIMATION_PLACEABLE_OPEN));
}
