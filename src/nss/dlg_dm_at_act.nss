
// Activates the transition to the DME entry waypoint.

void main()
{
    if (!GetIsDM(GetPCSpeaker())) return;

    SetTransitionTarget(GetObjectByTag("DME_Transition"), GetWaypointByTag("DME_Entry"));
}
