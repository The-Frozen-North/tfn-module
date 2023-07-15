#include "inc_quest"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int nSkill = SKILL_BLUFF;
    int nDC = GetLocalInt(OBJECT_SELF, "quest7_bluff_dc");

    AdjustAlignment(oPC, ALIGNMENT_CHAOTIC, BLUFF_CHAOS_SHIFT, FALSE);
    if(GetIsSkillSuccessful(oPC, nSkill, nDC))
    {
        AdvanceQuest(OBJECT_SELF, oPC, 7, TRUE);
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
