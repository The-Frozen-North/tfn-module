#include "inc_gold"

void main()
{
    object oPC = GetPCSpeaker();

    int nCost = CharismaModifiedGold(oPC, GetLocalInt(OBJECT_SELF, "cost"));

    if (GetGold(oPC) >= nCost)
    {
        TakeGoldFromCreature(nCost, oPC, TRUE);
        location lLocation = GetLocation(GetObjectByTag(GetScriptParam("target")));
        FadeToBlack(oPC);
        DelayCommand(2.5, AssignCommand(oPC, JumpToLocation(lLocation)));
        DelayCommand(5.0, FadeFromBlack(oPC));
    }
}
