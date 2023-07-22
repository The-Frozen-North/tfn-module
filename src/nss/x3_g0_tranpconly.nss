////////////////////////////////////////////////////////////
// OnClick/OnAreaTransitionClick  - No monsters!!!
// NW_G0_Transition.nss
// Copyright (c) 2001 Bioware Corp.
////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////

void main()
{
  object oClicker = GetClickingObject();


  // * Only PC's or associates of pc's can do this
  if (GetIsPC(oClicker) || GetIsPC(GetMaster(oClicker)) == TRUE)
  {

      object oTarget = GetTransitionTarget(OBJECT_SELF);

      SetAreaTransitionBMP(AREA_TRANSITION_RANDOM);

      AssignCommand(oClicker,JumpToObject(oTarget));

          // Get all the possible associates of this PC via loop
    object oMember = GetFirstFactionMember(oClicker, FALSE);
    while (GetIsObjectValid(oMember))
    {
        if(!GetIsPC(oMember) && GetMaster(oMember)==oClicker)
        {//If oMember's Master is the PC initiating the trans.. jump oMember.
            AssignCommand(oMember, ClearAllActions());
            AssignCommand(oMember, JumpToObject(oTarget));
        }//Now.. we want next faction member.
        oMember = GetNextFactionMember(oClicker, FALSE);
    }
  }
 /* else
  This turned out to be unnecessary since GetIsPC returns true
  if a player controlled, which includes familiars.
  // * This is an NPC attempting to cross the transition
  // * Clear all actions on it (to prevent system
  // * resource eating by a creature trying to cross
  // * an area transition that it can't
  {
    AssignCommand(oClicker, ClearAllActions());
  }
  */
}

