#include "inc_treasure"
/*

This file deals with:
- Selecting loot items in the system areas, and (if wanted) make an initialised copy in the inventory of another object.
- Selecting an equipped item off a creature to drop as loot in place of a random item
- Debug: be capable of tracking the expected number/value of items produced for design purposes - see dev_allarealoot

Supports both the common default chances of parameters used for most kinds of objects, and fully configurable ways to manipulate them.

Calling for a random loot item goes like this:

1) Work out what type/class of item to drop
2) Work out the tier of item to drop (this depends on the item type, eg potions are more likely to be of higher tier than weapons/armor are)
3) Work out rarity (common/uncommon/rare) and uniqueness/nonuniqueness of the item, which also depends on the item type
4) Find the corresponding storage in the staging area and pick something at random from that container
5) Copy to the target inventory if requested.

*/

////////
// Configurables.

// Lower these to decrease the base chance of getting certain tiers.
    const int BASE_T1_WEIGHT = 2000;
    const int BASE_T2_WEIGHT = 200;
    const int BASE_T3_WEIGHT = 100;
    const int BASE_T4_WEIGHT = 50;
    const int BASE_T5_WEIGHT = 20;

// These affect the area CR where each tier of item starts to show up.
// See the implementation for more on what these are and how they work
    const int T1_SIGMOID_MIDPOINT = 1;
    const int T2_SIGMOID_MIDPOINT = 1;
    const int T3_SIGMOID_MIDPOINT = 7;
    const int T4_SIGMOID_MIDPOINT = 10;
    const int T5_SIGMOID_MIDPOINT = 13;

// Standard percentage chance of unique items
    const int UNIQUE_ITEM_CHANCE = 50;

// Loot type weights for standard distribution
// Does not need to sum to 100 or a specific number
// This is used for most things (eg random loot) with some exceptions (eg items stocked by pawnshops)
    const int LOOT_WEAPON_MELEE_WEIGHT = 5;
    const int LOOT_WEAPON_RANGE_WEIGHT = 4;
    const int LOOT_ARMOR_WEIGHT = 2;
    const int LOOT_APPAREL_WEIGHT = 4;
    const int LOOT_SCROLL_WEIGHT = 6;
    const int LOOT_POTION_WEIGHT = 12;
    const int LOOT_MISC_WEIGHT = 3;
    const int LOOT_MISCCONS_WEIGHT = 2;
    const int LOOT_JEWEL_WEIGHT = 7;


// Rarity chances - these need not sum to 100
// (the old values did, and these are just brought forward)
    // Used for LOOT_TYPE_WEAPON_MELEE and LOOT_TYPE_WEAPON_RANGE
    const int WEAPON_COMMON_WEIGHT = 37;
    const int WEAPON_UNCOMMON_WEIGHT = 33;
    const int WEAPON_RARE_WEIGHT = 30;

    // Used for anything else (at the time of writing, LOOT_TYPE_APPAREL and LOOT_TYPE_ARMOR)
    const int OTHER_COMMON_WEIGHT = 42;
    const int OTHER_UNCOMMON_WEIGHT = 33;
    const int OTHER_RARE_WEIGHT = 25;

// Placeable loot quantity modifiers - so big chests have more items in than crates
    // To use this, placeables should have a local string "treasure" set on them with a value of "low" "medium" or "high"
    // The quantity variables set quantity_mult on containers, multiplying the effective CHANCE_* constants for loot in there
    // Manually setting these on the containers will override these values
    // Doing things this way is nice because the entire module's loot can be changed by messing with these script constants
    // Instead of going through blueprints to change variables like what was needed to implement this in the first place
    const float TREASURE_HIGH_QUANTITY = 3.0;
    const float TREASURE_MEDIUM_QUANTITY = 1.75;
    const float TREASURE_LOW_QUANTITY = 1.0;

// Quality modifiers - makes low/high tiers more/less likely from some sources
    // A value of -1.0 (smallest possible) makes all available tier items equal chance
    // Values between will squash the normal weights together, making higher quality items more likely.
    // A value >0.0 will widen the gap between normal weights, making higher quality items less likely.
    // See also: https://docs.google.com/spreadsheets/d/1OEeU2aANF8ERT8o1wSLb0Lo6W4xqu0QADGR0Vo-ynk4/edit#gid=1129304103 - Boss Weight Exponent

    // The boss/semiboss/treasure quality modifiers do not stack with each other
    // boss/semiboss work on treasures as well as creatures!
    // but do stack with the item type modifiers

    // These apply both to creatures and placeables
    // 0.3 on the sheet means -0.7 here. Subtract the exponent from -1.0
    const float SEMIBOSS_QUALITY_MODIFIER = -0.4;
    const float BOSS_QUALITY_MODIFIER = -0.7;

    const float TREASURE_HIGH_QUALITY = -0.2;
    const float TREASURE_MEDIUM_QUALITY = 0.0;
    const float TREASURE_LOW_QUALITY = 0.4;

    // Without skewing consumable quality like this you get an incredibly high amount of cure light wounds potions 
    // and cantrip scrolls, even at max level areas...
    const float POTION_QUALITY_MODIFIER = -0.3;
    const float MISC_CONSUMABLE_QUALITY_MODIFIER = -0.2;
    const float SCROLL_CONSUMABLE_QUALITY_MODIFIER = -0.2;

// Dropping of equipped items
    // Variables can set on items to alter this:
        // "tfn_item_name" (string) on the item: the named item will be dropped instead of the actually equipped one
        // The base item type has to be the same, though.
        // Eg many creatures have "Infinite Longbow", setting this to just "Longbow" (case sensitive) will let them drop that instead

        // "creature_drop_only" (int) to any nonzero value will allow creatures to drop their items
        // even if they don't exist within the TFN loot pool. This means that creatures can have "unique" equipment
        // that can't be obtained anywhere else.

    // Creatures that roll a random item of the same tier as something they have equipped
    // have this (percent) chance to drop that item type instead of a random one
    const int CHANCE_TO_DROP_EQUIPPED_ITEM = 70;
    // Bosses have this (percent) chance to ignore the tier matching restriction, and drop an equipped item regardless of what tier was rolled
    const int BOSS_EQUIPPED_ITEM_DROPS_IGNORE_TIER_CHANCE = 0;




////////////


const int LOOT_TYPE_MISCCONS = 1;
const int LOOT_TYPE_MISC = 2;
const int LOOT_TYPE_SCROLL = 4;
const int LOOT_TYPE_POTION = 8;
const int LOOT_TYPE_WEAPON_MELEE = 16;
const int LOOT_TYPE_WEAPON_RANGE = 32;
const int LOOT_TYPE_ARMOR = 64;
const int LOOT_TYPE_APPAREL = 128;
const int LOOT_TYPE_JEWEL = 256;

const int LOOT_TYPE_ANY = 511;
const int LOOT_TYPE_EQUIPPABLE = 240; //LOOT_TYPE_WEAPON_MELEE + LOOT_TYPE_WEAPON_RANGE + LOOT_TYPE_ARMOR + LOOT_TYPE_APPAREL;
const int LOOT_TYPE_CONSUMABLE = 13; //LOOT_TYPE_SCROLL + LOOT_TYPE_POTION + LOOT_TYPE_MISCCONS;

const int LOOT_TYPES_WITH_RARITIES = 240; //LOOT_TYPE_WEAPON_MELEE + LOOT_TYPE_WEAPON_RANGE + LOOT_TYPE_ARMOR + LOOT_TYPE_APPAREL;
const int LOOT_TYPES_WITH_NONUNIQUES = 120; //LOOT_TYPE_WEAPON_MELEE + LOOT_TYPE_WEAPON_RANGE + LOOT_TYPE_ARMOR + LOOT_TYPE_POTION;

const int LOOT_RARITY_UNDEFINED = 1;
const int LOOT_RARITY_COMMON = 2;
const int LOOT_RARITY_UNCOMMON = 4;
const int LOOT_RARITY_RARE = 8;
const int LOOT_RARITY_ANY = 15;
const int LOOT_RARITY_CATEGORISED = 14;

const int LOOT_UNIQUENESS_UNIQUE = 1;
const int LOOT_UNIQUENESS_NONUNIQUE = 2;
const int LOOT_UNIQUENESS_ANY = 3;

// These constants deliberately start high, so that they can be differentiated from the raw values 1-5.
const int LOOT_TIER_ONE = 16;
const int LOOT_TIER_TWO = 32;
const int LOOT_TIER_THREE = 64;
const int LOOT_TIER_FOUR = 128;
const int LOOT_TIER_FIVE = 256;

////////////////////////////////
// Helpers intended for external usage:

