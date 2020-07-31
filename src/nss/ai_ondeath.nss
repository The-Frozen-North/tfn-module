//:://////////////////////////////////////////////////////
//:: NW_C2_DEFAULT7
/*
  Default OnDeath event handler for NPCs.

  Adjusts killer's alignment if appropriate and
  alerts allies to our death.
 */
//::///////////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 12/22/2002
//::///////////////////////////////////////////////////////
//::///////////////////////////////////////////////////////
//:: Modified By: Deva Winblood
//:: Modified On: April 1st, 2008
//:: Added Support for Dying Wile Mounted
//:: Modified By: Sir Elric
//:: Modified On: July 20th, 2008
//:: Added Support for Sir Elric's Simple Creature Respawns
//::///////////////////////////////////////////////////////

#include "inc_respawn"
#include "inc_general"

void main()
{
    TakeGoldFromCreature(1000, OBJECT_SELF, TRUE);

    object oKiller = GetLastKiller();

    // Call to allies to let them know we're dead
    SpeakString("NW_I_AM_DEAD", TALKVOLUME_SILENT_TALK);

    //Shout Attack my target, only works with the On Spawn In setup
    SpeakString("NW_ATTACK_MY_TARGET", TALKVOLUME_SILENT_TALK);

    StartRespawn();

// only give credit if a PC or their associate killed it or if it was already tagged
    if (GetIsPC(GetMaster(oKiller)) || GetIsPC(oKiller) || (GetLocalInt(OBJECT_SELF, "player_tagged") == 1))
    {
        ExecuteScript("party_credit", OBJECT_SELF);
    }

// Set for no credit after first death so no multiple credit is rewarded (cases of rez or resurrection)
    SetLocalInt(OBJECT_SELF, "no_credit", 1);

    string sScript = GetLocalString(OBJECT_SELF, "death_script");
    if (sScript != "") ExecuteScript(sScript);

    if (GibsNPC(OBJECT_SELF))
    {
        DoMoraleCheckSphere(OBJECT_SELF, 16);
    }
    else
    {
        DoMoraleCheckSphere(OBJECT_SELF, 12);
    }
}
