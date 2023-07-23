#include "inc_gold"
#include "inc_ship"
#include "inc_general"

void main()
{
    object oPC = GetPCSpeaker();

    int nCost = CharismaModifiedGold(oPC, GetLocalInt(OBJECT_SELF, "cost"));

    if (GetGold(oPC) >= nCost)
    {
        TakeGoldFromCreature(nCost, oPC, TRUE);

        IncrementStat(oPC, "gold_spent_on_ferries", nCost);
        IncrementStat(oPC, "ferries_used");

        location lLocation = GetLocation(GetObjectByTag(GetScriptParam("target")));
        FadeToBlack(oPC);
        if (GetAreaFromLocation(lLocation) == GetArea(OBJECT_SELF))
        {
           DelayCommand(2.5, AssignCommand(oPC, ReallyJumpToLocationInSameArea(lLocation)));
        }
        else
        {
            DelayCommand(2.5, AssignCommand(oPC, ReallyJumpToLocation(lLocation, 20)));
        }
        DelayCommand(5.0, FadeFromBlack(oPC));
    }
}
