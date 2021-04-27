//::///////////////////////////////////////////////
//:: Behaviors Library
//:: inc_behaviors
//:://////////////////////////////////////////////
/*
    Contains functions for managing special
    behaviors triggered via user defined events.
*/
//:://////////////////////////////////////////////
//:: Created By: Peppermint
//:: Created On: August 8, 2016
//:://////////////////////////////////////////////

#include "inc_ai_event"

/**********************************************************************
 * CONFIG PARAMETERS
 **********************************************************************/

// Determines the name of attached event scripts to be run.
const string EVENT_SCRIPT_ON_ASSOCIATE_REMOVED = "RUN_ON_ASSOCIATE_REMOVED_";
const string EVENT_SCRIPT_ON_ATTACKED =          "RUN_ON_ATTACKED_";
const string EVENT_SCRIPT_ON_BASHED =            "RUN_ON_BASHED_";
const string EVENT_SCRIPT_ON_BLOCKED =           "RUN_ON_BLOCKED_";
const string EVENT_SCRIPT_ON_CLEANUP =           "RUN_ON_CLEANUP_";
const string EVENT_SCRIPT_ON_COMBAT_ROUND_END =  "RUN_ON_COMBAT_ROUND_END_";
const string EVENT_SCRIPT_ON_DAMAGED =           "RUN_ON_DAMAGED_";
const string EVENT_SCRIPT_ON_DAYPOST =           "RUN_ON_DAYPOST_";
const string EVENT_SCRIPT_ON_DEATH =             "RUN_ON_DEATH_";
const string EVENT_SCRIPT_ON_DIALOGUE =          "RUN_ON_DIALOGUE_";
const string EVENT_SCRIPT_ON_DISTURBED =         "RUN_ON_DISTURBED_";
const string EVENT_SCRIPT_ON_GUARD_ALERT =       "RUN_ON_GUARD_ALERT_";
const string EVENT_SCRIPT_ON_GUARD_RESOLVE =     "RUN_ON_GUARD_RESOLVE_";
const string EVENT_SCRIPT_ON_HEARTBEAT =         "RUN_ON_HEARTBEAT_";
const string EVENT_SCRIPT_ON_NIGHTPOST =         "RUN_ON_NIGHTPOST_";
const string EVENT_SCRIPT_ON_OPENED =            "RUN_ON_OPENED_";
const string EVENT_SCRIPT_ON_PERCEPTION =        "RUN_ON_PERCEPTION_";
const string EVENT_SCRIPT_ON_RESTED =            "RUN_ON_RESTED_";
const string EVENT_SCRIPT_ON_SECURITY_ALERT =    "RUN_ON_SECURITY_ALERT_";
const string EVENT_SCRIPT_ON_SECURITY_HEARD =    "RUN_ON_SECURITY_HEARD_";
const string EVENT_SCRIPT_ON_SECURITY_RESOLVE =  "RUN_ON_SECURITY_RESOLVE_";
const string EVENT_SCRIPT_ON_SECURITY_SPOT =     "RUN_ON_SECURITY_SPOT_";
const string EVENT_SCRIPT_ON_SPAWN =             "RUN_ON_SPAWN_";
const string EVENT_SCRIPT_ON_SPELL_CAST_AT =     "RUN_ON_SPELL_CAST_AT_";

/**********************************************************************
 * CONSTANT DEFINITIONS
 **********************************************************************/

// Prefix to separate behavior variables from other libraries.
const string LIB_BEHAVIORS_PREFIX = "Lib_Behaviors_";

// Custom event numbers.
const int EVENT_ASSOCIATE_REMOVED = 30000;

/**********************************************************************
 * PUBLIC FUNCTION PROTOTYPES
 **********************************************************************/

// Adds a special behavior to the creature pertaining to nEvent. sScript will be
// executed when the event occurs.
void AddSpecialBehavior(object oCreature, int nEvent, string sScript);
// Runs all attached user defined events for the object that correspond to
// the given event number.
void RunSpecialBehaviors(int nEvent);
// Returns the name of the attached event scripts that correspond to
// the given event number.
string UserDefinedEventToEventScript(int nEvent);

/**********************************************************************
 * PUBLIC FUNCTION DEFINITIONS
 **********************************************************************/

//::///////////////////////////////////////////////
//:: AddSpecialBehavior
//:://////////////////////////////////////////////
/*
    Adds a special behavior to the creature
    pertaining to nEvent. sScript will be
    executed when the event occurs.
*/
//:://////////////////////////////////////////////
//:: Created By: Peppermint
//:: Created On: January 16, 2017
//:://////////////////////////////////////////////
void AddSpecialBehavior(object oCreature, int nEvent, string sScript)
{
    int i = 1;
    string sScriptPrefix = UserDefinedEventToEventScript(nEvent);

    while(GetLocalString(oCreature, sScriptPrefix + IntToString(i)) != "")
    {
        i++;
    }
    SetLocalString(oCreature, sScriptPrefix + IntToString(i), sScript);
}

