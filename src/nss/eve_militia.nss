#include "inc_debug"
#include "inc_event"

void main()
{
    object oEventCreature = CreateEventCreature("militia");
    DeleteLocalInt(oEventCreature, "respawn");

    SendDebugMessage("event creature created: "+GetName(oEventCreature), TRUE);
}
