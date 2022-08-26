#include "inc_gold"

void ReallyJumpToLocation(location lTarget)
{
    object oTargetArea = GetAreaFromLocation(lTarget);
    object oMyArea = GetArea(OBJECT_SELF);
    if (!GetIsObjectValid(oMyArea))
    {
        return;
    }
    if (oMyArea == oTargetArea)
    {
        return;
    }
    JumpToLocation(lTarget);
    DelayCommand(1.0, ReallyJumpToLocation(lTarget));
}

void main()
{
    object oPC = GetPCSpeaker();

    int nCost = CharismaModifiedGold(oPC, GetLocalInt(OBJECT_SELF, "cost"));

    if (GetGold(oPC) >= nCost)
    {
        TakeGoldFromCreature(nCost, oPC, TRUE);
        location lLocation = GetLocation(GetObjectByTag(GetScriptParam("target")));
        FadeToBlack(oPC);
        DelayCommand(2.5, AssignCommand(oPC, ReallyJumpToLocation(lLocation)));
        DelayCommand(5.0, FadeFromBlack(oPC));
    }
}
