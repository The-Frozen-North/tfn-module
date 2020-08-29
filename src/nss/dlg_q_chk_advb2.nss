#include "inc_quest"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int nSkill = SKILL_PERSUADE;
    int nDC = GetLocalInt(OBJECT_SELF, "quest2_bluff_dc");

    if(GetIsSkillSuccessful(oPC, nSkill, nDC))
    {
        AdvanceQuest(OBJECT_SELF, oPC, 2, TRUE);
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
