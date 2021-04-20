void main()
{
    ClearAllActions();
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSleep(), OBJECT_SELF, 10.0);
    ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_IMP_SLEEP), OBJECT_SELF);
}
