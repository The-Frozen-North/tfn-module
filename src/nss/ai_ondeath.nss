/*/////////////////////// [On Death] ///////////////////////////////////////////
    Filename: J_AI_OnDeath or nw_c2_default7
///////////////////////// [On Death] ///////////////////////////////////////////
    Speeded up no end, when compiling, with seperate Include.
    Cleans up all un-droppable items, all ints and all local things when destroyed.

    Check down near the bottom for a good place to add XP or corpse lines ;-)
///////////////////////// [History] ////////////////////////////////////////////
    1.3 - Added in Turn of corpses toggle
        - Added in appropriate space for XP awards, marked with ideas (effect death)
    1.4 - Removed the redudnant notes on the "You have gained 0 experience" message
///////////////////////// [Workings] ///////////////////////////////////////////
    You can edit this for experience, there is a seperate section for it.

    It will use DeathCheck to execute a cleanup-and-destroy script, that removes
    any coprse, named "j_ai_destroyself".
///////////////////////// [Arguments] //////////////////////////////////////////
    Arguments: GetLastKiller.
///////////////////////// [On Death] /////////////////////////////////////////*/

// We only require the constants/debug file. We have 1 function, not worth another include.
#include "inc_ai_constants"
#include "inc_general"

void main()
{
    TakeGoldFromCreature(100000, OBJECT_SELF, TRUE);

    // no pre-user defined events

    // Who killed us? (alignment changing, debug, XP).
    object oKiller = GetLastKiller();

    // only give credit if a PC or their associate killed it or if it was already tagged
    if (GetIsPC(GetMaster(oKiller)) || GetIsPC(oKiller) || (GetLocalInt(OBJECT_SELF, "player_tagged") == 1))
    {
        ExecuteScript("party_credit", OBJECT_SELF);
    }


    // Always shout when we are killed. Reactions - Morale penalty, and
    // attack the killer.
    AISpeakString(AI_SHOUT_I_WAS_KILLED);

    // Speaks the set death speak, like "AGGGGGGGGGGGGGGGGGGG!! NOOOO!" for instance :-)
    // Note for 1.4: No need for "CanSpeak()" for this, of course.
    SpeakArrayString(AI_TALK_ON_DEATH);

// must be called from an execute because the ai constants file uses the same name of some bio functions
    ExecuteScript("murder_dismiss");

    string sScript = GetLocalString(OBJECT_SELF, "death_script");
    if (sScript != "") ExecuteScript(sScript);

    // morale check if extra spectacular death
    if (GibsNPC(OBJECT_SELF))
    {
        DoMoraleCheckSphere(OBJECT_SELF, 16);
    }
    else
    {
        DoMoraleCheckSphere(OBJECT_SELF, 12);
    }


    // Signal the death event.
    FireUserEvent(AI_FLAG_UDE_DEATH_EVENT, EVENT_DEATH_EVENT);
}
