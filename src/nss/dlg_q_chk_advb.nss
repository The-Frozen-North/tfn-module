#include "inc_quest"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int nTarget = StringToInt(GetScriptParam("target"));
    int nSkill = SKILL_BLUFF;
    int nDC = GetLocalInt(OBJECT_SELF, "quest" + IntToString(nTarget) + "_bluff_dc");

    if(GetIsSkillSuccessful(oPC, nSkill, nDC))
    {
        AdvanceQuest(OBJECT_SELF, oPC, nTarget, TRUE);
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
