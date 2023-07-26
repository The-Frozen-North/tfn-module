//::///////////////////////////////////////////////
//:: Associate: On Dialogue
//:: NW_CH_AC4
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Determines the course of action to be taken
    by the generic script after dialogue or a
    shout is initiated.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 24, 2001
//:://////////////////////////////////////////////
/*
Patch 1.72
- fixed bug that allowed to speak with associate in disable states such as petrify
- HotU associate conversation will now be used even outside of the HotU campaign
*/

// we are NOT using Jasperre's AI for conversation

#include "j_inc_henchman"
#include "inc_henchman"
#include "x2_inc_switches"

// * This function checks to make sure no
// * dehibilating effects are on the player that should
// * Don't use getcommandable for this since the dying system
// * will sometimes leave a player in a noncommandable state
int AbleToTalk(object oSelf)
{
    if (GetLocalInt(oSelf, "pending_destroy") == 1)
    {
        AssignCommand(OBJECT_SELF, ActionMoveToObject(GetNearestObject(OBJECT_TYPE_DOOR)));
        return FALSE;
    }

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
    object oMaster = GetMaster();
    int nMatch = GetListenPatternNumber();
    object oShouter = GetLastSpeaker();
    object oIntruder;



    if (nMatch == ASSOCIATE_COMMAND_LEAVEPARTY)
    {
        DelayCommand(0.1, AddHenchman(oMaster));
        SendMessageToPC(oMaster, "Henchmen cannot be dismissed from the radial menu");
    }

    if (GetIsControllable(OBJECT_SELF) && nMatch == 200 && GetIsFriend(oShouter) && !GetIsFighting()) // PARTY_I_WAS_ATTACKED
    {
        HenchmenCombatRound(GetLastHostileActor(oShouter));
    }

    if (nMatch == -1) {
        if(AbleToTalk(OBJECT_SELF) && GetCurrentAction() != ACTION_OPENLOCK)
        {
            ClearActions(CLEAR_NW_CH_AC4_28);

            // * if in XP2, use an alternative dialog file
            string sDialog = "";
            if (GetLocalInt(GetModule(), "X2_L_XP2") ==  1 || (GetAssociateType(OBJECT_SELF) != ASSOCIATE_TYPE_NONE && GetAssociateType(OBJECT_SELF) != ASSOCIATE_TYPE_HENCHMAN))
            {
                sDialog = "x2_associate";
            }
            BeginConversation(sDialog);
        }
    } else if (GetIsControllable(OBJECT_SELF)) {
        // listening pattern matched
        if (GetIsObjectValid(oShouter) && oMaster == oShouter)
        {
            SetCommandable(TRUE);
            AI_RespondToHenchmenShout(oShouter, nMatch, oIntruder, TRUE);
        }
    }

    // Signal user-defined event
    //if(GetSpawnInCondition(NW_FLAG_ON_DIALOGUE_EVENT)) {
    //    SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_DIALOGUE));
    //}
}


