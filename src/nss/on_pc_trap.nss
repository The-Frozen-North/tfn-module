#include "nwnx_events"
#include "inc_horse"

void main()
{
    if (GetIsMounted(OBJECT_SELF))
    {
        SendMessageToPC(OBJECT_SELF, "You cannot interact with traps while mounted.");
        NWNX_Events_SkipEvent();
    }
}
