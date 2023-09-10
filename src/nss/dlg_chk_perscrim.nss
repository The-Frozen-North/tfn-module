#include "inc_general"
// DC is 13 + level
// set script param "dc" to use that instead

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    string sTag = GetTag(OBJECT_SELF);
    int nSkill = SKILL_PERSUADE;
    int nDC = 13 + GetHitDice(OBJECT_SELF);
    int nScriptParam = StringToInt(GetScriptParam("dc"));

    if (nScriptParam != 0)
    {
        nDC = nScriptParam;
    }

    if(!(GetIsSkillSuccessful(oPC, nSkill, nDC)))
    {
        IncrementPlayerStatistic(oPC, "persuade_failed");
        return FALSE;
    }
    IncrementPlayerStatistic(oPC, "persuade_succeeded");
    return TRUE;
}
