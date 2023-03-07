#include "util_i_csvlists"

void JumpDuergar(object oDuergar, location lLoc, int nWeaponDrawn)
{
    AssignCommand(oDuergar, ClearAllActions());
    AssignCommand(oDuergar, JumpToLocation(lLoc));
    if (nWeaponDrawn && !GetIsObjectValid(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oDuergar)))
    {
        object oTest = GetFirstItemInInventory(oDuergar);
        while (GetIsObjectValid(oTest))
        {
            if (!GetPickpocketableFlag(oTest))
            {
                int nBaseItem = GetBaseItemType(oTest);
                if (nBaseItem == BASE_ITEM_SMALLSHIELD ||
                    nBaseItem == BASE_ITEM_LARGESHIELD ||
                    nBaseItem == BASE_ITEM_TOWERSHIELD)
                {
                    AssignCommand(oDuergar, ActionEquipItem(oTest, INVENTORY_SLOT_LEFTHAND));
                }
                else
                {
                    AssignCommand(oDuergar, ActionEquipItem(oTest, INVENTORY_SLOT_RIGHTHAND));
                }
            }
            oTest = GetNextItemInInventory(oDuergar);
        }
    }
    else if (!nWeaponDrawn)
    {
        AssignCommand(oDuergar, ActionUnequipItem(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oDuergar)));
        AssignCommand(oDuergar, ActionUnequipItem(GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oDuergar)));
    }
}

void main()
{
    object oPC = GetEnteringObject();
    object oMaker3 = GetObjectByTag("ud_maker3");
    int nState = GetLocalInt(OBJECT_SELF, "dahanna_ambush");
    int nTargetState = 0;
    if (!GetIsPC(oPC)) { return; }
    string sPC = GetPCPublicCDKey(oPC) + GetName(oPC);
    // If there are any other PCs in the area, we do nothing
    // Having npcs jump around will be super disjointed...
    // but it shouldn't stop Dahanna initiating the angry conversation when they
    // walk back to the boat

    // note: The boatman's convo should clear the "been in the ruins"
    // entry for a PC
    // So if you die in the ruins and come back after respawning, the duergar
    // should be okay with you rather than clustered around the door
    // angry at the PC that's... walking off the boat behind them
    // I'm not sure if a creature's location is valid in an area onenter event
    // to check if they are actually by the ruins otherwise
    object oPCTest = GetFirstPC();
    int nThereAreOtherPCs = 0;
    while (GetIsObjectValid(oPCTest))
    {
        if (GetArea(oPCTest) == OBJECT_SELF && oPC != oPCTest)
        {
            nThereAreOtherPCs = 1;
            break;
        }
        oPCTest = GetNextPC();
    }
    

    if (!nThereAreOtherPCs)
    {
        // if entering PC has been beyond the first level, the duergar should
        // be unhappy with them
        if (FindListItem(GetLocalString(oMaker3, "pcs_entered"), sPC) > -1)
        {
            nTargetState = 1;
        }
        
        //SendMessageToPC(oPC, "state = " +IntToString(nState) + ", target = " + IntToString(nTargetState));

        if (nState != nTargetState)
        {
            int nWarrior = 1;
            int nSkirmisher = 1;
            int nWeaponDrawn = nTargetState == 1 ? 1 : 0;
            string sWaypointSuffix = nTargetState == 1 ? "ambush" : "relax";
            object oTest = GetFirstObjectInArea(OBJECT_SELF);
            while (GetIsObjectValid(oTest))
            {
                if (GetObjectType(oTest) == OBJECT_TYPE_CREATURE && !GetIsPC(oTest) && !GetIsObjectValid(GetMaster(oTest)))
                {
                    string sName = GetName(oTest);
                    string sWP = "maker1_";
                    if (sName == "Duergar Skirmisher")
                    {
                        sWP = sWP + "skirmisher" + IntToString(nSkirmisher);
                        nSkirmisher++;
                    }
                    else if (sName == "Duergar Warrior")
                    {
                        sWP = sWP + "warrior" + IntToString(nWarrior);
                        nWarrior++;
                    }
                    else if (sName == "Duergar Wizard")
                    {
                        sWP = sWP + "wizard";
                    }
                    else if (sName == "Duergar Cleric")
                    {
                        sWP = sWP + "cleric";
                    }
                    else if (sName == "Dahanna")
                    {
                        sWP = sWP + "dahanna";
                    }
                    sWP = sWP + "_" + sWaypointSuffix;
                    if (nTargetState == 1)
                    {
                        // Stops wandering and makes them not return to their spawns
                        SetLocalInt(oTest, "ambient", 1);
                        SetLocalInt(oTest, "no_wander", 1);
                    }
                    else
                    {
                        DeleteLocalInt(oTest, "ambient");
                        DeleteLocalInt(oTest, "no_wander");
                    }
                    object oWP = GetWaypointByTag(sWP);
                    JumpDuergar(oTest, GetLocation(oWP), nWeaponDrawn);
                }
                oTest = GetNextObjectInArea(OBJECT_SELF);
            }
            SetLocalInt(OBJECT_SELF, "dahanna_ambush", nTargetState);
        }
    }
}
