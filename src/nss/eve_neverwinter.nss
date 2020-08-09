#include "inc_debug"

void main()
{
    object oEventCreature;

    switch (d3())
    {
        case 1:
        case 2:
            oEventCreature = CreateObject(OBJECT_TYPE_CREATURE, "nwguard", GetLocation(OBJECT_SELF));
        break;
        case 3:
            oEventCreature = CreateObject(OBJECT_TYPE_CREATURE, "nwknight", GetLocation(OBJECT_SELF));
        break;
    }

    DeleteLocalInt(oEventCreature, "respawn");

    SendDebugMessage("event creature created: "+GetName(oEventCreature), TRUE);
}
