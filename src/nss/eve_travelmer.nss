#include "inc_debug"
#include "inc_loot"

void main()
{
    object oMerchant = CreateObject(OBJECT_TYPE_CREATURE, "travel_merchant", GetLocation(OBJECT_SELF));

    object oStore = CreateObject(OBJECT_TYPE_STORE, "mer_travel", GetLocation(OBJECT_SELF));

    SetLocalObject(oMerchant, "store", oStore);

    object oBodyguard;

    int i;
    for (i = 1; i < 4; i++)
    {
        oBodyguard = CreateObject(OBJECT_TYPE_CREATURE, "mer_bodyguard", GetLocation(OBJECT_SELF));
        SetLocalObject(oBodyguard, "travel_merchant", oMerchant);
    }

    SendDebugMessage("event creature created: "+GetName(oMerchant), TRUE);
}
