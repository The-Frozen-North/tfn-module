void main()
{
 object oBench = OBJECT_SELF;
 object oPlayer = GetPCSpeaker();
 object oOccupent = GetSittingCreature(oBench);
 if (oOccupent == OBJECT_INVALID)
  {
   AssignCommand(oPlayer,ActionSit(oBench));
  }
}
