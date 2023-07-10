#include "nwnx_events"
#include "inc_general"

void main()
{
    if (GetIsDead(OBJECT_SELF))
    {
        SendMessageToPC(OBJECT_SELF, "The dead cannot speak.");
        NWNX_Events_SkipEvent();
    }
    else if (GetIsMute(OBJECT_SELF))
    {
        SendMessageToPC(OBJECT_SELF, "You cannot speak while incapacitated.");
        NWNX_Events_SkipEvent();
    }
}
