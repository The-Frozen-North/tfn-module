#include "nwnx_events"

void main()
{
    if (GetIsDead(OBJECT_SELF))
    {
        SendMessageToPC(OBJECT_SELF, "The dead cannot speak.");
        NWNX_Events_SkipEvent();
    }
}
