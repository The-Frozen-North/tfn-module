#include "inc_debug"

object CreateEventCreature(string sResRef)
{
    object oCreature = CreateObject(OBJECT_TYPE_CREATURE, sResRef, GetLocation(OBJECT_SELF));
    SetTag(oCreature, GetResRef(GetArea(OBJECT_SELF))+"_event");
    return oCreature;
}

object CreateEventStore(string sResRef)
{
    // Other things in the merchant/store system look to depend on the tag
    // Meaning that the above approach probably won't work
    object oStore = CreateObject(OBJECT_TYPE_STORE, sResRef, GetLocation(OBJECT_SELF));
    int nIndex;
    object oArea = GetArea(OBJECT_SELF);
    for (nIndex=0; nIndex < 10; nIndex++)
    {
        string sVar = "event_store" + IntToString(nIndex);
        object oSaved = GetLocalObject(oArea, sVar);
        if (!GetIsObjectValid(oSaved))
        {
            SetLocalObject(oArea, sVar, oStore);
            break;
        }
    }
    if (nIndex >= 10)
    {
        SendDebugMessage("Warning: All event store slots on " + GetTag(oArea) + " are full, further stores will not be cleared by refresh", TRUE);
    }
    return oStore;
}

//void main() {}
