#include "x3_inc_string"
#include "inc_debug"

int CheckDeadSpeak(object oPC)
{
    int bDead = GetIsDead(oPC);
    if (bDead)
    {
        SetPCChatMessage("");
        SendMessageToPC(oPC, "The dead cannot speak.");
    }
    return bDead;
}


void main()
{
  object oPC = GetPCChatSpeaker();

  if(!GetIsPC(oPC))
  {
       return;
  }

  string sVolume;
  switch (GetPCChatVolume())
  {
     case TALKVOLUME_TALK:
        if (CheckDeadSpeak(oPC)) return;
        sVolume = "TALK";
     break;
     case TALKVOLUME_WHISPER:
        if (CheckDeadSpeak(oPC)) return;
        sVolume = "WHISPER";
     break;
     case TALKVOLUME_SHOUT: sVolume = "SHOUT"; break;
     case TALKVOLUME_SILENT_SHOUT: sVolume = "SILENT_SHOUT"; break;
     case TALKVOLUME_PARTY: sVolume = "PARTY"; break;
  }

  string sMessage = GetPCChatMessage();

  WriteTimestampedLogEntry(PlayerDetailedName(oPC)+" ["+sVolume+"]: "+sMessage);

  if (GetIsDead(oPC)) return;

  string sLCMessage = GetStringLowerCase(sMessage);
  int nMessageLength = GetStringLength(sLCMessage);


  if(nMessageLength == 0)
  {
    return;
  }

  StringReplace(sLCMessage, ".", "");

  if (sLCMessage == "lol" || sLCMessage == "rofl" || sLCMessage == "lmao"|| sLCMessage == "roflmao" || sLCMessage == "haha"|| sLCMessage == "hehe"|| sLCMessage == "hah"|| sLCMessage == "heh"|| sLCMessage == "ha"|| sLCMessage == "lawl")
  {
    PlayVoiceChat(VOICE_CHAT_LAUGH, oPC);
    AssignCommand(oPC, ActionPlayAnimation(ANIMATION_LOOPING_TALK_LAUGHING));
  }


}
