#include "inc_debug"

void main()
{
    object oPC = GetPCSpeaker();

    if (GetIsDeveloper(oPC))
    {
        SendMessageToPC(oPC, "T1 "+IntToString(GetLocalInt(GetModule(), "T1")));
        SendMessageToPC(oPC, "T2 "+IntToString(GetLocalInt(GetModule(), "T2")));
        SendMessageToPC(oPC, "T3 "+IntToString(GetLocalInt(GetModule(), "T3")));
        SendMessageToPC(oPC, "T4 "+IntToString(GetLocalInt(GetModule(), "T4")));
        SendMessageToPC(oPC, "T5 "+IntToString(GetLocalInt(GetModule(), "T5")));
    }
}
