/*/////////////////////// [On Conversation] ////////////////////////////////////
    Filename: J_AI_OnConversat or nw_c2_default4
///////////////////////// [On Conversation] ////////////////////////////////////
    OnConversation/ Listen to shouts.
    Documented, and checked. -Working-

    Added spawn in condition - Never clear actions when talking.
///////////////////////// [History] ////////////////////////////////////////////
    1.3 - Added in conversation thing - IE we can set speakstrings, no need for conversation file.
        - Sorted more shouts out.
        - Should work right, and not cause too many actions (as we ignore
          shouts for normally 12 or so seconds before letting them affect us again).
    1.4 - Deafness incorpreated.
///////////////////////// [Workings] ///////////////////////////////////////////
    Uses RespondToShout to react to allies' shouts, and just attacks any enemy
    who speaks, or at least moves to them. (OK, dumb if they are invisible, but
    oh well, they shouldn't talk so loud!)

    Remember, whispers are never heard if too far away, speakstrings don't go
    through walls, and shouts are always heard (so we don't go off to anyone
    not in our area, remember)

    Deafness causes us to never hear battle, so unless we see the target speaking
    we do not react. Doesn't apply to normal conversations - although if we cannot
    talk (also restricted by deafness) then so be it.
///////////////////////// [Arguments] //////////////////////////////////////////
    Arguments: GetListenPatternNumber, GetLastSpeaker, TestStringAgainstPattern,
               GetMatchedSubstring
///////////////////////// [On Conversation] //////////////////////////////////*/

#include "inc_hai_other"

void main()
{
    // Pre-conversation-event. Returns TRUE if we interrupt this script call.
    if(FirePreUserEvent(AI_FLAG_UDE_ON_DIALOGUE_PRE_EVENT, EVENT_ON_DIALOGUE_PRE_EVENT)) return;

    // AI status check. Is the AI on?
    if(GetAIOff()) return;

    // Declarations
    int nMatch = GetListenPatternNumber();
    object oShouter = GetLastSpeaker();
    string sSpoken = GetMatchedSubstring(0);

    // We can ignore everything under special cases - EG no valid shouter,
    // we are fleeing, its us, or we are not in the same area.
    // - We break out of the script if this happens.
    if(!GetIsObjectValid(oShouter) ||     /* Must be a valid speaker! */
        oShouter == OBJECT_SELF ||        /* Not us!     */
        GetIsPerformingSpecialAction() || /* Not fleeing */
        GetIgnore(oShouter) ||            /* Not ignoring the shouter */
        GetArea(oShouter) != GetArea(OBJECT_SELF))/* Same area (Stops loud yellow shouts getting NPCs) */
    {
        // Fire End of Dialogue event
        FireUserEvent(AI_FLAG_UDE_ON_DIALOGUE_EVENT, EVENT_ON_DIALOGUE_EVENT);
        return;
    }

    // Conversation if not a shout.
    if(nMatch == -1)
    {
        // * Don't speak when dead. 1.4 change (an obvious one to make)
        if(CanSpeak())
        {
            // Make sure it is a PC and we are not fighting.
            if(!GetIsFighting() && (GetIsPC(oShouter) || GetIsDMPossessed(oShouter)))
            {
                BeginConversation();
            }
        }
    }
    // If it is a valid shout...and a valid shouter.
    // - Not a DM. Not ignoring shouting. Not a Debug String.
    else if(!GetLocalTimer(AI_TIMER_SHOUT_IGNORE_ANYTHING_SAID) &&// Not listening (IE heard already)
            !GetIsDM(oShouter) && FindSubString(sSpoken, "[Debug]") == -1 &&
    // 1.4 - Deafness (or they are seen) check, for fun.
            (!GetHasEffect(EFFECT_TYPE_DEAF) || GetObjectSeen(oShouter)))
    {
        if(GetFactionEqual(oShouter))
        {
            // only respond to shouts that is a party member - pok
            RespondToShout(oShouter, nMatch);

            // Else either is PC or is shout 0 (everything!)
            // - not if we are in combat, or they are not.
            /*
            if(!CannotPerformCombatRound() &&
                     GetIsInCombat(oShouter) &&
                     GetObjectType(oShouter) == OBJECT_TYPE_CREATURE)
            {
                // 57: "[Shout] Friend (may be PC) in combat. Attacking! [Friend] " + GetName(oShouter)
                DebugActionSpeakByInt(57, oShouter);

                // Respond to oShouter
                IWasAttackedResponse(oShouter);
            }
            */
        }
        else if(GetIsEnemy(oShouter) && GetObjectType(oShouter) == OBJECT_TYPE_CREATURE)
        {
            // If we hear anything said by an enemy, and are not fighting, attack them!
            if(!CannotPerformCombatRound())
                // the negatives are associate shouts, Normally (!)
                // 0+ are my shouts. 0 is anything
            {
                // emote disable removed - pok

                // 58: "[Shout] Responding to shout [Enemy] " + GetName(oShouter) + " Who has spoken!"
                DebugActionSpeakByInt(58, oShouter);

                // Short non-respond
                SetLocalTimer(AI_TIMER_SHOUT_IGNORE_ANYTHING_SAID, 6.0);

                // Attack the enemy!
                ClearAllActions();
                DetermineCombatRound(oShouter);

                // Shout to allies to attack the shouter
                AISpeakString(AI_SHOUT_I_WAS_ATTACKED);
            }
        }
    }
    // Fire End of Dialogue event
    FireUserEvent(AI_FLAG_UDE_ON_DIALOGUE_EVENT, EVENT_ON_DIALOGUE_EVENT);
}

