#include "inc_persist"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    if (GetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+GetResRef(OBJECT_SELF)+"_pp") == 1)
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
