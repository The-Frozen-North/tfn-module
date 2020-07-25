#include "1_inc_persist"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

    if (GetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+"_militia_pers") == 1) return FALSE;

    return TRUE;
}

