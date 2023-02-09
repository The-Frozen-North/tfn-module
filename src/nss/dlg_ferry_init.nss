#include "inc_gold"

void main()
{
    object oPC = GetPCSpeaker();

    int nLocalCost = GetLocalInt(OBJECT_SELF, "cost");

    int nCost = CharismaDiscountedGold(oPC, nLocalCost);
    int nPersuadeCost = CharismaModifiedPersuadeGold(oPC, nLocalCost);

    SetCustomToken(CTOKEN_FERRY_COST, IntToString(nCost));
    SetCustomToken(CTOKEN_FERRY_PERSUADE_COST, IntToString(nPersuadeCost));
}
