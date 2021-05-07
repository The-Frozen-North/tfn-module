#include "inc_ai_event"

void main()
{
    DeleteLocalInt(OBJECT_SELF, "invis");
    DeleteLocalInt(OBJECT_SELF, "gsanc");
    DeleteLocalInt(OBJECT_SELF, "combat");
    DeleteLocalInt(OBJECT_SELF, "fast_buffed");
    SignalEvent(OBJECT_SELF, EventUserDefined(GS_EV_ON_RESTED));
}

