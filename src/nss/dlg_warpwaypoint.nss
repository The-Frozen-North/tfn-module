// Jump a PC to a waypoint after a slight delay
// Param "waypoint" should be the tag of the waypoint to jump to.

#include "inc_ship"

void main()
{
    object oPC = GetPCSpeaker();
    object oArea = GetArea(oPC);
    object oWP = GetWaypointByTag(GetScriptParam("waypoint"));
    object oDestArea = GetArea(oWP);

    if (GetIsObjectValid(oWP))
    {
        FadeToBlack(oPC);
        if (oArea == oDestArea)
        {
            DelayCommand(2.5, AssignCommand(oPC, ReallyJumpToLocationInSameArea(GetLocation(oWP))));
        }
        else
        {
            DelayCommand(2.5, AssignCommand(oPC, ReallyJumpToLocation(GetLocation(oWP), 20)));
        }
        DelayCommand(5.0, FadeFromBlack(oPC));
    }

}
