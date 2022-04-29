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
#include "inc_webhook"
#include "inc_sql"
#include "inc_penalty"

void main()
{
    object oPlayer = GetLastPlayerDied();
    object oItem;
    effect eEffect;

    if (SQLocalsPlayer_GetInt(oPlayer, "PETRIFIED") == 1)
    {
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_COM_CHUNK_STONE_MEDIUM), GetLocation(oPlayer));

        ExecuteScript("pc_respawn", oPlayer);

        // don't do the rest of the script
        return;
    }

    object oKiller = GetLastHostileActor(oPlayer);

    string sPenalty = IntToString(GetXP(oPlayer) - GetXPOnRespawn(oPlayer)) + " XP and " + IntToString(GetGoldLossOnRespawn(oPlayer)) + " gold";

    string sDeathMessage = "You will be automatically revived if there is an ally nearby, there are no enemies, and you are out of combat, or you can respawn at your chosen temple for " + sPenalty + ".";

    RemoveMount(oPlayer);

// Apply penalty only at first death
    if (SQLocalsPlayer_GetInt(oPlayer, "DEAD") == 0)
    {
        SQLocalsPlayer_SetInt(oPlayer, "times_died", SQLocalsPlayer_GetInt(oPlayer, "times_died")+1);

        location lDeathSpot = GetLocation(oPlayer);
        float fFacing = GetFacing(oPlayer);

// Create a blood spot on dying.
        object oBloodSpot = CreateObject(OBJECT_TYPE_PLACEABLE, "_pc_bloodstain", lDeathSpot);
        AssignCommand(oBloodSpot, SetFacing(fFacing));
     }

     RemoveDeathEffectPenalty(oPlayer);

     if (!IsCreatureRevivable(oPlayer))
        sDeathMessage = "You have died too many times and cannot be revived by allies. You can respawn at your chosen temple for " + sPenalty + ", or wait for a Raise Dead spell.";

     SQLocalsPlayer_SetInt(oPlayer, "DEAD", 1);

     SavePCInfo(oPlayer);

     DeathWebhook(oPlayer, oKiller);

// Give a gore animation if the PC took a lot of damage.

     WriteTimestampedLogEntry(PlayerDetailedName(oPlayer)+" was killed by "+GetName(oKiller)+".");

     if (Gibs(oPlayer))
     {
        DoMoraleCheckSphere(oPlayer, MORALE_PANIC_GIB_DC);
     }
     else
     {
        DoMoraleCheckSphere(oPlayer, MORALE_PANIC_DEATH_DC);
     }

     KillTaunt(oKiller, oPlayer);

     DelayCommand(4.5, PopUpDeathGUIPanel(oPlayer, TRUE, TRUE, 0, sDeathMessage));

}

