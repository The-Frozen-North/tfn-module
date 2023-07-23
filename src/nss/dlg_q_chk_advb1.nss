#include "inc_quest"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int nSkill = SKILL_BLUFF;
    int nDC = GetLocalInt(OBJECT_SELF, "quest1_bluff_dc");

    AdjustAlignment(oPC, ALIGNMENT_CHAOTIC, BLUFF_CHAOS_SHIFT, FALSE);
    if(GetIsSkillSuccessful(oPC, nSkill, nDC))
    {
        IncrementPlayerStatistic(oPC, "bluff_succeeded");
        AdvanceQuest(OBJECT_SELF, oPC, 1, TRUE);
        return TRUE;
    }
    else
    {
        IncrementPlayerStatistic(oPC, "bluff_failed");
        return FALSE;
    }
}
