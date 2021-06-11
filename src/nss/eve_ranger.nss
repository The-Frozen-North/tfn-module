#include "inc_debug"
#include "inc_event"
#include "nwnx_object"

void main()
{
    object oEventCreature = CreateEventCreature("ranger");

    SetCurrentHitPoints(oEventCreature, 25);

    if (d2() == 1)
    {
        SetLocalInt(oEventCreature, "semiboss", 1);
    }
    else
    {
        SetLocalInt(oEventCreature, "no_credit", 1);
        NWNX_Object_SetDialogResref(OBJECT_SELF, "ranger");
    }

    SendDebugMessage("event creature created: "+GetName(oEventCreature), TRUE);
}