// Roll loot for oLootOrigin using standard parameters.
// If oTargetInventory is a valid object, makes a copy of the selected item in that object's inventory and returns the new copy.
// Otherwise, returns the object still inside the staging area container.
// nAllowedLootTypes is a bitmask of allowed LOOT_TYPE_* constants.
// If more than one bit is set, the type selected will be weighted according to the using standard loot type weightings.
object SelectLootItemForLootSource(object oTargetInventory, object oLootOrigin, int nAllowedLootTypes=LOOT_TYPE_ANY, int nUniqueChance=UNIQUE_ITEM_CHANCE);

// Roll a random item of fixed tier.
// nTier may be either a literal 1-5 or a LOOT_TIER_* constant. If passed a bitmask of multiple values, will pick between them at equal odds.
// If oTargetInventory is a valid object, makes a copy of the selected item in that object's inventory and returns the new copy.
// Otherwise, returns the object still inside the staging area container.
// nAllowedLootTypes is a bitmask of allowed LOOT_TYPE_* constants.
// If more than one bit is set, the type selected will be weighted according to the using standard loot type weightings.
// Practical usage: quest rewards (rewarding a random t3 melee weapon), specific merchant stocking (stock a random t5 armor)
object SelectLootItemFixedTier(object oTargetInventory, int nTier, int nAllowedLootTypes=LOOT_TYPE_ANY, int nUniqueChance=UNIQUE_ITEM_CHANCE);

// Performs the copying step, making and returning a copy of oStagingItem in oTargetInventory.
// Does various initialisation steps such as randomising the quantity of mundane ammunition created.
// If oTargetInventory is invalid, will copy the item (as a ground item) to lTarget instead.
object CopyTierItemFromStaging(object oStagingItem, object oTargetInventory=OBJECT_INVALID, location lTarget=LOCATION_INVALID);

// Roll an item at standard quality for area CR nACR.
// If oTargetInventory is a valid object, makes a copy of the selected item in that object's inventory and returns the new copy.
// Otherwise, returns the object still inside the staging area container.
// nAllowedLootTypes is a bitmask of allowed LOOT_TYPE_* constants.
// If more than one bit is set, the type selected will be one of them selected at random using standard loot type weightings.
// In most cases, using SelectLootItemForLootSource is preferable - this should be used if we don't HAVE a loot source, or if we don't want to use them
// Practical usage: pickpocket items (don't want to copy boss tier modifiers)
object SelectLootItemFromACR(object oTargetInventory, int nACR, int nAllowedLootTypes=LOOT_TYPE_ANY, int nUniqueChance=UNIQUE_ITEM_CHANCE);

// Roll a random item of fixed tier.
// nTier may be either a literal 1-5 or a LOOT_TIER_* constant. If passed a bitmask of multiple values, will pick between them at equal odds.
// If oTargetInventory is a valid object, makes a copy of the selected item in that object's inventory and returns the new copy.
// Otherwise, returns the object still inside the staging area container.
// nAllowedLootTypes is a bitmask of allowed LOOT_TYPE_* constants.
// If more than one bit is set, the type selected will be one of them selected at random at EQUAL ODDS (which is different to how standard loot works).
// Practical usage: pawnshop random stock. Most other applications would benefit from SelectLootItemFixedTier and the standard item type distribution.
object SelectLootItemFixedTierEqualLootTypeOdds(object oTargetInventory, int nTier, int nAllowedLootTypes=LOOT_TYPE_ANY, int nUniqueChance=UNIQUE_ITEM_CHANCE);

// Roll an item at standard quality for area CR nACR.
// If oTargetInventory is a valid object, makes a copy of the selected item in that object's inventory and returns the new copy.
// Otherwise, returns the object still inside the staging area container.
// nAllowedLootTypes is a bitmask of allowed LOOT_TYPE_* constants.
// If more than one bit is set, the type selected will be one of them selected at random at EQUAL ODDS (which is different to how standard loot works).
// In most cases, using SelectLootItemForLootSource is preferable - this should be used if we don't HAVE a loot source, or if we don't want to use them
// Practical usage: pawnshop random stock.
object SelectLootItemFromACREqualLootTypeOdds(object oTargetInventory, int nACR, int nAllowedLootTypes=LOOT_TYPE_ANY, int nUniqueChance=UNIQUE_ITEM_CHANCE);

//////////////////////////////
// The fully configurable versions:

// These require setting up weighting arrays manually, which is a bit laborious, but should allow for much finer control in any situations that need it.
    // This makes use of json arrays (of ints) to carry weights for different possibilities.
    // For example, for the 5 tiers of loot: their weights can be specified individually
    // The first element corresponds to t1, the second to t2, etc. This is in increasing bit significance order
    // For instance passing [10, 5, 2, 1, 0] as tier weights is t1=10, t2=5, t3=2, t4=1, t5=0.
    // The same applies to LOOT_RARITY, LOOT_TYPE, and LOOT_UNIQUENESS.
    // In the above example, the weight sum is 10+5+2+1 = 18, giving 10/18 chance to be t1, 5/18 to be t2, etc.
    // This should give a slightly involved but flexible way to ask for different odds of just about anything
    // ... and the value debug calculator should be able to keep up with whatever is specified in this way.


// The following construct standard weighting arrays used in loot calculation.

    // Performs logic on oLootOrigin (creature or treasure placeable) and returns standard tier weights.
    // nLootType should be a single specific LOOT_TYPE_* only, not a combined bitmask.
    // The json object returned is newly generated and is safe to use inplace modification on without problems.
    json GetStandardLootTierWeightsFromLootSource(object oLootOrigin, int nLootType=LOOT_TYPE_ANY, float fWeightExponentModifier=0.0);

    // Return a weighting array of tier weights for an area of nACR, single loot type nLootType and exponent modifier fWeightExponentModifier.
    // nLootType should be a single specific LOOT_TYPE_* only, not a combined bitmask.
    // The json object returned is newly generated and is safe to use inplace modification on without problems.
    json GetStandardLootTierWeights(int nACR, int nLootType=LOOT_TYPE_ANY, float fWeightExponentModifier=0.0);

    // Return a weighting array using standard rarity for the specified loot types (any combination of LOOT_TYPE_* bitmask values).
    // The json object returned is newly generated and is safe to use inplace modification on without problems.
    json GetStandardLootTypeWeights(int nAllowedLootTypes=LOOT_TYPE_ANY);

    // Return a weighting array of rarities for the given LOOT_TYPE_* type.
    // nLootType should be a single specific LOOT_TYPE only, not a combined bitmask.
    // The json object returned is newly generated and is safe to use inplace modification on without problems.
    json GetStandardLootRarityWeights(int nLootType);

    // Return the standard weighting array of uniqueness weights.
    // nUniqueChance is the percent chance for uniques if the loot type supports them. Default is the standard value.
    // The json object returned is newly generated and is safe to use inplace modification on without problems.
    json GetStandardLootUniquenessWeights(int nUniqueChance=UNIQUE_ITEM_CHANCE);
    
    // Returns a weighting array that contains a weighting of 1 for all bits set in nBitmask.
    // Pass a single bit to get a weighting array that is guaranteed to result in that being selected.
    // The json object returned is newly generated and is safe to use inplace modification on without problems.
    json GetWeightArrayForBitmaskAtEqualOdds(int nBitmask);
    
    
    
// The following may help manipulate these arrays.
    // Zero out corresponding weightings in jWeightArray that are NOT set in the provided nMask.
    // Performs inplace modification.
    void ClearWeightArrayBitsThatAreNotSetInMask(json jWeightArray, int nMask);
    // Zero out corresponding weightings in jWeightArray that are ARE set in the provided nMask.
    // Performs inplace modification.
    void ClearWeightArrayBitsThatAreSetInMask(json jWeightArray, int nMask);


// The fully configurable function:
    // All the above end up going through this at some point.
 

    // Roll a random item with fully configurable parameters.
    // Pass JsonNull() for any weight array parameter to use default weights. Doing this for jLootTierWeights will use GetStandardLootTierWeightsFromLootSource on oLootOrigin instead
    // This means that either a valid oLootOrigin OR jLootTierWeights must be supplied.
    // If oTargetInventory is a valid object, makes a copy of the selected item in that object's inventory and returns the new copy.
    // Otherwise, returns the object still inside the staging area container.
    // All parameters are weighting arrays for their respective types.
    // All of the above simply calculate weighting arrays and are fed into this function. It should be able to do the majority of loot selection that anyone could want,
    // but setting up the weight arrays manually every time is a bit laborious.
    object SelectLootItemCustom(object oTargetInventory, json jLootTierWeights, json jLootTypeWeights, json jLootRarityWeights, json jLootUniquenessWeights, object oLootOrigin=OBJECT_INVALID);
    
        


