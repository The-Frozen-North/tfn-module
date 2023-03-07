void main()
{
    if (!GetLocalInt(OBJECT_SELF, "used"))
    {
        object oWPOctagon = GetWaypointByTag("maker2_trap_mid");
        location lOctagon = GetLocation(oWPOctagon);
        object oTest = GetFirstObjectInShape(SHAPE_SPHERE, 25.0, lOctagon, FALSE, OBJECT_TYPE_TRIGGER);
        while (GetIsObjectValid(oTest))
        {
            if (GetLocalInt(oTest, "octagon_trap"))
            {
                DestroyObject(oTest);
            }
            oTest = GetNextObjectInShape(SHAPE_SPHERE, 25.0, lOctagon, FALSE, OBJECT_TYPE_TRIGGER);
        }
        SpeakString("A crunch of mechanisms can be heard from the middle of the room.");
        SetLocalInt(OBJECT_SELF, "used", 1);
    }
    else
    {
        SpeakString("There is no sign of anything happen when pulling the lever.");
    }
}
