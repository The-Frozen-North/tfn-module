//::///////////////////////////////////////////////
//:: Name act_cav_jumpisle
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The PC is transported to the Isle of the maker
    (the first time, via the boat cutscene)
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: Oct 1/03
//:://////////////////////////////////////////////

#include "x2_inc_globals"

void main()
{
    object oPC = GetPCSpeaker();

    SetGlobalInt("Island Maker Plot Started", 10);


    //Let's do the boat cutscene before starting the new module
   //only show the boat cutscene once...
    if (GetLocalInt(GetModule(), "X2_Cutscene115DoneOnce") == 1)
    {
        object oMakerStartPoint = GetWaypointByTag("q4a_pc_boat_entry");
        AssignCommand(oPC, JumpToObject(oMakerStartPoint));
    }
    else
    {
        SetLocalInt(GetModule(), "X2_Cutscene115DoneOnce", 1);
        SetLocalString(oPC, "X2_BoatmanModule", "q4a_pc_boat_entry");
        object oCutStart = GetWaypointByTag("cut115wp_pcstart");
        AssignCommand(oPC, JumpToObject(oCutStart));
    }

}
