// Returns TRUE if the PC is at or past quest#: ##_<quest_name>, zero padded
#include "inc_quest"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

    int nTarget = StringToInt(GetScriptParam("target"));

    if (nTarget == 0)
        return FALSE;

    return GetIsAtQuestStage(OBJECT_SELF, oPC, nTarget);
}
