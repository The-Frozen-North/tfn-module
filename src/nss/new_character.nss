#include "inc_persist"
#include "inc_xp"
#include "inc_gold"
#include "inc_quest"

void main()
{
    object oPC = OBJECT_SELF;
    GiveXPToCreature(oPC, 1);

// They might as well start off with a set of healing potions.
    CreateItemOnObject("cure_potion1", oPC, 3);

// And a healing kit.
    CreateItemOnObject("misc24", oPC, 1);

// Give some gold
   GiveGoldToCreature(oPC, CharismaModifiedGold(oPC, 200));

// Based on their class, we will give them some sort of starting equipment.
    object oChest, oLeftHand, oRightHand, oArrows, oBolts, oBullets;

    int nClass = GetClassByPosition(1, oPC);

    switch (nClass)
    {
        case CLASS_TYPE_BARBARIAN:
            oChest = CreateItemOnObject("nw_aarcl008", oPC); // hide armor
            oLeftHand = CreateItemOnObject("nw_waxbt001", oPC); // battleaxe
            CreateItemOnObject("nw_wthax001", oPC, 30); // throwing axe
        break;
        case CLASS_TYPE_BARD:
            oChest = CreateItemOnObject("nw_aarcl009", oPC); // padded armor
            CreateItemOnObject("nw_wswdg001", oPC); //dagger
            oBolts = CreateItemOnObject("nw_wambo001", oPC, 99); // bolts
            oLeftHand = CreateItemOnObject("nw_wbwxl001", oPC); // light crossbow
        break;
        case CLASS_TYPE_CLERIC:
            oChest = CreateItemOnObject("nw_aarcl009", oPC); // padded armor
            oLeftHand = CreateItemOnObject("nw_wblml001", oPC); //mace
            oRightHand = CreateItemOnObject("nw_ashsw001", oPC); // small shield
            oBullets = CreateItemOnObject("nw_wambu001", oPC, 99); // bullets
            CreateItemOnObject("nw_wbwsl001", oPC); // sling
        break;
        case CLASS_TYPE_FIGHTER:
            oChest = CreateItemOnObject("nw_aarcl012", oPC); // chain shirt
            oLeftHand = CreateItemOnObject("nw_wswls001", oPC); //long sword
            oArrows = CreateItemOnObject("nw_wamar001", oPC, 99); // arrows
            CreateItemOnObject("nw_wbwsh001", oPC); // shortbow
        break;
        case CLASS_TYPE_PALADIN:
            oChest = CreateItemOnObject("nw_aarcl003", oPC); // scale mail
            oLeftHand = CreateItemOnObject("nw_wblms001", oPC); // morningstar
            oBolts = CreateItemOnObject("nw_wambo001", oPC, 99); // bolts
            CreateItemOnObject("nw_wbwxl001", oPC); // light crossbow
        break;
        case CLASS_TYPE_DRUID:
            oChest = CreateItemOnObject("nw_aarcl001", oPC); // leather armor
            oLeftHand = CreateItemOnObject("nw_wspsc001", oPC); //sickle
            oRightHand = CreateItemOnObject("nw_ashsw001", oPC); // small shield
            oBullets = CreateItemOnObject("nw_wambu001", oPC, 99); // bullets
            CreateItemOnObject("nw_wbwsl001", oPC); // sling
        break;
        case CLASS_TYPE_RANGER:
            oChest = CreateItemOnObject("nw_aarcl002", oPC); // studded leather armor
            oLeftHand = CreateItemOnObject("nw_wswss001", oPC); //short sword
            oRightHand = CreateItemOnObject("nw_waxhn001", oPC); //handaxe
            oArrows = CreateItemOnObject("nw_wamar001", oPC, 99); // arrows
            CreateItemOnObject("nw_wbwsh001", oPC); // shortbow
        break;
        case CLASS_TYPE_ROGUE:
            oChest = CreateItemOnObject("nw_aarcl001", oPC); // leather armor
            CreateItemOnObject("nw_wswdg001", oPC); //dagger
            oArrows = CreateItemOnObject("nw_wamar001", oPC, 99); // arrows
            oLeftHand = CreateItemOnObject("nw_wbwsh001", oPC); // shortbow
        break;
        case CLASS_TYPE_SORCERER:
            oChest = CreateItemOnObject("nw_cloth008", oPC); // sorcerer's outfit
            CreateItemOnObject("nw_wswdg001", oPC); //dagger
            oLeftHand = CreateItemOnObject("nw_wthdt001", oPC, 50); // dart
        break;
        case CLASS_TYPE_WIZARD:
            oChest = CreateItemOnObject("nw_cloth005", oPC); // wizard's outfit
            CreateItemOnObject("nw_wswdg001", oPC); //dagger
            oBolts = CreateItemOnObject("nw_wambo001", oPC, 99); // bolts
            oLeftHand = CreateItemOnObject("nw_wbwxl001", oPC); // light crossbow
        break;
        case CLASS_TYPE_MONK:
            oChest = CreateItemOnObject("nw_cloth016", oPC); // monks outfit
            oLeftHand = CreateItemOnObject("nw_wspka001", oPC); //kama
            CreateItemOnObject("nw_wthsh001", oPC, 50); // shuriken
        break;
        default:
            oChest = CreateItemOnObject("nw_cloth022", oPC); // commoners outfit
            oLeftHand = CreateItemOnObject("nw_wswdg001", oPC); //dagger
        break;
    }

    DelayCommand(0.5, AssignCommand(oPC, ActionEquipItem(oChest, INVENTORY_SLOT_CHEST)));
    DelayCommand(0.5, AssignCommand(oPC, ActionEquipItem(oLeftHand, INVENTORY_SLOT_LEFTHAND)));
    DelayCommand(0.5, AssignCommand(oPC, ActionEquipItem(oRightHand, INVENTORY_SLOT_RIGHTHAND)));
    DelayCommand(0.5, AssignCommand(oPC, ActionEquipItem(oArrows, INVENTORY_SLOT_ARROWS)));
    DelayCommand(0.5, AssignCommand(oPC, ActionEquipItem(oBullets, INVENTORY_SLOT_BULLETS)));
    DelayCommand(0.5, AssignCommand(oPC, ActionEquipItem(oBolts, INVENTORY_SLOT_BOLTS)));

    SendDebugMessage("New player script finished");

}
