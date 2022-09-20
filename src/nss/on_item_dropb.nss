#include "nwnx_events"
#include "inc_persist"


void main()
{
    SendMessageToPC(GetFirstPC(), "Boing");
    if (!CanSavePCInfo(OBJECT_SELF))
    {
        FloatingTextStringOnCreature("You cannot drop items while polymorphed or bartering.", OBJECT_SELF, FALSE);
        NWNX_Events_SkipEvent();
    }
}