///////////////////
// DEBUGGING

// To turn on, set LOOT_DEBUG_ENABLED on the module to 1.
// This also requires the server in dev mode

// Various debugging variables - all should go on the module
const string LOOT_DEBUG_ENABLED = "dev_loot_debug";
// Set on the module, should be equal to the expected number of items rolled by the creature that is dying
const string LOOT_DEBUG_DROP_CHANCE_MULT = "dev_loot_debug_drop_chance_mult";
// These are all floats, and are the expected amount of gold of items of the given tier generated
const string LOOT_DEBUG_OUTPUT = "dev_loot_debug_t";
const string LOOT_DEBUG_GOLD = "dev_loot_debug_gold";
// If set, only track loot generated in this area (to avoid picking up other loot system calls for anything unrelated)
const string LOOT_DEBUG_AREA = "dev_loot_debug_area";

// Whether or not to track loot probabilities. Enabling this adds quite a lot of extra float calculations
int ShouldDebugLoot();

// Output the loot tracker's numbers.
// If running the development server, this outputs broken down values to the server log.
// Returns total gold + expected gold value of items as an int
int LootDebugOutput();

// Reset the loot tracker.
void ResetLootDebug();

// Returns a list of loot debug variables parts that might be set on the module.
// The variable names are actually:
// LOOT_DEBUG_OUTPUT + <array item> + IntToString(nTier)
// Where nTier is a value in the range 1-5, NOT a LOOT_TIER_* constant.
json GetLootDebugVariablePrefixes();

///////////////////////////////
// Other functions used internally without envisaged external use cases
// ... but still might be useful in some future world

// Return a raw weighting value for nTier at area CR nACR for nLootType.
// nTier may be either a literal 1-5 or a LOOT_TIER_* constant. Bitmasks of LOOT_TIER_* constants with multiple bits set will return 0.
// nLootType is used to apply item specific weight modifiers (eg potions/scrolls/consumables are more likely to be higher tier).
// fWeightExponentModifier is an additional modifier added to the item type's value (eg bosses use this to skew toward higher quality loot)
int GetTierWeight(int nACR, int nTier, int nLootType, float fWeightExponentModifier=0.0);

// Selects and returns a random bit from nBitmask.
int SelectARandomSetBitFromMask(int nBitmask);

// 1 if nLootType has rarities, else 0.
// Return value will be misleading if nLootType has more than one bit set.
int DoesLootTypeHaveRarities(int nLootType);

// 1 if nLootType has non-uniques, else 0.
// Return value will be misleading if nLootType has more than one bit set.
int DoesLootTypeHaveNonUniques(int nLootType);

// Roll a random item with fixed tier/type/rarity/uniqueness.
// If oTargetInventory is a valid object, makes a copy of the selected item in that object's inventory and returns the new copy.
// Otherwise, returns the object still inside the staging area container.
// 
// All of the following should be SINGLE BITS not compound masks
// nTier - either LOOT_TIER_* (multiple bits set are not supported)
// nLootType - LOOT_TYPE_*
// nRarity - LOOT_RARITY_*
// nUniqueness - LOOT_UNIQUENESS_*
object SelectLootItemFixedCategories(object oTargetInventory, int nTier, int nLootType, int nRarity, int nUniqueness);



/////////////

int _ConvertPassedTierToBitmask(int nPassedTier)
{
    if (nPassedTier <= 0)
        return 0;
    if (nPassedTier >= LOOT_TIER_ONE)
        return nPassedTier;
    int nBitmask = LOOT_TIER_ONE;
    while (nPassedTier > 1)
    {
        nPassedTier--;
        nBitmask *= 2;
    }
    return nBitmask;
}

int _TierBitmaskToNumeric(int nBitmask)
{
    if (nBitmask < LOOT_TIER_ONE)
        return nBitmask;
    int nTier = 1;
    int nTestBitmask = LOOT_TIER_ONE;
    while (1)
    {
        if (nBitmask & nTestBitmask || nTestBitmask > nBitmask)
            return nTier;
        nTier++;
        nTestBitmask *= 2;
    }
    return nTier;
}

// These are used to find out what tag of chest to pull from
string _LootRarityToString(int nLootRarity)
{
    if (nLootRarity == LOOT_RARITY_COMMON) return "Common";
    else if (nLootRarity == LOOT_RARITY_UNCOMMON) return "Uncommon";
    else if (nLootRarity == LOOT_RARITY_RARE) return "Rare";
    else if (nLootRarity == LOOT_RARITY_UNDEFINED) return "";
    WriteTimestampedLogEntry("ERROR: " + GetScriptName() + ": inc_lootselect: no text defined for item rarity constant " + IntToString(nLootRarity));
    return "";
}

string _LootTypeToString(int nLootType)
{
    if (nLootType == LOOT_TYPE_MISC) return "Misc";
    else if (nLootType == LOOT_TYPE_MISCCONS) return "MiscCons";
    else if (nLootType == LOOT_TYPE_POTION) return "Potions";
    else if (nLootType == LOOT_TYPE_APPAREL) return "Apparel";
    else if (nLootType == LOOT_TYPE_JEWEL) return "Jewels";
    else if (nLootType == LOOT_TYPE_ARMOR) return "Armor";
    else if (nLootType == LOOT_TYPE_WEAPON_RANGE) return "Range";
    else if (nLootType == LOOT_TYPE_WEAPON_MELEE) return "Melee";
    else if (nLootType == LOOT_TYPE_SCROLL) return "Scrolls";
    WriteTimestampedLogEntry("ERROR: " + GetScriptName() + ": inc_lootselect: no text defined for item type constant " + IntToString(nLootType));
    return "";
}

string _LootUniquenesstoString(int nLootUniqueness)
{
    if (nLootUniqueness == LOOT_UNIQUENESS_UNIQUE) return "";
    else if (nLootUniqueness == LOOT_UNIQUENESS_NONUNIQUE) return "NonUnique";
    WriteTimestampedLogEntry("ERROR: " + GetScriptName() + ": inc_lootselect: no text defined for item uniqueness constant " + IntToString(nLootUniqueness));
    return "";
}

string _LootTierToString(int nTier)
{
    if (nTier == LOOT_TIER_ONE) return "T1";
    else if (nTier == LOOT_TIER_TWO) return "T2";
    else if (nTier == LOOT_TIER_THREE) return "T3";
    else if (nTier == LOOT_TIER_FOUR) return "T4";
    else if (nTier == LOOT_TIER_FIVE) return "T5";
    WriteTimestampedLogEntry("ERROR: " + GetScriptName() + ": inc_lootselect: no text defined for item tier constant " + IntToString(nTier));
    return "";
}

int SelectBitFromWeightingArray(json jWeightArray, int nFallbackValue);

/////////////

// Dropping equippables.

json _AddToDroppableLootArray(json jItems, object oLootOrigin, object oItem, int nTier, int bSkipTierCheck)
{
    json jBlacklist = GetLocalJson(oLootOrigin, "OwnDroppableLootBlacklist");
    
    object oTFN = GetTFNStagedEquipmentForItem(oItem);
    if (GetLocalInt(oItem, "creature_drop_only"))
    {
        oTFN = oItem;
    }
    if (GetIsObjectValid(oTFN) && (bSkipTierCheck || GetItemTier(oTFN) == nTier))
    {
        json jNewEntry = JsonString(ObjectToString(oTFN));
        if (jBlacklist == JsonNull() || JsonFind(jBlacklist, jNewEntry) == JsonNull())
        {
            jItems = JsonArrayInsert(jItems, jNewEntry);
        }
    }
    
    return jItems;
}

void _AddToDroppableLootBlacklist(object oLootOrigin, object oItem)
{
    json jBlacklist = GetLocalJson(oLootOrigin, "OwnDroppableLootBlacklist");
    if (jBlacklist == JsonNull())
    {
        jBlacklist = JsonArray();
    }
    jBlacklist = JsonArrayInsert(jBlacklist, JsonString(ObjectToString(oItem)));
    SetLocalJson(oLootOrigin, "OwnDroppableLootBlacklist", jBlacklist);
}


