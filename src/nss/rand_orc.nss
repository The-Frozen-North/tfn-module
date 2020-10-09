void main()
{
    object oWeapon, oAmmo, oBackup;
    switch (d3())
    {
        case 1:
        case 2:
            oWeapon = CreateItemOnObject("nw_waxgr001", OBJECT_SELF);
        break;
        case 3:
            oWeapon = CreateItemOnObject("nw_wbwln001", OBJECT_SELF);
            oAmmo = CreateItemOnObject("nw_wammar002", OBJECT_SELF, 99);
            oBackup = CreateItemOnObject("nw_waxbt001");

            SetDroppableFlag(oBackup, FALSE);
            SetPickpocketableFlag(oBackup, FALSE);
            SetDroppableFlag(oAmmo, FALSE);
            SetPickpocketableFlag(oAmmo, FALSE);

            AssignCommand(OBJECT_SELF, ActionEquipItem(oAmmo, INVENTORY_SLOT_ARROWS));
            SetLocalInt(OBJECT_SELF, "range", 1);
        break;
    }

    AssignCommand(OBJECT_SELF, ActionEquipItem(oWeapon, INVENTORY_SLOT_RIGHTHAND));

    SetDroppableFlag(oWeapon, FALSE);
    SetPickpocketableFlag(oWeapon, FALSE);
}
