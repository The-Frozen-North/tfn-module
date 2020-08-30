#include "inc_quest"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int nSkill = SKILL_BLUFF;
    int nDC = GetLocalInt(OBJECT_SELF, "quest8_bluff_dc");

    if(GetIsSkillSuccessful(oPC, nSkill, nDC))
    {
        AdvanceQuest(OBJECT_SELF, oPC, 8, TRUE);
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
