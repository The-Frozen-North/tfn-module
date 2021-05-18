#include "inc_general"

void main()
{
    object oPC = GetPCSpeaker();
    object oArea = GetArea(oPC);

    ExecuteScript("pc_dth_penalty", oPC);

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_RESTORATION), GetLocation(oPC));

    location lRespawnLocation = GetLocation(GetObjectByTag("RESPAWN_NEVERWINTER"));

    object oChosenRespawn = GetObjectByTag(GetLocalString(oArea, "RESPAWN_"+SQLocalsPlayer_GetString(oPC, "respawn")));

    if (GetIsObjectValid(oChosenRespawn))
        lRespawnLocation = GetLocation(oChosenRespawn);

    SQLocalsPlayer_DeleteInt(oPC, "times_died");

    DetermineDeathEffectPenalty(oPC);

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_RESTORATION), lRespawnLocation);

    AssignCommand(oPC, JumpToLocation(lRespawnLocation));
}
