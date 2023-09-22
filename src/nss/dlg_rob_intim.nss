#include "inc_persist"
#include "inc_xp"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int nSkill = SKILL_INTIMIDATE;
    int nDC = StringToInt(GetScriptParam("dc"));

    AdjustAlignment(oPC, ALIGNMENT_EVIL, 3, FALSE);

    SetTemporaryInt(PCAndNPCKey(oPC, OBJECT_SELF)+"_robi", 1, 900.0);

    if(!(GetIsSkillSuccessful(oPC, nSkill, nDC)))
    {
        return FALSE;
    }
    else
    {
        GiveDialogueSkillXP(oPC, nDC, nSkill);
        
        int nGold = StringToInt(GetScriptParam("gold"));

        GiveGoldToCreature(oPC, nGold);

        return TRUE;
    }
}
