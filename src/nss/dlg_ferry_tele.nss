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

void ReallyJumpToLocationInSameArea(location lTarget, float fDist=-1.0)
{
    location lMe = GetLocation(OBJECT_SELF);
    if (fDist < 0.0)
    {
        fDist = GetDistanceBetweenLocations(lMe, lTarget);
    }
    float fThisDist = GetDistanceBetweenLocations(lMe, lTarget);
    if (fThisDist * 2.0 < fDist || fThisDist < 8.0)
    {
        return;
    }
    JumpToLocation(lTarget);
    DelayCommand(1.0, ReallyJumpToLocationInSameArea(lTarget, fDist));
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
        if (GetAreaFromLocation(lLocation) == GetArea(OBJECT_SELF))
        {
           DelayCommand(2.5, AssignCommand(oPC, ReallyJumpToLocationInSameArea(lLocation))); 
        }
        else
        {
            DelayCommand(2.5, AssignCommand(oPC, ReallyJumpToLocation(lLocation)));
        }
        DelayCommand(5.0, FadeFromBlack(oPC));
    }
}
