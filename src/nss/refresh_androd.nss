void main()
{
    object oDoor = GetObjectByTag("DocksToAndrod");

    AssignCommand(oDoor, ActionCloseDoor(oDoor));
    SetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_MELEE_ATTACKED, "bash_lock");
    SetLocked(oDoor, TRUE);
}