json _BuildListOfOwnDroppableLoot(object oLootOrigin, int nTier, int bForceSkipTierCheck=-1)
{
    json jItems = JsonArray();
    if (GetObjectType(oLootOrigin) != OBJECT_TYPE_CREATURE)
    {
        return jItems;
    }

    int bSkipTierCheck = 0;
    if (GetLocalInt(oLootOrigin, "boss") && bForceSkipTierCheck == -1)
    {
        bSkipTierCheck = Random(100) < BOSS_EQUIPPED_ITEM_DROPS_IGNORE_TIER_CHANCE;
    }
    if (bForceSkipTierCheck != -1)
    {
        bSkipTierCheck = bForceSkipTierCheck;
    }

    jItems = _AddToDroppableLootArray(jItems, oLootOrigin, GetItemInSlot(INVENTORY_SLOT_CHEST, oLootOrigin), nTier, bSkipTierCheck);
    jItems = _AddToDroppableLootArray(jItems, oLootOrigin, GetItemInSlot(INVENTORY_SLOT_HEAD, oLootOrigin), nTier, bSkipTierCheck);
    jItems = _AddToDroppableLootArray(jItems, oLootOrigin, GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oLootOrigin), nTier, bSkipTierCheck);
    jItems = _AddToDroppableLootArray(jItems, oLootOrigin, GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oLootOrigin), nTier, bSkipTierCheck);
    jItems = _AddToDroppableLootArray(jItems, oLootOrigin, GetItemInSlot(INVENTORY_SLOT_ARMS, oLootOrigin), nTier, bSkipTierCheck);
    jItems = _AddToDroppableLootArray(jItems, oLootOrigin, GetItemInSlot(INVENTORY_SLOT_BELT, oLootOrigin), nTier, bSkipTierCheck);
    jItems = _AddToDroppableLootArray(jItems, oLootOrigin, GetItemInSlot(INVENTORY_SLOT_BOOTS, oLootOrigin), nTier, bSkipTierCheck);
    jItems = _AddToDroppableLootArray(jItems, oLootOrigin, GetItemInSlot(INVENTORY_SLOT_CLOAK, oLootOrigin), nTier, bSkipTierCheck);
    jItems = _AddToDroppableLootArray(jItems, oLootOrigin, GetItemInSlot(INVENTORY_SLOT_LEFTRING, oLootOrigin), nTier, bSkipTierCheck);
    jItems = _AddToDroppableLootArray(jItems, oLootOrigin, GetItemInSlot(INVENTORY_SLOT_RIGHTRING, oLootOrigin), nTier, bSkipTierCheck);
    jItems = _AddToDroppableLootArray(jItems, oLootOrigin, GetItemInSlot(INVENTORY_SLOT_NECK, oLootOrigin), nTier, bSkipTierCheck);

    return jItems;
}

object SelectEquippedItemToDropAsLoot(object oLootOrigin, int nLootType, int nTier)
{
    // Have a chance to drop equipped items instead of random stuff
    if (GetIsObjectValid(oLootOrigin) && 
        GetObjectType(oLootOrigin) == OBJECT_TYPE_CREATURE &&
        // Not the things that use different tier weights
        (nLootType & LOOT_TYPE_CONSUMABLE) == 0 &&
        // Avoid assigning equipped items as droppable loot from pickpocketing
        GetIsDead(oLootOrigin))
    {
        if (Random(100) < CHANCE_TO_DROP_EQUIPPED_ITEM)
        {
            json jItems = _BuildListOfOwnDroppableLoot(oLootOrigin, nTier);
            int nNumItems = JsonGetLength(jItems);
            SendDebugMessage("SelectEquippedItemToDropAsLoot: " + GetName(oLootOrigin) + " has " + IntToString(nNumItems) + " own items that could drop at tier" + IntToString(nTier), TRUE);
            if (nNumItems > 0)
            {
                int nIndex = Random(JsonGetLength(jItems));
                object oReturn = StringToObject(JsonGetString(JsonArrayGet(jItems, nIndex)));
                _AddToDroppableLootBlacklist(oLootOrigin, oReturn);
                SendDebugMessage(GetName(oLootOrigin) + ": Drop equipped item: " + GetName(oReturn), TRUE);
                return oReturn;
            }
        }
    }
    return OBJECT_INVALID;
}

// Other things.

int GetTierWeight(int nACR, int nTier, int nLootType, float fWeightExponentModifier=0.0)
{
    nTier = _ConvertPassedTierToBitmask(nTier);
    int nBase = -1;
    int nMidpoint = 0;
    // T1 does deliberately not use nACR in its base calc
    // This function looks demented, but was designed with a fairly large amount of reasoning in mind
    // This also discusses the issues with the significantly simpler system that it replaced
    // https://docs.google.com/document/d/1t451EgutNToXGVbuQGHraBaefI8TsWlcWbqXDpU-HA0
    // As the person that spent a few hours coming up with them, I would strongly encourage
    // a detailed discussion of what about the design of these is wrong before messing with them!
    
    if (nTier == LOOT_TIER_ONE)
    {
        nBase = BASE_T1_WEIGHT;
        nMidpoint = T1_SIGMOID_MIDPOINT;
    }
    else if (nTier == LOOT_TIER_TWO)
    {
        nBase = nACR * BASE_T2_WEIGHT;
        nMidpoint = T2_SIGMOID_MIDPOINT;
    }
    else if (nTier == LOOT_TIER_THREE)
    {
        nBase = nACR* BASE_T3_WEIGHT;
        nMidpoint = T3_SIGMOID_MIDPOINT;
    }
    else if (nTier == LOOT_TIER_FOUR)
    {
        nBase = nACR * BASE_T4_WEIGHT;
        nMidpoint = T4_SIGMOID_MIDPOINT;
    }
    else if (nTier == LOOT_TIER_FIVE)
    {
        nBase = nACR * BASE_T5_WEIGHT;
        nMidpoint = T5_SIGMOID_MIDPOINT;
    }
    else
        return 0;
    
    float fWeight = nBase * fmax(0.0, ((68.0 + atan((nACR - nMidpoint) * 0.6))/158.0));
    
    if (fWeight <= 0.0)
        return 0;
    
    float fExponent = 1.0 + fWeightExponentModifier;
    if (nLootType == LOOT_TYPE_MISCCONS)
        fExponent += MISC_CONSUMABLE_QUALITY_MODIFIER;
    else if (nLootType == LOOT_TYPE_POTION)
        fExponent += POTION_QUALITY_MODIFIER;
    else if (nLootType == LOOT_TYPE_SCROLL)
        fExponent += SCROLL_CONSUMABLE_QUALITY_MODIFIER;
    
    fWeight = pow(fWeight, fExponent);
    return FloatToInt(fWeight * 1000.0);
}

int SelectARandomSetBitFromMask(int nBitmask)
{
    int n = 1;
    int nTotalWeight = 0;
    while (n <= nBitmask)
    {
        if (nBitmask & n)
        {
            nTotalWeight ++;
        }
        n *= 2;
    }
    int nRolledWeight = Random(nTotalWeight)+1;
    n = 1;
    while (n <= nBitmask)
    {
        if (nBitmask & n)
        {
            nRolledWeight--;
            if (nRolledWeight <= 0)
                return n;
        }
        n *= 2;
    }
    return 0;
}

// 1 if nLootType has rarities, else 0.
// Return value will be misleading if nLootType has more than one bit set.
int DoesLootTypeHaveRarities(int nLootType)
{
    return (nLootType & LOOT_TYPES_WITH_RARITIES) > 0;
}

// 1 if nLootType has uniques, else 0.
// Return value will be misleading if nLootType has more than one bit set.
int DoesLootTypeHaveNonUniques(int nLootType)
{
    return (nLootType & LOOT_TYPES_WITH_NONUNIQUES) > 0;
}

// Zero out corresponding weightings in jWeightArray that are NOT set in the provided nMask.
void ClearWeightArrayBitsThatAreNotSetInMask(json jWeightArray, int nMask)
{
    int nIndex = 0;
    int nBit = 1;
    int nLength = JsonGetLength(jWeightArray);
    while (nIndex < nLength)
    {
        if ((nMask & nBit) == 0)
        {
            JsonArraySetInplace(jWeightArray, nIndex, JsonInt(0));
        }
        nIndex++;
        nBit *= 2;
    }
}

void ClearWeightArrayBitsThatAreSetInMask(json jWeightArray, int nMask)
{
    int nIndex = 0;
    int nBit = 1;
    int nLength = JsonGetLength(jWeightArray);
    while (nBit <= nMask && nIndex < nLength)
    {
        if ((nMask & nBit) > 0)
        {
            JsonArraySetInplace(jWeightArray, nIndex, JsonInt(0));
        }
        nIndex++;
        nBit *= 2;
    }
}

