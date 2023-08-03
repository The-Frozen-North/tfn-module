#include "inc_housing"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

    //if (GetIsPlayerHomeless(oPC)) return FALSE;

    if (FindSubString(GetName(GetArea(OBJECT_SELF)), "Neverwinter") == -1) return FALSE; 

    if (GetLocalInt(OBJECT_SELF, "target") > 0) return FALSE;

    if (GetLocalString(OBJECT_SELF, "cd_key") != "") return FALSE;

    if (GetAvailablePetSlot(oPC) == -1) return FALSE;

    return TRUE;
}
