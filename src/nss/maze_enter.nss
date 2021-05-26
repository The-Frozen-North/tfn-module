void main()
{
    object oPC = GetPCSpeaker();
    location lLocation = GetLocation(GetObjectByTag("TP_MAZE"));

    ActionCastFakeSpellAtObject(SPELL_FREEDOM_OF_MOVEMENT, OBJECT_SELF);

    ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_IMP_UNSUMMON), GetLocation(oPC));
    ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_IMP_UNSUMMON), lLocation);

    AssignCommand(oPC, DelayCommand(1.5, JumpToLocation(lLocation)));
}
