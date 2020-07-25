//::////////////////////////////////////////////////////////////////////////////
//:: Name Respawn Door/s v1.1
//:: FileName se_door_death
//:: Copyright (c) 2001 Bioware Corp.
//::////////////////////////////////////////////////////////////////////////////
/*
     Respawn a door after a set delay
     Set a float on the door ie. RESPAWN_TIMER = xx else the default is used
     Thanks to Craig Welburn for the insight
     Cheers to Zarathustra217
*/
//::////////////////////////////////////////////////////////////////////////////
//:: Created By: Sir Elric
//:: Created On: 8th May, 2006
//:: Modified On: 16th August, 2007
//:: Event Used: OnDeath event of a door
//::////////////////////////////////////////////////////////////////////////////

#include "1_inc_respawn"


// -----------------------------------------------------------------------------
//  CONSTANTS - Settings below
// -----------------------------------------------------------------------------

const int RESPAWN_TIMER_DEFAULT = SECONDS_TO_RESPAWN;


// -----------------------------------------------------------------------------
//  PROTOTYPES
// -----------------------------------------------------------------------------

// Respawn a door after a set delay
// If no float is set on the door ie. RESPAWN_TIMER = xx
// The default delay will be used ie. RESPAWN_TIMER_DEFAULT = xx
// oSelf: - Object calling the script
void SE_RespawnDoor(object oSelf);


// -----------------------------------------------------------------------------
//  FUNCTIONS
// -----------------------------------------------------------------------------

void SE_RespawnDoor(object oSelf)
{
    PlayAnimation(ANIMATION_DOOR_CLOSE);
    int nHealAmount = GetMaxHitPoints(oSelf) - GetCurrentHitPoints(oSelf);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(nHealAmount), oSelf);
}


// -----------------------------------------------------------------------------
//  MAIN
// -----------------------------------------------------------------------------

void main()
{
    object oSelf = OBJECT_SELF;
    SetIsDestroyable(FALSE);

    float fDelay = IntToFloat(GetLocalInt(oSelf, "respawn_seconds"));
    if(fDelay == 0.0)
        fDelay = IntToFloat(RESPAWN_TIMER_DEFAULT);

    DelayCommand(fDelay, SE_RespawnDoor(oSelf));
}
