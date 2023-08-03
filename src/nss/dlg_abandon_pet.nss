#include "inc_housing"

void main()
{
    object oPC = GetPCSpeaker();

    if (GetPCPublicCDKey(GetPCSpeaker()) != GetLocalString(OBJECT_SELF, "cd_key")) return;

    AssignCommand(oPC, PlayVoiceChat(VOICE_CHAT_GOODBYE));

    AbandonPet(oPC, OBJECT_SELF);
}
