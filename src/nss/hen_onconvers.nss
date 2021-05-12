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

// * This function checks to make sure no
// * dehibilating effects are on the player that should
// * Don't use getcommandable for this since the dying system
// * will sometimes leave a player in a noncommandable state
int AbleToTalk(object oSelf)
{
    if (GetLocalInt(oSelf, "pending_destroy")) return FALSE;

    effect eSearch = GetFirstEffect(oSelf);
    while(GetIsEffectValid(eSearch))
    {
        switch(GetEffectType(eSearch))
        {
            case EFFECT_TYPE_CONFUSED:
            case EFFECT_TYPE_DOMINATED:
            case EFFECT_TYPE_PETRIFY:
            case EFFECT_TYPE_PARALYZE:
            case EFFECT_TYPE_STUNNED:
            case EFFECT_TYPE_FRIGHTENED:
            case EFFECT_TYPE_DAZED:
            case EFFECT_TYPE_CHARMED:
            case EFFECT_TYPE_TURNED:
            case EFFECT_TYPE_CUTSCENE_PARALYZE:
            case EFFECT_TYPE_SLEEP:
            return FALSE;
        }
        switch(GetEffectSpellId(eSearch))
        {
            case SPELL_BIGBYS_FORCEFUL_HAND:
            case SPELL_BALAGARNSIRONHORN:
            return FALSE;
        }
        eSearch = GetNextEffect(oSelf);
    }
    return TRUE;
}

void main()
{
    if (GetLocalInt(OBJECT_SELF, "pending_destroy")) return;

    object oShouter = GetLastSpeaker();

    object oMaster = GetMaster();
    int nMatch = GetListenPatternNumber();

    if (nMatch == ASSOCIATE_COMMAND_LEAVEPARTY)
    {
        DelayCommand(0.1, AddHenchman(oMaster));
        SendMessageToPC(oMaster, "Henchmen cannot be dismissed from the radial menu");
    }

    if (nMatch == -1 && AbleToTalk(OBJECT_SELF) && GetCurrentAction() != ACTION_OPENLOCK)
    {
        ClearActions(CLEAR_NW_CH_AC4_28);

        BeginConversation();
    }

    // respond to friendly party members - pok
    if (nMatch == 901 && GetIsFriend(oShouter))
    {
        HenchDetermineCombatRound(GetLastHostileActor(oShouter));
    }

    object oIntruder;

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

    // Signal user-defined event
    if(GetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_DIALOGUE));
    }
}


