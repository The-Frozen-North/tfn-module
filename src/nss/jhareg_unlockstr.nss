void OpenAndUnlock(object oDoor)
{
    AssignCommand(oDoor, ActionOpenDoor(oDoor));
    SetLocked(oDoor, FALSE);
}

void main()
{
    object oStraightDoor2 = GetObjectByTag("JharegStraightDoor2");

    OpenAndUnlock(oStraightDoor2);
}
