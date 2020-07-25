void main()
{
    object oPC = GetLastSpeaker();

    ClearAllActions();
    ActionCastFakeSpellAtObject(SPELL_CHAIN_LIGHTNING, oPC);

    DelayCommand(2.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_LIGHTNING_S), oPC));
    DelayCommand(2.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d20(20), DAMAGE_TYPE_ELECTRICAL), oPC));
}
