#include "x2_inc_itemprop"
#include "inc_debug"
#include "inc_general"
#include "nwnx_player"

// ===========================================================
// START CONSTANTS
// ===========================================================

// Seconds before loot is automatically destroyed.
const float LOOT_DESTRUCTION_TIME = 600.0;

// chance that a treasure will spawn at all out of 100
const int TREASURE_CHANCE = 25;

// chance that there won't be placeable treasure at all out of 100
const int NO_PLACEABLE_TREASURE_CHANCE = 30;

// Chance of this item type dropping
const int BASE_DEFAULT_WEIGHT = 2;
const int BASE_WEAPON_WEIGHT = 9;
const int BASE_ARMOR_WEIGHT = 2;
const int BASE_APPAREL_WEIGHT = 4;
const int BASE_SCROLL_WEIGHT = 3;
const int BASE_POTION_WEIGHT = 12;
const int BASE_MISC_WEIGHT = 10;

const int BASE_ADJUST_CHANCE = 25;

// The chance for one, two or three items to drop, specifically. This is out of 100.

const int CHANCE_ONE = 40;
const int CHANCE_TWO = 15;
const int CHANCE_THREE = 5;

// Lower these to decrease the base chance of getting certain tiers.
const int BASE_T1_WEIGHT = 3000;
const int BASE_T2_WEIGHT = 160;
const int BASE_T3_WEIGHT = 40;
const int BASE_T4_WEIGHT = 20;
const int BASE_T5_WEIGHT = 5;

const int MIN_T3_AREA_CR = 3;
const int MIN_T4_AREA_CR = 6;
const int MIN_T5_AREA_CR = 10;

// increase this to increase weight of better loot
// in correlation to CR
const float BASE_CR_MULTIPLIER = 1.1;

// The string to play when there isn't loot available
const string NO_LOOT = "This container doesn't have any items.";


// ===========================================================
// START PROTOTYPES
// ===========================================================

// Generate a tier Item. Specific Tier granted if nTier is 1-5.
// Valid types: "Armor", "Melee", "Range", "Misc, "Apparel"
// "Potion", "ScrollsDivine", "ScrollsArcane"
object GenerateTierItem(int iCR, int iAreaCR, object oContainer, string sType = "", int nTier = 0, int bNonUnique = FALSE);

// Open a personal loot. Called from a containing object.
void OpenPersonalLoot(object oContainer, object oPC);

// ===========================================================
// START FUNCTIONS
// ===========================================================

