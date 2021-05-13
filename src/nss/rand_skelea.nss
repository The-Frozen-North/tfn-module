void main()
{
    object oWeapon;

    switch (d2())
    {
        case 1:
            oWeapon = CreateItemOnObject("cre_infhcxbow1", OBJECT_SELF);
        break;
        case 2:
            oWeapon = CreateItemOnObject("cre_infclbow1", OBJECT_SELF);
        break;
    }

    AssignCommand(OBJECT_SELF, ActionEquipItem(oWeapon, INVENTORY_SLOT_RIGHTHAND));
    SetDroppableFlag(oWeapon, FALSE);
    SetPickpocketableFlag(oWeapon, FALSE);
}
