#include "inc_quest"

void main()
{
    object oPC = GetLastUsedBy();

    // do not continue if the player did not finish the quest
    if (GetQuestEntry(oPC, "q_charwood") != 3) return;

    ActionOpenDoor(OBJECT_SELF);
    SetLocked(OBJECT_SELF, FALSE);

}
