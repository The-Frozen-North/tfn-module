#include "nwnx_object"

int StartingConditional()
{
    if (NWNX_Object_GetInt(GetPCSpeaker(), GetLocalString(OBJECT_SELF, "ship1_known")) == 1)
    {
        return TRUE;
    }
    {
        return FALSE;
    }
}
