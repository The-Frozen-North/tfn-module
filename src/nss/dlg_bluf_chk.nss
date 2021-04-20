#include "inc_persist"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int nSkill = SKILL_BLUFF;
    int nDC = StringToInt(GetScriptParam("bluff"));

    if(!(GetIsSkillSuccessful(oPC, nSkill, nDC)))
    {
        SetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+GetTag(OBJECT_SELF)+"_bluf", 1, 900.0);
        return FALSE;
    }
    else
    {
        return TRUE;
    }
}
