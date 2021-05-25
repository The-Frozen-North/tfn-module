// Attempts to advance a quest based on variables on an object. quest#: ##_<quest_name>, zero padded.
// Leave quest#_prereq for no prerequisite quest stages.
// quest#_reward_xp_tier, quest#_reward_xp_level, quest#_reward_gold
// quest#_reward_item - must be a resref
#include "inc_quest"

void main()
{
    object oPC = GetPCSpeaker();

    int nTarget = StringToInt(GetScriptParam("target"));

    if (nTarget == 0)
        return;

    if (GetScriptParam("aoe") == "1")
    {
        AdvanceQuestSphere(OBJECT_SELF, nTarget);
    }
    else
    {
        AdvanceQuest(OBJECT_SELF, oPC, nTarget);
    }
}
