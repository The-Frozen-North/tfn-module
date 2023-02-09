#include "inc_gold"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

    if (GetGold(oPC) >= CharismaDiscountedGold(oPC, GetLocalInt(OBJECT_SELF, "cost")))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
