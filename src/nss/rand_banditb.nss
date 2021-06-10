#include "nwnx_creature"

void main()
{
    SetCreatureBodyPart(CREATURE_PART_HEAD, d4(), OBJECT_SELF);

    object oMelee;

    switch (d8())
    {
        case 1:
        case 2:
        case 3:
            oMelee = CreateItemOnObject("nw_wplss001", OBJECT_SELF); // spear
        break;
        case 4:
            oMelee = CreateItemOnObject("nw_waxgr001", OBJECT_SELF); // greataxe
        break;
        case 5:
            oMelee = CreateItemOnObject("nw_wswgs001", OBJECT_SELF); // greatsword
        break;
        case 6:
            oMelee = CreateItemOnObject("nw_wswbs001", OBJECT_SELF); // bastard sword
        break;
        case 7:
            oMelee = CreateItemOnObject("nw_wplhb001", OBJECT_SELF); // halberd
        break;
        case 8:
            oMelee = CreateItemOnObject("nw_wblfh001", OBJECT_SELF); // heavy flail
        break;
    }

    AssignCommand(OBJECT_SELF, ActionEquipItem(oMelee, INVENTORY_SLOT_RIGHTHAND));

    SetDroppableFlag(oMelee, FALSE);
    SetPickpocketableFlag(oMelee, FALSE);

    SetLocalObject(OBJECT_SELF, "melee_weapon", oMelee);
}
