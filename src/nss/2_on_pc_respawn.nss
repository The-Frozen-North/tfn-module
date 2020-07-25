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
#include "1_inc_persist"
#include "x0_i0_spells"


void main()
{
    object oRespawner = GetLastRespawnButtonPresser();

    WriteTimestampedLogEntry(PlayerDetailedName(oRespawner)+" respawned.");

    //1.70: double respawn protection: if player isn't dead, dying or petrified, cancel respawn
    if (!GetIsDead(oRespawner) && !GetHasEffect(EFFECT_TYPE_PETRIFY,oRespawner))
    {
        return;
    }

    //1.72: changed to remove all effects even positive ones - as those could still be on player in case he respawned from dying
    effect eEffect = GetFirstEffect(oRespawner);
    while(GetIsEffectValid(eEffect))
    {
        RemoveEffect(oRespawner,eEffect);
        eEffect = GetNextEffect(oRespawner);
    }
    RemoveEffects(oRespawner);

    NWNX_Object_DeleteInt(oRespawner, "DEAD");

    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), oRespawner);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(GetMaxHitPoints(oRespawner)), oRespawner);

    location lRespawnLocation = GetLocation(GetObjectByTag("NW_DEATH_TEMPLE"));

// Apply a visual effect
    effect eVisual = EffectVisualEffect(VFX_IMP_RESTORATION);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, oRespawner);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVisual, lRespawnLocation);

// Teleport back to the respawn location
    AssignCommand(oRespawner, JumpToLocation(lRespawnLocation));

    DelayCommand(1.0, SavePCInfo(oRespawner));
    if (GetPCPublicCDKey(oRespawner) != "") DelayCommand(1.1, ExportSingleCharacter(oRespawner));
}
