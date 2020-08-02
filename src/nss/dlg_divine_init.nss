#include "inc_gold"

void main()
{
    object oPC = GetPCSpeaker();

    int nLocalCost = GetLocalInt(OBJECT_SELF, "cost");

    int nCost = CharismaModifiedGold(oPC, nLocalCost);
    int nPersuadeCost = CharismaModifiedPersuadeGold(oPC, nLocalCost);

    SetCustomToken(4900, IntToString(nCost));
    SetCustomToken(4901, IntToString(nPersuadeCost));
}
