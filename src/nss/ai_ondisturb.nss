#include "inc_ai_combat"
#include "inc_ai_event"
//#include "inc_crime"

void main()
{
    SignalEvent(OBJECT_SELF, EventUserDefined(GS_EV_ON_DISTURBED));

    if (GetInventoryDisturbType() == INVENTORY_DISTURB_TYPE_STOLEN &&
        ! gsCBGetIsInCombat())
    {
        PlayVoiceChat(VOICE_CHAT_CUSS);
        gsCBDetermineCombatRound(GetLastDisturbed());
    }

    /*
      Author: Mithreas
      Date: 17 Apr 06
      Description: Addition to hook into the criminal scripts.
    */
    /*
    object oItem = GetInventoryDisturbItem(); // The item that was stolen
    object oPickPocketer = GetLastDisturbed();
    int nValue = 0;
    int nNation = CheckFactionNation(OBJECT_SELF);

    if (GetIsObjectValid(oItem))
    {
      Trace(BOUNTY, "Item stolen, getting its value.");
      nValue = GetGoldPieceValue(oItem);
    }

    if (GetIsPC(oPickPocketer) && nNation != NATION_INVALID)
    {
      Trace(BOUNTY, "Adding to thief's bounty.");
	  SpeakString("Stop, thief! GUARDS!", TALKVOLUME_SHOUT);
      AddToBounty(nNation, FINE_THEFT + nValue, oPickPocketer);
    }
    else if ((GetAssociateType(oPickPocketer) != ASSOCIATE_TYPE_NONE) &&
             GetIsPC(GetMaster(oPickPocketer)) && nNation != NATION_INVALID)
    {
      // Add to master's bounty.
      Trace(BOUNTY, "Adding to master's bounty.");
      AddToBounty(nNation, FINE_THEFT + nValue, GetMaster(oPickPocketer));
    }
    */
}

