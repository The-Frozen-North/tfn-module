#include "x2_inc_itemprop"
#include "inc_debug"
#include "inc_general"
#include "nwnx_player"
#include "nwnx_item"
#include "nwnx_visibility"
#include "util_i_math"
#include "nw_i0_plot"
#include "inc_treasure"
#include "inc_treasuremap"
#include "inc_lootowing"
#include "inc_lootselect"

// General loot include.
// This handles general loot system features, like the personal loot bags.

// For selection of random items from the system chests (and creatures dropping equipped items) see inc_lootselect
// For assignment of items amongst members of parties ("owings" are tracked and assignment has some balancing), see inc_lootowing
// For the script called when killing creatures and opening placeables, see party_credit

// ===========================================================
// START CONSTANTS
// ===========================================================

// Seconds before loot is automatically destroyed.
const float LOOT_DESTRUCTION_TIME = 600.0;

// chance that a treasure will spawn at all out of 100
// This gets modified based on the difference between a monster's CR and the area CR
// Currently, the treasure drop rate as a percentage is:
// min(100, 20 * pow(2.0, ((MonsterCR - AreaCR)/2))
const float TREASURE_CHANCE = 30.0;
const float TREASURE_CHANCE_EXPONENT_DENOMINATOR = 2.0;

// The chance for one, two or three items to drop, specifically. This is out of 100.
const int CHANCE_ONE = 35;
const int CHANCE_TWO = 15;
const int CHANCE_THREE = 5;

// The message to show when there isn't loot available
const string NO_LOOT = "This container doesn't have any items.";

// CHANCE_X are multiplied by this for placeables that are destroyed (rather than opening the lock)
const float PLACEABLE_DESTROY_LOOT_PENALTY = 0.6;

const int BOSS_GOLD_MULTIPLIER = 5;
const int SEMIBOSS_RARE_GOLD_MULTIPLIER = 3;

// The real chance of a tiered pawnshop item to be unique is:
// UNIQUE_ITEM_CHANCE/100 * PAWNSHOP_CHANCE_TO_ALLOW_UNIQUE/100
// With both set at 33 that brings it to about 10.9%
// Pawnshops also typically stock lots of level appropriate random items that work like monster drops
// This applies ONLY to the fixed items of X tier
const int PAWNSHOP_CHANCE_TO_ALLOW_UNIQUE = 100;
// Merchants make a handful of rolls (typically 3-7) each with this percent chance to succeed
// Each success results in them stocking a t5 item - this deliberately keeps t5 items rare in stores
const int STORE_RANDOM_T5_CHANCE = 3;


const int OPENED_LOOT_HIGHLIGHT = 0x6464d0;
// #808080 - grey
const string OPENED_LOOT_HIGHLIGHT_STRING = "<c\x80\x80\x80>";


// ===========================================================
// START PROTOTYPES
// ===========================================================

// Call for when oPC attempts to loot oContainer.
// Will autoloot any gold assigned to them and show them their personal loot container inventory.
void OpenPersonalLoot(object oContainer, object oPC);

// Return the personal loot container that oPC will open when they try to loot oLootSource.
// This does not exist until party_credit has been called.
// It can be used to alter the contents of personal loot after the main script has been run.
// (Eg: treasure map rewards)
// if bCreateIfMissing, will create the personal loot if it doesn't exist already.
object GetPersonalLootForPC(object oLootSource, object oPC, int bCreateIfMissing=FALSE);

// ===========================================================
// START FUNCTIONS
// ===========================================================

const string PERSONAL_LOOT_GOLD_AMOUNT = "personal_loot_gold";


