#include "nwnx_visibility"

void main()
{
// don't proceed if in combat
    if (GetIsInCombat()) return;

    object oArea = GetArea(OBJECT_SELF);

    // Simply despawn during daytime as long as you aren't in combat
    // The dusk calendar event spawns these now
    if (!GetIsAreaInterior(oArea) && GetIsDay())
    {
        DestroyObject(OBJECT_SELF);
    }
}
