#include "inc_gold"

void main()
{
    object oPC = GetPCSpeaker();

    int nCost = CharismaDiscountedGold(oPC, 70);
    TakeGoldFromCreature(nCost, oPC, TRUE);
}
