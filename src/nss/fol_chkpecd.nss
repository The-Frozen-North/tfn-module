#include "inc_persist"

int StartingConditional()
{
    object oPC = GetPCSpeaker();

    if (GetTemporaryInt(GetObjectUUID(oPC)+"_"+GetObjectUUID(OBJECT_SELF)+"_pers") == 1) return FALSE;

    return TRUE;
}

