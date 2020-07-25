// Attempts to advance a quest based on variables on an object. quest#: ##_<quest_name>, zero padded.
// Leave quest#_prereq for no prerequisite quest stages.
// quest#_reward_xp_tier, quest#_reward_xp_level, quest#_reward_gold
// quest#_reward_item - must be a resref
#include "1_inc_quest"

void main()
{
    object oPC = GetPCSpeaker();

    AdvanceQuest(OBJECT_SELF, oPC, 2);
}