int SelectBitFromWeightingArray(json jWeightArray, int nFallbackValue)
{
    int nTotalWeight = 0;
    int nLength = JsonGetLength(jWeightArray);
    int i;
    for (i=0; i<nLength; i++)
    {
        nTotalWeight += JsonGetInt(JsonArrayGet(jWeightArray, i));
    }
    if (nTotalWeight == 0)
        return nFallbackValue;
    int nRolled = Random(nTotalWeight) + 1;
    for (i=0; i<nLength; i++)
    {
        nRolled -= JsonGetInt(JsonArrayGet(jWeightArray, i));
        if (nRolled <= 0)
            return FloatToInt(pow(2.0, IntToFloat(i)));
    }
    return nFallbackValue;
}

// Return a weighting array of tier weights for an area of nACR, single loot type nLootType and exponent modifier fWeightExponentModifier.
json GetStandardLootTierWeightsFromLootSource(object oLootOrigin, int nLootType=LOOT_TYPE_ANY, float fWeightExponentModifier=0.0)
{
    if (GetLocalInt(oLootOrigin, "boss"))
    {
       fWeightExponentModifier += BOSS_QUALITY_MODIFIER;
    }
    else if (GetLocalInt(oLootOrigin, "semiboss"))
    {
       fWeightExponentModifier += SEMIBOSS_QUALITY_MODIFIER;
    }
    else if (GetObjectType(oLootOrigin) == OBJECT_TYPE_PLACEABLE)
    {
        string sQuality = GetLocalString(oLootOrigin, "treasure");
        if (sQuality == "low")
        {
           fWeightExponentModifier += TREASURE_LOW_QUALITY;
        }
        else if (sQuality == "medium")
        {
           fWeightExponentModifier += TREASURE_MEDIUM_QUALITY;
        }
        else if (sQuality == "high")
        {
           fWeightExponentModifier += TREASURE_HIGH_QUALITY;
        }
    }
    
    int nACR = GetLocalInt(oLootOrigin, "area_cr");
    
    return GetStandardLootTierWeights(nACR, nLootType, fWeightExponentModifier);
}

// Return a weighting array of tier weights for an area of nACR, single loot type nLootType and exponent modifier fWeightExponentModifier.
json GetStandardLootTierWeights(int nACR, int nLootType=LOOT_TYPE_ANY, float fWeightExponentModifier=0.0)
{
    if (nLootType == LOOT_TYPE_POTION)
        fWeightExponentModifier += POTION_QUALITY_MODIFIER;
    else if (nLootType == LOOT_TYPE_MISCCONS)
        fWeightExponentModifier += MISC_CONSUMABLE_QUALITY_MODIFIER;
    else if (nLootType == LOOT_TYPE_SCROLL)
        fWeightExponentModifier += SCROLL_CONSUMABLE_QUALITY_MODIFIER;
    
    json jArr = JsonArray();
    int nTier = 1;
    while (nTier <= LOOT_TIER_FIVE)
    {
        if (nTier < LOOT_TIER_ONE)
        {
             JsonArrayInsertInplace(jArr, JsonInt(0));
        }
        else
        {
            JsonArrayInsertInplace(jArr, JsonInt(GetTierWeight(nACR, nTier, nLootType, fWeightExponentModifier)));
        }
        nTier *= 2;
    }
    //WriteTimestampedLogEntry("Standard loot weights, ACR " + IntToString(nACR) + ", exponent " + FloatToString(fWeightExponentModifier) + " -> " + JsonDump(jArr));
    return jArr;
}

// Return the standard weighting array of rarity weights for the given loot type.
json GetStandardLootRarityWeights(int nLootType)
{
    json jArr = JsonArray();
    JsonArrayInsertInplace(jArr, JsonInt(1)); // LOOT_RARITY_UNDEFINED
    if (nLootType & (LOOT_TYPE_WEAPON_MELEE + LOOT_TYPE_WEAPON_RANGE) > 0)
    {
        JsonArrayInsertInplace(jArr, JsonInt(WEAPON_COMMON_WEIGHT));
        JsonArrayInsertInplace(jArr, JsonInt(WEAPON_UNCOMMON_WEIGHT));
        JsonArrayInsertInplace(jArr, JsonInt(WEAPON_RARE_WEIGHT));
    }
    else
    {
        JsonArrayInsertInplace(jArr, JsonInt(OTHER_COMMON_WEIGHT));
        JsonArrayInsertInplace(jArr, JsonInt(OTHER_UNCOMMON_WEIGHT));
        JsonArrayInsertInplace(jArr, JsonInt(OTHER_RARE_WEIGHT));
    }
    return jArr;
}

json GetStandardLootUniquenessWeights(int nUniqueChance=UNIQUE_ITEM_CHANCE)
{
    json jArr = JsonArray();
    int nNonUnique = 100-nUniqueChance;
    JsonArrayInsertInplace(jArr, JsonInt(nUniqueChance));
    JsonArrayInsertInplace(jArr, JsonInt(nNonUnique));
    return jArr;
}

json GetStandardLootTypeWeights(int nAllowedLootTypes=LOOT_TYPE_ANY)
{
    json jArr = JsonArray();
    
    int nWeight;
    nWeight = (nAllowedLootTypes & LOOT_TYPE_MISCCONS) ? LOOT_MISCCONS_WEIGHT : 0;
    JsonArrayInsertInplace(jArr, JsonInt(nWeight));
    nWeight = (nAllowedLootTypes & LOOT_TYPE_MISC) ? LOOT_MISC_WEIGHT : 0;
    JsonArrayInsertInplace(jArr, JsonInt(nWeight));
    nWeight = (nAllowedLootTypes & LOOT_TYPE_SCROLL) ? LOOT_SCROLL_WEIGHT : 0;
    JsonArrayInsertInplace(jArr, JsonInt(nWeight));
    nWeight = (nAllowedLootTypes & LOOT_TYPE_POTION) ? LOOT_POTION_WEIGHT : 0;
    JsonArrayInsertInplace(jArr, JsonInt(nWeight));
    nWeight = (nAllowedLootTypes & LOOT_TYPE_WEAPON_MELEE) ? LOOT_WEAPON_MELEE_WEIGHT : 0;
    JsonArrayInsertInplace(jArr, JsonInt(nWeight));
    nWeight = (nAllowedLootTypes & LOOT_TYPE_WEAPON_RANGE) ? LOOT_WEAPON_RANGE_WEIGHT : 0;
    JsonArrayInsertInplace(jArr, JsonInt(nWeight));
    nWeight = (nAllowedLootTypes & LOOT_TYPE_ARMOR) ? LOOT_ARMOR_WEIGHT : 0;
    JsonArrayInsertInplace(jArr, JsonInt(nWeight));
    nWeight = (nAllowedLootTypes & LOOT_TYPE_APPAREL) ? LOOT_APPAREL_WEIGHT : 0;
    JsonArrayInsertInplace(jArr, JsonInt(nWeight));
    nWeight = (nAllowedLootTypes & LOOT_TYPE_JEWEL) ? LOOT_JEWEL_WEIGHT : 0;
    JsonArrayInsertInplace(jArr, JsonInt(nWeight));
 
    return jArr;
}

json GetWeightArrayForBitmaskAtEqualOdds(int nBitmask)
{
    int n = 1;
    json jArr = JsonArray();
    if (nBitmask < 1)
        return jArr;
    
    while (n <= nBitmask)
    {
        if (nBitmask & n)
        {
            JsonArrayInsertInplace(jArr, JsonInt(1));
        }
        else
        {
            JsonArrayInsertInplace(jArr, JsonInt(0));
        }
        n *= 2;
    }
    //WriteTimestampedLogEntry("Weight array for mask " + IntToString(nBitmask) + " -> " + JsonDump(jArr));
    return jArr;
}


object SelectLootItemFixedTierEqualLootTypeOdds(object oTargetInventory, int nTier, int nAllowedLootTypes=LOOT_TYPE_ANY, int nUniqueChance=UNIQUE_ITEM_CHANCE)
{
    nTier = _ConvertPassedTierToBitmask(nTier);
    json jTierWeights = GetWeightArrayForBitmaskAtEqualOdds(nTier);
    json jLootTypeWeights = GetWeightArrayForBitmaskAtEqualOdds(nAllowedLootTypes);
    json jLootUniquenessWeights = GetStandardLootUniquenessWeights(nUniqueChance);
    json jRarityWeights = JsonNull();
    return SelectLootItemCustom(oTargetInventory, jTierWeights, jLootTypeWeights, jRarityWeights, jLootUniquenessWeights);
}

