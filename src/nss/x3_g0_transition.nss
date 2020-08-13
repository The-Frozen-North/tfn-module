void main()
{
    object oClicker = GetClickingObject();

// Set transition target if area has been recreated
// Courtesy of jasperre

// I think this can be commented out because the transition target is stored on area initialization
    //if (GetLocalString(OBJECT_SELF, "TRANSITION_TARGET") == "")
    //{
    //    //SendMessageToPC(GetFirstPC(), "Invalid local var, setting tag to:"+GetTag(GetTransitionTarget(OBJECT_SELF)));
    //    SetLocalString(OBJECT_SELF, "TRANSITION_TARGET", GetTag(GetTransitionTarget(OBJECT_SELF)));
    //}

    if (!GetIsObjectValid(GetTransitionTarget(OBJECT_SELF)) || !GetIsObjectValid(GetArea(GetTransitionTarget(OBJECT_SELF))))
    {
        //SendMessageToPC(GetFirstPC(), "Resetting tranistion target to:"+GetTag(GetObjectByTag(GetLocalString(OBJECT_SELF, "TRANSITION_TARGET"))));
        SetTransitionTarget(OBJECT_SELF, GetObjectByTag(GetLocalString(OBJECT_SELF, "TRANSITION_TARGET")));
    }

    //else { SendMessageToPC(GetFirstPC(), "Valid waypoint target: " + GetTag(GetTransitionTarget(OBJECT_SELF))); }
    object oTarget = GetTransitionTarget(OBJECT_SELF);

    SetAreaTransitionBMP(AREA_TRANSITION_RANDOM);

    AssignCommand(oClicker,JumpToObject(oTarget));
}
