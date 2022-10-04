#include "inc_debug"
#include "inc_event"
#include "inc_adventurer"

void main()
{
    object oArea = GetArea(OBJECT_SELF);
    int nAdventurerHD = GetLocalInt(oArea, "adventurer_hd");
    if (nAdventurerHD <= 0)
    {
        nAdventurerHD = GetLocalInt(oArea, "cr");
    }
    if (nAdventurerHD <= 0)
    {
        WriteTimestampedLogEntry("eve_adventure has no HD setting for adventurer in area " + GetResRef(oArea));
        //return;
    }
    if (nAdventurerHD < 3)
    {
        nAdventurerHD = 3;
    }
    
    
    int bAltered = 0;
    // Maybe vary a bit
    if (nAdventurerHD >= 4)
    {
        if (Random(100) < 30)
        {
            nAdventurerHD--;
            bAltered = 1;
        }
    }
    if (!bAltered)
    {
        if (Random(100) < 30)
        {
            nAdventurerHD++;
        }
    }
    
    if (nAdventurerHD > 12)
    {
        nAdventurerHD = 12;
    }
    
    object oEventCreature = CreateEventCreature("adventurer");
    AdvanceCreatureAlongAdventurerPath(oEventCreature, SelectAdventurerPath(), nAdventurerHD);
    EquipAdventurer(oEventCreature);
    SendDebugMessage("event creature created: "+GetName(oEventCreature), TRUE);
}
