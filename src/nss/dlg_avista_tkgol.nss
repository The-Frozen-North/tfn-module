#include "inc_gold"

void main()
{
    object oPC = GetPCSpeaker();

    int nCost = CharismaModifiedGold(oPC, 70);
    TakeGoldFromCreature(nCost, oPC, TRUE);
}
