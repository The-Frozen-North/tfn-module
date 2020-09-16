/************************ [On Death] *******************************************
    Filename: ai_ondeath or nw_c2_default7
************************* [On Death] *******************************************
    Speeded up no end, when compiling, with seperate Include.
    Cleans up all un-droppable items, all ints and all local things when destroyed.

    Check down near the bottom for a good place to add XP or corpse lines ;-)
************************* [History] ********************************************
    1.3 - Added in Turn of corpses toggle
        - Added in appropriate space for XP awards, marked with ideas (effect death)
************************* [Workings] *******************************************
    You can edit this for experience, there is a seperate section for it.

    It will use DeathCheck to execute a cleanup-and-destroy script, that removes
    any coprse, named "ai_destroyself".
************************* [Arguments] ******************************************
    Arguments: GetLastKiller.
************************* [On Death] ******************************************/

// We only require the constants/debug file. We have 1 function, not worth another include.
#include "inc_ai_constants"

// We need a wrapper. If the amount of deaths, got in this, is not equal to iDeaths,
// we don't execute the script, else we do. :-P
void DeathCheck(int iDeaths);

void main()
{
    // If we are set to, don't fire this script at all
    if(GetAIInteger(I_AM_TOTALLY_DEAD)) return;

    // Pre-death-event
    if(FireUserEvent(AI_FLAG_UDE_DEATH_PRE_EVENT, EVENT_DEATH_PRE_EVENT))
        // We may exit if it fires
        if(ExitFromUDE(EVENT_DEATH_PRE_EVENT)) return;

    // Note: No AI on/off check here.

    // Who killed us? (alignment changing, debug, XP).
    object oKiller = GetLastKiller();

    // Stops if we just applied EffectDeath to ourselves.
    if(GetLocalTimer(AI_TIMER_DEATH_EFFECT_DEATH)) return;

    // Special: To stop giving out multiple amounts of XP, we use EffectDeath
    // to change the killer, so the XP systems will NOT award MORE XP.
    // - Even the default one suffers from this!
    if(GetAIInteger(WE_HAVE_DIED_ONCE))
    {
        if(!GetLocalTimer(AI_TIMER_DEATH_EFFECT_DEATH))
        {
            // Don't apply effect death to self more then once per 2 seconds.
            SetLocalTimer(AI_TIMER_DEATH_EFFECT_DEATH, f2);
            // This should make the last killer us.
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), OBJECT_SELF);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(GetMaxHitPoints()), OBJECT_SELF);
        }
    }
    else if(oKiller != OBJECT_SELF)
    {
        // Set have died once, stops giving out mulitple amounts of XP.
        SetAIInteger(WE_HAVE_DIED_ONCE, TRUE);

/************************ [Experience] *****************************************
    THIS is the place for it, below this comment. To reward XP, you might want
    to first apply EffectDeath to ourselves (uncomment the example lines) which
    will remove the "You recieved 0 Experience" if you have normal XP at 0, as
    the On Death event is before the reward, and therefore now our last killer
    will be outselves. It will not cause any errors, oKiller is already set.

    Anything else, I leave to you. GetFirstFactionMember (and next), GiveXPToCreature,
    GetXP, SetXP, GetChallengeRating all are really useful.

    Bug note: GetFirstFactionMember/Next with the PC parameter means either ONLY PC
************************* [Experience] ****************************************/
    // Do XP things (Use object "oKiller").



/************************ [Experience] ****************************************/
    }

    // Note: Here we do a simple way of checking how many times we have died.
    // Nothing special. Debugging most useful aspect.
    int iDeathCounterNew = GetAIInteger(AMOUNT_OF_DEATHS);
    iDeathCounterNew++;
    SetAIInteger(AMOUNT_OF_DEATHS, iDeathCounterNew);

    // Here is the last time (in game seconds) we died. It is used in the executed script
    // to make sure we don't prematurly remove areselves.

    // We may want some sort of visual effect - like implosion or something, to fire.
    int iDeathEffect = GetAIConstant(AI_DEATH_VISUAL_EFFECT);

    // Valid constants from 0 and up. Apply to our location (not to us, who will go!)
    if(iDeathEffect >= i0)
    {
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(iDeathEffect), GetLocation(OBJECT_SELF));
    }
    // Default Commoner alignment changing. (If the commoner is not evil!)
    if(GetLevelByClass(CLASS_TYPE_COMMONER) > i0 &&
       GetAlignmentGoodEvil(OBJECT_SELF) != ALIGNMENT_EVIL &&
      !GetSpawnInCondition(AI_FLAG_OTHER_NO_COMMONER_ALIGNMENT_CHANGE, AI_OTHER_MASTER))
    {
        if(GetIsPC(oKiller))
        {
            AdjustAlignment(oKiller, ALIGNMENT_EVIL, i5);
        }
        else
        {
            // If it is a summon, henchmen or familar of a PC, we adust the PC itself
            // Clever, eh?
            object oMaster = GetMaster(oKiller);
            if(GetIsObjectValid(oMaster) && GetIsPC(oMaster))
            {
                AdjustAlignment(oMaster, ALIGNMENT_EVIL, i5);
            }
        }
    }
    // Always shout when we are killed. Reactions - Morale penalty, and attack the killer.
    AISpeakString(I_WAS_KILLED);

    // Speaks the set death speak, like "AGGGGGGGGGGGGGGGGGGG!! NOOOO!" for instance :-)
    SpeakArrayString(AI_TALK_ON_DEATH);

    // First check - do we use "destroyable corpses" or not? (default, yes)
    if(!GetSpawnInCondition(AI_FLAG_OTHER_TURN_OFF_CORPSES, AI_OTHER_MASTER))
    {
        // We will actually dissapear after 30.0 seconds if not raised.
        int iTime = GetAIInteger(AI_CORPSE_DESTROY_TIME);
        if(iTime == i0) // Error checking
        {
            iTime = i30;
        }
        // 64: "[Death] Checking corpse status in " + IntToString(iTime) + " [Killer] " + GetName(oKiller) + " [Times Died Now] " + IntToString(iDeathCounterNew)
        DebugActionSpeakByInt(64, oKiller, iTime, IntToString(iDeathCounterNew));
        // Delay check
        DelayCommand(IntToFloat(iTime), DeathCheck(iDeathCounterNew));
    }
    else
    {
/************************ [Alternative Corpses] ********************************
    This is where you can add some alternative corpse code - EG looting
    and so on, without disrupting the rest of the AI (as the corpses
    are turned off).
************************* [Alternative Corpses] *******************************/
    // Add alternative corpse code here


/************************ [Alternative Corpses] *******************************/
    }
    // Signal the death event.
    FireUserEvent(AI_FLAG_UDE_DEATH_EVENT, EVENT_DEATH_EVENT);
}

// We need a wrapper. If the amount of deaths, got in this, is not equal to iDeaths,
// we don't execute the script, else we do. :-P
void DeathCheck(int iDeaths)
{
    // Do the deaths imputted equal the amount we have suffered?
    if(GetAIInteger(AMOUNT_OF_DEATHS) == iDeaths)
    {
        // - This now includes a check for Bioware's lootable functions and using them.
        ExecuteScript(FILE_DEATH_CLEANUP, OBJECT_SELF);
    }
}
