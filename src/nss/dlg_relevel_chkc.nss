#include "inc_gold"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

    if (GetGold(oPC) >= CharismaModifiedGold(oPC, GetXP(oPC)/GetLocalInt(OBJECT_SELF, "cost_factor")))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
