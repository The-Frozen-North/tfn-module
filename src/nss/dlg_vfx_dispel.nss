void main()
{
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DISPEL), OBJECT_SELF);
    DeleteLocalString(OBJECT_SELF, "heartbeat_script");
}
