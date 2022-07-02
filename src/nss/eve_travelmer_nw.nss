#include "inc_debug"
#include "inc_loot"
#include "inc_event"

void main()
{
    object oMerchant = CreateEventCreature("travel_merch_nw");

    object oStore = CreateEventStore("mer_travel_nw");

    SetLocalObject(oMerchant, "store", oStore);

    object oBodyguard;

    int i;
    // He's not doing so well, and probably needs less protection...
    oBodyguard = CreateEventCreature("mer_bodyguard");
    SetLocalObject(oBodyguard, "travel_merchant", oMerchant);

    SendDebugMessage("event creature created: "+GetName(oMerchant), TRUE);
}
