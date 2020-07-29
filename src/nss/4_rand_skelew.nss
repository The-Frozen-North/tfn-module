#include "nwnx_creature"

void main()
{
    switch (d2())
    {
        case 2:
            SetPortraitResRef(OBJECT_SELF, "po_sk_war02_");
            SetCreatureAppearanceType(OBJECT_SELF, APPEARANCE_TYPE_SKELETON_WARRIOR_2);
        break;
    }

    object oWeapon;

    switch (d6())
    {
        case 1:
            oWeapon = CreateItemOnObject("nw_wplmhb002", OBJECT_SELF); // halberd +1
        break;
        case 2:
            oWeapon = CreateItemOnObject("nw_wblmfh002", OBJECT_SELF); // heavy flail +1
        break;
        case 3:
            oWeapon = CreateItemOnObject("nw_wplmss002", OBJECT_SELF); // spear +1
        break;
        case 4:
            oWeapon = CreateItemOnObject("nw_wplmsc002", OBJECT_SELF); // scythe +1
        break;
        case 5:
            oWeapon = CreateItemOnObject("nw_wswmgs002", OBJECT_SELF); // greatsword +1
        break;
        case 6:
            oWeapon = CreateItemOnObject("nw_waxmgr002", OBJECT_SELF); // greataxe +1
        break;
    }

    AssignCommand(OBJECT_SELF, ActionEquipItem(oWeapon, INVENTORY_SLOT_RIGHTHAND));
    SetDroppableFlag(oWeapon, FALSE);
    SetPickpocketableFlag(oWeapon, FALSE);
}
