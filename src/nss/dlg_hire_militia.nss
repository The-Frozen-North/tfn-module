#include "inc_follower"

void main()
{
    object oPC = GetPCSpeaker();

    if (!GetIsObjectValid(oPC))
        return;

    if (!GetIsPC(oPC))
        return;

    object oMilitia = CreateObject(OBJECT_TYPE_CREATURE, "militia", GetLocation(oPC));
    SetFollowerMaster(oMilitia, oPC);
    DelayCommand(1.0, PlayVoiceChat(VOICE_CHAT_HELLO, oMilitia));
}
