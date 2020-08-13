#include "inc_debug"
#include "inc_event"

void main()
{
    object oEventCreature = CreateEventCreature("paladin");

    SendDebugMessage("event creature created: "+GetName(oEventCreature), TRUE);
}
