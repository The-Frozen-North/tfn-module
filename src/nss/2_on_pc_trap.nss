#include "nwnx_events"
#include "1_inc_horse"

void main()
{
    if (GetIsMounted(OBJECT_SELF))
    {
        SendMessageToPC(OBJECT_SELF, "You cannot interact with traps while mounted.");
        NWNX_Events_SkipEvent();
    }
}
