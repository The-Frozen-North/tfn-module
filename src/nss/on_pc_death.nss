//::///////////////////////////////////////////////
//:: Death Script
//:: NW_O0_DEATH.NSS
//:: Copyright (c) 2008 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This script handles the default behavior
    that occurs when a player dies.

    BK: October 8 2002: Overriden for Expansion

    Deva Winblood:  April 21th, 2008: Modified to
    handle dismounts when PC dies while mounted.

*/
//:://////////////////////////////////////////////
//:: Created By: Brent Knowles
//:: Created On: November 6, 2001
//:://////////////////////////////////////////////

#include "inc_persist"
#include "inc_general"
#include "inc_horse"

void main()
{
    object oPlayer = GetLastPlayerDied();
    object oItem;
    effect eEffect;

    object oKiller = GetLastHostileActor(oPlayer);
    string sDeathMessage = "You will be automatically revived if there is a friend nearby, there are no enemies, and you are out of combat, or you can respawn at the nearest Temple of Tyr at cost of XP and gold.";

    RemoveMount(oPlayer);

// Take away XP only at the first death
    if (NWNX_Object_GetInt(oPlayer, "DEAD") == 0)
    {
        location lDeathSpot = GetLocation(oPlayer);
        float fFacing = GetFacing(oPlayer);

// Create a blood spot on dying.
        object oBloodSpot = CreateObject(OBJECT_TYPE_PLACEABLE, "_pc_bloodstain", lDeathSpot);
        AssignCommand(oBloodSpot, SetFacing(fFacing));

     }

     DelayCommand(4.5, PopUpDeathGUIPanel(oPlayer, TRUE, TRUE, 0, sDeathMessage));

     NWNX_Object_SetInt(oPlayer, "DEAD", 1, TRUE);

    SavePCInfo(oPlayer);


    SetStandardFactionReputation(STANDARD_FACTION_COMMONER, 50, oPlayer);
    SetStandardFactionReputation(STANDARD_FACTION_MERCHANT, 50, oPlayer);
    SetStandardFactionReputation(STANDARD_FACTION_DEFENDER, 50, oPlayer);


// Give a gore animation if the PC took a lot of damage.

    WriteTimestampedLogEntry(PlayerDetailedName(oPlayer)+" was killed by "+GetName(oKiller)+".");

    Gibs(oPlayer);

    KillTaunt(oKiller, oPlayer);

}

