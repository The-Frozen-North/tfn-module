
// Determine whether or not to show the "Activate DME Portal" option in the
//  wand conversation.  If the entry waypoint "DME_Entry" does not exist,
//  then we shouldn't be able to activate the transition.

int StartingConditional()
{
    if (!GetIsDM(GetPCSpeaker())) return FALSE;

    return GetIsObjectValid(GetWaypointByTag("DME_Entry"));
}
