#include "inc_gold"

void main()
{
    object oPC = GetPCSpeaker();

    int nLocalCost = 70;

    int nCost = CharismaModifiedGold(oPC, nLocalCost);
    int nPersuadeCost = CharismaModifiedPersuadeGold(oPC, nLocalCost);

    SetCustomToken(CTOKEN_FERRY_COST, IntToString(nCost));
    SetCustomToken(CTOKEN_FERRY_PERSUADE_COST, IntToString(nPersuadeCost));
}
