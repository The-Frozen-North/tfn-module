#include "nwnx_util"

void main()
{
    object oPC = GetPCSpeaker();

    SendMessageToPC(oPC, "Tick count: "+IntToString(NWNX_Util_GetServerTicksPerSecond()));
}
