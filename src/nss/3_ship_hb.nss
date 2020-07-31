void main()
{
    object oDestination = GetObjectByTag(GetLocalString(OBJECT_SELF, "destination"));

// return if invalid location
    if (!GetIsObjectValid(oDestination)) return;

    location lLocation = GetLocation(oDestination);

    int nTravelTime = GetLocalInt(OBJECT_SELF, "travel_time") - 1;

    if (nTravelTime < -1) nTravelTime = -1;

    SetLocalInt(OBJECT_SELF, "travel_time", nTravelTime);

// do teleport
    if (nTravelTime <= 0)
    {
        object oPC = GetFirstObjectInArea(OBJECT_SELF);

        while (GetIsObjectValid(oPC))
        {
            if (GetIsPC(oPC)) AssignCommand(oPC, ActionJumpToLocation(lLocation));

            oPC = GetNextObjectInArea(OBJECT_SELF);
        }
    }
}
