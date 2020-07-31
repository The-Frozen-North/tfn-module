#include "1_inc_ship"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

    if (GetGold(oPC) >= GetShipCost(OBJECT_SELF, oPC, 1))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
