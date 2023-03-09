void main()
{
    object oLeave = GetExitingObject();
    if (!GetIsPC(oLeave) && !GetIsObjectValid(GetMaster(oLeave)))
    {
        string sResRef = GetResRef(oLeave);
        if (GetStringLeft(sResRef, 7) == "nsword_")
        {
            location lJump = GetLocalLocation(oLeave, "spawn");
            AssignCommand(oLeave, ClearAllActions(1));
            AssignCommand(oLeave, JumpToLocation(lJump));
        }
    }
}