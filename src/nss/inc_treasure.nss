#include "x2_i0_spells"
#include "inc_debug"
#include "inc_general"
#include "nwnx_item"
#include "nwnx_util"
#include "70_inc_itemprop"

// Based on item value, they will be sorted on these constants
const int MIN_VALUE_T2 = 175;
const int MIN_VALUE_T3 = 2000;
const int MIN_VALUE_T4 = 7000;
const int MIN_VALUE_T5 = 16000;

const int MIN_VALUE_SCROLL_T2 = 500;

const string TREASURE_MELEE_SEED_CHEST = "_MeleeSeed";
const string TREASURE_RANGE_SEED_CHEST = "_RangeSeed";
const string TREASURE_ARMOR_SEED_CHEST = "_ArmorSeed";

const string TREASURE_DISTRIBUTION = "_TreasureDistribution";

const float TREASURE_CREATION_DELAY = 0.0;

const int SCROLL_VALUE_MULTIPLIER = 6;
const int MISC_VALUE_MULTIPLIER = 5;


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

int GetItemTier(object oItem)
{
    int nIdentified = GetLocalInt(oItem, "identified");
    SetIdentified(oItem, 1);
    int nValue = GetGoldPieceValue(oItem);
    int nEnchantValue = GetEnchantValue(oItem);
    int nBaseType = GetBaseItemType(oItem);
    int nTier = -1;
    string sName = GetName(oItem);

    int nMinValueT2 = MIN_VALUE_T2;

   // scrolls have a low innate value, bump them up to the correct tiers
   switch (nBaseType)
   {
       case BASE_ITEM_SPELLSCROLL:
          nValue *= SCROLL_VALUE_MULTIPLIER;
          nMinValueT2 = MIN_VALUE_SCROLL_T2;
       break;
   }

    string sResRef = GetResRef(oItem);
    // Apply a multiplier for misc items (junk and art)
    // magic bags have their prices set elsewhere anyway
    if (TestStringAgainstPattern("**misc**", sResRef))
    {
        if (nBaseType != BASE_ITEM_LARGEBOX)
        {
            nValue *= MISC_VALUE_MULTIPLIER;
        }
    }

    // Sort by item value
    if (nValue >= MIN_VALUE_T5) {nTier = 5;}
    else if (nValue >= MIN_VALUE_T4) {nTier = 4;}
    else if (nValue >= MIN_VALUE_T3) {nTier = 3;}
    else if (nValue >= nMinValueT2) {nTier = 2;}
    else {nTier = 1;}

    string sNonUnique;
    if (GetTag(oItem) == "non_unique") sNonUnique = "NonUnique";
    if (GetLocalInt(oItem, "non_unique") == 1) sNonUnique = "NonUnique";
    // All non-TFN items (this matters for creatures dropping their own stuff) should get this treatment
    // they NEED to run through the +1/+2/+3 enhancement tier changes
    if (GetStringLeft(sResRef, 3) == "nw_" ||
        (GetStringLeft(sResRef, 5) != "armor" &&
        GetStringLeft(sResRef, 6) != "weapon" &&
        GetStringLeft(sResRef, 7) != "apparel"))
        {
            sNonUnique = "NonUnique";
        }

    // special rule to bump up unidentified items to the next tier, too much magic gear encountered at low level
    // basically, 
    if (nBaseType != BASE_ITEM_SPELLSCROLL && nTier == 1 && nIdentified == 0)
    {
       nTier = 2;
    }

    // High quality/composite range items are always T2
    if (nEnchantValue == 0 && (GetStringLeft(sName, 12) == "High Quality" || GetStringLeft(sName, 9) == "Composite"))
    {
       nTier = 2;
    }

    // Force +3 monk gloves to t5
    if (nEnchantValue == 3 && (nBaseType == BASE_ITEM_GLOVES || nBaseType == BASE_ITEM_BRACER))
    {
       nTier = 5;
    }

    // Boost some full plates and tower shields to next tier
   if (sName == "Tower Shield +1") nTier = 4;
   if (sName == "Tower Shield +2") nTier = 5;
   if (sName == "Half Plate +1") nTier = 4;
   if (sName == "Full Plate +1") nTier = 4;
   if (sName == "Full Plate +2") nTier = 5;

// Bump up items to the right tier for non-uniques
   if (sNonUnique == "NonUnique")
   {
       if (FindSubString(sName, "+1") > -1 && nTier == 2) nTier = 3;
       if (FindSubString(sName, "+2") > -1 && nTier == 3) nTier = 4;
       if (FindSubString(sName, "+3") > -1 && nTier == 4) nTier = 5;
   }

    if (nBaseType == BASE_ITEM_SPELLSCROLL)
    {
        SetIdentified(oItem, TRUE);
    }
    else
    {
        SetIdentified(oItem, nIdentified);
    }
    //WriteTimestampedLogEntry("GetItemTier: " + GetName(oItem) + " -> " + IntToString(nTier) + " (nonunique=" + sNonUnique);
    return nTier;
}