int GetFirstBossKillGuaranteedLootTier(int nACR, int bSemiboss)
{
    if (bSemiboss)
    {
        nACR = Round(IntToFloat(nACR)*0.7);
    }
    if (nACR < 3)
        return 2;
    else if (nACR == 3)
        return Random(100) < 15 ? 3 : 2;
    else if (nACR == 4)
        return Random(100) < 50 ? 3 : 2;
    else if (nACR == 5)
        return Random(100) < 80 ? 3 : 2;
    else if (nACR == 6)
        return Random(100) < 10 ? 4 : 3;
    else if (nACR == 7)
        return Random(100) < 25 ? 4 : 3;
    else if (nACR == 8)
        return Random(100) < 50 ? 4 : 3;
    else if (nACR == 9)
        return Random(100) < 70 ? 4 : 3;
    else if (nACR == 10)
        return Random(100) < 5 ? 5 : 4;
    else if (nACR == 11)
        return Random(100) < 15 ? 5 : 4;
    else if (nACR == 12)
        return Random(100) < 40 ? 5 : 4;
    else if (nACR == 13)
        return Random(100) < 80 ? 5 : 4;
    else
        return 5;
    
}

int GetIdentifiedItemCost(object oItem)
{
    int nState = GetIdentified(oItem);
    if (!nState)
    {
        SetIdentified(oItem, TRUE);
    }
    int nVal = GetGoldPieceValue(oItem);
    SetIdentified(oItem, nState);
    return nVal;
}

string GetIdentifiedItemName(object oItem)
{
    int nState = GetIdentified(oItem);
    if (!nState)
    {
        SetIdentified(oItem, TRUE);
    }
    string sVal = GetName(oItem);
    SetIdentified(oItem, nState);
    return sVal;
}


void DecrementLootAndDestroyIfEmpty(object oOpener, object oLootParent, object oPersonalLoot)
{
    // do not continue unless there are still items
    if (GetIsObjectValid(GetFirstItemInInventory(oPersonalLoot))) return;

    int nUnlooted = GetLocalInt(oLootParent, "unlooted")-1;

    // Decrement number of players who looted this, and destroy the loot container.
    SetLocalInt(oLootParent, "unlooted", nUnlooted);
    DestroyObject(oPersonalLoot);

    int bIsTreasure = GetStringLeft(GetResRef(oLootParent), 6) == "treas_";

    // Hide lootbags for players that have taken all their stuff
    if (!bIsTreasure)
    {
        NWNX_Visibility_SetVisibilityOverride(oOpener, oLootParent, NWNX_VISIBILITY_HIDDEN);
    }
    else
    {
        // Placeables instead become unusable
        NWNX_Player_SetPlaceableUsable(oOpener, oLootParent, FALSE);
    }

    // 0 or less unlooted means everyone has already looted this.
    if (nUnlooted <= 0)
    {
        SetPlotFlag(oLootParent, FALSE);

        if (bIsTreasure)
        {
            // Stay open, but be unusuable
            SetUseableFlag(oLootParent, FALSE);

        }
        else
        {
            // Assume this is a loot bag, destroy
            DestroyObject(oLootParent);
        }
    }
}

object GetPersonalLootForPC(object oLootSource, object oPC, int bCreateIfMissing=FALSE)
{
    object oPersonalLoot = GetObjectByUUID(GetLocalString(oLootSource, "personal_loot_"+GetPCPublicCDKey(oPC, TRUE)));
    if (!GetIsObjectValid(oPersonalLoot))
    {
        vector vPosition = GetPosition(oLootSource);
        vPosition.z = -100.0; // Make the personal loot go under the map
        location lLocation  = Location(GetArea(oLootSource), vPosition, 0.0);
        oPersonalLoot = CreateObject(OBJECT_TYPE_PLACEABLE, "_loot_personal", lLocation, FALSE);

        string sPlayerCDKey = GetPCPublicCDKey(oPC, TRUE);
        ForceRefreshObjectUUID(oPersonalLoot);

        SetLocalString(oLootSource, "personal_loot_"+sPlayerCDKey, GetObjectUUID(oPersonalLoot));
        SetLocalString(oPersonalLoot, "loot_parent_uuid", GetObjectUUID(oLootSource));
    }
    return oPersonalLoot;
}

