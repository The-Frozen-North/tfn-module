
// Activates the transition to the DME entry waypoint.

void main()
{
    SetTransitionTarget(GetObjectByTag("DME_Transition"), GetWaypointByTag("DME_Entry"));
}
