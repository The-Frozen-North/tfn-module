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

    object oArea = GetArea(oPC);
    object oMilitia = GetLocalObject(oArea, "helper_militia");
    if (!GetIsObjectValid(oMilitia) || GetArea(oMilitia) != oArea || GetIsDead(oMilitia) || GetIsObjectValid(GetMaster(oMilitia)))
    {
        oMilitia = CreateObject(OBJECT_TYPE_CREATURE, "militia", GetLocation(oPC));
    }
    // In the name of player choice, don't force the NPCs to join
    // ... but really really encourage it
    //SetFollowerMaster(oMilitia, oPC);
    DelayCommand(1.0, PlayVoiceChat(VOICE_CHAT_HELLO, oMilitia));

    object oBim = GetObjectByTag("hen_bim");

    if (!GetIsObjectValid(oBim)) return;
    if (GetIsDead(oBim)) return;

// if Bim already has a master, do not allow him to get recruited automatically otherwise he will be in a weird state
    string sMaster = GetResRef(oBim)+"_master";
    object oModule = GetModule();
    if (GetLocalString(oModule, sMaster) != "") return;

// already have a henchman? dont allow players to cheese the dialogue and get another henchman without persuade checks
    if (GetHenchmanCount(oPC) > 0) return;

    if (!GetIsObjectValid(GetMasterByUUID(oBim)))
    {
        //SetMaster(oBim, oPC);
        SetLocalInt(oPC, "bim_graduate", 1);
        DelayCommand(60.0, DeleteLocalInt(oPC, "bim_graduate"));
        DelayCommand(5.0, AssignCommand(oBim, ActionStartConversation(oPC)));
    }
}
