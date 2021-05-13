void HealDesther()
{
    object oDesther = GetObjectByTag("desther");

    if (GetIsObjectValid(oDesther) && !GetIsDead(oDesther))
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(d4(3)), oDesther);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_HEALING_S), oDesther);
    }
}

void main()
{
    if (GetIsDead(OBJECT_SELF))
        return;

    object oDesther = GetObjectByTag("desther");

    ActionCastFakeSpellAtObject(SPELL_CURE_SERIOUS_WOUNDS, OBJECT_SELF);

    DelayCommand(6.0, HealDesther());
}
