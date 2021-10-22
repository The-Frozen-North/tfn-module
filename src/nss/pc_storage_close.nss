void main()
{
    object oArea = GetArea(OBJECT_SELF);
    object oObject = GetFirstObjectInArea(oArea);

    while (GetIsObjectValid(oObject))
    {
        if (GetStringLeft(GetResRef(oObject), 7) == "storage" && GetIsOpen(oObject))
        {
            AssignCommand(oObject, ActionPlayAnimation(ANIMATION_PLACEABLE_CLOSE));
        }

        oObject = GetNextObjectInArea(oArea);
    }
    AssignCommand(GetLastClosedBy(), ClearAllActions());
}
