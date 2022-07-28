#include "inc_follower"
#include "inc_henchman"

void main()
{
    object oPC = GetPCSpeaker();

    if (GetLocalInt(oPC, "recruited_militia") == 1)
        return;

    if (!GetIsObjectValid(oPC))
        return;

    if (!GetIsPC(oPC))
        return;

    SetLocalInt(oPC, "recruited_militia", 1);

    object oMilitia = CreateObject(OBJECT_TYPE_CREATURE, "militia", GetLocation(oPC));
    SetFollowerMaster(oMilitia, oPC);
    DelayCommand(1.0, PlayVoiceChat(VOICE_CHAT_HELLO, oMilitia));


    object oBim = GetObjectByTag("hen_bim");

    if (!GetIsObjectValid(oBim)) return;
    if (GetIsDead(oBim)) return;
    if (GetHenchmanCount(oPC) > 0) return;

    SetMaster(oBim, oPC);

    AssignCommand(oBim, ActionMoveToObject(oPC));
    DelayCommand(4.0, PlayVoiceChat(VOICE_CHAT_HELLO, oBim));
}
