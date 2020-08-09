#include "inc_debug"

void main()
{
    object oEventCreature = CreateObject(OBJECT_TYPE_CREATURE, "militia", GetLocation(OBJECT_SELF));
    DeleteLocalInt(oEventCreature, "respawn");

    SendDebugMessage("event creature created: "+GetName(oEventCreature), TRUE);
}
