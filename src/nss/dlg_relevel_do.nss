#include "inc_gold"

void main()
{
    object oPC = GetPCSpeaker();

    int nXP = GetXP(oPC);

    int nCost = CharismaModifiedGold(oPC, GetXP(oPC)/GetLocalInt(OBJECT_SELF, "cost_factor"));

    if (GetGold(oPC) >= nCost)
    {
        TakeGoldFromCreature(nCost, oPC, TRUE);
        SetXP(oPC, 1);
        SetXP(oPC, nXP);

        FadeToBlack(oPC);
        DelayCommand(5.0, AssignCommand(oPC, ActionStartConversation(oPC, "", TRUE, FALSE))); // tinygiant98
        DelayCommand(5.0, FadeFromBlack(oPC));
    }
}
