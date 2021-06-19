void main()
{
    object oDoor = GetObjectByTag("BlacklakeTopToHodgeTop");

    AssignCommand(oDoor, ActionCloseDoor(oDoor));
    SetEventScript(oDoor, EVENT_SCRIPT_DOOR_ON_MELEE_ATTACKED, "bash_lock");
    SetLocked(oDoor, TRUE);

    object oDoor2 = GetObjectByTag("BlacklakeBottomToHodgeBottom");

    AssignCommand(oDoor2, ActionCloseDoor(oDoor2));
    SetEventScript(oDoor2, EVENT_SCRIPT_DOOR_ON_MELEE_ATTACKED, "bash_lock");
    SetLocked(oDoor2, TRUE);
}
