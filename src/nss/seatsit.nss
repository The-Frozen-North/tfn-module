// Script to allow a character to sit on a chair/bench
// Designed to check if someone is already sitting
// Already sitting person and attempting to sit person interact if so
// Otherwise player goes ahead and sits
//
// Designed by Voodoo (drfunk@mpinet.net)

void main()
{
 object oBench = OBJECT_SELF;
 object oPlayer = GetLastUsedBy();
 object oOccupent = GetSittingCreature(oBench);
 if (oOccupent == OBJECT_INVALID)
  {
   AssignCommand(oPlayer,ActionSit(oBench));
  }
/* else
  {
   AssignCommand(oOccupent,PlayVoiceChat(VOICE_CHAT_CANTDO));
   AssignCommand(oPlayer,ActionPlayAnimation(ANIMATION_LOOPING_TALK_FORCEFUL));
   AssignCommand(oPlayer,PlayVoiceChat(VOICE_CHAT_MOVEOVER));
  } */
}
