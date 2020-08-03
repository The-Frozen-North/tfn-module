#include "inc_gold"
#include "inc_persist"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

    if (GetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+"_geldar") == 1) return FALSE;

    if (GetGold(oPC) >= CharismaModifiedPersuadeGold(oPC, GetXP(oPC)/GetLocalInt(OBJECT_SELF, "cost_factor")))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
