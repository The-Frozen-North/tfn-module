#include "x2_i0_spells"
#include "inc_debug"
#include "inc_general"

// Based on item value, they will be sorted on these constants
const int MIN_VALUE_T2 = 175;
const int MIN_VALUE_T3 = 2000;
const int MIN_VALUE_T4 = 7000;
const int MIN_VALUE_T5 = 16000;

const string TREASURE_MELEE_SEED_CHEST = "_MeleeSeed";
const string TREASURE_RANGE_SEED_CHEST = "_RangeSeed";
const string TREASURE_ARMOR_SEED_CHEST = "_ArmorSeed";

const string TREASURE_DISTRIBUTION = "_TreasureDistribution";

const float TREASURE_CREATION_DELAY = 0.0;

// =======================================================
// DETERMINE ENCHANT VALUE
// =======================================================
int GetEnchantValue(object oItem)
{
    itemproperty ip = GetFirstItemProperty(oItem);
    int nFound = 0;
    while (nFound == 0 && GetIsItemPropertyValid(ip))
    {
        if (GetItemPropertyType(ip) == ITEM_PROPERTY_ENHANCEMENT_BONUS || GetItemPropertyType(ip) == ITEM_PROPERTY_ATTACK_BONUS || GetItemPropertyType(ip) == ITEM_PROPERTY_AC_BONUS)
        {
            nFound = GetItemPropertyCostTableValue(ip);
            break; // stop after the first one
        }
        ip = GetNextItemProperty(oItem);
    }
    return nFound;
}

// =======================================================
// ENCHANTED WEIGHT REDUCTION
// =======================================================
void AddEnchantedWeightReduction(object oItem)
{
// do not add the enchanted weight reduction again
   if (GetLocalInt(oItem, "enchanted_weight_applied") == 1) return;
   SetLocalInt(oItem, "enchanted_weight_applied", 1);

// do not proceed for the following item types
   int nBaseItemType = GetBaseItemType(oItem);
   switch (nBaseItemType)
   {
       case BASE_ITEM_SPELLSCROLL:
       case BASE_ITEM_MISCLARGE:
       case BASE_ITEM_MISCMEDIUM:
       case BASE_ITEM_MISCSMALL:
       case BASE_ITEM_MISCTALL:
       case BASE_ITEM_MISCTHIN:
       case BASE_ITEM_TRAPKIT:
       case BASE_ITEM_THIEVESTOOLS:
       case BASE_ITEM_HEALERSKIT:
       case BASE_ITEM_MISCWIDE:
       case BASE_ITEM_ENCHANTED_POTION:
       case BASE_ITEM_POTIONS:
       case BASE_ITEM_GEM:
       case BASE_ITEM_LARGEBOX:
           return;
       break;
   }

   int nItemPropertyType;
   itemproperty oItemProperty = GetFirstItemProperty(oItem);
// if there aren't any item properties, then return
   if (!GetIsItemPropertyValid(oItemProperty)) return;

   while (GetIsItemPropertyValid(oItemProperty))
   {
        nItemPropertyType = GetItemPropertyType(oItemProperty);

// do not proceed if the item already has a weight reduction
        if (nItemPropertyType == ITEM_PROPERTY_BASE_ITEM_WEIGHT_REDUCTION) return;

        oItemProperty = GetNextItemProperty(oItem);
   }

// Get weight reduction by enchant value
   int nWeightReduction = GetEnchantValue(oItem);

// if we fail to get a value through the bonus, then try by cost
   if (nWeightReduction < 1)
   {
       int nCost = GetGoldPieceValue(oItem);

       if (nCost > MIN_VALUE_T5) { nWeightReduction = IP_CONST_REDUCEDWEIGHT_40_PERCENT; }
       else if (nCost > MIN_VALUE_T4) { nWeightReduction = IP_CONST_REDUCEDWEIGHT_60_PERCENT; }
       else if (nCost > MIN_VALUE_T3) { nWeightReduction = IP_CONST_REDUCEDWEIGHT_80_PERCENT; }
   }

// if we still don't have a proper value, then we shall not proceed
   if (nWeightReduction < 1) return;

   AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyWeightReduction(nWeightReduction), oItem);
}


// ALWAYS USE AN AREA FOR STAGING!!!
// IT WILL HANG IF WE USE A MERCHANT FOR STAGING
location GetTreasureStagingLocation() {return Location(GetObjectByTag("_TREASURE_STAGING"), Vector(1.0, 1.0, 1.0), 0.0);}

//void main() {}
