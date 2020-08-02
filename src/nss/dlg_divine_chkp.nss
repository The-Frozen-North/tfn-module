#include "inc_gold"
#include "inc_persist"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

    if (GetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+"_divine") == 1) return FALSE;

    if (GetGold(oPC) >= CharismaModifiedPersuadeGold(oPC, GetLocalInt(OBJECT_SELF, "cost")))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
