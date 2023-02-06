int StartingConditional()
{
    effect eTest = GetFirstEffect(OBJECT_SELF);
    while (GetIsEffectValid(eTest))
    {
        if (GetEffectType(eTest) == EFFECT_TYPE_CUTSCENE_PARALYZE)
        {
            return 1;
        }
        eTest = GetNextEffect(OBJECT_SELF);
    }
    return 0;
}
