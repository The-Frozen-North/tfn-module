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
    object oDesther = GetObjectByTag("desther");

    if (GetIsDead(OBJECT_SELF))
        return;

    if (GetIsDead(oDesther))
        return;

    if (GetCurrentHitPoints(oDesther) >= GetMaxHitPoints(oDesther))
        return;

    ActionCastFakeSpellAtObject(SPELL_CURE_SERIOUS_WOUNDS, OBJECT_SELF);

    DelayCommand(6.0, HealDesther());
}
