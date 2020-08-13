#include "inc_debug"
#include "inc_event"

void main()
{
    object oEventCreature = CreateEventCreature("ghoul");

    SendDebugMessage("event creature created: "+GetName(oEventCreature), TRUE);
}
