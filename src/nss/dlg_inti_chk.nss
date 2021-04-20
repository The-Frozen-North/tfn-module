#include "inc_persist"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int nSkill = SKILL_INTIMIDATE;
    int nDC = StringToInt(GetScriptParam("intimidate"));

    if(!(GetIsSkillSuccessful(oPC, nSkill, nDC)))
    {
        SetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+GetTag(OBJECT_SELF)+"_inti", 1, 900.0);
        return FALSE;
    }
    else
    {
        return TRUE;
    }
}
