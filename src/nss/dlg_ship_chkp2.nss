#include "inc_ship"
#include "inc_persist"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

    if (GetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+"_"+GetTag(OBJECT_SELF)+"_pers") == 1) return FALSE;

    if (GetGold(oPC) >= GetShipCostPersuade(OBJECT_SELF, oPC, 2))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
