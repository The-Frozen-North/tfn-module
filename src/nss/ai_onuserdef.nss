/*/////////////////////// [On User Defined] ////////////////////////////////////
    Filename: J_AI_OnUserDef or nw_c2_defaultd
///////////////////////// [Workings] ///////////////////////////////////////////
    1.4 Adds proper Pre-event functionality. Use this to make sure you keep the
    AI working, but making small additions using this event.

    Can be deleted to save space if you want :-)

    How to use user defined events (brief):

    There are a set of optional Spawn In values you can set within the spawn file.
    If you set one of the Events to fire, it will activate this script. Then,
    under the correct choice (EG I choose the Pre-Heartbeat event, then I
    uncomment the line "SetSpawnInCondition(AI_FLAG_UDE_HEARTBEAT_PRE_EVENT, AI_UDE_MASTER);"
    and find, in this file, the section with EVENT_HEARTBEAT_PRE_EVENT above it).
    add in whatever to do.

    With my Pre-heartbeat example, if I wanted it to check for a PC, then
    check for a combat dummy, and attack it, I'd add this between the brackets:

    // Code:

    // Not in combat, of course!
    if(!GetIsInCombat())
    {
        // Function in j_inc_npc_attack to get nearest PC
        object oPC = GetNearestPCCreature();
        // Why check for a PC? Well, it saves memory
        if(GetIsObjectValid(oPC) && GetDistanceToObject(oPC) <= 40.0)
        {
            object oDummy = GetNearestObjectByTag("DUMMY");
            if(GetIsObjectValid(oDummy))
            {
                ClearAllActions();
                ActionAttack(oDummy);
                // Exit (Stop the rest of the script)
                SetToExitFromUDE(EVENT_HEARTBEAT_PRE_EVENT);
                // Stop rest of script
                return;
            }
        }
    }

    // End code

    Simple, no?

    You can delete sections you don't need, and is recommended as long as you know
    how to use User Defined events.
///////////////////////// [History] ////////////////////////////////////////////
    1.3 - Added in with some documentation
    1.4 - Changed Pre-events. Now, it uses Execute Script. Will need to set
          a special string on the creature to now what script to fire.
          - It means they work correctly, however!
///////////////////////// [Arguments] //////////////////////////////////////////
    Arguments: Dependant on event. See seperate event scripts.
///////////////////////// [On User Defined] //////////////////////////////////*/

//  This contains a lot of useful things.
//  - Combat starting
//  - Constant values
//  - Get/Set spawn in values.
#include "inc_ai_other"
//  This contains some useful things to get NPC's to attack and so on.
#include "inc_ai_attack"

/************************ [UDE Values] *****************************************
    These are uneeded, but here for reference. Use the constants in the file
    "j_inc_constants" like "EVENT_HEARTBEAT_PRE_EVENT" which is classed as 1021.
    * The normal death event might not fire before the creature has vanished.
      Use the Pre-event (but with no stopping the death event) if you want a special
      death event to happen.

    Name                Normal-End event -  Pre-Event
    Heartbeat Event     1001                1021
    Percieve Event      1002                1022
    Combat Round Event  1003                1023
    Dialog Event        1004                1024
    Attack Event        1005                1025
    Damaged Event       1006                1026
    Death Event         1007                1027
    Disturbed Event     1008                1028
    Rested Event        1009                1029
    Spell Cast At Event 1011                1031
    Combat Action Event 1012                1032
    Damaged 1HP Event   1014                -
    Blocked Event       1015                1035
************************* [UDE Values] ****************************************/

