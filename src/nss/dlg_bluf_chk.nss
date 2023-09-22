#include "inc_persist"
#include "inc_general"
#include "inc_xp"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int nSkill = SKILL_BLUFF;
    int nDC = StringToInt(GetScriptParam("bluff"));

    if(!(GetIsSkillSuccessful(oPC, nSkill, nDC)))
    {
        IncrementPlayerStatistic(oPC, "bluff_failed");
        SetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+GetTag(OBJECT_SELF)+"_bluf", 1, 900.0);
        return FALSE;
    }
    else
    {
        GiveDialogueSkillXP(oPC, nDC, nSkill);
        IncrementPlayerStatistic(oPC, "bluff_succeeded");
        return TRUE;
    }
}
