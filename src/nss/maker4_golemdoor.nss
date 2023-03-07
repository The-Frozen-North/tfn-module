void main()
{
    object oArea = GetArea(OBJECT_SELF);
    object oTest = GetFirstObjectInArea(oArea);
    int bOpen = 1;
    while (GetIsObjectValid(oTest))
    {
        if (GetResRef(oTest) == "mithralgolem" && !GetIsDead(oTest))
        {
            bOpen = 0;
            break;
        }
        oTest = GetNextObjectInArea(oArea);
    }

    if (bOpen)
    {
        SetLocked(OBJECT_SELF, 0);
        ActionOpenDoor(OBJECT_SELF);
    }
}
