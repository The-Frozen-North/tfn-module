#include "inc_persist"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

    if (GetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+GetTag(OBJECT_SELF)+"_bluf") == 1) return FALSE;

    return TRUE;
}