object SelectLootItemFromACREqualLootTypeOdds(object oTargetInventory, int nACR, int nAllowedLootTypes=LOOT_TYPE_ANY, int nUniqueChance=UNIQUE_ITEM_CHANCE)
{
    int nItemType = SelectBitFromWeightingArray(GetWeightArrayForBitmaskAtEqualOdds(nAllowedLootTypes), 0);
    if (nItemType == 0)
        return OBJECT_INVALID;
    json jTierWeights = GetStandardLootTierWeights(nACR, nItemType);
    return SelectLootItemCustom(oTargetInventory, jTierWeights, GetWeightArrayForBitmaskAtEqualOdds(nItemType), JsonNull(), GetStandardLootUniquenessWeights(nUniqueChance));
}

object SelectLootItemFixedTier(object oTargetInventory, int nTier, int nAllowedLootTypes=LOOT_TYPE_ANY, int nUniqueChance=UNIQUE_ITEM_CHANCE)
{
    nTier = _ConvertPassedTierToBitmask(nTier);
    json jTierWeights = GetWeightArrayForBitmaskAtEqualOdds(nTier);
    json jLootTypeWeights = GetStandardLootTypeWeights(nAllowedLootTypes);
    json jLootUniquenessWeights = GetStandardLootUniquenessWeights(nUniqueChance);
    json jRarityWeights = JsonNull();
    return SelectLootItemCustom(oTargetInventory, jTierWeights, jLootTypeWeights, jRarityWeights, jLootUniquenessWeights);
}

object SelectLootItemForLootSource(object oTargetInventory, object oLootOrigin, int nAllowedLootTypes=LOOT_TYPE_ANY, int nUniqueChance=UNIQUE_ITEM_CHANCE)
{
    json jTierWeights = JsonNull();
    json jLootTypeWeights = GetStandardLootTypeWeights(nAllowedLootTypes);
    json jLootUniquenessWeights = GetStandardLootUniquenessWeights(nUniqueChance);
    json jRarityWeights = JsonNull();
    return SelectLootItemCustom(oTargetInventory, jTierWeights, jLootTypeWeights, jRarityWeights, jLootUniquenessWeights, oLootOrigin);
}

object SelectLootItemFromACR(object oTargetInventory, int nACR, int nAllowedLootTypes=LOOT_TYPE_ANY, int nUniqueChance=UNIQUE_ITEM_CHANCE)
{
    int nItemType = SelectBitFromWeightingArray(GetStandardLootTypeWeights(nAllowedLootTypes), 0);
    if (nItemType == 0)
        return OBJECT_INVALID;
    json jTierWeights = GetStandardLootTierWeights(nACR, nItemType);
    return SelectLootItemCustom(oTargetInventory, jTierWeights, GetWeightArrayForBitmaskAtEqualOdds(nItemType), JsonNull(), GetStandardLootUniquenessWeights(nUniqueChance));
}

// Convert a weight array into an array of floats of actual probabilities of each item
// Should sum to 1.0f
json GetRawProbabilitiesFromWeightArray(json jWeightArray)
{
    json jArr = JsonArray();
    int nLength = JsonGetLength(jWeightArray);
    int nWeightSum = 0;
    int i;
    for (i=0; i<nLength; i++)
    {
        nWeightSum += JsonGetInt(JsonArrayGet(jWeightArray, i));
    }
    if (nWeightSum == 0)
        return JsonNull();
    
    float fWeightSum = IntToFloat(nWeightSum);
    for (i=0; i<nLength; i++)
    {
        float fProb = IntToFloat(JsonGetInt(JsonArrayGet(jWeightArray, i)))/fWeightSum;
        JsonArrayInsertInplace(jArr, JsonFloat(fProb));
    }
    return jArr;
}

// Return the staging area chest for nTier/nLootType/nRarity/nUniqueness.
// All should be single bit LOOT_* constants, not combinations of them
object SelectLootStorageChest(int nTier, int nLootType, int nRarity, int nUniqueness)
{
    nTier = _ConvertPassedTierToBitmask(nTier);
    string sType = _LootTypeToString(nLootType);
    string sRarity = _LootRarityToString(nRarity);
    string sUnique = _LootUniquenesstoString(nUniqueness);
    string sTier = _LootTierToString(nTier);
    
    object oChest = GetObjectByTag("_"+sType+sRarity+sTier+sUnique);
    // If no uniques, fetch a nonunique instead
    if (!GetIsObjectValid(oChest) && nUniqueness != LOOT_UNIQUENESS_NONUNIQUE)
    {
        sUnique = _LootUniquenesstoString(LOOT_UNIQUENESS_NONUNIQUE);
        oChest = GetObjectByTag("_"+sType+sRarity+sTier+sUnique);
    }
    if (!GetIsObjectValid(oChest))
    {
        SendDebugMessage(GetScriptName() + " wanted to get an item from nonexistent chest: " + "_"+sType+sRarity+sTier+sUnique, TRUE);
    }
    return oChest;
}

float GetAverageGoldValueOfStorageChest(object oStorageChest)
{
    if (!GetIsObjectValid(oStorageChest))
        return 0.0f;
    
    if (GetLocalFloat(oStorageChest, "average_gold_value") > 0.0)
        return GetLocalFloat(oStorageChest, "average_gold_value");
    
    float fTotal = 0.0f;
    int nCount = 0;
    object oTest = GetFirstItemInInventory(oStorageChest);
    while (GetIsObjectValid(oTest))
    {
        int nState = GetIdentified(oTest);
        if (!nState)
        {
            SetIdentified(oTest, TRUE);
        }
        int nVal = GetGoldPieceValue(oTest);
        SetIdentified(oTest, nState);
        fTotal += IntToFloat(nVal);
        nCount++;
        oTest = GetNextItemInInventory(oStorageChest);
    }
    float fFinal = fTotal/IntToFloat(nCount);
    SetLocalFloat(oStorageChest, "average_gold_value", fFinal);
    return fFinal;
}

object SelectLootItemCustom(object oTargetInventory, json jLootTierWeights, json jLootTypeWeights, json jLootRarityWeights, json jLootUniquenessWeights, object oLootOrigin=OBJECT_INVALID)
{
    if (GetLocalInt(GetModule(), "treasure_ready") != 1)
    {
       SendMessageToAllPCs("Treasure isn't ready. No treasure will be generated.");
       return OBJECT_INVALID;
    }

    if (GetLocalInt(GetModule(), "treasure_tainted") == 1)
    {
       SendMessageToAllPCs("Treasure is tainted. No treasure will be generated.");
       return OBJECT_INVALID;
    }
   
    if (jLootTierWeights == JsonNull() && !GetIsObjectValid(oLootOrigin))
    {
        WriteTimestampedLogEntry("Warning: " + GetScriptName() + ": SelectLootItemCustom called with null tier weights and invalid loot origin, this is not allowed: returned OBJECT_INVALID");
        return OBJECT_INVALID;
    }
    
    if (jLootTypeWeights == JsonNull())
    {
        jLootTypeWeights = GetStandardLootTypeWeights(LOOT_TYPE_ANY);
    }
    
    if (jLootUniquenessWeights == JsonNull())
    {
        jLootUniquenessWeights = GetStandardLootUniquenessWeights(UNIQUE_ITEM_CHANCE);
    }
    
