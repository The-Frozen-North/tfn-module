void main()
{
    object oPC = GetPCSpeaker();

    location lLocation = GetLocation(GetObjectByTag("druid_camp"));

    ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_FNF_DISPEL_DISJUNCTION), GetLocation(oPC));
    ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_FNF_DISPEL_DISJUNCTION), lLocation);

    AssignCommand(oPC, DelayCommand(0.5, JumpToLocation(lLocation)));
}
