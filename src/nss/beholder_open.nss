void main()
{
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_PWSTUN), OBJECT_SELF);

    object oDoor = GetObjectByTag("beholder_door");

    AssignCommand(oDoor, ActionOpenDoor(oDoor));
}