/************************ [On Conversation] ************************************
    Filename: j_ai_onconversat or nw_c2_default4
************************* [On Conversation] ************************************
    OnConversation/ Listen to shouts.
    Documented, and checked. -Working-

    Added spawn in condition - Never clear actions when talking.
************************* [History] ********************************************
    1.3 - Added in conversation thing - IE we can set speakstrings, no need for conversation file.
        - Sorted more shouts out.
        - Should work right, and not cause too many actions (as we ignore
          shouts for normally 12 or so seconds before letting them affect us again).
************************* [Workings] *******************************************
    Uses RespondToShout to react to allies' shouts, and just attacks any enemy
    who speaks, or at least moves to them. (OK, dumb if they are invisible, but
    oh well, they shouldn't talk so loud!)

    Remember, whispers are never heard if too far away, speakstrings don't go
    through walls, and shouts are always heard (so we don't go off to anyone
    not in our area, remember)
************************* [Arguments] ******************************************
    Arguments: GetListenPatternNumber, GetLastSpeaker, TestStringAgainstPattern,
               GetMatchedSubstring
************************* [On Conversation] ***********************************/
/*

//#include "j_inc_other_ai"
//#include "inc_henchman"

void main()
{
    ExecuteScript("hen_onconvers");

    // Pre-heartbeat-event
    if(FireUserEvent(AI_FLAG_UDE_ON_DIALOGUE_PRE_EVENT, EVENT_ON_DIALOGUE_PRE_EVENT))
        // We may exit if it fires
        if(ExitFromUDE(EVENT_ON_DIALOGUE_PRE_EVENT)) return;

    // AI status check. Is the AI on?
    if(GetAIOff()) return;

    // Declarations
    int nMatch = GetListenPatternNumber();
    object oShouter = GetLastSpeaker();
    string sSpoken = GetMatchedSubstring(i0);
    object oMaster = GetMaster();

    if (nMatch == ASSOCIATE_COMMAND_LEAVEPARTY)
    {
        //DelayCommand(0.1, AddHenchman(oMaster));
        SendMessageToPC(oMaster, "Henchmen cannot be dismissed from the radial menu");
    }

    // We can ignore everything under special cases - EG no valid shouter,
    // we are fleeing, its us, or we are not in the same area.
    // - We break out of the script if this happens.
    if(!GetIsObjectValid(oShouter) ||     // Must be a valid speaker!
       !GetCommandable() ||               // Commandable 
        oShouter == OBJECT_SELF ||        // Not us! 
        GetIsPerformingSpecialAction() || // Not fleeing
        GetIgnore(oShouter) ||            // Not ignoring the shouter
        GetArea(oShouter) != GetArea(OBJECT_SELF)) // Same area (Stops "SHOUT" getting NPCs 
    {
        // Fire End of Dialogue event
        FireUserEvent(AI_FLAG_UDE_ON_DIALOGUE_EVENT, EVENT_ON_DIALOGUE_EVENT);
        return;
    }

    // Conversation if not a shout.
    if(nMatch == iM1)
    {
        // Make sure it is a PC and we are not fighting.
        if(!GetIsFighting() && (GetIsPC(oShouter) || GetIsDMPossessed(oShouter)))
        {
            // If we have something random (or not) to say instead of
            // the conversation, we will say that.
            if(GetLocalInt(OBJECT_SELF, ARRAY_SIZE + AI_TALK_ON_CONVERSATION))
            {
                ClearAllActions();// Stop
                SetFacingPoint(GetPosition(oShouter));// Face
                SpeakArrayString(AI_TALK_ON_CONVERSATION);// Speak string
                PlayAnimation(ANIMATION_LOOPING_TALK_NORMAL, f1, f3);// "Talk", then resume potitions.
                ActionDoCommand(ExecuteScript(FILE_WALK_WAYPOINTS, OBJECT_SELF));
            }
            else
            {
                // If we are set to NOT clear all actions, we won't.
                if(!GetSpawnInCondition(AI_FLAG_OTHER_NO_CLEAR_ACTIONS_BEFORE_CONVERSATION, AI_OTHER_MASTER))
                {
                    ClearAllActions();
                }
                BeginConversation();
            }
        }
    }
    // If it is a valid shout...and a valid shouter.
    // - Not a DM. Not ignoring shouting. Not a Debug String.
    else if(!GetLocalTimer(AI_TIMER_SHOUT_IGNORE_ANYTHING_SAID) && // Not listening (IE heard already)
            !GetIsDM(oShouter) && FindSubString(sSpoken, "[Debug]") == iM1)
    {
        if(GetIsFriend(oShouter) || GetFactionEqual(oShouter))
        {
            // If they are a friend, not a PC, and a valid number, react.
            // In the actual RespondToShout call, we do check to see if we bother.
            // - Is PC - or is...master?
            // - Shouts of 1 or over only.
            if(nMatch >= i1 && !GetIsPC(oShouter) && !GetIsPC(GetMaster(oShouter)))
            {
                // Respond to the shout
                RespondToShout(oShouter, nMatch);
            }
            // Else either is PC or is shout 0 (everything!)
            // - not if we are in combat, or they are not.
            else if(!CannotPerformCombatRound() &&
                     GetIsInCombat(oShouter) &&
                     GetObjectType(oShouter) == OBJECT_TYPE_CREATURE)
            {
                // Only use attack target.
                object oIntruder = GetIntruderFromShout(oShouter);
                // Valid, and not a friend if a PC speaker
                if(GetIsObjectValid(oIntruder) &&
                  !GetFactionEqual(oIntruder) &&
                  !GetIsFriend(oIntruder))
                {
                    // 57: "[Shout] Friend (may be PC) in combat. Attacking! [Friend] " + GetName(oShouter)
                    DebugActionSpeakByInt(57, oShouter);
                    DetermineCombatRound(oIntruder);
                }
            }
        }
        else if(GetIsEnemy(oShouter) && GetObjectType(oShouter) == OBJECT_TYPE_CREATURE)
        {
            // If we hear anything said by an enemy, and are not fighting, attack them!
            if(!CannotPerformCombatRound())
                // the negatives are associate shouts, 0+ are my shouts. 0 is anything
            {
                // We make sure it isn't an emote (set by default)
                if(nMatch == i0 && GetSpawnInCondition(AI_FLAG_OTHER_DONT_RESPOND_TO_EMOTES, AI_OTHER_MASTER))
                {
                    // Jump out if its an emote - "*Nods*"
                    if(GetStringLeft(sSpoken, i1) == EMOTE_STAR &&
                       GetStringRight(sSpoken, i1) == EMOTE_STAR)
                    {
                        // Fire End of Dialogue event
                        FireUserEvent(AI_FLAG_UDE_ON_DIALOGUE_EVENT, EVENT_ON_DIALOGUE_EVENT);
                        return;
                    }
                }
                // 58: "[Shout] Responding to shout [Enemy] " + GetName(oShouter) + " Who has spoken!"
                DebugActionSpeakByInt(58, oShouter);
                // Short non-respond
                SetLocalTimer(AI_TIMER_SHOUT_IGNORE_ANYTHING_SAID, f6);
                // Attack the enemy!
                ClearAllActions();
                DetermineCombatRound(oShouter);
            }
        }
    }
    // Fire End of Dialogue event
    FireUserEvent(AI_FLAG_UDE_ON_DIALOGUE_EVENT, EVENT_ON_DIALOGUE_EVENT);
}

*/