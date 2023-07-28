#include "nwnx_events"

void main()
{
    // If the throwing weapon or ammo has ANY item property at all, it is considered magical / infinite
    if (GetIsItemPropertyValid(GetFirstItemProperty(OBJECT_SELF)))
    {
        NWNX_Events_SkipEvent();
    }
}
