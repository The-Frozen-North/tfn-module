//::///////////////////////////////////////////////
//:: Generic On Pressed Respawn Button
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
// * June 1: moved RestoreEffects into plot include
*/
//:://////////////////////////////////////////////
//:: Created By:   Brent
//:: Created On:   November
//:://////////////////////////////////////////////
#include "inc_persist"
#include "x0_i0_spells"
#include "inc_general"

void main()
{
    object oRespawner = GetLastRespawnButtonPresser();

    object oArea = GetArea(oRespawner);

    WriteTimestampedLogEntry(PlayerDetailedName(oRespawner)+" respawned.");

    //1.70: double respawn protection: if player isn't dead, dying or petrified, cancel respawn
    if (!GetIsDead(oRespawner) && !GetHasEffect(EFFECT_TYPE_PETRIFY,oRespawner))
    {
        return;
    }

    //1.72: changed to remove all effects even positive ones - as those could still be on player in case he respawned from dying
    /*
    effect eEffect = GetFirstEffect(oRespawner);
    while(GetIsEffectValid(eEffect))
    {
        RemoveEffect(oRespawner,eEffect);
        eEffect = GetNextEffect(oRespawner);
    }
    RemoveEffects(oRespawner);
    */

    SQLocalsPlayer_DeleteInt(oRespawner, "DEAD");
    SQLocalsPlayer_DeleteInt(oRespawner, "times_died");

    DetermineDeathEffectPenalty(oRespawner);

    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), oRespawner);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(GetMaxHitPoints(oRespawner)), oRespawner);

    location lRespawnLocation = GetLocation(GetObjectByTag("RESPAWN_NEVERWINTER"));

    object oChosenRespawn = GetObjectByTag(GetLocalString(oArea, "RESPAWN_"+SQLocalsPlayer_GetString(oRespawner, "respawn")));

    if (GetIsObjectValid(oChosenRespawn))
        lRespawnLocation = GetLocation(oChosenRespawn);

// Apply a visual effect
    effect eVisual = EffectVisualEffect(VFX_IMP_RESTORATION);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, oRespawner);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVisual, lRespawnLocation);

// for sergol
    SetLocalInt(oRespawner, "NW_L_I_DIED", 1);

// Teleport back to the respawn location
    AssignCommand(oRespawner, JumpToLocation(lRespawnLocation));

     SetStandardFactionReputation(STANDARD_FACTION_COMMONER, 50, oRespawner);
     SetStandardFactionReputation(STANDARD_FACTION_MERCHANT, 50, oRespawner);
     SetStandardFactionReputation(STANDARD_FACTION_DEFENDER, 50, oRespawner);

    ExecuteScript("pc_dth_penalty", oRespawner);

    DelayCommand(1.0, SavePCInfo(oRespawner));
    if (GetPCPublicCDKey(oRespawner) != "") DelayCommand(1.1, ExportSingleCharacter(oRespawner));
}