// ---------------------------------------------------------
// This function is used to determine the tier of the drop.
// ---------------------------------------------------------
string DetermineTier(int iCR, int iAreaCR, string sType = "")
{
    float fCR = IntToFloat(iCR);
    string sTier;

    //SendDebugMessage("Loot fCR: "+FloatToString(fCR));

// If there is a CR available, use this to modify the loot chance
    float fMod = fCR*BASE_CR_MULTIPLIER;

    if (fMod < 1.0) fMod = 1.0;

    //SendDebugMessage("Loot fMod: "+FloatToString(fMod));

    int nT1Weight = BASE_T1_WEIGHT;
    int nT2Weight = FloatToInt(BASE_T2_WEIGHT * fMod);
    int nT3Weight = FloatToInt(BASE_T3_WEIGHT * fMod);
    int nT4Weight = FloatToInt(BASE_T4_WEIGHT * fMod);
    int nT5Weight = FloatToInt(BASE_T5_WEIGHT * fMod);

   int nCombinedWeight = 0;

// If any of these happen to be less than 0, make it 0

   if (nT1Weight < 0) nT1Weight = 0;
   if (nT2Weight < 0) nT2Weight = 0;
   if (nT3Weight < 0) nT3Weight = 0;
   if (nT4Weight < 0) nT4Weight = 0;
   if (nT5Weight < 0) nT5Weight = 0;

// if the CR is greater than the area CR, override it
   if (iCR > iAreaCR) iAreaCR = iCR;

// modify weight by area CR
    if (iAreaCR < MIN_T3_AREA_CR)
    {
        if (nT3Weight > 0) nT3Weight = nT3Weight/100;
        if (nT4Weight > 0) nT4Weight = nT4Weight/100;
        if (nT5Weight > 0) nT5Weight = nT5Weight/100;
    }
    else if (iAreaCR < MIN_T4_AREA_CR)
    {
        if (nT4Weight > 0) nT3Weight = nT4Weight/100;
        if (nT5Weight > 0) nT3Weight = nT5Weight/100;
    }
    else if (iAreaCR < MIN_T5_AREA_CR)
    {
        if (nT5Weight > 0) nT3Weight = nT5Weight/100;
    }


   //SendDebugMessage("Loot T1Weight: "+IntToString(nT1Weight));
   //SendDebugMessage("Loot T2Weight: "+IntToString(nT2Weight));
   //SendDebugMessage("Loot T3Weight: "+IntToString(nT3Weight));
   //SendDebugMessage("Loot T4Weight: "+IntToString(nT4Weight));
   //SendDebugMessage("Loot T5Weight: "+IntToString(nT5Weight));

   nCombinedWeight = nT1Weight + nT2Weight + nT3Weight + nT4Weight + nT5Weight;
   //SendDebugMessage("Combined: "+IntToString(nCombinedWeight));

   int nTierRoll = Random(nCombinedWeight)+1;
   //SendDebugMessage("Roll: "+IntToString(nTierRoll));

   while (TRUE)
   {
        nTierRoll = nTierRoll - nT1Weight;
        if (nTierRoll <= 0) {sTier = "T1";break;}

        nTierRoll = nTierRoll - nT2Weight;
        if (nTierRoll <= 0) {sTier = "T2";break;}

        if (iAreaCR >= MIN_T3_AREA_CR)
        {
            nTierRoll = nTierRoll - nT3Weight;
            if (nTierRoll <= 0) {sTier = "T3";break;}
        }

        if (iAreaCR >= MIN_T4_AREA_CR)
        {
            nTierRoll = nTierRoll - nT4Weight;
            if (nTierRoll <= 0) {sTier = "T4";break;}
        }


        if (iAreaCR >= MIN_T5_AREA_CR)
        {
            nTierRoll = nTierRoll - nT5Weight;
            if (nTierRoll <= 0) {sTier = "T5";break;}
        }
    }

    //SendDebugMessage("Chosen Tier: "+sTier);

    int nCount = GetLocalInt(GetModule(), sTier);
    SetLocalInt(GetModule(), sTier, nCount+1);

    return sTier;
}

// ---------------------------------------------------------
// This function is used to generate a tier item.
// ---------------------------------------------------------
object GenerateTierItem(int iCR, int iAreaCR, object oContainer, string sType = "", int nTier = 0, int bNonUnique = FALSE)
{
    string sTier = DetermineTier(iCR, iAreaCR, sType);
    string sRarity = "";
    string sNonUnique = "";

// Given no type, generate a random one.
    if (sType == "")
    {
        switch(Random(7))
        {
           case 0: sType = "Misc"; break;
           case 1: sType = "Scrolls"; break;
           case 2: sType = "Weapon"; break;
           case 3: sType = "Armor"; break;
           case 4: sType = "Range"; break;
           case 5: sType = "Apparel"; break;
           case 6: sType = "Potions"; break;
        }
    }

// These types are special cases because they have rarities.
    if (sType == "Melee" || sType == "Weapon" || sType == "Armor" || sType == "Apparel")
    {
        switch(d12())
        {
           case 1: case 2: case 3: case 4: case 5: sRarity = "Common"; break;
           case 6: case 7: case 8: case 9: sRarity = "Uncommon"; break;
           case 10: case 11: case 12: sRarity = "Rare"; break;
        }
    }

// These types can have either a unique, or non-unique
    if ((sType == "Weapon" || sType == "Armor" || sType == "Potions") && d2() == 2) sNonUnique = "NonUnique";

