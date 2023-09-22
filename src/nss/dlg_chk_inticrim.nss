#include "inc_xp"

//#include "inc_general"
// DC is 11 + level
// set script param "dc" to use that instead

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    string sTag = GetTag(OBJECT_SELF);
    int nSkill = SKILL_INTIMIDATE;
    int nDC = 11 + GetHitDice(OBJECT_SELF);
    int nScriptParam = StringToInt(GetScriptParam("dc"));

    if (nScriptParam != 0)
    {
        nDC = nScriptParam;
    }

    if(!(GetIsSkillSuccessful(oPC, nSkill, nDC)))
    {
        //IncrementPlayerStatistic(oPC, "intimidate_failed");
        return FALSE;
    }
    //IncrementPlayerStatistic(oPC, "intimidate_succeeded");
    GiveDialogueSkillXP(oPC, nDC, nSkill);
    return TRUE;
}
