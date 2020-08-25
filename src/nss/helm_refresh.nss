void main()
{
    DeleteLocalInt(GetArea(OBJECT_SELF), "ambushed");

    DestroyObject(GetObjectByTag("helm_ambush", 0));
    DestroyObject(GetObjectByTag("helm_ambush", 1));
    DestroyObject(GetObjectByTag("helm_ambush", 2));
    DestroyObject(GetObjectByTag("helm_ambush", 3));
    DestroyObject(GetObjectByTag("helm_ambush", 4));

    object oDoor = GetObjectByTag("HelmToComplex");

    AssignCommand(oDoor, ActionCloseDoor(oDoor));
    SetLocked(oDoor, TRUE);

    object oDoor2 = GetObjectByTag("HelmToBeggars");

    AssignCommand(oDoor2, ActionCloseDoor(oDoor2));
    SetLocked(oDoor2, FALSE);
}
