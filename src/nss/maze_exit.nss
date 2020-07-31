void main()
{
    object oPC = GetLastUsedBy();

    if (GetIsInCombat(oPC)) return;

    location lLocation = GetLocation(GetObjectByTag("TP_MELDANEN"));

    ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_IMP_UNSUMMON), GetLocation(oPC));
    ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_IMP_UNSUMMON), lLocation);

    AssignCommand(oPC, DelayCommand(0.5, JumpToLocation(lLocation)));
}
