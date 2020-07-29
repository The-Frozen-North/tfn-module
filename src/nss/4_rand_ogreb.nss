#include "nwnx_creature"

void main()
{
    switch (d2())
    {
        case 2:
            SetPortraitResRef(OBJECT_SELF, "po_OgreChiefB_");
            SetCreatureAppearanceType(OBJECT_SELF, APPEARANCE_TYPE_OGRE_CHIEFTAINB);
        break;
    }

    object oWeapon;

    switch (d3())
    {
        case 1:
            oWeapon = CreateItemOnObject("nw_wblfh001", OBJECT_SELF); // heavy flail
        break;
        case 2:
            oWeapon = CreateItemOnObject("nw_wswgs001", OBJECT_SELF); // greatsword
        break;
        case 3:
            oWeapon = CreateItemOnObject("nw_waxgr001", OBJECT_SELF); // greataxe
        break;
    }

    AssignCommand(OBJECT_SELF, ActionEquipItem(oWeapon, INVENTORY_SLOT_RIGHTHAND));
    SetDroppableFlag(oWeapon, FALSE);
    SetPickpocketableFlag(oWeapon, FALSE);
}
