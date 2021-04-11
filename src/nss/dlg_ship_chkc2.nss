#include "inc_ship"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

    if (GetGold(oPC) >= GetShipCost(OBJECT_SELF, oPC, 2))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
