void main()
{
    object oPC = GetPCSpeaker();
    object oArea = GetArea(oPC);

    ExecuteScript("3_pc_dth_penalty", oPC);

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_RESTORATION), GetLocation(oPC));

    location lRespawnLocation = GetLocation(GetObjectByTag("RESPAWN_NEVERWINTER"));

    object oNearestRespawn = GetObjectByTag(GetLocalString(oArea, "respawn"));
    if (GetIsObjectValid(oNearestRespawn)) lRespawnLocation = GetLocation(oNearestRespawn);

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_RESTORATION), lRespawnLocation);

    AssignCommand(oPC, JumpToLocation(lRespawnLocation));
}