    if (bNonUnique) sNonUnique = "NonUnique";


    if (sType == "Weapon")
    {
        sType = "Melee";
// chance of this being a range weapon
        if (d10() <= 4) sType = "Range";
    }

    if (nTier > 0)
    {
        switch (nTier)
        {
           case 1: sTier = "T1"; break;
           case 2: sTier = "T2"; break;
           case 3: sTier = "T3"; break;
           case 4: sTier = "T4"; break;
           case 5: sTier = "T5"; break;
        }
    }

    object oChest = GetObjectByTag("_"+sType+sRarity+sTier+sNonUnique);

// we'll use the non-unique chest if the unique container, if applicable simply don't exist
    if (!GetIsObjectValid(oChest)) oChest = GetObjectByTag("_"+sType+sRarity+sTier+"NonUnique");

// chest still invalid at that point? return
    if (!GetIsObjectValid(oChest)) return OBJECT_INVALID;

    int nRandom = Random(StringToInt(GetDescription(oChest)));
    object oItem = GetFirstItemInInventory(oChest);
    while (nRandom)
    {
        nRandom--;
        oItem = GetNextItemInInventory(oChest);
    }

    object oNewItem = CopyItem(oItem, oContainer);

    int nCount = GetLocalInt(GetModule(), sType);
    SetLocalInt(GetModule(), sType, nCount+1);

// Set a stack size. Don't go above 50, due to certain stack sizes.
    int nBaseType = GetBaseItemType(oNewItem);
    if (nBaseType == BASE_ITEM_THROWINGAXE || nBaseType == BASE_ITEM_DART || nBaseType == BASE_ITEM_SHURIKEN || nBaseType == BASE_ITEM_ARROW || nBaseType == BASE_ITEM_BULLET || nBaseType == BASE_ITEM_BOLT) SetItemStackSize(oNewItem, Random(45)+1);

    return oNewItem;
}

// ---------------------------------------------------------
// Generates loot. Typically used for creatures or containers.
// ---------------------------------------------------------
void GenerateLoot(object oContainer, int nBonusItems = 0)
{
   if (!GetHasInventory(oContainer)) return; // stop if the container has no inventory

   if (GetLocalInt(GetModule(), "treasure_ready") != 1)
   {
       SendMessageToAllPCs("Treasure isn't ready. No treasure will be generated.");
       return;
   }

   if (GetLocalInt(GetModule(), "treasure_tainted") == 1)
   {
       SendMessageToAllPCs("Treasure is tainted. No treasure will be generated.");
       return;
   }

   int iCR = GetLocalInt(oContainer, "cr");
   int iAreaCR = GetLocalInt(oContainer, "area_cr");

// Add all the weights
   int nCombinedWeight = 0;

   int nMiscWeight = BASE_MISC_WEIGHT;
   int nScrollsWeight = BASE_SCROLL_WEIGHT;
   int nPotionsWeight = BASE_POTION_WEIGHT;
   int nWeaponWeight = BASE_WEAPON_WEIGHT;
   int nArmorWeight = BASE_ARMOR_WEIGHT;
   int nApparelWeight = BASE_APPAREL_WEIGHT;

// If any of these happen to be less than 0, make it 0
   if (nMiscWeight < 0) nMiscWeight = 0;
   if (nScrollsWeight < 0) nScrollsWeight = 0;
   if (nPotionsWeight < 0) nPotionsWeight = 0;
   if (nWeaponWeight < 0) nWeaponWeight = 0;
   if (nArmorWeight < 0) nArmorWeight = 0;
   if (nApparelWeight < 0) nApparelWeight = 0;

   nCombinedWeight = nMiscWeight + nScrollsWeight + nPotionsWeight + nWeaponWeight + nArmorWeight + nApparelWeight;

   int nItemRoll = Random(nCombinedWeight)+1;
   while (TRUE)
   {
       nItemRoll = nItemRoll - nMiscWeight;
       if (nItemRoll <= 0) {GenerateTierItem(iCR, iAreaCR, oContainer, "Misc");break;}

       nItemRoll = nItemRoll - nScrollsWeight;
       if (nItemRoll <= 0) {GenerateTierItem(iCR, iAreaCR, oContainer, "Scrolls");break;}

       nItemRoll = nItemRoll - nPotionsWeight;
       if (nItemRoll <= 0) {GenerateTierItem(iCR, iAreaCR, oContainer, "Potions");break;}

       nItemRoll = nItemRoll - nWeaponWeight;
       if (nItemRoll <= 0) {GenerateTierItem(iCR, iAreaCR, oContainer, "Weapon");break;}

       nItemRoll = nItemRoll - nArmorWeight;
       if (nItemRoll <= 0) {GenerateTierItem(iCR, iAreaCR, oContainer, "Armor");break;}

       nItemRoll = nItemRoll - nApparelWeight;
       if (nItemRoll <= 0) {GenerateTierItem(iCR, iAreaCR, oContainer, "Apparel");break;}
   }

}

