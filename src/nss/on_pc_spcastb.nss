#include "nwnx_events"
#include "inc_horse"

void main()
{
    if (GetIsPC(OBJECT_SELF) && GetIsMounted(OBJECT_SELF))
    {
        SendMessageToPC(OBJECT_SELF, "You cannot cast spells while mounted.");
        NWNX_Events_SkipEvent();
    }
}
