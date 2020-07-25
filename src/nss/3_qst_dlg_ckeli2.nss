// Check if the PC is eligible for this quest stage
// if the PC is NOT at quest#: ##_<quest_name>, zero padded
// and quest#_prereq<1-9>: ##_<quest_name>, zero padded is met, return TRUE
#include "1_inc_quest"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

    return GetIsQuestStageEligible(OBJECT_SELF, oPC, 2);
}