// ---------------------------------------------------------
// This function is used to access a loot container.
// ---------------------------------------------------------
void OpenPersonalLoot(object oContainer, object oPC)
{
// don't do anything if not a PC
    if (!GetIsPC(oPC)) return;

    string sVar = "HighlightChange_" + GetPCPublicCDKey(oPC, TRUE) + "_" + ObjectToString(oPC);
    if (!GetLocalInt(oContainer, sVar))
    {
        NWNX_Player_SetObjectHiliteColorOverride(oPC, oContainer, OPENED_LOOT_HIGHLIGHT);
        NWNX_Player_SetPlaceableNameOverride(oPC, oContainer, OPENED_LOOT_HIGHLIGHT_STRING + GetName(oContainer) + "</c>");
        SetLocalInt(oContainer, sVar, 1);
    }

    // Get the personal container
    object oPersonalLoot = GetPersonalLootForPC(oContainer, oPC);

    int nGold = GetLocalInt(oPersonalLoot, PERSONAL_LOOT_GOLD_AMOUNT);
    if (nGold > 0)
    {
        AssignCommand(oContainer, ActionPlayAnimation(ANIMATION_PLACEABLE_OPEN));

        IncrementPlayerStatistic(oPC, "gold_looted", nGold);
        IncrementPlayerStatistic(oPC, "treasures_looted");

        GiveGoldToCreature(oPC, nGold);
        DeleteLocalInt(oPersonalLoot, PERSONAL_LOOT_GOLD_AMOUNT);
        NWNX_Player_PlaySound(oPC, "it_coins", oPC);
    }

    // if the loot container doesn't exist, give a message
    if (oPersonalLoot == OBJECT_INVALID)
    {
        if (nGold <= 0)
        {
            FloatingTextStringOnCreature(NO_LOOT, oPC, FALSE);
            int bIsTreasure = GetStringLeft(GetResRef(oContainer), 6) == "treas_";

            // Hide the lootbag
            if (!bIsTreasure)
            {
                NWNX_Visibility_SetVisibilityOverride(oPC, oContainer, NWNX_VISIBILITY_HIDDEN);
            }
            else
            {
                // Flag placeable unusable for this PC
                NWNX_Player_SetPlaceableUsable(oPC, oContainer, FALSE);
            }
        }
    }
    // if there are no items in it, destroy it immediately and do the logic
    else if (!GetIsObjectValid(GetFirstItemInInventory(oPersonalLoot)))
    {
        if (nGold <= 0)
        {
            FloatingTextStringOnCreature(NO_LOOT, oPC, FALSE);
            DecrementLootAndDestroyIfEmpty(oPC, oContainer, oPersonalLoot);
        }
        if (nGold > 0)
        {
            DelayCommand(1.0, DecrementLootAndDestroyIfEmpty(oPC, oContainer, oPersonalLoot));
        }
    }
    else
    {
        NWNX_Player_ForcePlaceableInventoryWindow(oPC, oPersonalLoot);
    }
}


int DetermineGoldFromCR(int iCR, int nMultiplier=1)
{
    if (iCR < 1) iCR = 1;
    int iResult = nMultiplier * (3+d3(iCR));

    if (d10() == 10) iResult = iResult*2; // 10% chance to double gold
    if (ShouldDebugLoot())
    {
        float fAvg = IntToFloat(nMultiplier * (3 + (iCR * 2)));
        fAvg *= 1.1;
        float fChanceForNoLootMultiplier = GetLocalFloat(GetModule(), LOOT_DEBUG_DROP_CHANCE_MULT);
        fAvg *= fChanceForNoLootMultiplier;
        SetLocalFloat(GetModule(), LOOT_DEBUG_GOLD, GetLocalFloat(GetModule(), LOOT_DEBUG_GOLD) + fAvg);
    }
    return iResult;
}

object GenerateAnimalLoot(object oCreature, int nAnimalGoldMultiplier, object oContainer)
{
    int nCreatureSize = GetCreatureSize(oCreature);
    if (nCreatureSize < CREATURE_SIZE_MEDIUM) return OBJECT_INVALID;

    string sResRef = "loot_skin";

