//:://////////////////////////////////////////////////
//:: X0_CH_HEN_CONV
/*

  OnDialogue event handler for henchmen/associates.

 */
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 01/05/2003
//:://////////////////////////////////////////////////


#include "inc_hai_hensho"
#include "inc_hai_monsho"
#include "x0_i0_henchman"


void main()
{
    // * XP2, special handling code for interjections
    // * This script only fires if someone inits with me.
    // * with that in mind, I am now clearing any interjections
    // * that the character might have on themselves.
    if (GetLocalInt(GetModule(), "X2_L_XP2") == TRUE)
    {
        SetLocalInt(OBJECT_SELF, "X2_BANTER_TRY", 0);
        SetHasInterjection(GetMaster(OBJECT_SELF), FALSE);
        SetLocalInt(OBJECT_SELF, "X0_L_BUSY_SPEAKING_ONE_LINER", 0);
        SetOneLiner(FALSE, 0);
    }

    object oShouter = GetLastSpeaker();
    if (GetTag(OBJECT_SELF) == "x0_hen_dee")
    {
        string sCall = GetCampaignString("Deekin", "q6_Deekin_Call"+ GetName(oShouter), oShouter);

        if (sCall == "")
        {
            SetCustomToken(1001, GetStringByStrRef(40570));
        }
        else SetCustomToken(1001, sCall);
    }

//    int i = GetLocalInt(OBJECT_SELF, sAssociateMasterConditionVarname);
//    SendMessageToPC(GetFirstPC(), IntToHexString(i));
    if (GetIsHenchmanDying() == TRUE)
    {
        return;
    }

    object oMaster = GetMaster();
    int nMatch = GetListenPatternNumber();

    object oIntruder;

    if (nMatch == -1)
    {
        if(GetCommandable() && !GetIsDisabled(OBJECT_SELF) &&
            (GetCurrentAction() != ACTION_OPENLOCK))
        {
            ClearActions(CLEAR_X0_CH_HEN_CONV_26);
            string sDialogFileToUse = GetDialogFileToUse(GetLastSpeaker());
            // special code for last henchman
            if (GetTag(OBJECT_SELF) == "H2_Aribeth")
            {
                sDialogFileToUse = "xp2_hen_last";
            }
            BeginConversation(sDialogFileToUse);
        }
    }
    else
    {
        // listening pattern matched
        if (GetIsObjectValid(oMaster))
        {
            // we have a master, only listen to them
            if (GetIsObjectValid(oShouter) && oMaster == oShouter && !GetIsDisabled(OBJECT_SELF))
            {
                SetCommandable(TRUE);
                HenchChRespondToShout(oShouter, nMatch, oIntruder);
                // bkRespondToHenchmenShout(oShouter, nMatch, oIntruder);
            }
        }

        // we don't have a master, behave in default way
        else if (GetIsObjectValid(oShouter)
                 && !GetIsPC(oShouter)
                 && GetIsFriend(oShouter))
        {
             object oIntruder = OBJECT_INVALID;
             // Determine the intruder if any
             if(nMatch == 4)
             {
                 oIntruder = GetLocalObject(oShouter, "NW_BLOCKER_INTRUDER");
             }
             else if (nMatch == 5)
             {
                oIntruder = GetLocalObject(oShouter, sHenchLastTarget);
                if(!GetIsObjectValid(oIntruder))
                {
                     oIntruder = GetLastHostileActor(oShouter);
                     if(!GetIsObjectValid(oIntruder))
                     {
                         oIntruder = GetAttemptedAttackTarget();
                         if(!GetIsObjectValid(oIntruder))
                         {
                             oIntruder = GetAttemptedSpellTarget();
                         }
                     }
                 }
             }

             // Actually respond to the shout
             HenchMonRespondToShout(oShouter, nMatch, oIntruder);
         }
    }

    // Signal user-defined event
    if(GetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_DIALOGUE));
    }
}


