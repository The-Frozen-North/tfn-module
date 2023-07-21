void main()
{
    string sSound = "as_cv_hammering" + IntToString(d3());

    PlaySound(sSound);

    object oHouse = GetObjectByTag(GetLocalString(OBJECT_SELF, "area"));

    object oObject = GetFirstObjectInArea(oHouse);

    while (GetIsObjectValid(oObject))
    {
        if (GetIsPC(oObject))
        {
            FloatingTextStringOnCreature("*Someone is knocking on the door.*", oObject, FALSE);
        }
        else if (GetObjectType(oObject) == OBJECT_TYPE_DOOR)
        {
            AssignCommand(oObject, PlaySound(sSound));
        }

        oObject = GetNextObjectInArea(oHouse);
    }
}
