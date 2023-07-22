// Returns TRUE if the PC has a house in blacklake
#include "inc_housing"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

    if (GetHomeTagInDistrict(GetPCPublicCDKey(oPC), "blak") != "") return TRUE;

    return FALSE;
}
