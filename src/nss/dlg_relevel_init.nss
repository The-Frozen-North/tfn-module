#include "inc_gold"

void main()
{
    object oPC = GetPCSpeaker();

    int nLocalCost = GetXP(oPC)/GetLocalInt(OBJECT_SELF, "cost_factor");

    int nCost = CharismaDiscountedGold(oPC, nLocalCost);
    int nPersuadeCost = CharismaModifiedPersuadeGold(oPC, nLocalCost);

    SetCustomToken(CTOKEN_RELEVEL_COST, IntToString(nCost));
    SetCustomToken(CTOKEN_RELEVEL_PERSUADE_COST, IntToString(nPersuadeCost));
}
