#include "nwnx_creature"

void main()
{
    SetCreatureBodyPart(CREATURE_PART_HEAD, 2+d4(), OBJECT_SELF);

    object oArmor, oMelee, oShield, oHelmet;

    switch (d6())
    {
        case 1:
        case 2:
        case 3:
        case 4:
           oArmor = CreateItemOnObject("nw_aarcl002"); //studded
        break;
        case 5:
           oArmor = CreateItemOnObject("nw_aarcl003"); //scale mail
        break;
        case 6:
           oArmor = CreateItemOnObject("nw_aarcl010"); //breastplate
        break;
    }

    switch (d6())
    {
        case 1:
           oHelmet = CreateItemOnObject("nw_arhe006"); //pot helmet
        break;
        case 2:
           oHelmet = CreateItemOnObject("nw_arhe003"); //winged helmet
        break;
        case 3:
           oHelmet = CreateItemOnObject("nw_arhe002"); //spike helmet
        break;
    }


    switch (d10())
    {
        case 1:
        case 2:
        case 3:
            oShield = CreateItemOnObject("nw_ashsw001", OBJECT_SELF); // smol shield
        break;
        case 4:
        case 5:
            oShield = CreateItemOnObject("nw_ashlw001", OBJECT_SELF); // large shield
        break;
        case 6:
            oShield = CreateItemOnObject("nw_ashto001", OBJECT_SELF); // tower shield
        break;
    }

    switch (d6())
    {
        case 1:
            oMelee = CreateItemOnObject("nw_waxbt001", OBJECT_SELF); // battleaxe
        break;
        case 2:
            oMelee = CreateItemOnObject("nw_wblhw001", OBJECT_SELF); // warhammer
        break;
        case 3:
            oMelee = CreateItemOnObject("nw_wswls001", OBJECT_SELF); // longsword
        break;
        case 4:
            oMelee = CreateItemOnObject("nw_wblfl001", OBJECT_SELF); // light flail
        break;
        case 5:
            oMelee = CreateItemOnObject("nw_wblms001", OBJECT_SELF); // morningstar
        break;
        case 6:
            oMelee = CreateItemOnObject("x2_wdwraxe001", OBJECT_SELF); // dwarvern waraxe
        break;
    }

    AssignCommand(OBJECT_SELF, ActionEquipItem(oArmor, INVENTORY_SLOT_CHEST));
    AssignCommand(OBJECT_SELF, ActionEquipItem(oHelmet, INVENTORY_SLOT_HEAD));
    AssignCommand(OBJECT_SELF, ActionEquipItem(oShield, INVENTORY_SLOT_LEFTHAND));

// 25% chance of using throwing axes
    if (d4() == 1)
    {
        object oRange = CreateItemOnObject("nw_wthax001", OBJECT_SELF, 50); // throwing axe
        SetLocalObject(OBJECT_SELF, "range_weapon", oRange);
        SetDroppableFlag(oRange, FALSE);
        SetPickpocketableFlag(oRange, FALSE);
        AssignCommand(OBJECT_SELF, ActionEquipItem(oRange, INVENTORY_SLOT_RIGHTHAND));
    }
    else
    {
        AssignCommand(OBJECT_SELF, ActionEquipItem(oMelee, INVENTORY_SLOT_RIGHTHAND));
    }

    SetDroppableFlag(oMelee, FALSE);
    SetPickpocketableFlag(oMelee, FALSE);

    SetDroppableFlag(oShield, FALSE);
    SetPickpocketableFlag(oShield, FALSE);

    SetDroppableFlag(oArmor, FALSE);
    SetPickpocketableFlag(oArmor, FALSE);

    SetDroppableFlag(oHelmet, FALSE);
    SetPickpocketableFlag(oHelmet, FALSE);

    SetLocalObject(OBJECT_SELF, "melee_weapon", oMelee);
}
