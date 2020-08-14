#include "inc_debug"
#include "nwnx_util"

void main()
{
    object oPC = GetPCSpeaker();

    if (GetIsDeveloper(oPC))
    {
        SendMessageToPC(oPC, "Tick count: "+IntToString(NWNX_Util_GetServerTicksPerSecond()));
    }
}
