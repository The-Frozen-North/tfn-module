#include "inc_persist"
#include "inc_ship"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int nSkill = SKILL_PERSUADE;
    int nDC = GetLocalInt(OBJECT_SELF, "ship1_persuade_dc");

    SetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+"_"+GetTag(OBJECT_SELF)+"_pers", 1, 900.0);

    if(!(GetIsSkillSuccessful(oPC, nSkill, nDC))) return FALSE;

    PayShipAndTravel(OBJECT_SELF, GetPCSpeaker(), 1, TRUE);

    return TRUE;
}
