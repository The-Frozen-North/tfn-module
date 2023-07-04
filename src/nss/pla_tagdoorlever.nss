void main()
{
    if (!GetIsPC(GetLastUsedBy())) return;
    
    ActionPlayAnimation(ANIMATION_PLACEABLE_ACTIVATE);
    
    if(GetLocalInt(OBJECT_SELF,"NW_L_Pulled") == FALSE)
    {
        object oDoor = GetObjectByTag(GetLocalString(OBJECT_SELF, "door"));
        SetLocked(oDoor, FALSE);
        
        FloatingTextStringOnCreature("Something opens in the distance.", GetLastUsedBy());

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
