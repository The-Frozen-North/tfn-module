#include "inc_gold"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

    if (GetGold(oPC) >= CharismaDiscountedGold(oPC, 70))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
