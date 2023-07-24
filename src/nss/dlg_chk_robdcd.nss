// returns false if robbed recently

#include "inc_persist"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

    if (GetTemporaryInt(PCAndNPCKey(oPC, OBJECT_SELF)+"_robi") == 1) return FALSE;
    if (GetTemporaryInt(PCAndNPCKey(oPC, OBJECT_SELF)+"_brob") == 1) return FALSE;

    return TRUE;
}
