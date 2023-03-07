//maker1: isle of the maker exterior

void main()
{
    // Duergar unequip weapons and change faction
    object oTest = GetFirstObjectInArea(OBJECT_SELF);
    while (GetIsObjectValid(oTest))
    {
        if (GetObjectType(oTest) == OBJECT_TYPE_CREATURE)
        {
            string sName = GetName(oTest);
            if (sName == "Dahanna" || FindSubString(sName, "Duergar") > -1)
            {
                ChangeToStandardFaction(oTest, STANDARD_FACTION_DEFENDER);
                AssignCommand(oTest, SpeakString("defender"));
                if (sName != "Dahanna")
                {
                    SetLocalString(oTest, "conversation_override", "maker1_duergar");
                }
                AssignCommand(oTest, ActionUnequipItem(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTest)));
                AssignCommand(oTest, ActionUnequipItem(GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oTest)));
            }
        }
        oTest = GetNextObjectInArea(OBJECT_SELF);
    }
    DeleteLocalInt(OBJECT_SELF, "dahanna_ambush");
}
