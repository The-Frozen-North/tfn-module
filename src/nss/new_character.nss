#include "inc_persist"
#include "inc_xp"
#include "inc_gold"
#include "inc_quest"

void StripItems(object oPC)
{
    int nSlot;

    // Destroy the items in the main inventory.
    object oItem = GetFirstItemInInventory(oPC);
    while ( oItem != OBJECT_INVALID ) {
        DestroyObject(oItem);
        oItem = GetNextItemInInventory(oPC);
    }
    // Destroy equipped items.
    for ( nSlot = 0; nSlot < NUM_INVENTORY_SLOTS; ++nSlot )
        DestroyObject(GetItemInSlot(nSlot, oPC));

    // Remove all gold.
    AssignCommand(oPC, TakeGoldFromCreature(GetGold(oPC), oPC, TRUE));
}

void GiveStartingGold(object oPC)
{
    int nBalance = 1000;

    int nGoldValueFromItems = 0;

    object oItem = GetFirstItemInInventory(oPC);

    while (GetIsObjectValid(oItem))
    {
         nGoldValueFromItems = nGoldValueFromItems + GetGoldPieceValue(oItem);
         oItem = GetNextItemInInventory(oPC);
    }

    int nSlot;
    for ( nSlot = 0; nSlot < NUM_INVENTORY_SLOTS; ++nSlot )
    {
         nGoldValueFromItems = nGoldValueFromItems + GetGoldPieceValue(GetItemInSlot(nSlot, oPC));
    }

    nBalance = nBalance - nGoldValueFromItems;

    if (nBalance > 300) nBalance = 300;

    if (nBalance < 100) nBalance = 100;

    nBalance = CharismaModifiedGold(oPC, nBalance);

    GiveGoldToCreature(oPC, nBalance);

    SendDebugMessage("New player script finished");
}

