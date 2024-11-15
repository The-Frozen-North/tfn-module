#include "inc_debug"
#include "inc_area"

object CreateEventCreature(string sResRef)
{
    object oCreature = CreateObject(OBJECT_TYPE_CREATURE, sResRef, GetLocation(OBJECT_SELF));
    AddObjectToAreaCleanupList(GetArea(OBJECT_SELF), oCreature);
    return oCreature;
}

object CreateEventStore(string sResRef)
{
    object oStore = CreateObject(OBJECT_TYPE_STORE, sResRef, GetLocation(OBJECT_SELF));
    AddObjectToAreaCleanupList(GetArea(OBJECT_SELF), oStore);
    return oStore;
}

//void main() {}
