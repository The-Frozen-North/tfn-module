
// Deactivates the transition to the DME entry waypoint.

void main()
{
    if (!GetIsDM(GetPCSpeaker())) return;

    SetTransitionTarget(GetObjectByTag("DME_Transition"), OBJECT_INVALID);
}