void main()
{
    object oPC = OBJECT_SELF;

    if (GetXP(oPC) > 1) return;

    GiveXPToCreature(oPC, 1);

    StripItems(oPC);

// They might as well start off with a set of healing potions.
    CreateItemOnObject("cure_potion1", oPC, 3);

// And a healing kit.
    object oHealingKit = CreateItemOnObject("misc24", oPC, 1);

// And a torch.
    CreateItemOnObject("misc25", oPC, 1);

// Give some gold
   GiveGoldToCreature(oPC, CharismaModifiedGold(oPC, 200));

// Based on their class, we will give them some sort of starting equipment.
    object oChest, oLeftHand, oRightHand, oArrows, oBolts, oBullets, oWand;

    int nClass = GetClassByPosition(1, oPC);

    object oFavored;

    if (GetHasFeat(FEAT_WEAPON_FOCUS_BASTARD_SWORD, oPC)) {oFavored = CreateItemOnObject("nw_wswbs001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_BATTLE_AXE, oPC)) {oFavored = CreateItemOnObject("nw_waxbt001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_CLUB, oPC)) {oFavored = CreateItemOnObject("nw_wblcl001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_DAGGER, oPC)) {oFavored = CreateItemOnObject("nw_wswdg001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_DART, oPC)) {oFavored = CreateItemOnObject("nw_wthdt001", oPC, 50);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_DIRE_MACE, oPC)) {oFavored = CreateItemOnObject("nw_wdbma001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_DOUBLE_AXE, oPC)) {oFavored = CreateItemOnObject("nw_wdbax001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_DWAXE, oPC)) {oFavored = CreateItemOnObject("x2_wdwraxe001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_GREAT_AXE, oPC)) {oFavored = CreateItemOnObject("nw_waxgr001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_GREAT_SWORD, oPC)) {oFavored = CreateItemOnObject("nw_wswgs001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_HALBERD, oPC)) {oFavored = CreateItemOnObject("nw_wplhb001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_HAND_AXE, oPC)) {oFavored = CreateItemOnObject("nw_waxhn001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_HEAVY_CROSSBOW, oPC)) {oFavored = CreateItemOnObject("nw_wbwxh001", oPC); oBolts = CreateItemOnObject("nw_wambo001", oPC, 99);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_HEAVY_FLAIL, oPC)) {oFavored = CreateItemOnObject("nw_wblfh001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_KAMA, oPC)) {oFavored = CreateItemOnObject("nw_wspka001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_KATANA, oPC)) {oFavored = CreateItemOnObject("nw_wswka001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_KUKRI, oPC)) {oFavored = CreateItemOnObject("nw_wspku001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_CROSSBOW, oPC)) {oFavored = CreateItemOnObject("nw_wbwxl001", oPC); oBolts = CreateItemOnObject("nw_wambo001", oPC, 99);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_FLAIL, oPC)) {oFavored = CreateItemOnObject("nw_wblfl001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_HAMMER, oPC)) {oFavored = CreateItemOnObject("nw_wblhl001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_MACE, oPC)) {oFavored = CreateItemOnObject("nw_wblml001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_LONG_SWORD, oPC)) {oFavored = CreateItemOnObject("nw_wswls001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_LONGBOW, oPC)) {oFavored = CreateItemOnObject("nw_wbwln001", oPC); oArrows = CreateItemOnObject("nw_wamar001", oPC, 99);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_MORNING_STAR, oPC)) {oFavored = CreateItemOnObject("nw_wblms001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_RAPIER, oPC)) {oFavored = CreateItemOnObject("nw_wswrp001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_SCIMITAR, oPC)) {oFavored = CreateItemOnObject("nw_wswsc001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_SCYTHE, oPC)) {oFavored = CreateItemOnObject("nw_wplsc001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_SHORT_SWORD, oPC)) {oFavored = CreateItemOnObject("nw_wswss001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_SHORTBOW, oPC)) {oFavored = CreateItemOnObject("nw_wbwsh001", oPC); oArrows = CreateItemOnObject("nw_wamar001", oPC, 99);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_SHURIKEN, oPC)) {oFavored = CreateItemOnObject("nw_wthsh001", oPC, 50);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_SICKLE, oPC)) {oFavored = CreateItemOnObject("nw_wspsc001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_SLING, oPC)) {oFavored = CreateItemOnObject("nw_wbwsl001", oPC); oBullets = CreateItemOnObject("nw_wambu001", oPC, 99);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_SPEAR, oPC)) {oFavored = CreateItemOnObject("nw_wplss001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_STAFF, oPC)) {oFavored = CreateItemOnObject("nw_wdbqs001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_THROWING_AXE, oPC)) {oFavored = CreateItemOnObject("nw_wthax001", oPC, 50);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_TRIDENT, oPC)) {oFavored = CreateItemOnObject("nw_wpltr001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_TWO_BLADED_SWORD, oPC)) {oFavored = CreateItemOnObject("nw_wdbsw001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_WAR_HAMMER, oPC)) {oFavored = CreateItemOnObject("nw_wblhw001", oPC);}
    else if (GetHasFeat(FEAT_WEAPON_FOCUS_WHIP, oPC)) {oFavored = CreateItemOnObject("x2_it_wpwhip", oPC);}

    int bFavoredRanged, bFavoredMelee;
    int bFavoredValid = GetIsObjectValid(oFavored);


    if (bFavoredValid && GetWeaponRanged(oFavored))
    {
        bFavoredRanged = TRUE;
    }
    else if (bFavoredValid)
    {
        bFavoredMelee = TRUE;
    }

    switch (nClass)
    {
        case CLASS_TYPE_BARBARIAN:
            oChest = CreateItemOnObject("nw_aarcl008", oPC); // hide armor
            if (!bFavoredValid || (bFavoredValid && !bFavoredMelee)) oLeftHand = CreateItemOnObject("nw_waxbt001", oPC); // battleaxe
            if (!bFavoredValid || (bFavoredValid && !bFavoredRanged)) CreateItemOnObject("nw_wthax001", oPC, 30); // throwing axe
        break;
        case CLASS_TYPE_BARD:
            oChest = CreateItemOnObject("nw_aarcl009", oPC); // padded armor
            if (!bFavoredValid || (bFavoredValid && !bFavoredMelee)) CreateItemOnObject("nw_wswdg001", oPC); //dagger
            if (!bFavoredValid || (bFavoredValid && !bFavoredRanged))
            {
                oBolts = CreateItemOnObject("nw_wambo001", oPC, 99); // bolts
                oLeftHand = CreateItemOnObject("nw_wbwxl001", oPC); // light crossbow
            }
            CreateItemOnObject("misc23", oPC, 3); // thieves tool
            SetItemStackSize(oHealingKit, 3); // extra healing kits
        break;
        case CLASS_TYPE_CLERIC:
            oChest = CreateItemOnObject("nw_aarcl009", oPC); // padded armor
            oRightHand = CreateItemOnObject("nw_ashsw001", oPC); // small shield
            if (!bFavoredValid || (bFavoredValid && !bFavoredMelee)) oLeftHand = CreateItemOnObject("nw_wblml001", oPC); //mace
            if (!bFavoredValid || (bFavoredValid && !bFavoredRanged))
            {
                oBullets = CreateItemOnObject("nw_wambu001", oPC, 99); // bullets
                CreateItemOnObject("nw_wbwsl001", oPC); // sling
            }
            SetItemStackSize(oHealingKit, 3); // extra healing kits
        break;
        case CLASS_TYPE_FIGHTER:
            oChest = CreateItemOnObject("nw_aarcl012", oPC); // chain shirt
            if (!bFavoredValid || (bFavoredValid && !bFavoredMelee)) oLeftHand = CreateItemOnObject("nw_wswls001", oPC); //long sword
            if (!bFavoredValid || (bFavoredValid && !bFavoredRanged))
            {
                oArrows = CreateItemOnObject("nw_wamar001", oPC, 99); // arrows
                CreateItemOnObject("nw_wbwsh001", oPC); // shortbow
            }
        break;
        case CLASS_TYPE_PALADIN:
            oChest = CreateItemOnObject("nw_aarcl003", oPC); // scale mail
            if (!bFavoredValid || (bFavoredValid && !bFavoredMelee)) oLeftHand = CreateItemOnObject("nw_wblms001", oPC); // morningstar
            if (!bFavoredValid || (bFavoredValid && !bFavoredRanged))
            {
                oBolts = CreateItemOnObject("nw_wambo001", oPC, 99); // bolts
                CreateItemOnObject("nw_wbwxl001", oPC); // light crossbow
            }
        break;
        case CLASS_TYPE_DRUID:
            oChest = CreateItemOnObject("nw_aarcl001", oPC); // leather armor
            oRightHand = CreateItemOnObject("nw_ashsw001", oPC); // small shield
            if (!bFavoredValid || (bFavoredValid && !bFavoredMelee)) oLeftHand = CreateItemOnObject("nw_wspsc001", oPC); //sickle
            if (!bFavoredValid || (bFavoredValid && !bFavoredRanged))
            {
                oBullets = CreateItemOnObject("nw_wambu001", oPC, 99); // bullets
                CreateItemOnObject("nw_wbwsl001", oPC); // sling
            }
            SetItemStackSize(oHealingKit, 3); // extra healing kits
        break;
        case CLASS_TYPE_RANGER:
            oChest = CreateItemOnObject("nw_aarcl002", oPC); // studded leather armor
            oRightHand = CreateItemOnObject("nw_waxhn001", oPC); //handaxe
            if (!bFavoredValid || (bFavoredValid && !bFavoredMelee)) oLeftHand = CreateItemOnObject("nw_wswss001", oPC); //short sword
            if (!bFavoredValid || (bFavoredValid && !bFavoredRanged))
            {
                oArrows = CreateItemOnObject("nw_wamar001", oPC, 99); // arrows
                CreateItemOnObject("nw_wbwsh001", oPC); // shortbow
            }
        break;
        case CLASS_TYPE_ROGUE:
            oChest = CreateItemOnObject("nw_aarcl001", oPC); // leather armor
            if (!bFavoredValid || (bFavoredValid && !bFavoredMelee)) CreateItemOnObject("nw_wswdg001", oPC); //dagger
            if (!bFavoredValid || (bFavoredValid && !bFavoredRanged))
            {
                oArrows = CreateItemOnObject("nw_wamar001", oPC, 99); // arrows
                oLeftHand = CreateItemOnObject("nw_wbwsh001", oPC); // shortbow
            }
            CreateItemOnObject("nw_it_trap001", oPC); // spike trap
            CreateItemOnObject("nw_it_trap001", oPC);
            CreateItemOnObject("misc23", oPC, 3); // thieves tool
            SetItemStackSize(oHealingKit, 3); // extra healing kits
        break;
        case CLASS_TYPE_SORCERER:
            oChest = CreateItemOnObject("armor120", oPC); // sorcerer's outfit
            if (!bFavoredValid || (bFavoredValid && !bFavoredMelee)) CreateItemOnObject("nw_wswdg001", oPC); //dagger
            if (!bFavoredValid || (bFavoredValid && !bFavoredRanged)) oLeftHand = CreateItemOnObject("nw_wthdt001", oPC, 50); // dart
            oWand = CreateItemOnObject("weapon59", oPC);
            SetIdentified(oWand, TRUE);
        break;
        case CLASS_TYPE_WIZARD:
            oChest = CreateItemOnObject("armor121", oPC); // wizard's outfit
            if (!bFavoredValid || (bFavoredValid && !bFavoredMelee)) CreateItemOnObject("nw_wswdg001", oPC); //dagger
            if (!bFavoredValid || (bFavoredValid && !bFavoredRanged))
            {
                oBolts = CreateItemOnObject("nw_wambo001", oPC, 99); // bolts
                oLeftHand = CreateItemOnObject("nw_wbwxl001", oPC); // light crossbow
            }
            oWand = CreateItemOnObject("weapon59", oPC);
            SetIdentified(oWand, TRUE);
        break;
        case CLASS_TYPE_MONK:
            oChest = CreateItemOnObject("armor122", oPC); // monks outfit
            if (!bFavoredValid || (bFavoredValid && !bFavoredMelee)) oLeftHand = CreateItemOnObject("nw_wspka001", oPC); //kama
            if (!bFavoredValid || (bFavoredValid && !bFavoredRanged)) CreateItemOnObject("nw_wthsh001", oPC, 50); // shuriken
            SetItemStackSize(oHealingKit, 3); // extra healing kits
        break;
        default:
            oChest = CreateItemOnObject("nw_cloth022", oPC); // commoners outfit
            if (!bFavoredValid || (bFavoredValid && !bFavoredMelee)) oLeftHand = CreateItemOnObject("nw_wswdg001", oPC); //dagger
        break;
    }


    DelayCommand(0.5, AssignCommand(oPC, ActionEquipItem(oChest, INVENTORY_SLOT_CHEST)));
    DelayCommand(0.5, AssignCommand(oPC, ActionEquipItem(oArrows, INVENTORY_SLOT_ARROWS)));
    DelayCommand(0.5, AssignCommand(oPC, ActionEquipItem(oBullets, INVENTORY_SLOT_BULLETS)));
    DelayCommand(0.5, AssignCommand(oPC, ActionEquipItem(oBolts, INVENTORY_SLOT_BOLTS)));

    if (!bFavoredValid)
    {
        DelayCommand(0.5, AssignCommand(oPC, ActionEquipItem(oLeftHand, INVENTORY_SLOT_LEFTHAND)));
        DelayCommand(0.5, AssignCommand(oPC, ActionEquipItem(oRightHand, INVENTORY_SLOT_RIGHTHAND)));
    }
    else
    {
        DelayCommand(0.5, AssignCommand(oPC, ActionEquipItem(oFavored, INVENTORY_SLOT_LEFTHAND)));
    }

    DelayCommand(1.0, GiveStartingGold(oPC));

    object oSedos = GetObjectByTag("sedos");

    if (!IsInConversation(oSedos)) DelayCommand(3.0, AssignCommand(oPC, ActionStartConversation(oSedos)));
}
