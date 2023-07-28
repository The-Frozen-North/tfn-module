/************************ [Execute Combat Action] ******************************
    Filename: J_AI_DeterCombat
************************* [Execute Combat Action] ******************************
    Fired from other scripts, this runs an actual actions.

    It also contains the Pre-combat and Post-combat action events. In essense
    they therefore fire if they percieve a target, or a new round, or maybe
    a spell cast at - any combat action.

    Therefore, they only fire if the default AI is being used :-)

    Do NOT mess with this file, please. :-D
************************* [History] ********************************************
    1.3 - AI Include only fired from here. This script is executed from others,
          as the default in place of custom AI scripts.
************************* [Workings] *******************************************
    This is simple:

    - We execute it if there is no other AI files.
    - We use a stored target for things like "On Percieve, attack seen", so
      we react as normal.

    If there is a custom AI file specified, this won't fire.

    It cleans things up, and is the only script in the whole set that has
    j_inc_generic_ai in, reducing file size, and compile times. AI is more
    manageable too!
************************* [Arguments] ******************************************
    Arguments: See J_Inc_Generic_AI
************************* [Execute Combat Action] *****************************/

#include "j_inc_generic_ai"

int GetHasEffect(int nEffectType, object oTarget = OBJECT_SELF)
{
    effect eCheck = GetFirstEffect(oTarget);
    while(GetIsEffectValid(eCheck))
    {
        if(GetEffectType(eCheck) == nEffectType)
        {
             return TRUE;
             break;
        }
        eCheck = GetNextEffect(oTarget);
    }
    return FALSE;
}

void DoCombatVoice()
{
    if (GetIsDead(OBJECT_SELF)) return;

// don't proceed if there is a cooldown
    if (GetLocalInt(OBJECT_SELF, "battlecry_cd") == 1)
        return;

    SetLocalInt(OBJECT_SELF, "battlecry_cd", 1);

    DelayCommand(10.0+IntToFloat(d10()), DeleteLocalInt(OBJECT_SELF, "battlecry_cd"));

    string sBattlecryScript = GetLocalString(OBJECT_SELF, "battlecry_script");
    if (sBattlecryScript != "")
    {
        ExecuteScript(sBattlecryScript, OBJECT_SELF);
    }
    else
    {
        int nRand = 40;
        if (GetLocalInt(OBJECT_SELF, "boss") == 1) nRand = nRand/2;
        if (!GetHasEffect(EFFECT_TYPE_PETRIFY, OBJECT_SELF))
        {
            switch (Random(nRand))
            {
                case 0: PlayVoiceChat(VOICE_CHAT_BATTLECRY1, OBJECT_SELF); break;
                case 1: PlayVoiceChat(VOICE_CHAT_BATTLECRY2, OBJECT_SELF); break;
                case 2: PlayVoiceChat(VOICE_CHAT_BATTLECRY3, OBJECT_SELF); break;
                case 3: PlayVoiceChat(VOICE_CHAT_ATTACK, OBJECT_SELF); break;
                case 4: PlayVoiceChat(VOICE_CHAT_TAUNT, OBJECT_SELF); break;
                case 5: PlayVoiceChat(VOICE_CHAT_LAUGH, OBJECT_SELF); break;
            }
        }
    }
}

void main()
{
    if (!GetIsInCombat()) return;

    // Pre-combat-event
    if(FireUserEvent(AI_FLAG_UDE_COMBAT_ACTION_PRE_EVENT, EVENT_COMBAT_ACTION_PRE_EVENT))
        // We may exit if it fires
        if(ExitFromUDE(EVENT_COMBAT_ACTION_PRE_EVENT)) return;

    // Check: Are we imputting a target? We imputt it even if invalid
    object oTarget = GetLocalObject(OBJECT_SELF, AI_TEMP_SET_TARGET);

    // Speak combat round speakstring
    //SpeakArrayString(AI_TALK_ON_COMBAT_ROUND, TRUE);

    // Call combat round using include
    AI_DetermineCombatRound(oTarget);

    DelayCommand(IntToFloat(d10())/10.0, DoCombatVoice());

    // Delete it whatever happens
    DeleteAIObject(AI_TEMP_SET_TARGET);

    // Fire end of combat action event.
    FireUserEvent(AI_FLAG_UDE_COMBAT_ACTION_EVENT, EVENT_COMBAT_ACTION_EVENT);
}
