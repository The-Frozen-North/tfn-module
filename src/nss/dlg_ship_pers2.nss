#include "inc_persist"
#include "inc_ship"
#include "inc_general"
#include "inc_xp"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int nSkill = SKILL_PERSUADE;
    int nDC = GetLocalInt(OBJECT_SELF, "ship2_persuade_dc");

    SetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+"_"+GetTag(OBJECT_SELF)+"_pers", 1, 900.0);

    if(!(GetIsSkillSuccessful(oPC, nSkill, nDC)))
    {
        IncrementPlayerStatistic(oPC, "persuade_failed");
        return FALSE;
    }
    GiveDialogueSkillXP(oPC, nDC, nSkill);
    IncrementPlayerStatistic(oPC, "persuade_succeeded");
    PayShipAndTravel(OBJECT_SELF, GetPCSpeaker(), 2, TRUE);

    return TRUE;
}
