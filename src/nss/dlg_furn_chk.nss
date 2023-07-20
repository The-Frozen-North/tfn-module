#include "inc_ctoken"

int StartingConditional()
{
    int nCost = GetMaxHitPoints(OBJECT_SELF); // the cost of the furniture is the hit points
    object oPC = GetPCSpeaker();


    SetCustomToken(CTOKEN_PLACEABLE_PRICE, IntToString(nCost));

    if (GetGold(oPC) < nCost) return FALSE;

    return TRUE;
}
