#include "inc_gold"
#include "inc_persist"
#include "inc_general"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int nSkill = SKILL_PERSUADE;
    int nDC = 12;

    int nCost = CharismaModifiedPersuadeGold(oPC, 70);

    if (GetGold(oPC) < nCost) return FALSE;

    if(!(GetIsSkillSuccessful(oPC, nSkill, nDC)))
    {
        IncrementPlayerStatistic(oPC, "persuade_failed");
        SetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+GetTag(OBJECT_SELF), 1, 900.0);
        return FALSE;
    }
    else
    {
        IncrementPlayerStatistic(oPC, "persuade_succeeded");
        TakeGoldFromCreature(nCost, oPC, TRUE);
        return TRUE;
    }
}
