// Check if the PC is eligible for this quest stage
// if the PC is NOT at quest#: ##_<quest_name>, zero padded
// and quest#_prereq<1-9>: ##_<quest_name>, zero padded is met, return TRUE
#include "inc_quest"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

    int nTarget = StringToInt(GetScriptParam("target"));

    if (nTarget == 0)
        return FALSE;

    return GetIsQuestStageEligible(OBJECT_SELF, oPC, nTarget);
}
