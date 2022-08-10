#include "inc_debug"
#include "x0_i0_match"

void DoVoice(object oCreature, int nSelected)
{
    if (GetIsDead(oCreature)) return;
    if (GetHasEffect(EFFECT_TYPE_PETRIFY, oCreature)) { return; }

    if (nSelected > 4)
    {
        switch(nSelected)
        {
            case 5: PlayVoiceChat(VOICE_CHAT_TALKTOME, oCreature); break;
            case 6: PlayVoiceChat(VOICE_CHAT_THREATEN, oCreature); break;
            case 7: PlayVoiceChat(VOICE_CHAT_BORED, oCreature); break;
            case 8: PlayVoiceChat(VOICE_CHAT_ENCUMBERED, oCreature); break;
            case 9: PlayVoiceChat(VOICE_CHAT_REST, oCreature); break;
            case 10: PlayVoiceChat(VOICE_CHAT_NO, oCreature); break;
            case 11: PlayVoiceChat(VOICE_CHAT_STOP, oCreature); break;
            case 12: PlayVoiceChat(VOICE_CHAT_BADIDEA, oCreature); break;
            case 13: PlayVoiceChat(VOICE_CHAT_CUSS, oCreature); break;
            case 14: PlayVoiceChat(VOICE_CHAT_TAUNT, oCreature); DeleteLocalInt(oCreature, "selected"); break;
        }
    }
    else
    {
        switch (d3())
        {
            case 1: PlayVoiceChat(VOICE_CHAT_YES, oCreature); break;
            case 2: PlayVoiceChat(VOICE_CHAT_SELECTED, oCreature); break;
        }
    }
}

void main()
{
    object oCreature = GetLastGuiEventObject();
    object oPC = GetLastGuiEventPlayer();

    //SendDebugMessage("gui event: "+IntToString(GetLastGuiEventType())+" gui object: "+GetName(oCreature)+" gui object master: "+GetName(GetMaster(oCreature))+" object is pc: "+IntToString(GetIsPC(oCreature))+" object pc: "+GetName(oPC));

    if (GetIsDead(oPC)) return;
    if (GetIsDead(oCreature)) return;
    if (GetLastGuiEventType() != GUIEVENT_SELECT_CREATURE) return;
    if (!GetIsObjectValid(oCreature)) return;
    if (GetMaster(oCreature) != oPC) return;
    if (GetIsPC(oCreature)) return;
    if (GetLocalInt(oCreature, "voice_cd") == 1) return;

    int nSelected = GetLocalInt(oCreature, "selected");

    if (nSelected < 14) SetLocalInt(oCreature, "selected", nSelected + 1);
    DeleteLocalInt(oCreature, "selected_remove");

    SetLocalInt(oCreature, "voice_cd", 1);
    DelayCommand(3.0, DeleteLocalInt(oCreature, "voice_cd"));
    DelayCommand(IntToFloat(d3())/10.0, DoVoice(oCreature, nSelected));

}
