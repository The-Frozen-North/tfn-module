#include "inc_debug"
#include "inc_event"

void main()
{
    object oEventCreature;

    oEventCreature = CreateEventCreature("drunkard");
    oEventCreature = CreateEventCreature("brawler");

    SendDebugMessage("event creature created: "+GetName(oEventCreature), TRUE);
}
