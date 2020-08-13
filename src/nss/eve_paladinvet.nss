#include "inc_debug"
#include "inc_event"

void main()
{
    object oEventCreature = CreateEventCreature("paladin_vet");

    SendDebugMessage("event creature created: "+GetName(oEventCreature), TRUE);
}
