void main()
{
    if (IsInConversation(OBJECT_SELF)) return;

    if (d10() == 1)
    {
        ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_FNF_SMOKE_PUFF), GetLocation(OBJECT_SELF));
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectEthereal(), OBJECT_SELF, RoundsToSeconds(d3()));
    }
}
