void OpenAndUnlock(object oDoor)
{
    AssignCommand(oDoor, ActionOpenDoor(oDoor));
    SetLocked(oDoor, FALSE);
}

void CloseAndLock(object oDoor)
{
    AssignCommand(oDoor, ActionCloseDoor(oDoor));
    SetLocked(oDoor, TRUE);
}

void main()
{
    object oLeftDoor1 = GetObjectByTag("JharegLeftDoor1");
    object oLeftDoor2 = GetObjectByTag("JharegLeftDoor2");
    object oRightDoor1 = GetObjectByTag("JharegRightDoor1");
    object oRightDoor2 = GetObjectByTag("JharegRightDoor2");
    object oStraightDoor1 = GetObjectByTag("JharegStraightDoor1");
    object oStraightDoor2 = GetObjectByTag("JharegStraightDoor2");

    OpenAndUnlock(oLeftDoor1);
    OpenAndUnlock(oLeftDoor2);
    OpenAndUnlock(oRightDoor1);
    OpenAndUnlock(oRightDoor2);
    CloseAndLock(oStraightDoor1);
    CloseAndLock(oStraightDoor2);
}