//::///////////////////////////////////////////////
//:: RunSpecialBehaviors
//:://////////////////////////////////////////////
/*
    Returns all attached user defined events
    for the object that correspond to the given
    event number.
*/
//:://////////////////////////////////////////////
//:: Created By: Peppermint
//:: Created On: August 8, 2016
//:://////////////////////////////////////////////
void RunSpecialBehaviors(int nEvent)
{
    if(nEvent == GS_EV_ON_SPAWN)
    {
        if(GetLocalInt(OBJECT_SELF, LIB_BEHAVIORS_PREFIX + "OnSpawnExecuted"))
            return;
        SetLocalInt(OBJECT_SELF, LIB_BEHAVIORS_PREFIX + "OnSpawnExecuted", TRUE);
    }

    int i = 1;
    string sScript;
    string sScriptPrefix = UserDefinedEventToEventScript(nEvent);

    do
    {
        sScript = GetLocalString(OBJECT_SELF, sScriptPrefix + IntToString(i));
        ExecuteScript(sScript, OBJECT_SELF);
        i++;
    } while(sScript != "");
}

//::///////////////////////////////////////////////
//:: UserDefinedEventToEventScript
//:://////////////////////////////////////////////
/*
    Returns the name of the attached event
    scripts that correspond to the given event
    number.
*/
//:://////////////////////////////////////////////
//:: Created By: Peppermint
//:: Created On: August 8, 2016
//:://////////////////////////////////////////////
string UserDefinedEventToEventScript(int nEvent)
{
    switch(nEvent)
    {
        case EVENT_ASSOCIATE_REMOVED:    return EVENT_SCRIPT_ON_ASSOCIATE_REMOVED;
        case EVENT_ATTACKED:             return EVENT_SCRIPT_ON_ATTACKED;
        case EVENT_DAMAGED:              return EVENT_SCRIPT_ON_DAMAGED;
        case EVENT_DIALOGUE:             return EVENT_SCRIPT_ON_DIALOGUE;
        case EVENT_DISTURBED:            return EVENT_SCRIPT_ON_DISTURBED;
        case EVENT_END_COMBAT_ROUND:     return EVENT_SCRIPT_ON_COMBAT_ROUND_END;
        case EVENT_HEARTBEAT:            return EVENT_SCRIPT_ON_HEARTBEAT;
        case EVENT_PERCEIVE:             return EVENT_SCRIPT_ON_PERCEPTION;
        case EVENT_SPELL_CAST_AT:        return EVENT_SCRIPT_ON_SPELL_CAST_AT;
        case GS_EV_ON_BLOCKED:           return EVENT_SCRIPT_ON_BLOCKED;
        case GS_EV_ON_COMBAT_ROUND_END:  return EVENT_SCRIPT_ON_COMBAT_ROUND_END;
        case GS_EV_ON_CONVERSATION:      return EVENT_SCRIPT_ON_DIALOGUE;
        case GS_EV_ON_DAMAGED:           return EVENT_SCRIPT_ON_DAMAGED;
        case GS_EV_ON_DEATH:             return EVENT_SCRIPT_ON_DEATH;
        case GS_EV_ON_DISTURBED:         return EVENT_SCRIPT_ON_DISTURBED;
        case GS_EV_ON_HEART_BEAT:        return EVENT_SCRIPT_ON_HEARTBEAT;
        case GS_EV_ON_PERCEPTION:        return EVENT_SCRIPT_ON_PERCEPTION;
        case GS_EV_ON_PHYSICAL_ATTACKED: return EVENT_SCRIPT_ON_ATTACKED;
        case GS_EV_ON_RESTED:            return EVENT_SCRIPT_ON_RESTED;
        case GS_EV_ON_SPAWN:             return EVENT_SCRIPT_ON_SPAWN;
        case GS_EV_ON_SPELL_CAST_AT:     return EVENT_SCRIPT_ON_SPELL_CAST_AT;
        case SEP_EV_ON_NIGHTPOST:        return EVENT_SCRIPT_ON_NIGHTPOST;
        case SEP_EV_ON_DAYPOST:          return EVENT_SCRIPT_ON_DAYPOST;
        case SEP_EV_ON_SECURITY_HEARD:   return EVENT_SCRIPT_ON_SECURITY_HEARD;
        case SEP_EV_ON_SECURITY_SPOT:    return EVENT_SCRIPT_ON_SECURITY_SPOT;
        case SEP_EV_ON_SECURITY_RESOLVE: return EVENT_SCRIPT_ON_SECURITY_RESOLVE;
        case SEP_EV_ON_GUARD_ALERT:      return EVENT_SCRIPT_ON_GUARD_ALERT;
        case SEP_EV_ON_GUARD_RESOLVE:    return EVENT_SCRIPT_ON_GUARD_RESOLVE;
        case SEP_EV_ON_SECURITY_ALERT:   return EVENT_SCRIPT_ON_SECURITY_ALERT;
        case SEP_EV_ON_BASHED:           return EVENT_SCRIPT_ON_BASHED;
        case SEP_EV_ON_OPENED:           return EVENT_SCRIPT_ON_OPENED;
        case SEP_EV_ON_CLEANUP:          return EVENT_SCRIPT_ON_CLEANUP;
    }
    return "";
}

