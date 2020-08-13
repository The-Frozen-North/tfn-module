#include "inc_debug"
#include "inc_event"

void main()
{
    object oEventCreature;

    switch (d2())
    {
        case 1:
            oEventCreature = CreateEventCreature("bear_black");
            oEventCreature = CreateEventCreature("bear_black");
        case 2:
            oEventCreature = CreateEventCreature("bear_brown");
        break;
    }

    SendDebugMessage("event creature created: "+GetName(oEventCreature), TRUE);
}
