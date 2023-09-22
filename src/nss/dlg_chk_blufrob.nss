#include "inc_persist"
#include "inc_xp"

// Bluff against bluff_dc local variable, offer 1 attempt per 15min
// set script param "dc" to use that instead

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    string sTag = GetTag(OBJECT_SELF);
    int nSkill = SKILL_BLUFF;
    int nDC = StringToInt(GetScriptParam("dc"));

    AdjustAlignment(oPC, ALIGNMENT_CHAOTIC, 3, FALSE);

    if (nDC == 0) nDC = 13; // fallback in case we derped and forgot to set any value

    SetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+"_"+GetTag(OBJECT_SELF)+"_brob", 1, 900.0);

    if(!(GetIsSkillSuccessful(oPC, nSkill, nDC)))
    {
        return FALSE;
    }
    GiveDialogueSkillXP(oPC, nDC, nSkill);
    int nGold = StringToInt(GetScriptParam("gold"));

    GiveGoldToCreature(oPC, nGold);

    return TRUE;
}
