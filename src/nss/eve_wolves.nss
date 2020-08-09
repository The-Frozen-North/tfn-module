#include "inc_debug"

void main()
{
    int iMax = d4(2);

    object oEventCreature;

    int i;
    for (i = 0; i < iMax; i++)
    {
        oEventCreature = CreateObject(OBJECT_TYPE_CREATURE, "wolf", GetLocation(OBJECT_SELF));
    }

    SendDebugMessage("event creature created: "+GetName(oEventCreature), TRUE);
}
