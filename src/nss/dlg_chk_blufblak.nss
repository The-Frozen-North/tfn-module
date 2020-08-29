#include "inc_persist"
#include "inc_quest"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

    if (GetIsQuestStageEligible(OBJECT_SELF, oPC, 1)) return FALSE;

    if (GetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+"_"+GetTag(OBJECT_SELF)+"_bluf") == 1) return FALSE;

    return TRUE;
}
