void ShieldVisualEffect()
{
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_SPELL_MANTLE_USE), OBJECT_SELF);
}

void main()
{
    ExecuteScript("hb_q_talktome", OBJECT_SELF);

    DelayCommand(1.0, ShieldVisualEffect());
    DelayCommand(3.0, ShieldVisualEffect());
    DelayCommand(5.0, ShieldVisualEffect());
}
