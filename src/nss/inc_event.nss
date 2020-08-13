object CreateEventCreature(string sResRef)
{
    object oCreature = CreateObject(OBJECT_TYPE_CREATURE, sResRef, GetLocation(OBJECT_SELF));
    SetTag(oCreature, GetResRef(GetArea(OBJECT_SELF))+"_event");
    return oCreature;
}

//void main() {}
