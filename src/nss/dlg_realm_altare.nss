void main()
{
    object oPC = GetPCSpeaker();

    location lLocation = GetLocation(GetObjectByTag("WP_REALM_EXIT"));

    ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_FNF_DISPEL_DISJUNCTION), GetLocation(oPC));
    ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_FNF_DISPEL_DISJUNCTION), lLocation);

    AssignCommand(oPC, DelayCommand(0.5, JumpToLocation(lLocation)));
}
