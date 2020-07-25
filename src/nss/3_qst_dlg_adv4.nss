// Attempts to advance a quest based on variables on an object, like quest#_name to quest#_stage.
// Leave quest#_prereq_name or quest#_prereq_stage blank for no prerequisite quests or stages.
// quest#_reward_xp_tier, quest#_reward_xp_level, quest#_reward_gold
// quest#_reward_item - must be a resref
#include "1_inc_quest"

void main()
{
    object oPC = GetPCSpeaker();

    AdvanceQuest(OBJECT_SELF, oPC, 4);
}