    int nRace = GetRacialType(oCreature);
    switch (nRace)
    {
        case RACIAL_TYPE_MAGICAL_BEAST: sResRef = "loot_hide"; break;
        case RACIAL_TYPE_ANIMAL: sResRef = "loot_pelt"; break;
        case RACIAL_TYPE_BEAST: sResRef = "loot_pelt"; break;
        case RACIAL_TYPE_VERMIN: sResRef = "loot_carapace"; break;
    }

    int nBaseGold = GetMaxHitPoints(oCreature) + (GetHitDice(oCreature) * 4) + (GetBaseAttackBonus(oCreature) * 3);

    int nGold = nCreatureSize * (nAnimalGoldMultiplier * nBaseGold);

    object oItem = CreateItemOnObject(sResRef, oContainer);

    NWNX_Item_SetAddGoldPieceValue(oItem, nGold);

    // medium: 5 lbs, large: 10 lbs, huge: 15 lbs
    AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyWeightIncrease(nCreatureSize - 3), oItem);

    SetName(oItem, GetName(oItem) + " (" + GetName(oCreature) + ")");

    return oItem;
}

void CalculatePlaceableLootValues()
{
    object oModule = GetModule();
    int nACR;
    int nPlaceableTier;
    string sPlaceable;
    // This is in _BASE.
    location lSpawn = GetLocation(GetWaypointByTag("_calc_plc_values"));

    SetLocalInt(oModule, LOOT_DEBUG_ENABLED, 1);
    for (nPlaceableTier=0; nPlaceableTier<3; nPlaceableTier++)
    {
        if (nPlaceableTier == 0) { sPlaceable = "treas_bones_low"; }
        if (nPlaceableTier == 1) { sPlaceable = "treas_bones_med"; }
        if (nPlaceableTier == 2) { sPlaceable = "treas_bones_h"; }
        object oPlaceable = CreateObject(OBJECT_TYPE_PLACEABLE, sPlaceable, lSpawn);
        string sTreasureTier = GetLocalString(oPlaceable, "treasure");
        WriteTimestampedLogEntry("Spawned placeable " + GetName(oPlaceable) + " with tier " + sTreasureTier);
        ExecuteScript("treas_init", oPlaceable);
        for (nACR=0; nACR<=20; nACR++)
        {
            SetLocalInt(oPlaceable, "cr", nACR);
            SetLocalInt(oPlaceable, "area_cr", nACR);
            ExecuteScript("party_credit", oPlaceable);
            DeleteLocalInt(oPlaceable, "no_credit");
            int nGold = LootDebugOutput();
            WriteTimestampedLogEntry("Value of placeable loot " + sTreasureTier + " at ACR " + IntToString(nACR) + " = " + IntToString(nGold));
            SetLocalInt(oModule, "placeable_value_" + sTreasureTier + "_" + IntToString(nACR), nGold);
            ResetLootDebug();
        }
        DestroyObject(oPlaceable);
    }
    DeleteLocalInt(GetModule(), LOOT_DEBUG_ENABLED);
}

int GetAreaTargetPlaceableLootValue(object oArea)
{
    int nACR = GetLocalInt(oArea, "cr");
    float fAreaSize = IntToFloat(GetAreaSize(AREA_HEIGHT, oArea)*GetAreaSize(AREA_WIDTH, oArea));
    // Super tiny areas normally have a fight in them!
    fAreaSize = fAreaSize + 60.0;
    // Old: effectively just fAreaSize/10; but it didn't split on type
    // so if you assumed low/med/high are equal that's fAreaSize/30
    // buuuut they really aren't.
    float fMult = fAreaSize/60.0;
    // Because speed looting off a horse may become problematic.
    // Okay expeditious retreat can do the same thing, but... the areas where you can use a horse are typically more sparsely populated anyway
    if (GetLocalInt(oArea, "horse"))
    {
        fMult *= 0.3;
    }
    string sACR = IntToString(nACR);
    object oModule = GetModule();
    float fGold = IntToFloat(GetLocalInt(oModule, "placeable_value_low_" + sACR) + GetLocalInt(oModule, "placeable_value_medium_" + sACR) + GetLocalInt(oModule, "placeable_value_high_" + sACR));
    return FloatToInt(fGold * fMult);
}

//void main() {}
