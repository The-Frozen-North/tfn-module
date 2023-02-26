// rat opens door from other side

void main()
{
    object oWP = GetWaypointByTag("q4c_wp_rat_jump");
    object oDoor = GetNearestObjectByTag("q4c_jail_door");
    ClearAllActions();
    JumpToObject(oWP);
    DelayCommand(2.0, SetLocked(oDoor, FALSE));
    DelayCommand(2.1, AssignCommand(oDoor, ActionOpenDoor(oDoor)));
}
