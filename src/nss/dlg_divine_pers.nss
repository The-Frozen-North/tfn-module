#include "inc_gold"
#include "inc_persist"
#include "inc_general"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int nSkill = SKILL_PERSUADE;
    int nDC = 17;

    SetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+"_divine", 1, 900.0);

    int nCost = CharismaModifiedPersuadeGold(oPC, GetLocalInt(OBJECT_SELF, "cost"));

    if (GetGold(oPC) < nCost) return FALSE;

    if(!(GetIsSkillSuccessful(oPC, nSkill, nDC)))
    {
        IncrementPlayerStatistic(oPC, "persuade_failed");
        return FALSE;
    }
    else
    {
        IncrementPlayerStatistic(oPC, "persuade_succeeded");
        TakeGoldFromCreature(nCost, oPC, TRUE);
        location lLocation = GetLocation(GetObjectByTag(GetLocalString(OBJECT_SELF, "warden_tele_wp")));
        AssignCommand(oPC, JumpToLocation(lLocation));
        return TRUE;
    }
}
