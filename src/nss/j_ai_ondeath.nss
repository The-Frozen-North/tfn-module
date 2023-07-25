#include "inc_henchman"
#include "inc_general"

// we are NOT using jasperre's on death handler

void main()
{
    object oKiller = GetLastHostileActor();
    if (GetFactionEqual(oKiller, OBJECT_SELF))
    {
        IncrementStat(oKiller, "allies_killed");
        IncrementStat(GetMaster(OBJECT_SELF), "henchman_died");
    }
    
    if (GetLocalInt(OBJECT_SELF, "PETRIFIED") == 1)
    {
        location lLocation = GetLocation(OBJECT_SELF);
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_COM_CHUNK_STONE_MEDIUM), lLocation);
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_RESTORATION), lLocation);

        DestroyObject(OBJECT_SELF);

        // don't do the rest of the script
        return;
    }


    SpeakString("PARTY_I_WAS_ATTACKED", TALKVOLUME_SILENT_TALK);

    KillTaunt(oKiller, OBJECT_SELF);

    DestroyPet(OBJECT_SELF);

    if (GetStringLeft(GetResRef(OBJECT_SELF), 4) == "_hen")
    {
        SetLocalInt(OBJECT_SELF, "times_died", GetLocalInt(OBJECT_SELF, "times_died")+1);

        string sText = "*" + GetName(OBJECT_SELF) + " has died*";

        if (!IsCreatureRevivable(OBJECT_SELF))
        {
            sText = "*" + GetName(OBJECT_SELF) + " has died, and can only be revived by Raise Dead*";
            // Allow selecting henchmen to cast raise dead on them
            SetIsDestroyable(TRUE, TRUE, TRUE);
        }

        FloatingTextStringOnCreature(sText, GetMaster(OBJECT_SELF), FALSE);

        if (Gibs(OBJECT_SELF))
        {
            DoMoraleCheckSphere(OBJECT_SELF, MORALE_PANIC_GIB_DC);
        }
        else
        {
            DoMoraleCheckSphere(OBJECT_SELF, MORALE_PANIC_DEATH_DC);
        }
    }
    else // not a henchman and they can have die spectacularly
    {
        if (GibsNPC(OBJECT_SELF))
        {
            DoMoraleCheckSphere(OBJECT_SELF, MORALE_PANIC_GIB_DC);
        }
        else
        {
            DoMoraleCheckSphere(OBJECT_SELF, MORALE_PANIC_DEATH_DC);
        }
    }
}


/************************ [On Death] *******************************************
    Filename: j_ai_ondeath or nw_c2_default7
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
    any coprse, named "j_ai_destroyself".
************************* [Arguments] ******************************************
    Arguments: GetLastKiller.
************************* [On Death] ******************************************/
/*
// We only require the constants/debug file. We have 1 function, not worth another include.
#include "j_inc_constants"

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
*/