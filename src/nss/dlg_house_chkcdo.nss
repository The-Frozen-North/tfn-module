#include "inc_housing"

int StartingConditional()
{
    string sPlayerCDKey = GetPCPublicCDKey(GetPCSpeaker());
    string sCDKey = GetHouseCDKey(GetLocalString(OBJECT_SELF, "area"));

    if (sCDKey != "" && sCDKey != sPlayerCDKey)
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
