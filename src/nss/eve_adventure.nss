#include "inc_debug"
#include "inc_event"

void main()
{
    object oEventCreature = CreateEventCreature("adventurer");

    SendDebugMessage("event creature created: "+GetName(oEventCreature), TRUE);
}
