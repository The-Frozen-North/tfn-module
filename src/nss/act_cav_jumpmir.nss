//::///////////////////////////////////////////////
//:: Name act_cav_jumpmir
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The PC is transported to the Shattered Mirror
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

    //Let's do the boat cutscene before starting the new module
   //only show the boat cutscene once...
    if (GetLocalInt(GetModule(), "X2_Cutscene115DoneOnce") == 1)
    {
        object oMirrorStartPoint = GetWaypointByTag("wp_atdocks_shaorisfell");
        AssignCommand(oPC, JumpToObject(oMirrorStartPoint));
    }
    else
    {
        SetLocalInt(GetModule(), "X2_Cutscene115DoneOnce", 1);
        SetLocalString(oPC, "X2_BoatmanModule", "wp_atdocks_shaorisfell");
        object oCutStart = GetWaypointByTag("cut115wp_pcstart");
        AssignCommand(oPC, JumpToObject(oCutStart));
    }

}