void main()
{
    // Get the user defined number.
    // * NOTE: YOU MUST USE AI_GetUDENumber(), not GetUserDefinedEventNumber()!
    int nEvent = AI_GetUDENumber();

    // Events.
    switch(nEvent)
    {
        // Event Heartbeat
        // Arguments: Basically, none. Nothing activates this script. Fires every 6 seconds.
        case EVENT_HEARTBEAT_PRE_EVENT:
        {
            // This fires before the rest of the On Heartbeat file does

            // Exit (Stop the rest of the script)
            SetToExitFromUDE(EVENT_HEARTBEAT_PRE_EVENT);
        }
        break;
        case EVENT_HEARTBEAT_EVENT:
        {
            // This fires after the rest of the On Heartbeat file does

        }
        break;

        // Event Percieve
        // Arguments: GetLastPerceived, GetLastPerceptionSeen, GetLastPerceptionHeard,
        //   GetLastPerceptionVanished, GetLastPerceptionInaudible.
        case EVENT_PERCIEVE_PRE_EVENT:
        {
            // This fires before the rest of the On Percieve file does

            // Exit (Stop the rest of the script)
            SetToExitFromUDE(EVENT_PERCIEVE_PRE_EVENT);
        }
        break;
        case EVENT_PERCIEVE_EVENT:
        {
            // This fires after the rest of the On Percieve file does

        }
        break;

        // Event Combat Round End
        // Arguments: GetAttackTarget, GetLastHostileActor, GetAttemptedAttackTarget,
        //  GetAttemptedSpellTarget (Or these are useful at least!)
        case EVENT_END_COMBAT_ROUND_PRE_EVENT:
        {
            // This fires before the rest of the On Combat Round End file does

            // Exit (Stop the rest of the script)
            SetToExitFromUDE(EVENT_END_COMBAT_ROUND_PRE_EVENT);
        }
        break;
        case EVENT_END_COMBAT_ROUND_EVENT:
        {
            // This fires after the rest of the On Combat Round End file does

        }
        break;

        // Event Dialogue
        // Arguments: GetListenPatternNumber, GetLastSpeaker, TestStringAgainstPattern,
        //   GetMatchedSubstring (I think),
        case EVENT_ON_DIALOGUE_PRE_EVENT:
        {
            // This fires before the rest of the dialog file does

            // Exit (Stop the rest of the script)
            SetToExitFromUDE(EVENT_ON_DIALOGUE_PRE_EVENT);
        }
        break;
        case EVENT_ON_DIALOGUE_EVENT:
        {
            // This fires after the rest of the dialog file does

        }
        break;

        // Event Attacked
        // Arguments: GetLastAttacker, GetLastWeaponUsed, GetLastAttackMode,
        //   GetLastAttackType
        case EVENT_ATTACK_PRE_EVENT:
        {
            // This fires before the rest of the Attacked file does

            // Exit (Stop the rest of the script)
            SetToExitFromUDE(EVENT_ATTACK_PRE_EVENT);
        }
        break;
        case EVENT_ATTACK_EVENT:
        {
            // This fires after the rest of the Attacked file does

        }
        break;

        // Event Damaged
        // Arguments: GetTotalDamageDealt, GetLastDamager, GetCurrentHitPoints
        // (and max),  GetDamageDealtByType
        case EVENT_DAMAGED_PRE_EVENT:
        {
            // This fires before the rest of the damaged file does

            // Exit (Stop the rest of the script)
            SetToExitFromUDE(EVENT_DAMAGED_PRE_EVENT);
        }
        break;
        case EVENT_DAMAGED_EVENT:
        {
            // This fires after the rest of the damaged file does

        }
        break;

        // Event Death
        // Arguments: GetLastKiller
        case EVENT_DEATH_PRE_EVENT:
        {
            // This fires before the rest of the death file does

            // Exit (Stop the rest of the script)
            SetToExitFromUDE(EVENT_DEATH_PRE_EVENT);
        }
        break;
        case EVENT_DEATH_EVENT:
        {
            // This fires after the rest of the death file does

        }
        break;

        // Event Distrubed
        // Arguments: GetInventoryDisturbItem, GetLastDisturbed,
        //    GetInventoryDisturbType (should always be stolen :-( ).
        case EVENT_DISTURBED_PRE_EVENT:
        {
            // This fires before the rest of the disturbed file does

            // Exit (Stop the rest of the script)
            SetToExitFromUDE(EVENT_DISTURBED_PRE_EVENT);
        }
        break;
        case EVENT_DISTURBED_EVENT:
        {
            // This fires after the rest of the disturbed file does

        }
        break;

        // Event Rested
        // Arguments: None
        // Note: Not sure if this fires at the end of rest event, but the actual
        // duration of the rest is 0, so you never "see" it.
        case EVENT_RESTED_PRE_EVENT:
        {
            // This fires before the rest of the rested file does

            // Exit (Stop the rest of the script)
            SetToExitFromUDE(EVENT_RESTED_PRE_EVENT);
        }
        break;
        case EVENT_RESTED_EVENT:
        {
            // This fires after the rest of the rested file does

        }
        break;

        // Event Spell cast at
        // Arguments: GetLastSpellCaster, GetLastSpellHarmful GetLastSpell()
        case EVENT_SPELL_CAST_AT_PRE_EVENT:
        {
            // This fires before the rest of the Spell Cast At file does

            // Exit (Stop the rest of the script)
            SetToExitFromUDE(EVENT_SPELL_CAST_AT_PRE_EVENT);
        }
        break;
        case EVENT_SPELL_CAST_AT_EVENT:
        {
            // This fires after the rest of the Spell Cast At End file does

        }
        break;

        // Event Blocked
        // Arguements: GetBlockingDoor, GetIsDoorActionPossible, GetLocked,
        //   GetLockKeyRequired, GetLockKeyTag, GetLockUnlockDC, GetPlotFlag.
        case EVENT_ON_BLOCKED_PRE_EVENT:
        {
            // This fires before the rest of the on blocked file does

            // Exit (Stop the rest of the script)
            SetToExitFromUDE(EVENT_ON_BLOCKED_PRE_EVENT);
        }
        break;
        case EVENT_ON_BLOCKED_EVENT:
        {
            // This fires after the rest of the on blocked file does

        }
        break;

        // Event Combat Action
        // Arguments: GetAttackTarget(), and lots of others.
        // Note: Fires when DetermineCombatRound runs to perform an action.
        case EVENT_COMBAT_ACTION_PRE_EVENT:
        {
            // This fires before the rest of the Determine Combat Round call does

            // Exit (Stop the rest of the script)
            SetToExitFromUDE(EVENT_COMBAT_ACTION_PRE_EVENT);
        }
        break;
        case EVENT_COMBAT_ACTION_EVENT:
        {
            // This fires after the rest of the Determine Combat Round call does
            // Calling ClearAllActions should stop any actions added in the call.

        }
        break;

        // Event Damaged at 1 HP.
        // Arguments: None really.
        // Note: Fires OnDamaged, when we have exactly 1HP. Use for Immortal Creatures.
        case EVENT_DAMAGED_AT_1_HP:
        {
            // This fires after the rest of the On Combat Round End file does

        }
        break;

        // End all in-built events. Add more in here, if you wish.
    }
}