// =======================================================
// ITEM INITIALIZATION
// =======================================================

void AddEWR(object oItem)
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

// Applies enchanted weight reduction and a value modifier based on AC (for armor)
void InitializeItem(object oItem);
void InitializeItem(object oItem)
{
    if (!GetIsObjectValid(oItem)) { return; }
    float fScale = GetLocalFloat(oItem, "scale");
    if (fScale > 0.0)
    {
        SetObjectVisualTransform(oItem, OBJECT_VISUAL_TRANSFORM_SCALE, fScale);
    }


// never do this again for items
    if (GetLocalInt(oItem, "initialized") == 1)
    {
        return;
    }

    int nWasIdentified = GetIdentified(oItem);
    SetIdentified(oItem, 1);

    // if this item was not identified (probably magic) and it has a near zero gold cost, this item is probably screwed up from the negative 2da cost changes
    // destroy the item if so!
    if (!nWasIdentified && GetGoldPieceValue(oItem) <= 5)
    {
        WriteTimestampedLogEntry("Zero cost item: " + GetName(oItem));
        DestroyObject(oItem);
        return;
    }

    AddEWR(oItem);

    if (GetBaseItemType(oItem) == BASE_ITEM_ARMOR)
    {
        int nBaseArmorAC = GetBaseArmorAC(oItem);
    // Adjust the value of the item based on base AC. Every base AC = 10% more in value.
        if ((nBaseArmorAC > 0 && nBaseArmorAC < 5) || nBaseArmorAC == 8)
        {
            NWNX_Item_SetAddGoldPieceValue(oItem, NWNX_Item_GetAddGoldPieceValue(oItem) + FloatToInt( IntToFloat(GetGoldPieceValue(oItem)) * (IntToFloat(nBaseArmorAC) * 0.1) ) );
        }
        else if (nBaseArmorAC == 5)
        {
            NWNX_Item_SetAddGoldPieceValue(oItem, NWNX_Item_GetAddGoldPieceValue(oItem) + FloatToInt( IntToFloat(GetGoldPieceValue(oItem)) * (IntToFloat(2) * 0.1) ) );
        }
        else if (nBaseArmorAC == 6)
        {
            NWNX_Item_SetAddGoldPieceValue(oItem, NWNX_Item_GetAddGoldPieceValue(oItem) + FloatToInt( IntToFloat(GetGoldPieceValue(oItem)) * (IntToFloat(4) * 0.1) ) );
        }
        else if (nBaseArmorAC == 7)
        {
            NWNX_Item_SetAddGoldPieceValue(oItem, NWNX_Item_GetAddGoldPieceValue(oItem) + FloatToInt( IntToFloat(GetGoldPieceValue(oItem)) * (IntToFloat(6) * 0.1) ) );
        }
    }

     NWNX_Item_SetAddGoldPieceValue(oItem, NWNX_Item_GetAddGoldPieceValue(oItem) - GetLocalInt(oItem, "reduce_cost"));

    // Boomerang item values: additional item value is added once for each item in the stack
    // which means that additional item value needs to map stack size 1 -> max stack size
    if (GetItemHasItemProperty(oItem, ITEM_PROPERTY_BOOMERANG))
    {
        SetItemStackSize(oItem, 1);
        int nMaxStackSize = StringToInt(Get2DAString("baseitems", "Stacking", GetBaseItemType(oItem)));
        int nGold = GetGoldPieceValue(oItem);
        nGold *= (nMaxStackSize - 1);
        NWNX_Item_SetAddGoldPieceValue(oItem, NWNX_Item_GetAddGoldPieceValue(oItem) + nGold);
    }




    SetIdentified(oItem, nWasIdentified);
    SetLocalInt(oItem, "initialized", 1);
}


// ALWAYS USE AN AREA FOR STAGING!!!
// IT WILL HANG IF WE USE A MERCHANT FOR STAGING
location GetTreasureStagingLocation() {return Location(GetObjectByTag("_TREASURE_STAGING"), Vector(1.0, 1.0, 1.0), 0.0);}

