void main()
{
    object oDoor = GetObjectByTag("BlacklakeToZoo");

    AssignCommand(oDoor, ActionCloseDoor(oDoor));
    SetLocked(oDoor, TRUE);
}
