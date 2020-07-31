#include "nwnx_events"

void main()
{
    if (GetIsInCombat(OBJECT_SELF))
    {
        SendMessageToPC(OBJECT_SELF, "You cannot use healing kits while in combat!");
        NWNX_Events_SkipEvent();
    }
}
