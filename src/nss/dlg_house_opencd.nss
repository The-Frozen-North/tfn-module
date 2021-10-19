#include "inc_housing"

void main()
{
    string sPlayerCDKey = GetPCPublicCDKey(GetPCSpeaker());
    string sCDKey = GetHouseCDKey(GetLocalString(OBJECT_SELF, "area"));

    if (sCDKey != "" && sCDKey == sPlayerCDKey)
    {
        ActionOpenDoor(OBJECT_SELF);
    }
}
