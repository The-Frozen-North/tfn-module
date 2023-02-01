void main()
{
    object oPC = GetLastUsedBy();

    if (GetIsInCombat(oPC)) return;

    location lLocation = GetLocation(GetObjectByTag("JharegExitPortal"));

    effect eVFX = EffectVisualEffect(VFX_IMP_UNSUMMON);

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_UNSUMMON), GetLocation(oPC));
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_UNSUMMON), lLocation);

    FadeToBlack(oPC);

    AssignCommand(oPC, ClearAllActions());

    DelayCommand(1.0, AssignCommand(oPC, ActionJumpToLocation(lLocation)));
    DelayCommand(1.0, FadeFromBlack(oPC));
}
