void main()
{
    object oPC = GetEnteringObject();

    if (!GetIsPC(oPC)) return;

    string sTarget = GetLocalString(OBJECT_SELF, "target");
    string sSelf = GetLocalString(OBJECT_SELF, "self");

    object oDoor1 = GetObjectByTag("Jhareg"+sTarget+"Door1");
    object oDoor2 = GetObjectByTag("Jhareg"+sTarget+"Door2");

    if (GetLocked(oDoor1)) return;
    if (GetLocked(oDoor2)) return;

    object oSelfDoor1 = GetObjectByTag("Jhareg"+sSelf+"Door1");
    object oSelfDoor2 = GetObjectByTag("Jhareg"+sSelf+"Door2");

    if (GetLocked(oSelfDoor1)) return;
    if (GetLocked(oSelfDoor2)) return;

    effect eVFX = EffectVisualEffect(VFX_FNF_PWSTUN);

    AssignCommand(oDoor1, ActionCloseDoor(oDoor1));
    AssignCommand(oDoor2, ActionCloseDoor(oDoor2));

    SetLocked(oDoor1, TRUE);
    SetLocked(oDoor2, TRUE);

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVFX, GetLocation(oDoor1));
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVFX, GetLocation(oDoor2));
}
