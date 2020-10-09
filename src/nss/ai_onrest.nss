#include "inc_ai_event"

void main()
{
    DeleteLocalInt(OBJECT_SELF, "invis");
    DeleteLocalInt(OBJECT_SELF, "rest");
    SignalEvent(OBJECT_SELF, EventUserDefined(GS_EV_ON_RESTED));
}

