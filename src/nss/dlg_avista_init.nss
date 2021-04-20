#include "inc_gold"

void main()
{
    object oPC = GetPCSpeaker();

    int nLocalCost = 70;

    int nCost = CharismaModifiedGold(oPC, nLocalCost);
    int nPersuadeCost = CharismaModifiedPersuadeGold(oPC, nLocalCost);

    SetCustomToken(4950, IntToString(nCost));
    SetCustomToken(4951, IntToString(nPersuadeCost));
}
