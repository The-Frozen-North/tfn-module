#include "inc_persist"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    string sTag = GetTag(OBJECT_SELF);
    int nSkill = SKILL_PERSUADE;
    int nDC = GetLocalInt(OBJECT_SELF, "persuade_dc");

    if(!(GetIsSkillSuccessful(oPC, nSkill, nDC)))
    {
        SetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+"_"+GetTag(OBJECT_SELF)+"_pers", 1, 900.0);
        return FALSE;
    }

    return TRUE;
}
