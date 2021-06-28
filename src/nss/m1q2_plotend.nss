//::///////////////////////////////////////////////
//:: Checks that the Peninsula plot has been completed
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////


int StartingConditional()
{
return GetLocalInt(GetModule(),"NW_G_M1Q2MainPlot")==100;
}