    if (ShouldDebugLoot() && (GetObjectType(oLootOrigin) == OBJECT_TYPE_CREATURE || GetObjectType(oLootOrigin) == OBJECT_TYPE_PLACEABLE))
    {
        object oModule = GetModule();
        string sVarPrefix;
        if (GetObjectType(oLootOrigin) == OBJECT_TYPE_PLACEABLE)
        {
            string sTreasure = GetLocalString(oLootOrigin, "treasure");
            if (sTreasure != "high" && sTreasure != "medium" && sTreasure != "low")
            {
                sTreasure = "other";
            }
            if (GetLocalInt(oLootOrigin, "boss"))
            {
                sTreasure = "boss";
            }
            if (GetLocalInt(oLootOrigin, "semiboss"))
            {
                sTreasure = "semiboss";
            }
            sVarPrefix = "_plc_" + sTreasure;
        }
        else if (GetObjectType(oLootOrigin) == OBJECT_TYPE_CREATURE)
        {
            string sTreasure = "normal";
            if (GetLocalInt(oLootOrigin, "boss"))
            {
                sTreasure = "boss";
            }
            if (GetLocalInt(oLootOrigin, "semiboss"))
            {
                sTreasure = "semiboss";
            }
            sVarPrefix = "_cre_" + sTreasure;
        }
        
        
        
        json jTypeProbability = GetRawProbabilitiesFromWeightArray(jLootTypeWeights);
        int nLootType = 1;
        int nNumTypes = JsonGetLength(jTypeProbability);
        int nLootTypeIndex;
        for (nLootTypeIndex=0; nLootTypeIndex<nNumTypes; nLootTypeIndex++)
        {
            float fLootTypeProb = JsonGetFloat(JsonArrayGet(jTypeProbability, nLootTypeIndex));
            if (fLootTypeProb > 0.0)
            {
                string sType = _LootTypeToString(nLootType);
                // Make copies that are safe to modify inplace
                json jTypeTierWeights = JsonArrayGetRange(jLootTierWeights, 0, -1);
                json jTypeRarityWeights = JsonArrayGetRange(jLootRarityWeights, 0, -1);
                json jTypeUniqueWeights = JsonArrayGetRange(jLootUniquenessWeights, 0, -1);
                if (jTypeTierWeights == JsonNull())
                {
                    jTypeTierWeights = GetStandardLootTierWeightsFromLootSource(oLootOrigin, nLootType);
                }
                if (jTypeRarityWeights == JsonNull())
                {
                    jTypeRarityWeights = GetStandardLootRarityWeights(nLootType);
                }
                
                if (DoesLootTypeHaveRarities(nLootType))
                {
                    ClearWeightArrayBitsThatAreNotSetInMask(jTypeRarityWeights, LOOT_RARITY_CATEGORISED);
                }         
                else
                {
                    jTypeRarityWeights = GetWeightArrayForBitmaskAtEqualOdds(LOOT_RARITY_UNDEFINED);
                }

                if (!DoesLootTypeHaveNonUniques(nLootType))
                {
                    ClearWeightArrayBitsThatAreNotSetInMask(jTypeUniqueWeights, LOOT_UNIQUENESS_UNIQUE);
                }


                json jTierProbability = GetRawProbabilitiesFromWeightArray(jTypeTierWeights);
                json jRarityProbability = GetRawProbabilitiesFromWeightArray(jTypeRarityWeights);   
                json jUniquenessProbability = GetRawProbabilitiesFromWeightArray(jTypeUniqueWeights);
                int nNumUniqueness = JsonGetLength(jUniquenessProbability);    
                int nNumTiers = JsonGetLength(jTypeTierWeights);
                int nNumRarities = JsonGetLength(jTypeRarityWeights);
                
                
                int nTierIndex;
                int nRarityIndex;
                int nUniquenessIndex;

                WriteTimestampedLogEntry("Target item type: " + _LootTypeToString(nLootType) + " with chance " + FloatToString(fLootTypeProb));
                WriteTimestampedLogEntry("Tier probs: " + JsonDump(jTierProbability));
                WriteTimestampedLogEntry("Rarity probs: " + JsonDump(jRarityProbability));
                WriteTimestampedLogEntry("Uniqueness probs: " + JsonDump(jUniquenessProbability));

                
                // The alternative to nesting all these for loops would be to write a worker that takes an array of arrays
                // and recursively works its way through all combinations of them
                // I am not sure that implementing that is going to be any easier to write or understand than 4 levels of nested for looping
                int nTierBitmask = 1;
                for (nTierIndex=0; nTierIndex<nNumTiers; nTierIndex++)
                {
                    float fTierProb = JsonGetFloat(JsonArrayGet(jTierProbability, nTierIndex));
                    if (fTierProb > 0.0)
                    {
                        string sTierNonBitmask = IntToString(_TierBitmaskToNumeric(nTierBitmask));
                        int nRarity = 1;
                        for (nRarityIndex=0; nRarityIndex<nNumRarities; nRarityIndex++)
                        {
                            float fRarityProb = JsonGetFloat(JsonArrayGet(jRarityProbability, nRarityIndex));
                            if (fRarityProb > 0.0)
                            {
                                int nUnique = 1;
                                for (nUniquenessIndex=0; nUniquenessIndex<nNumUniqueness; nUniquenessIndex++)
                                {
                                    float fUniquenessProb = JsonGetFloat(JsonArrayGet(jUniquenessProbability, nUniquenessIndex));
                                    if (fUniquenessProb > 0.0)
                                    {
                                        float fThisProb = fLootTypeProb*fTierProb*fRarityProb*fUniquenessProb*GetLocalFloat(GetModule(), LOOT_DEBUG_DROP_CHANCE_MULT);
                                        float fThisValue = fThisProb*GetAverageGoldValueOfStorageChest(SelectLootStorageChest(nTierBitmask, nLootType, nRarity, nUnique));
                                        string sVar = LOOT_DEBUG_OUTPUT + sVarPrefix + sTierNonBitmask;
                                        SetLocalFloat(oModule, sVar, GetLocalFloat(oModule, sVar) + fThisValue);
                                        sVar = sVar + "_" + sType;
                                        SetLocalFloat(oModule, sVar, GetLocalFloat(oModule, sVar) + fThisValue);
                                        // Deliberately exclude consumables from calculated item counts, as this makes the num items statistic useless
                                        // (eg: number of t5 items will be hugely inflated by potions/scrolls, in reality we only want to know the nonconsumables)
                                        if ((nLootType & LOOT_TYPE_CONSUMABLE) == 0)
                                        {
                                            sVar = LOOT_DEBUG_OUTPUT + sVarPrefix + sTierNonBitmask + "_numitems";
                                            SetLocalFloat(oModule, sVar, GetLocalFloat(oModule, sVar) + fThisProb);
                                        }
                                    }                                    
                                    nUnique *= 2;
                                }
                            }                            
                            nRarity *= 2;
                        }
                    }
                    nTierBitmask *= 2;
                }
            }
            nLootType *= 2;
        }
    }
    
    
    int nLootType = SelectBitFromWeightingArray(jLootTypeWeights, -1);
    //WriteTimestampedLogEntry("Weights: " + JsonDump(jLootTypeWeights) + " -> " + IntToString(nLootType));
    if (nLootType == -1)
    {
        WriteTimestampedLogEntry("Warning: " + GetScriptName() + ": SelectLootItemCustom called with bad item type weights " + JsonDump(jLootTypeWeights) + ": returned OBJECT_INVALID");
        return OBJECT_INVALID;
    }
    
    if (jLootTierWeights == JsonNull())
    {
        jLootTierWeights = GetStandardLootTierWeightsFromLootSource(oLootOrigin, nLootType);
    }
    
    if (jLootRarityWeights == JsonNull())
    {
        jLootRarityWeights = GetStandardLootRarityWeights(nLootType);
    }
    
    
    
    int nTier = SelectBitFromWeightingArray(jLootTierWeights, -1);
    if (nTier == -1)
    {
        WriteTimestampedLogEntry("Warning: " + GetScriptName() + ": SelectLootItemCustom called with bad tier weights " + JsonDump(jLootTierWeights) + ": returned OBJECT_INVALID");
        return OBJECT_INVALID;
    }
    
    // Consider dropping an equipped item.
    // I don't think there's any point in throwing this into the debugging. I had it in before the refactor, but on the whole
    // the effect on gold value is probably not incredibly large.
    object oEquipped = SelectEquippedItemToDropAsLoot(oLootOrigin, nLootType, nTier);
    if (GetIsObjectValid(oEquipped))
    {
        if (GetIsObjectValid(oTargetInventory))
        {
            return CopyTierItemFromStaging(oEquipped, oTargetInventory);
        }
    }
    
    int nRarity;
    int nUniqueness;
    
    if (DoesLootTypeHaveRarities(nLootType))
    {
        ClearWeightArrayBitsThatAreNotSetInMask(jLootRarityWeights, LOOT_RARITY_CATEGORISED);
        nRarity = SelectBitFromWeightingArray(jLootRarityWeights, -1);
        if (nRarity == -1)
        {
            WriteTimestampedLogEntry("Warning: " + GetScriptName() + ": SelectLootItemCustom ended up with bad rarity weights " + JsonDump(jLootRarityWeights) + ": returned OBJECT_INVALID");
            return OBJECT_INVALID;
        }
    }
    else
    {
        nRarity = LOOT_RARITY_UNDEFINED;
    }
    
    if (DoesLootTypeHaveNonUniques(nLootType))
    {
        nUniqueness = SelectBitFromWeightingArray(jLootUniquenessWeights, -1);
        if (nUniqueness == -1)
        {
            WriteTimestampedLogEntry("Warning: " + GetScriptName() + ": SelectLootItemCustom called with bad uniqueness weights " + JsonDump(jLootUniquenessWeights) + ": returned OBJECT_INVALID");
            return OBJECT_INVALID;
        }
    }
    else
    {
        nUniqueness = LOOT_UNIQUENESS_UNIQUE;
    }
    
    return SelectLootItemFixedCategories(oTargetInventory, nTier, nLootType, nRarity, nUniqueness);
}



