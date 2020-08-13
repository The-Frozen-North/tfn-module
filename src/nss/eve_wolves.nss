#include "inc_event"

void main()
{
    int iMax = d3(2);

    object oEventCreature;

    int i;
    for (i = 0; i < iMax; i++)
    {
        CreateEventCreature("wolf");
    }
}
