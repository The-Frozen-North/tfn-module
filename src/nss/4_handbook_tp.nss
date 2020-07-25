void main()
{
    object oPC = GetPCSpeaker();

    ExecuteScript("3_pc_dth_penalty", oPC);

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_RESTORATION), GetLocation(oPC));

    AssignCommand(oPC, JumpToLocation(GetLocation(GetObjectByTag("NW_DEATH_TEMPLE"))));
}
