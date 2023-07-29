#include "nwnx_events"
#include "inc_general"

void main()
{
    // If the throwing weapon or ammo has ANY item property at all, it is considered magical / infinite
    if (IsAmmoInfinite(OBJECT_SELF))
    {
        NWNX_Events_SkipEvent();
    }
}