object SelectLootItemFixedCategories(object oTargetInventory, int nTier, int nLootType, int nRarity, int nUniqueness)
{
    nTier = _ConvertPassedTierToBitmask(nTier);
    //WriteTimestampedLogEntry("SelectLootStorageChest " + IntToString(nTier) + " " + IntToString(nLootType) + " " + IntToString(nRarity) + " " + IntToString(nUniqueness));
    object oChest = SelectLootStorageChest(nTier, nLootType, nRarity, nUniqueness);
    
    if (!GetIsObjectValid(oChest))
    {
        return OBJECT_INVALID;
    }
    
    int nRandom = Random(StringToInt(GetDescription(oChest)));
    object oItem = GetFirstItemInInventory(oChest);

    while (nRandom)
    {
        nRandom--;
        oItem = GetNextItemInInventory(oChest);
    }

    if (GetPlotFlag(oItem) && GetObjectType(oTargetInventory) == OBJECT_TYPE_STORE)
    {
        return OBJECT_INVALID; // do not allow plot items to be created on stores
    }
    
    if (GetIsObjectValid(oTargetInventory))
    {
        return CopyTierItemFromStaging(oItem, oTargetInventory);
    }
    return oItem;
}

object CopyTierItemFromStaging(object oStagingItem, object oTargetInventory=OBJECT_INVALID, location lTarget=LOCATION_INVALID)
{
    if (!GetIsObjectValid(oStagingItem))
    {
        return OBJECT_INVALID;
    }

    int nBaseType = GetBaseItemType(oStagingItem);

    object oNewItem;
    if (GetIsObjectValid(oTargetInventory))
    {
        oNewItem = CopyItem(oStagingItem, oTargetInventory, TRUE);
    }
    else
    {
        oNewItem = CopyObject(oStagingItem, lTarget, OBJECT_INVALID, GetTag(oStagingItem), TRUE);
    }
    
    if (!GetIsObjectValid(oNewItem))
    {
        return OBJECT_INVALID;
    }

    if (nBaseType == BASE_ITEM_THROWINGAXE || nBaseType == BASE_ITEM_DART || nBaseType == BASE_ITEM_SHURIKEN || nBaseType == BASE_ITEM_ARROW || nBaseType == BASE_ITEM_BULLET || nBaseType == BASE_ITEM_BOLT)
    {
        if (IsAmmoInfinite(oNewItem))
        { // If the ammo has ANY item properties at all, it is considered magical and infinite. Make sure it only has a stack size of 1.
            SetItemStackSize(oNewItem, 1);
            // Prevents stacking
            SetLocalString(oNewItem, "new_uuid", GetRandomUUID());
        }
        else
        { // Set a stack size for mundane items. Don't go above 50, due to certain stack sizes.
            SetItemStackSize(oNewItem, Random(45)+1);
        }
    }

    // for magic wands and rods, set a random number of charges based on the initial (max) amount of charges
    int nCharges = GetItemCharges(oNewItem);
    if (nCharges > 0 && (nBaseType == BASE_ITEM_MAGICWAND || nBaseType == BASE_ITEM_MAGICROD)) SetItemCharges(oNewItem, Random(nCharges)+1);

    // Set visual transforms, and do the rest if it wasn't done for any reason
    InitializeItem(oNewItem);

    return oNewItem;
}


// Debug.


int ShouldDebugLoot()
{
    if (GetLocalInt(GetModule(), LOOT_DEBUG_ENABLED))
    {
        if (GetIsDevServer())
        {
            return TRUE;
        }
        // The module now uses this on startup to calculate a few things
        if (!GetLocalInt(GetModule(), "init_complete"))
        {
            return TRUE;
        }
    }
    return FALSE;
}

json GetLootDebugVariablePrefixes()
{
    json jOut = GetLocalJson(GetModule(), "loot_debug_var_prefixes");
    //if (jOut == JsonNull())
    if (1)
    {
        jOut = JsonArray();;
        int nType;
        int nSubtype;
        int nItemTypeIndex;

        // type 0: creature
        // type 1: placeable
        // type 2: undefined (should be unused but...)
        for (nType=0; nType<=2; nType++)
        {
            string sTypePrefix;

            json jSubtypeLabels = JsonArray();
            if (nType == 0)
            {
                sTypePrefix = "cre";
                JsonArrayInsertInplace(jSubtypeLabels, JsonString("normal"));
                JsonArrayInsertInplace(jSubtypeLabels, JsonString("boss"));
                JsonArrayInsertInplace(jSubtypeLabels, JsonString("semiboss"));
            }
            else if (nType == 1)
            {
                sTypePrefix = "plc";
                JsonArrayInsertInplace(jSubtypeLabels, JsonString("low"));
                JsonArrayInsertInplace(jSubtypeLabels, JsonString("medium"));
                JsonArrayInsertInplace(jSubtypeLabels, JsonString("high"));
                JsonArrayInsertInplace(jSubtypeLabels, JsonString("other"));
                JsonArrayInsertInplace(jSubtypeLabels, JsonString("boss"));
                JsonArrayInsertInplace(jSubtypeLabels, JsonString("semiboss"));
            }
            else
            {
                sTypePrefix = "";
                JsonArrayInsertInplace(jSubtypeLabels, JsonString(""));
            }
            int nNumSubtypes = JsonGetLength(jSubtypeLabels);
            // Creatures: "normal", "boss", "semiboss"
            // Placeable: "low", "medium", "high", "boss", "semiboss", "other"
            for (nSubtype=0; nSubtype<nNumSubtypes; nSubtype++)
            {
                string sSubtype = JsonGetString(JsonArrayGet(jSubtypeLabels, nSubtype));
                string sPrefix = "_" + sTypePrefix;
                if (sTypePrefix == "") { sPrefix = ""; }
                if (sSubtype != "") { sPrefix = sPrefix + "_" + sSubtype; }
                JsonArrayInsertInplace(jOut, JsonString(sPrefix));
            }
        }
        SetLocalJson(GetModule(), "loot_debug_var_prefixes", jOut);
    }
    return jOut;
}

// Reset the loot tracker.
void ResetLootDebug()
{
    int nTier;
    json jTypePrefixes = GetLootDebugVariablePrefixes();
    int nNumTypePrefixes = JsonGetLength(jTypePrefixes);
    int nPrefixIndex;
    for (nTier=1; nTier<=5; nTier++)
    {
        for (nPrefixIndex=0; nPrefixIndex<nNumTypePrefixes; nPrefixIndex++)
        {
            string sPrefix = JsonGetString(JsonArrayGet(jTypePrefixes, nPrefixIndex));
            string sVar = LOOT_DEBUG_OUTPUT + sPrefix + IntToString(nTier);
            SetLocalFloat(GetModule(), sVar, 0.0);
            sVar = sVar + "_numitems";
            SetLocalFloat(GetModule(), sVar, 0.0);
        }
    }
    SetLocalFloat(GetModule(), LOOT_DEBUG_GOLD, 0.0);
    DeleteLocalObject(GetModule(), LOOT_DEBUG_AREA);
}

int LootDebugOutput()
{
    int nTier;
    float fGoldTotal = 0.0;
    json jTypePrefixes = GetLootDebugVariablePrefixes();
    int nNumTypePrefixes = JsonGetLength(jTypePrefixes);
    int nPrefixIndex;
    for (nTier=1; nTier<=5; nTier++)
    {
        for (nPrefixIndex=0; nPrefixIndex<nNumTypePrefixes; nPrefixIndex++)
        {
            string sPrefix = JsonGetString(JsonArrayGet(jTypePrefixes, nPrefixIndex));
            string sVar = LOOT_DEBUG_OUTPUT + sPrefix + IntToString(nTier);
            float fThisVal = GetLocalFloat(GetModule(), sVar);
            fGoldTotal += fThisVal;
            if (fThisVal > 0.0)
            {
                SendDebugMessage("Expected value of prefix \"" + sPrefix + "\" tier " + IntToString(nTier) + " items: " + FloatToString(GetLocalFloat(GetModule(), sVar)), TRUE);
                sVar = sVar + "_numitems";
                SendDebugMessage("Expected number of prefix \"" + sPrefix + "\" tier " + IntToString(nTier) + " items: " + FloatToString(GetLocalFloat(GetModule(), sVar)), TRUE);
            }
        }
    }
    float fRawGold = GetLocalFloat(GetModule(), LOOT_DEBUG_GOLD);
    SendDebugMessage("Expected raw gold: " + FloatToString(fRawGold), TRUE);
    SendDebugMessage("Total item value: " + FloatToString(fGoldTotal), TRUE);

    return FloatToInt(fGoldTotal + fRawGold);
}


