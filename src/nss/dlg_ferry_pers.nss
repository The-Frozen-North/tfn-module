#include "inc_gold"
#include "inc_persist"
#include "inc_general"
#include "inc_xp"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int nSkill = SKILL_PERSUADE;
    int nDC = 14;

    SetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+GetTag(OBJECT_SELF), 1, 900.0);

    int nCost = CharismaModifiedPersuadeGold(oPC, GetLocalInt(OBJECT_SELF, "cost"));

    if (GetGold(oPC) < nCost) return FALSE;

    if(!(GetIsSkillSuccessful(oPC, nSkill, nDC)))
    {
        IncrementPlayerStatistic(oPC, "persuade_failed");
        return FALSE;
    }
    else
    {
        GiveDialogueSkillXP(oPC, nDC, nSkill);
        TakeGoldFromCreature(nCost, oPC, TRUE);
        IncrementPlayerStatistic(oPC, "persuade_succeeded");
        IncrementPlayerStatistic(oPC, "gold_spent_on_ferries", nCost);
        IncrementPlayerStatistic(oPC, "ferries_used");

        location lLocation = GetLocation(GetObjectByTag(GetScriptParam("target")));
        FadeToBlack(oPC);
        DelayCommand(2.5, AssignCommand(oPC, JumpToLocation(lLocation)));
        DelayCommand(5.0, FadeFromBlack(oPC));
        return TRUE;
    }
}
