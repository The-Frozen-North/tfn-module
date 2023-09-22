#include "inc_persist"
#include "inc_general"
#include "inc_xp"

// Bluff against bluff_dc local variable, offer 1 attempt per 15min
// set script param "dc" to use that instead

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    string sTag = GetTag(OBJECT_SELF);
    int nSkill = SKILL_BLUFF;
    int nDC = GetLocalInt(OBJECT_SELF, "bluff_dc");
    int nScriptParam = StringToInt(GetScriptParam("dc"));

    AdjustAlignment(oPC, ALIGNMENT_CHAOTIC, 1, FALSE);

    if (nScriptParam != 0)
    {
        nDC = nScriptParam;
    }

    if (nDC == 0) nDC = 13; // fallback in case we derped and forgot to set any value

    if(!(GetIsSkillSuccessful(oPC, nSkill, nDC)))
    {
        IncrementPlayerStatistic(oPC, "bluff_failed");
        SetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+"_"+GetTag(OBJECT_SELF)+"_bluf", 1, 900.0);
        return FALSE;
    }
    GiveDialogueSkillXP(oPC, nDC, nSkill);
    IncrementPlayerStatistic(oPC, "bluff_succeeded");
    return TRUE;
}
