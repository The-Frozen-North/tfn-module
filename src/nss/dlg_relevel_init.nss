#include "inc_gold"

void main()
{
    object oPC = GetPCSpeaker();

    int nLocalCost = GetXP(oPC)/GetLocalInt(OBJECT_SELF, "cost_factor");

    int nCost = CharismaModifiedGold(oPC, nLocalCost);
    int nPersuadeCost = CharismaModifiedPersuadeGold(oPC, nLocalCost);

    SetCustomToken(4900, IntToString(nCost));
    SetCustomToken(4901, IntToString(nPersuadeCost));
}
