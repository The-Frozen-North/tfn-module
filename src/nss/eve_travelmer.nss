#include "inc_debug"
#include "inc_loot"
#include "inc_event"

void main()
{
    object oMerchant = CreateEventCreature("travel_merchant");

    object oStore = CreateEventStore("mer_travel");

    SetLocalObject(oMerchant, "store", oStore);

    object oBodyguard;

    int i;
    for (i = 1; i < 4; i++)
    {
        oBodyguard = CreateEventCreature("mer_bodyguard");
        SetLocalObject(oBodyguard, "travel_merchant", oMerchant);
    }

    SendDebugMessage("event creature created: "+GetName(oMerchant), TRUE);
}
