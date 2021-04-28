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


void main()
{
    TakeGoldFromCreature(100000, OBJECT_SELF, TRUE);

    // If we are set to, don't fire this script at all
    if(GetAIInteger(I_AM_TOTALLY_DEAD)) return;

    // Pre-death-event. Returns TRUE if we interrupt this script call.
    if(FirePreUserEvent(AI_FLAG_UDE_DEATH_PRE_EVENT, EVENT_DEATH_PRE_EVENT)) return;

    // Note: No AI on/off check here.

    // Who killed us? (alignment changing, debug, XP).
    object oKiller = GetLastKiller();

    // only give credit if a PC or their associate killed it or if it was already tagged
    if (GetIsPC(GetMaster(oKiller)) || GetIsPC(oKiller) || (GetLocalInt(OBJECT_SELF, "player_tagged") == 1))
    {
        ExecuteScript("party_credit", OBJECT_SELF);
    }

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
            SetLocalTimer(AI_TIMER_DEATH_EFFECT_DEATH, 2.0);
            // This should make the last killer us.
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), OBJECT_SELF);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(GetMaxHitPoints()), OBJECT_SELF);
        }
    }
    else if(oKiller != OBJECT_SELF)
    {
        // Set have died once, stops giving out mulitple amounts of XP.
        SetAIInteger(WE_HAVE_DIED_ONCE, TRUE);

/*/////////////////////// [Experience] /////////////////////////////////////////
    THIS is the place for it, below this comment.

    It is useful to use GetFirstFactionMember (and Next), GiveXPToCreature,
    GetXP, SetXP, GetChallengeRating (of self) all are really useful.

    Bug note: GetFirstFactionMember/Next with the PC parameter means either ONLY PC,
    and so NPC henchmen, unless FALSE is used, will not be even recognised.
///////////////////////// [Experience] ///////////////////////////////////////*/
    // Do XP things (Use object "oKiller" for who killed us).



/*/////////////////////// [Experience] ///////////////////////////////////////*/
    }

    // Note: Here we do a simple way of checking how many times we have died.
    // Nothing special. Debugging most useful aspect.
    int nDeathCounterNew = GetAIInteger(AMOUNT_OF_DEATHS);
    nDeathCounterNew++;
    SetAIInteger(AMOUNT_OF_DEATHS, nDeathCounterNew);

    // Here is the last time (in game seconds) we died. It is used in the executed script
    // to make sure we don't prematurly remove areselves.

    // We may want some sort of visual effect - like implosion or something, to fire.
    int nDeathEffect = GetAIConstant(AI_DEATH_VISUAL_EFFECT);

    // Valid constants from 0 and up. Apply to our location (not to us, who will go!)
    if(nDeathEffect >= 0)
    {
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(nDeathEffect), GetLocation(OBJECT_SELF));
    }
    // Default Commoner alignment changing. (If the commoner is not evil!)
    if(GetLevelByClass(CLASS_TYPE_COMMONER) > 0 &&
       GetAlignmentGoodEvil(OBJECT_SELF) != ALIGNMENT_EVIL &&
      !GetSpawnInCondition(AI_FLAG_OTHER_NO_COMMONER_ALIGNMENT_CHANGE, AI_OTHER_MASTER))
    {
        if(GetIsPC(oKiller))
        {
            AdjustAlignment(oKiller, ALIGNMENT_EVIL, 5);
        }
        else
        {
            // If it is a summon, henchmen or familar of a PC, we adust the PC itself
            // Clever, eh?
            object oMaster = GetMaster(oKiller);
            if(GetIsObjectValid(oMaster) && GetIsPC(oMaster))
            {
                AdjustAlignment(oMaster, ALIGNMENT_EVIL, 5);
            }
        }
    }
    // Always shout when we are killed. Reactions - Morale penalty, and
    // attack the killer.
    AISpeakString(AI_SHOUT_I_WAS_KILLED);

    // Speaks the set death speak, like "AGGGGGGGGGGGGGGGGGGG!! NOOOO!" for instance :-)
    // Note for 1.4: No need for "CanSpeak()" for this, of course.
    SpeakArrayString(AI_TALK_ON_DEATH);

    ExecuteScript("murder_dismiss", OBJECT_SELF);

    string sScript = GetLocalString(OBJECT_SELF, "death_script");
    if (sScript != "") ExecuteScript(sScript);


    // Signal the death event.
    FireUserEvent(AI_FLAG_UDE_DEATH_EVENT, EVENT_DEATH_EVENT);
}
