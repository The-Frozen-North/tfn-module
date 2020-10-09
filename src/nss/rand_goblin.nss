void main()
{
    switch (d2())
    {
        case 2:
            SetCreatureAppearanceType(OBJECT_SELF, APPEARANCE_TYPE_GOBLIN_B);
            SetPortraitResRef(OBJECT_SELF, "po_GoblinB_");
        break;
    }
    object oWeapon, oAmmo, oShield;
    switch (d2())
    {
// melee
        case 1:
            switch (d12())
            {
                case 1:
                    oWeapon = CreateItemOnObject("nw_wblcl001", OBJECT_SELF); // club
                break;
                case 2:
                    oWeapon = CreateItemOnObject("nw_waxbt001", OBJECT_SELF); // battleaxe
                break;
                case 3:
                    oWeapon = CreateItemOnObject("nw_wblhw001", OBJECT_SELF); // warhammer
                break;
                case 4:
                    oWeapon = CreateItemOnObject("nw_wswls001", OBJECT_SELF); // longsword
                break;
                case 5:
                    oWeapon = CreateItemOnObject("nw_wblfl001", OBJECT_SELF); // light flail
                break;
                case 6:
                    oWeapon = CreateItemOnObject("nw_wblms001", OBJECT_SELF); // morningstar
                break;
                case 7:
                    oWeapon = CreateItemOnObject("nw_waxhn001", OBJECT_SELF); // handaxe
                    oShield = CreateItemOnObject("nw_ashsw001", OBJECT_SELF); // small shield
                break;
                case 8:
                    oWeapon = CreateItemOnObject("nw_wswdg001", OBJECT_SELF); // dagger
                    oShield = CreateItemOnObject("nw_ashsw001", OBJECT_SELF); // small shield
                break;
                case 9:
                    oWeapon = CreateItemOnObject("nw_wswss001", OBJECT_SELF); // shortsword
                    oShield = CreateItemOnObject("nw_ashsw001", OBJECT_SELF); // small shield
                break;
                case 10:
                    oWeapon = CreateItemOnObject("nw_wspsc001", OBJECT_SELF); // sickle
                    oShield = CreateItemOnObject("nw_ashsw001", OBJECT_SELF); // small shield
                break;
                case 11:
                    oWeapon = CreateItemOnObject("nw_wblmhl001", OBJECT_SELF); // light hammer
                    oShield = CreateItemOnObject("nw_ashsw001", OBJECT_SELF); // small shield
                break;
                case 12:
                    oWeapon = CreateItemOnObject("nw_wblml001", OBJECT_SELF); // mace
                    oShield = CreateItemOnObject("nw_ashsw001", OBJECT_SELF); // small shield
                break;
            }
        break;
// range
        case 2:
            switch (d4())
            {
                case 1:
                case 2:
                    oWeapon = CreateItemOnObject("nw_wbwsh001", OBJECT_SELF); // shortbow
                    oAmmo = CreateItemOnObject("nw_wamar001", OBJECT_SELF, 99); // arrows
                    AssignCommand(OBJECT_SELF, ActionEquipItem(oAmmo, INVENTORY_SLOT_ARROWS)); // arrows
                break;
                case 3:
                    oWeapon = CreateItemOnObject("nw_wbwsl001", OBJECT_SELF); // sling
                    oAmmo = CreateItemOnObject("nw_wambu001", OBJECT_SELF, 99); // bullets
                    AssignCommand(OBJECT_SELF, ActionEquipItem(oAmmo, INVENTORY_SLOT_BULLETS));
                    oShield = CreateItemOnObject("nw_ashsw001", OBJECT_SELF); // small shield
                break;
                case 4:
                    oWeapon = CreateItemOnObject("nw_wthdt001", OBJECT_SELF, 50); // dart
                    oShield = CreateItemOnObject("nw_ashsw001", OBJECT_SELF); // small shield
                break;
            }

            SetDroppableFlag(oAmmo, FALSE);
            SetPickpocketableFlag(oAmmo, FALSE);

            SetLocalInt(OBJECT_SELF, "range", 1);
        break;
    }

    AssignCommand(OBJECT_SELF, ActionEquipItem(oWeapon, INVENTORY_SLOT_RIGHTHAND));
    AssignCommand(OBJECT_SELF, ActionEquipItem(oShield, INVENTORY_SLOT_LEFTHAND));

    SetDroppableFlag(oShield, FALSE);
    SetPickpocketableFlag(oShield, FALSE);

    SetDroppableFlag(oWeapon, FALSE);
    SetPickpocketableFlag(oWeapon, FALSE);
}
