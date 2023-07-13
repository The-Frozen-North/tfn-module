// Check if the PC is eligible for this quest stage
// if the PC is NOT at quest#: ##_<quest_name>, zero padded
// and quest#_prereq<1-9>: ##_<quest_name>, zero padded is met, return TRUE

// Additionally, check if the NPC with the tag is alive, within line of sight, and within 15m
#include "inc_quest"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    object oNPC = GetObjectByTag(GetScriptParam("npc_tag"));

    if (GetIsDead(oNPC)) return FALSE;
    if (!LineOfSightObject(oPC, oNPC)) return FALSE;

    float fDistance = GetDistanceToObject(oNPC);
    if (fDistance <= -1.0) return FALSE; // invalid distance
    if (fDistance > 15.0) return FALSE; // too far

    int nTarget = StringToInt(GetScriptParam("target"));

    if (nTarget == 0)
        return FALSE;

    return GetIsQuestStageEligible(OBJECT_SELF, oPC, nTarget);
}

