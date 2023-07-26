#include "inc_gold"
#include "inc_persist"
#include "inc_general"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int nSkill = SKILL_PERSUADE;
    int nDC = 16;

    int nXP = GetXP(oPC);

    SetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+"_geldar", 1, 900.0);

    int nCost = CharismaModifiedPersuadeGold(oPC, nXP/GetLocalInt(OBJECT_SELF, "cost_factor"));

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
        SetXP(oPC, 1);
        SetXP(oPC, nXP);

        FadeToBlack(oPC);
        DelayCommand(5.0, AssignCommand(oPC, ActionStartConversation(oPC, "", TRUE, FALSE))); // tinygiant98
        DelayCommand(5.0, FadeFromBlack(oPC));

        return TRUE;
    }
}
