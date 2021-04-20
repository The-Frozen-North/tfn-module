#include "inc_gold"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

    if (GetGold(oPC) >= CharismaModifiedGold(oPC, 70))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
