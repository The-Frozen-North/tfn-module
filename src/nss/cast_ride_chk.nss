#include "nwnx_events"
#include "inc_horse"

void main()
{
    if (GetIsMounted(OBJECT_SELF) && GetIsInCombat(OBJECT_SELF))
    {
        SendMessageToPC(OBJECT_SELF, "You cannot cast spells in combat while mounted.");
        NWNX_Events_SkipEvent();
    }
}