void DecrementLootAndDestroyIfEmpty(object oOpener, object oLootParent, object oPersonalLoot)
{

// do not continue unless there are still items
    if (GetIsObjectValid(GetFirstItemInInventory(oPersonalLoot))) return;

// play a closing sound
    AssignCommand(oOpener, PlaySound("as_sw_clothcl1"));

    int nUnlooted = GetLocalInt(oLootParent, "unlooted")-1;

// Decrement number of players who looted this, and destroy the loot container.
    SetLocalInt(oLootParent, "unlooted", nUnlooted);
    DestroyObject(oPersonalLoot);

// 0 or less unlooted means everyone has already looted this.
    if (nUnlooted <= 0)
    {
        SetPlotFlag(oLootParent, FALSE);

        if (GetStringLeft(GetResRef(oLootParent), 6) == "treas_")
        {
            AssignCommand(oLootParent, ActionPlayAnimation(ANIMATION_PLACEABLE_CLOSE));
            DestroyObject(oLootParent, 2.0);
            // Assume this is a placeable treasure, close it then destroy it.
        }
        else
        {
            DestroyObject(oLootParent);
            // Assume this is a loot bag, destroy
        }
    }
}


// ---------------------------------------------------------
// This function is used to access a loot container.
// ---------------------------------------------------------
void OpenPersonalLoot(object oContainer, object oPC)
{
// don't do anything if not a PC
    if (!GetIsPC(oPC)) return;

// Get the personal container
    object oPersonalLoot = GetObjectByUUID(GetLocalString(oContainer, "personal_loot_"+GetPCPublicCDKey(oPC, TRUE)));

// if the loot container doesn't exist, give a message
    if (oPersonalLoot == OBJECT_INVALID)
    {
        FloatingTextStringOnCreature(NO_LOOT, oPC, FALSE);
    }
// if there are no items in it, destroy it immediately and do the logic
    else if (!GetIsObjectValid(GetFirstItemInInventory(oPersonalLoot)))
    {
        FloatingTextStringOnCreature(NO_LOOT, oPC, FALSE);
        DecrementLootAndDestroyIfEmpty(oPC, oContainer, oPersonalLoot);
    }
    else
    {
        NWNX_Player_ForcePlaceableInventoryWindow(oPC, oPersonalLoot);
    }
}


int DetermineGoldFromCR(int iCR)
{
    if (iCR < 1) iCR = 1;
    int iResult = 6+d4(iCR);

    if (d10() == 10) iResult = iResult*2; // 10% chance to double gold
    return iResult;
}

//void main() {}
