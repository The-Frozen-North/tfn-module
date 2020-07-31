void main()
{
    object oPC = GetClickingObject();

    if (GetIsObjectValid(GetItemPossessedBy(oPC, "key_water")) && GetIsObjectValid(GetItemPossessedBy(oPC, "key_earth")))
    {
        SetLocked(OBJECT_SELF, FALSE);
        AssignCommand(OBJECT_SELF, ActionOpenDoor(OBJECT_SELF));
    }
    else
    {
        FloatingTextStringOnCreature("There appears to be two keyholes on this door. You will probably need both to open it.", oPC, FALSE);
    }
}
