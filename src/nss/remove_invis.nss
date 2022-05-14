void main()
{
    effect eEffect = GetFirstEffect(OBJECT_SELF);

    while (GetIsEffectValid(eEffect))
    {
        if (GetEffectType(eEffect) == EFFECT_TYPE_INVISIBILITY)
            RemoveEffect(OBJECT_SELF, eEffect);

        eEffect = GetNextEffect(OBJECT_SELF);
    }
}
