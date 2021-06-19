void main()
{
    object oMelee;

    switch (d8())
    {
        case 1:
            oMelee = CreateItemOnObject("nw_waxbt001", OBJECT_SELF); // battleaxe
        break;
        case 2:
            oMelee = CreateItemOnObject("nw_wblhw001", OBJECT_SELF); // warhammer
        break;
        case 3:
        case 4:
        case 5:
        case 6:
            oMelee = CreateItemOnObject("nw_wswls001", OBJECT_SELF); // longsword
        break;
        case 7:
            oMelee = CreateItemOnObject("nw_wblfl001", OBJECT_SELF); // light flail
        break;
        case 8:
            oMelee = CreateItemOnObject("nw_wblms001", OBJECT_SELF); // morningstar
        break;
    }

    AssignCommand(OBJECT_SELF, ActionEquipItem(oMelee, INVENTORY_SLOT_RIGHTHAND));

    SetDroppableFlag(oMelee, FALSE);
    SetPickpocketableFlag(oMelee, FALSE);

    SetLocalObject(OBJECT_SELF, "melee_weapon", oMelee);
}
