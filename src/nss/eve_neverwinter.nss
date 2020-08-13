#include "inc_debug"
#include "inc_event"

void main()
{
    object oEventCreature;

    switch (d3())
    {
        case 1:
        case 2:
            oEventCreature = CreateEventCreature("nwguard");
        break;
        case 3:
            oEventCreature = CreateEventCreature("nwknight");
        break;
    }

    DeleteLocalInt(oEventCreature, "respawn");

    SendDebugMessage("event creature created: "+GetName(oEventCreature), TRUE);
}
