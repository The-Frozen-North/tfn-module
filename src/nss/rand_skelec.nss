#include "nwnx_creature"

void main()
{
    object oWeapon;

    switch (d6())
    {
        case 1:
            oWeapon = CreateItemOnObject("nw_wplmhb010", OBJECT_SELF); // halberd +2
        break;
        case 2:
            oWeapon = CreateItemOnObject("nw_wplmhb010", OBJECT_SELF); // heavy flail +2
        break;
        case 3:
            oWeapon = CreateItemOnObject("nw_wplmss010", OBJECT_SELF); // spear +2
        break;
        case 4:
            oWeapon = CreateItemOnObject("nw_wplmsc010", OBJECT_SELF); // scythe +2
        break;
        case 5:
            oWeapon = CreateItemOnObject("nw_wswmgs011", OBJECT_SELF); // greatsword +2
        break;
        case 6:
            oWeapon = CreateItemOnObject("nw_waxmgr009", OBJECT_SELF); // greataxe +2
        break;
    }

    AssignCommand(OBJECT_SELF, ActionEquipItem(oWeapon, INVENTORY_SLOT_RIGHTHAND));
    SetDroppableFlag(oWeapon, FALSE);
    SetPickpocketableFlag(oWeapon, FALSE);
}