// Creatures "dropping items they have equipped" is actually way worse than it sounds
// because TFN enchanted items etc don't really exist
// and all the templates use the generic ones which don't have tfn resrefs
// Also, some creatures add itemprops to them on spawn, which isn't ideal
// To get around that we can map the generic names to the TFN object
// ... which this DB can do for us happily
void BuildItemNamesToObjectsDB()
{
    object oMod = GetModule();
    sqlquery sql = SqlPrepareQueryObject(GetModule(),
    "CREATE TABLE IF NOT EXISTS item_name_lookup (" +
    "itemname TEXT PRIMARY KEY ON CONFLICT FAIL, " +
    "oid TEXT);");
    SqlStep(sql);
    int nTier;
    int nItemType;
    int nUniqueness;
    int nRarity;
    string sRarity;
    string sItemType;
    for (nTier=1; nTier<=5; nTier++)
    {
        // Armor, Melee, Range, Apparel
        for (nItemType=0;nItemType<4; nItemType++)
        {
            if (nItemType == 0) { sItemType = "Armor"; }
            else if (nItemType == 1) { sItemType = "Melee"; }
            else if (nItemType == 2) { sItemType = "Range"; }
            else if (nItemType == 3) { sItemType = "Apparel"; }
            else if (nItemType == 4) { sItemType = "Misc"; }

            for (nUniqueness=0; nUniqueness<2; nUniqueness++)
            {
                string sUniqueness = nUniqueness ? "" : "NonUnique";
                for (nRarity=0; nRarity<3; nRarity++)
                {
                    if (nRarity == 0) { sRarity = "Common"; }
                    else if (nRarity == 1) { sRarity = "Uncommon"; }
                    else if (nRarity == 2) { sRarity = "Rare"; }
                    string sChest = "_" + sItemType + sRarity + "T" + IntToString(nTier) + sUniqueness;
                    object oChest = GetObjectByTag(sChest);
                    if (GetIsObjectValid(oChest))
                    {
                        WriteTimestampedLogEntry("Writing item name -> object db for: " + sChest);
                        object oTest = GetFirstItemInInventory(oChest);
                        while (GetIsObjectValid(oTest))
                        {
                            int bIdentified = GetIdentified(oTest);
                            SetIdentified(oTest, 1);
                            // As of right now there are about four items who conflict
                            // including base item name resolves them all
                            string sName = GetName(oTest) + IntToString(GetBaseItemType(oTest));
                            SetIdentified(oTest, bIdentified);
                            sql = SqlPrepareQueryObject(GetModule(),
                                "INSERT INTO item_name_lookup " +
                                "(itemname, oid) VALUES (@itemname, @oid);");// +
                                //" ON CONFLICT (itemname) DO UPDATE SET value = @oid;");
                                //" ON CONFLICT FAIL;");
                            SqlBindString(sql, "@itemname", sName);
                            SqlBindString(sql, "@oid", ObjectToString(oTest));
                            SqlStep(sql);
                            string sError = SqlGetError(sql);
                            if (sError != "")
                            {
                                WriteTimestampedLogEntry("Error while writing item name: " + sName);
                            }
                            oTest = GetNextItemInInventory(oChest);
                        }
                    }
                }
            }
        }
    }
}

object GetTFNEquipmentByName(object oItem)
{
    if (GetIsObjectValid(oItem))
    {
        int bIdentified = GetIdentified(oItem);
        SetIdentified(oItem, 1);
        string sName = GetName(oItem);
        if (GetLocalString(oItem, "tfn_item_name") != "")
        {
            sName = GetLocalString(oItem, "tfn_item_name");
        }
        sName = sName + IntToString(GetBaseItemType(oItem));
        SetIdentified(oItem, bIdentified);
        sqlquery sql = SqlPrepareQueryObject(GetModule(),
            "SELECT oid FROM item_name_lookup " +
            "WHERE itemname = @itemname;");
        SqlBindString(sql, "@itemname", sName);
        if (SqlStep(sql))
        {
            object oRet = StringToObject(SqlGetString(sql, 0));
            //WriteTimestampedLogEntry("GetTFNEquipmentByName: " + GetName(oItem) + " -> " + GetName(oRet));
            return oRet;
        }
        //WriteTimestampedLogEntry("GetTFNEquipmentByName: " + GetName(oItem) + " -> invalid");
    }
    return OBJECT_INVALID;
}

//void main() {}
