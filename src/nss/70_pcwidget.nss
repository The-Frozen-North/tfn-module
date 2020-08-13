//::///////////////////////////////////////////////
//:: PC Widget OnActivation Script
//:: 70_pcwidget
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*

*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow
//:://////////////////////////////////////////////

#include "x2_inc_switches"

void main()
{
    if (GetUserDefinedItemEventNumber() ==  X2_ITEM_EVENT_ACTIVATE)
    {
        object oPC = GetItemActivator();
        AssignCommand(oPC,ActionStartConversation(oPC,"70_pcwidget",TRUE,FALSE));
    }
}
