#include "inc_henchman"
#include "inc_persist"


int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int nSkill = SKILL_PERSUADE;
    int nDC = 13 + GetHenchmanCount(oPC)*7;

    SetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+GetResRef(OBJECT_SELF), 1, 900.0);

    if(!(GetIsSkillSuccessful(oPC, nSkill, nDC)))
    {
        return FALSE;
    }
    else
    {
        IncrementStat(oPC, "henchman_recruited");
        SetMaster(OBJECT_SELF, oPC);
        ForceRest(OBJECT_SELF);
        return TRUE;
    }
}
