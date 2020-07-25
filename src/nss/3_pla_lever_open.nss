void main()
{
    ActionPlayAnimation(ANIMATION_PLACEABLE_ACTIVATE);
    if(GetLocalInt(OBJECT_SELF,"NW_L_Pulled") == FALSE)
    {
        object oDoor = GetNearestObject(OBJECT_TYPE_DOOR, OBJECT_SELF);
        SetLocked(oDoor, FALSE);
        if (GetIsOpen(oDoor))
        {
            AssignCommand(oDoor,ActionCloseDoor(oDoor));
        }
        else
        {
            AssignCommand(oDoor,ActionOpenDoor(oDoor));
        }
    }
    ActionPlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE);
}
