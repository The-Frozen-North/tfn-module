#include "inc_debug"

void main()
{
    object oEventCreature;

    switch (d2())
    {
        case 1:
            oEventCreature = CreateObject(OBJECT_TYPE_CREATURE, "bear_black", GetLocation(OBJECT_SELF));
            oEventCreature = CreateObject(OBJECT_TYPE_CREATURE, "bear_black", GetLocation(OBJECT_SELF));
        case 2:
            oEventCreature = CreateObject(OBJECT_TYPE_CREATURE, "bear_brown", GetLocation(OBJECT_SELF));
        break;
    }

    SendDebugMessage("event creature created: "+GetName(oEventCreature), TRUE);
}
