/************************ [On Rested] ******************************************
    Filename: j_ai_onrest or nw_c2_defaulta
************************* [On Rested] ******************************************
    This will play the sitting animation for 6 seconds, just something for resting.
    Also, walks waypoints (as resting would stop this) :-) and signals event (if so be)
    Feel free to edit.

    It does have the spell trigger information resetting, however. This can
    only be removed if they have no spell triggers, although it is hardly worth it.
************************* [History] ********************************************
    1.3 - Added sitting.
************************* [Workings] *******************************************
    This fires once, at the END of resting.

    If ClearAllActions is added, the resting is actually stopped, or so it seems.

    It doesn't fire more then once.
************************* [Arguments] ******************************************
    Arguments: None, it seems.
************************* [On Rested] *****************************************/

#include "j_inc_constants"

// Resets all spell triggers used for sString
void LoopResetTriggers(string sString, object oTrigger);

void main()
{
    object oFamiliar = GetAssociate(ASSOCIATE_TYPE_FAMILIAR);
    if (GetIsObjectValid(oFamiliar))
    {
        ForceRest(oFamiliar);
        DecrementRemainingFeatUses(OBJECT_SELF, FEAT_SUMMON_FAMILIAR);
    }

    object oCompanion = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION);
    if (GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION)))
    {
        ForceRest(oCompanion);
        DecrementRemainingFeatUses(OBJECT_SELF, FEAT_ANIMAL_COMPANION);
    }

    //DeleteLocalInt(OBJECT_SELF, "invis");
    DeleteLocalInt(OBJECT_SELF, "gsanc");
    DeleteLocalInt(OBJECT_SELF, "healers_kit_cd");
    
    // Pre-heartbeat-event
    if(FireUserEvent(AI_FLAG_UDE_RESTED_PRE_EVENT, EVENT_RESTED_PRE_EVENT))
        // We may exit if it fires
        if(ExitFromUDE(EVENT_RESTED_PRE_EVENT)) return;

    // AI status check. Is the AI on?
    if(GetAIOff()) return;

    // Simple debug.
    // 66: "[Rested] Resting. Type: " + IntToString(GetLastRestEventType())
    DebugActionSpeakByInt(66, OBJECT_INVALID, GetLastRestEventType());

    // Reset all spell triggers.
    // Set all triggers
    object oTrigger = GetAIObject(AI_SPELL_TRIGGER_CREATURE);
    if(GetIsObjectValid(oTrigger))
    {
        LoopResetTriggers(SPELLTRIGGER_NOT_GOT_FIRST_SPELL, oTrigger);
        LoopResetTriggers(SPELLTRIGGER_DAMAGED_AT_PERCENT, oTrigger);
        LoopResetTriggers(SPELLTRIGGER_IMMOBILE, oTrigger);
        LoopResetTriggers(SPELLTRIGGER_START_OF_COMBAT, oTrigger);
    }
    // Some sitting for a few seconds.
    //ActionPlayAnimation(ANIMATION_LOOPING_SIT_CROSS, f1, f6);
    //DelayCommand(f9, ExecuteScript(FILE_WALK_WAYPOINTS, OBJECT_SELF));

    // Fire End-heartbeat-UDE
    FireUserEvent(AI_FLAG_UDE_RESTED_EVENT, EVENT_RESTED_EVENT);
}

// Resets all spell triggers used for sString
void LoopResetTriggers(string sString, object oTrigger)
{
    int iCnt, iBreak, iUsed;
    for(iCnt = i1; iBreak != TRUE; iCnt++)
    {
        // Check max for this setting
        iUsed = GetLocalInt(oTrigger, sString + USED);
        if(iUsed)
        {
            DeleteLocalInt(oTrigger, sString + USED);
        }
        else
        {
            iBreak = TRUE;
        }
    }
}
