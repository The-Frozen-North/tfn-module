#include "nwnx_creature"

void main()
{
    switch (d2())
    {
        case 2:
            NWNX_Creature_SetGender(OBJECT_SELF, GENDER_FEMALE);
            SetCreatureBodyPart(CREATURE_PART_HEAD, 12, OBJECT_SELF);
            SetPortraitResRef(OBJECT_SELF, "po_hu_f_14_");
            NWNX_Creature_SetSoundset(OBJECT_SELF, 188);
        break;
    }

    object oArmor, oRange, oMelee, oAmmo;

    switch (d10())
    {
        case 1:
        case 2:
        case 3:
        case 4:
           oArmor = CreateItemOnObject("nw_aarcl009"); //padded
        break;
        case 5:
        case 6:
        case 7:
           oArmor = CreateItemOnObject("nw_aarcl001"); //leather
        break;
        case 8:
        case 9:
           oArmor = CreateItemOnObject("nw_aarcl002"); //studded
        break;
        case 10:
           oArmor = CreateItemOnObject("nw_aarcl012"); //chain shirt
        break;
    }

    switch (d6())
    {
        case 1:
        case 2:
        case 3:
           oRange = CreateItemOnObject("nw_wbwsh001", OBJECT_SELF); // shortbow
           oAmmo = CreateItemOnObject("nw_wamar001", OBJECT_SELF, 99); // arrows
           AssignCommand(OBJECT_SELF, ActionEquipItem(oAmmo, INVENTORY_SLOT_ARROWS));
        break;
        case 4:
        case 5:
           oRange = CreateItemOnObject("nw_wbwxl001"); //light xbow
           oAmmo = CreateItemOnObject("nw_wambo001", OBJECT_SELF, 99); // bolts
           AssignCommand(OBJECT_SELF, ActionEquipItem(oAmmo, INVENTORY_SLOT_BOLTS));
        break;
        case 6:
           oRange = CreateItemOnObject("nw_wbwsl001", OBJECT_SELF); // sling
           oAmmo = CreateItemOnObject("nw_wambu001", OBJECT_SELF, 99); // bullets
           AssignCommand(OBJECT_SELF, ActionEquipItem(oAmmo, INVENTORY_SLOT_BULLETS));
        break;
    }

    switch (d10())
    {
        case 1:
        case 2:
            oMelee = CreateItemOnObject("nw_wswss001", OBJECT_SELF); // shortsword
        break;
        case 3:
        case 4:
        case 5:
            oMelee = CreateItemOnObject("nw_wswdg001", OBJECT_SELF); // dagger
        break;
        case 6:
        case 7:
            oMelee = CreateItemOnObject("nw_wblcl001", OBJECT_SELF); // club
        break;
        case 8:
            oMelee = CreateItemOnObject("nw_waxhn001", OBJECT_SELF); // handaxe
        break;
        case 9:
            oMelee = CreateItemOnObject("nw_wblmhl001", OBJECT_SELF); // light hammer
        break;
        case 10:
            oMelee = CreateItemOnObject("nw_wblml001", OBJECT_SELF); // mace
        break;
    }

    AssignCommand(OBJECT_SELF, ActionEquipItem(oRange, INVENTORY_SLOT_RIGHTHAND));
    AssignCommand(OBJECT_SELF, ActionEquipItem(oArmor, INVENTORY_SLOT_CHEST));

    SetDroppableFlag(oRange, FALSE);
    SetPickpocketableFlag(oRange, FALSE);

    SetDroppableFlag(oMelee, FALSE);
    SetPickpocketableFlag(oMelee, FALSE);

    SetDroppableFlag(oArmor, FALSE);
    SetPickpocketableFlag(oArmor, FALSE);

    SetDroppableFlag(oAmmo, FALSE);
    SetPickpocketableFlag(oAmmo, FALSE);

    SetDroppableFlag(oMelee, FALSE);
    SetPickpocketableFlag(oMelee, FALSE);

    SetLocalObject(OBJECT_SELF, "melee_weapon", oMelee);
    SetLocalObject(OBJECT_SELF, "range_weapon", oRange);
}
