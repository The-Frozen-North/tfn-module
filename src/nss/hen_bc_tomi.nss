#include "inc_henchman"

void main()
{
    if (GetHasEffect(EFFECT_TYPE_PETRIFY, OBJECT_SELF)) { return; }
     int nRand = 60;

     switch (Random(nRand))
     {
          case 0: PlayVoiceChat(VOICE_CHAT_BATTLECRY1, OBJECT_SELF); break;
          case 1: PlayVoiceChat(VOICE_CHAT_BATTLECRY2, OBJECT_SELF); break;
          case 2: PlayVoiceChat(VOICE_CHAT_BATTLECRY3, OBJECT_SELF); break;
          case 3: PlayVoiceChat(VOICE_CHAT_ATTACK, OBJECT_SELF); break;
          case 4: PlayVoiceChat(VOICE_CHAT_TAUNT, OBJECT_SELF); break;
          case 5: PlayVoiceChat(VOICE_CHAT_LAUGH, OBJECT_SELF); break;
          case 6: PlayVoiceByStrRef(84069); break;
          case 7: PlayVoiceByStrRef(84070); break;
          case 8: PlayVoiceByStrRef(84071); break;
          case 9: PlayVoiceChat(VOICE_CHAT_THREATEN, OBJECT_SELF); break;
      }
}
