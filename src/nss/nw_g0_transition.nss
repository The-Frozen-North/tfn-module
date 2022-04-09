void main()
{
    object oPC = GetClickingObject();
    object oTarget = GetTransitionTarget(OBJECT_SELF);
    SetAreaTransitionBMP(AREA_TRANSITION_RANDOM);
      // Jump the PC
    AssignCommand(oPC, JumpToObject(oTarget));
    // Not a PC, so has no associates
    if (!GetIsPC(oPC))
        return;

    // Get all the possible associates of this PC via loop
    object oMember = GetFirstFactionMember(oPC, FALSE);
    while (GetIsObjectValid(oMember))
    {
        if(!GetIsPC(oMember) && GetMaster(oMember)==oPC)
        {//If oMember's Master is the PC initiating the trans.. jump oMember.
            AssignCommand(oMember, ClearAllActions());
            AssignCommand(oMember, JumpToObject(oTarget));
        }//Now.. we want next faction member.
        oMember = GetNextFactionMember(oPC, FALSE);
    }
}
