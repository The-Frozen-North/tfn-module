/*/////////////////////// [Include - Set Weapons] //////////////////////////////
    Filename: J_Inc_Setweapons
///////////////////////// [Include - Set Weapons] //////////////////////////////
    This holds all the stuff for setting up local objects for weapons we have
    or have not got - normally the best to worst.
///////////////////////// [History] ////////////////////////////////////////////
    1.0 - Put in include
    1.3 - Fixed minor things, added arrays of weapons (for deul wielding) and
          heal kits and stuff added.
          Added to OnSpawn.
    1.4 - Removed item checking for wands etc.
          TO DO:
        - Perhaps remove healing kit code? Check in the general AI at start of combat?
        - Perhaps add in the other feats? Maybe not
        - Have a setting to allow a cirtain weapon type be favoured/be able to
          override the default settings and set a weapon to use, in the spawn
          script.
        - Redo how potions and item spells are setup!
///////////////////////// [Workings] ///////////////////////////////////////////
    This is included in "J_AI_SetWeapons" and executed from other places VIA it.

    This migth change, but not likely. It could be re-included OnSpawn at least
    for spawning in.

    Yraen's script really. Modified some things in it though, trying to speed it up
    Changed things like if statements to switches, tried (somewhat unsucessfully) to
    Add the magical staff (never equips it?) and the values are now much cleaner and
    better valued.

    NOTE:

    - Ignores OVERWHELMING CRITICAL
    - Ignores DEVASTATING CRITICAL
    - Ignores EPIC WEAPON FOCUS
    - Ignores EPIC WEAPON SPECIALIZATION
    - Ignores WEAPON OF CHOICE

    So if you really want the item to be used, just use one weapon.

    This is because epic feats, 5 lots, xAmount of checks, is many too many for
    it to be worth it. Maybe less then 1% would ever come up true, out of the
    many GetHasFeat() checks.

    The lower level ones are taken into account, however! And these are much
    more common.
///////////////////////// [Arguments] //////////////////////////////////////////
    Arguments: N/A
///////////////////////// [Include - Set Weapons] ////////////////////////////*/

#include "J_INC_CONSTANTS"

/*****Structure******/

// Things we use throughout, saves time (and Get's) putting them here.
// These are boolean proficiencies. They either have them...or not!
// After those, are other variables like size, strength, and value of the current item.
int bProfWizard, bProfDruid, bProfMonk, bProfElf, bProfRogue, bProfSimple,
    bProfMartial, bProfExotic, bProfShield, bProfTwoWeapons, nCreatureSize,
    nCreatureStrength, nCurrentItemValue, bCurrentItemIsMighty, bCurrentItemIsUnlimited,
    nCurrentItemSize, nCurrentItemDamage, nCurrentItemType, bGotArrows, bGotBolts,
    bGotBullets;

// String for setting a value integer to an item
const string SETWEP_VALUE                       = "VALUE";
const string SETWEP_DISTANCE                    = "DISTANCE";
const string SETWEP_IS_UNLIMITED                = "SETWEP_IS_UNLIMITED";
const string SETWEP_SHIELD                      = "SHIELD";

// Constants for weapon size.
const int WEAPON_SIZE_INVALID = 0;
const int WEAPON_SIZE_TINY    = 1;
const int WEAPON_SIZE_SMALL   = 2;
const int WEAPON_SIZE_MEDIUM  = 3;
const int WEAPON_SIZE_LARGE   = 4;

//int CREATURE_SIZE_INVALID = 0;
//int CREATURE_SIZE_TINY =    1;
//int CREATURE_SIZE_SMALL =   2;
//int CREATURE_SIZE_MEDIUM =  3;
//int CREATURE_SIZE_LARGE =   4;
//int CREATURE_SIZE_HUGE =    5;

/**** MAIN CALLS ****/
// Start of the whole thing...
// - Runs through ALL inventory items, and the weapon/ammo slots, to
// set what weapons are best to use, backup ones, shields and so forth!
void SetWeapons(object oTarget = OBJECT_SELF);
// Goes through and sets a value and then a weopen to all weopen items
void SortInventory(object oTarget);
// This returns the size of oItem
int GetWeaponSize(object oItem = OBJECT_INVALID);
// reset healing kits only on oTarget.
void ResetHealingKits(object oTarget);

/**** SETTING ****/
// Ranged weopen is set - final one to use.
void SetRangedWeapon(object oTarget);
// Sets the primary weopen to use.
void SetPrimaryWeapon(object oTarget, object oItem = OBJECT_INVALID);
// sets the Two Handed Weopen to use.
void SetTwoHandedWeapon(object oTarget, object oItem = OBJECT_INVALID);
// Ammo counters are set, although I do not think they specifically are equipped.
void SetAmmoCounters(object oTarget);
// Sets the object shield to use. Best one.
void SetShield(object oTarget);
// Like the ranged weapons, we set this so we can have 2 shields (so we can tell
// when to re-set such things).
void StoreShield(object oTarget, object oItem);
// Uses right prefix to store the object to oTarget.
void SWFinalAIObject(object oTarget, string sName, object oObject);
// Uses right prefix to store the iInt to oTarget.
void SWFinalAIInteger(object oTarget, string sName, int nInt);
// Deletes object with Prefix
void SWDeleteAIObject(object oTarget, string sName);
// Deletes integer with Prefix
void SWDeleteAIInteger(object oTarget, string sName);

// Sets the weapon to the array, in the right spot...
// If bSecondary is TRUE, it uses the weapon size, and creature size to modifiy
// the value, IE: Sets it as the secondary weapon.
void ArrayOfWeapons(string sArray, object oTarget, object oItem, int nValue, int bSecondary = FALSE);
// Deletes all the things in an array...set to sArray
void DeleteDatabase(object oTarget, string sArray);
// Deletes all things, before we start!
void DeleteAllPreviousWeapons(object oTarget);

/**** STORING ****/
// Stores the ranged weopen - it also needs to check ammo before choosing one.
void StoreRangedWeapon(object oTarget, object oItem = OBJECT_INVALID);
// This adds the maximum damage onto the value
void BaseLargeWeapons(object oTarget, object oItem = OBJECT_INVALID);
// This adds the maximum damage onto the value.
void BaseMediumWeapons(object oTarget, object oItem = OBJECT_INVALID);
// This adds the maximum damage onto the value
void BaseSmallWeapons(object oTarget, object oItem = OBJECT_INVALID);
// This adds the maximum damage onto the value
void BaseTinyWeapons(object oTarget, object oItem = OBJECT_INVALID);
// This adds the effects onto the value
void BaseEffects(object oTarget, object oItem = OBJECT_INVALID);
// This will take the weapon size, and things, and apply the right base effects.
void DoEffectsOf(object oTarget, object oItem);

/*** OTHER ****/
// Erm...deletes the ints. Like wizard and so on.
void DeleteInts(object oTarget);
// This returns _STATE local int
int GetState(object oTarget);
// This is the deletion of the values of weapons.
void DeleteValueInts(object oTarget, string sArray);
// This moves the values from nMax to nNumberStart back one in the list.
void MoveArrayBackOne(string sArray, int nNumberStart, object oTarget, int nMax);

//::///////////////////////////////////////////////
//:: Name SetWeopens
//:://////////////////////////////////////////////
/*
  Main call - it starts the process of checking
  Inventory, and so on
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////

void SetWeapons(object oTarget = OBJECT_SELF)
{
    // Deletes all previous things, even if we don't have them, just in case.
    DeleteAllPreviousWeapons(oTarget);

    // We don't do this if we have AI_FLAG_OTHER_LAG_EQUIP_MOST_DAMAGING set.
    if(GetSpawnInCondition(AI_FLAG_OTHER_LAG_EQUIP_MOST_DAMAGING, AI_OTHER_MASTER)) return;

    // Gets the creature size, stores it...
    nCreatureSize = GetCreatureSize(oTarget);
    // No need to take off strength. It is pulrey for mighty weapons, we
    // add on this bonus to the value.
    // Thusly, we always make it a minimum of 0.
    nCreatureStrength = GetAbilityModifier(ABILITY_STRENGTH, oTarget);
    if(nCreatureStrength < 0) nCreatureStrength = 0;

    // Ints, globally set.
    bProfDruid = GetHasFeat(FEAT_WEAPON_PROFICIENCY_DRUID, oTarget);
    bProfElf = GetHasFeat(FEAT_WEAPON_PROFICIENCY_ELF, oTarget);
    bProfExotic = GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oTarget);
    bProfMartial = GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oTarget);
    bProfMonk = GetHasFeat(FEAT_WEAPON_PROFICIENCY_MONK, oTarget);
    bProfRogue = GetHasFeat(FEAT_WEAPON_PROFICIENCY_ROGUE, oTarget);
    bProfSimple = GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oTarget);
    bProfWizard = GetHasFeat(FEAT_WEAPON_PROFICIENCY_WIZARD, oTarget);
    bProfShield = GetHasFeat(FEAT_SHIELD_PROFICIENCY, oTarget);
    bProfTwoWeapons = (GetHasFeat(FEAT_TWO_WEAPON_FIGHTING, oTarget) ||
                       GetHasFeat(FEAT_AMBIDEXTERITY, oTarget) ||
                       GetHasFeat(FEAT_IMPROVED_TWO_WEAPON_FIGHTING, oTarget));

    // Sorts the inventory, on oTarget, with nCreatureSize of creature
    SortInventory(oTarget);
}

//::///////////////////////////////////////////////
//:: Name SortInventory
//:://////////////////////////////////////////////
/*
  Right - Goes through all items in the inventory
  It, based in Weopen size and creature size,
  do base effects of it (value it), if a weopen
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////

void SortInventory(object oTarget)
{
    // Note to self: Removed potion setting. THis is done each round in AI include
    // because it is probably better that way.
    int nBase, nWeaponSize, nCnt;
    object oItem, oHighestKit;
    int nHealingKitsAmount, nItemValue;
    int nRunningValue = 0; // For kits

    // Slots 11, 12 and 13. (some ammo slots)
    for(nCnt = INVENTORY_SLOT_ARROWS; //11
        nCnt <= INVENTORY_SLOT_BOLTS; //13
        nCnt++)
    {
        oItem  = GetItemInSlot(nCnt, oTarget);
        if(GetIsObjectValid(oItem))
        {
            // Sets ammo counters using nCurrentItemType.
            nCurrentItemType = GetBaseItemType(oItem);
            SetAmmoCounters(oTarget);
        }
    }
    // Slots 4 and 5. (HTH weapons)
    for(nCnt = INVENTORY_SLOT_RIGHTHAND; // 4
        nCnt <= INVENTORY_SLOT_LEFTHAND; // 5
        nCnt++)
    {
        oItem  = GetItemInSlot(nCnt, oTarget);
        if(GetIsObjectValid(oItem))
        {
            nCurrentItemType = GetBaseItemType(oItem);
            nCurrentItemSize = GetWeaponSize(oItem);
            nCurrentItemDamage = FALSE;// Reset
            if(nCurrentItemSize)// Is over 0
            {
                DoEffectsOf(oTarget, oItem);
            }
        }
    }
    // The inventory
    oItem = GetFirstItemInInventory(oTarget);
    while(GetIsObjectValid(oItem))
    {
        // Added some else statements to speed it up
        nCurrentItemType = GetBaseItemType(oItem);
        if(nCurrentItemType == BASE_ITEM_HEALERSKIT)
        {
            nHealingKitsAmount++;
            nItemValue = GetGoldPieceValue(oItem);
            // Stacked kits be worth what they should be seperatly.
            nItemValue = nItemValue/GetNumStackedItems(oItem);
            if(nItemValue > nRunningValue)
            {
                nRunningValue = nItemValue;
                oHighestKit = oItem;
            }
        }
        // Else, is it a arrow, bolt or bullet?
        else if(nCurrentItemType == BASE_ITEM_ARROW ||
                nCurrentItemType == BASE_ITEM_BOLT ||
                nCurrentItemType == BASE_ITEM_BULLET)
        {
            // Sets ammo counters using nCurrentItemType.
            SetAmmoCounters(oTarget);
        }
        else
        // else it isn't a healing kit, or ammo...what is it?
        // Likely a weapon, so we check
        {
            // Only need current item size, if it is a weapon!
            nCurrentItemSize = GetWeaponSize(oItem);
            nCurrentItemDamage = FALSE;// Reset
            if(nCurrentItemSize)// Is over 0 (valid weapon)
            {
                // Do the appropriate enchantment issuse and so on.
                DoEffectsOf(oTarget, oItem);
            }
        }
        oItem = GetNextItemInInventory(oTarget);
    }
    // Set our ranged weapons (if any)
    SetRangedWeapon(oTarget);
    // Set our shield  (if any)
    SetShield(oTarget);
    // Need some, any!
    if(nHealingKitsAmount > 0)
    {
        // set healing kits (if any)
        SWFinalAIObject(oTarget, AI_VALID_HEALING_KIT_OBJECT, oHighestKit);
        // Set amount left
        SWFinalAIInteger(oTarget, AI_VALID_HEALING_KITS, nHealingKitsAmount);
    }
    // Delete things, FINALLY. really! I mean, this is it, it runs, as it is,
    // and the other things run off it as things are met...!
    DelayCommand(0.1, DeleteInts(oTarget));
}

// This will take the weapon size, and things, and apply the right base effects.
void DoEffectsOf(object oTarget, object oItem)
{
    // 1.3 = changed to switch statement.
    // 1.4 - Minor bug (WEAPON_SIZE_SMALL, not CREATURE_SIZE_SMALL) fixed.
    // Note: Anything not done BaseEffects of cannot even be used by the character.
    switch(nCurrentItemSize)
    {
        // Tiny weapons - If we are under large size, and is a dagger or similar
        case WEAPON_SIZE_TINY:
        {
            if(nCreatureSize < CREATURE_SIZE_LARGE) BaseEffects(oTarget, oItem);
        }
        break;
        // Small Weapons - If we are large (not giant) and size is like a shortsword
        case CREATURE_SIZE_SMALL:
        {
            if(nCreatureSize < CREATURE_SIZE_HUGE) BaseEffects(oTarget, oItem);
        }
        break;
        // Medium weapons - If we are over tiny, and size is like a longsword
        case WEAPON_SIZE_MEDIUM:
        {
            if(nCreatureSize > CREATURE_SIZE_TINY) BaseEffects(oTarget, oItem);
        }
        break;
        // Large weapons - anything that is over small, and the size is like a spear
        case WEAPON_SIZE_LARGE:
        {
            if(nCreatureSize > CREATURE_SIZE_SMALL) BaseEffects(oTarget, oItem);
        }
        break;
    }
}

//::///////////////////////////////////////////////
//:: Name BaseEffects
//:://////////////////////////////////////////////
/*
    Sets the value (+/- int) of the item
    Things like haste are worth more...
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////

void BaseEffects(object oTarget, object oItem)
{
    // Reset value
    nCurrentItemValue = 0;
    if(GetIsObjectValid(oItem))
    {
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ABILITY_BONUS))
            nCurrentItemValue += 8;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_AC_BONUS))
            nCurrentItemValue += 5;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_AC_BONUS_VS_ALIGNMENT_GROUP))
            nCurrentItemValue += 4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_AC_BONUS_VS_DAMAGE_TYPE))
            nCurrentItemValue += 4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_AC_BONUS_VS_RACIAL_GROUP))
            nCurrentItemValue += 4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_AC_BONUS_VS_SPECIFIC_ALIGNMENT))
            nCurrentItemValue += 3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ATTACK_BONUS))
            nCurrentItemValue += 4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ATTACK_BONUS_VS_ALIGNMENT_GROUP))
            nCurrentItemValue += 3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ATTACK_BONUS_VS_RACIAL_GROUP))
            nCurrentItemValue += 3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ATTACK_BONUS_VS_SPECIFIC_ALIGNMENT))
            nCurrentItemValue += 3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_BASE_ITEM_WEIGHT_REDUCTION))
            nCurrentItemValue += 3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_BONUS_FEAT))
            nCurrentItemValue += 6;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_BONUS_SPELL_SLOT_OF_LEVEL_N))
            nCurrentItemValue += 2;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_CAST_SPELL))
            nCurrentItemValue += 5;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DAMAGE_BONUS))
            nCurrentItemValue += 6;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DAMAGE_BONUS_VS_ALIGNMENT_GROUP))
            nCurrentItemValue += 4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DAMAGE_BONUS_VS_RACIAL_GROUP))
            nCurrentItemValue += 4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DAMAGE_BONUS_VS_SPECIFIC_ALIGNMENT))
            nCurrentItemValue += 4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DAMAGE_REDUCTION))
            nCurrentItemValue += 8;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DAMAGE_RESISTANCE))
            nCurrentItemValue += 8;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DAMAGE_VULNERABILITY))
            nCurrentItemValue -= 3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DARKVISION))
            nCurrentItemValue += 3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DECREASED_ABILITY_SCORE))
            nCurrentItemValue -= 4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DECREASED_AC))
            nCurrentItemValue -= 4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DECREASED_ATTACK_MODIFIER))
            nCurrentItemValue -= 3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DECREASED_DAMAGE))
            nCurrentItemValue -= 3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DECREASED_ENHANCEMENT_MODIFIER))
            nCurrentItemValue -= 5;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DECREASED_SAVING_THROWS))
            nCurrentItemValue -= 4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DECREASED_SAVING_THROWS_SPECIFIC))
            nCurrentItemValue -= 3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DECREASED_SKILL_MODIFIER))
            nCurrentItemValue -= 2;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ENHANCEMENT_BONUS))
            nCurrentItemValue += 7;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_ALIGNMENT_GROUP))
            nCurrentItemValue += 6;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_RACIAL_GROUP))
            nCurrentItemValue += 6;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_SPECIFIC_ALIGNEMENT))
            nCurrentItemValue += 5;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_EXTRA_MELEE_DAMAGE_TYPE))
            nCurrentItemValue += 1;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_EXTRA_RANGED_DAMAGE_TYPE))
            nCurrentItemValue += 1;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_FREEDOM_OF_MOVEMENT))
            nCurrentItemValue += 5;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_HASTE))
            nCurrentItemValue += 12;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_HOLY_AVENGER))
            nCurrentItemValue += 10;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_IMMUNITY_DAMAGE_TYPE))
            nCurrentItemValue += 8;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_IMMUNITY_MISCELLANEOUS))
            nCurrentItemValue += 10;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_IMMUNITY_SPECIFIC_SPELL))
            nCurrentItemValue += 8;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_IMMUNITY_SPELL_SCHOOL))
            nCurrentItemValue += 12;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_IMPROVED_EVASION))
            nCurrentItemValue += 10;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_KEEN))
            nCurrentItemValue += 7;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_LIGHT))
            nCurrentItemValue += 1;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_MASSIVE_CRITICALS))
            nCurrentItemValue += 2;
//        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_MIND_BLANK))
//            nCurrentItemValue += 4;// Do not think It exsists.
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_MONSTER_DAMAGE))
            nCurrentItemValue += 1;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_NO_DAMAGE))
            nCurrentItemValue -= 10;// EEEKK! Bad bad bad!!
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ON_HIT_PROPERTIES))
            nCurrentItemValue += 8;// Includes all vorpal and so on!
//        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ON_MONSTER_HIT))
//            nCurrentItemValue += 8;// Can't be on a weapon
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_POISON))
            nCurrentItemValue += 5;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_REGENERATION))
            nCurrentItemValue += 8;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_REGENERATION_VAMPIRIC))
            nCurrentItemValue += 6;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_SAVING_THROW_BONUS))
            nCurrentItemValue += 5;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC))
            nCurrentItemValue += 4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_SKILL_BONUS))
            nCurrentItemValue += 2;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_SPELL_RESISTANCE))
            nCurrentItemValue += 7;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_TRUE_SEEING))
            nCurrentItemValue += 11;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_TURN_RESISTANCE))
            nCurrentItemValue += 8;
//        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_VORPAL))
//            nCurrentItemValue += 8;// Removed as Bioware will remove this constant. Doesn't exsist.
//        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_WOUNDING))
//            nCurrentItemValue += 8;// Removed as Bioware will remove this constant. Doesn't exsist.
        // Special cases
        // Set is unlimited to TRUE or FALSE, add 10 if TRUE.
        bCurrentItemIsUnlimited = GetItemHasItemProperty(oItem, ITEM_PROPERTY_UNLIMITED_AMMUNITION);
        if(bCurrentItemIsUnlimited) nCurrentItemValue += 10;
        // Same as above, for mighty
        bCurrentItemIsMighty = GetItemHasItemProperty(oItem, ITEM_PROPERTY_MIGHTY);
        if(bCurrentItemIsMighty) nCurrentItemValue += 3;

        switch (nCurrentItemSize)
        {
            case WEAPON_SIZE_INVALID:// Invalid Size, stop
            {
                return;
            }
            break;
            case WEAPON_SIZE_TINY:// Tiny weapons (EG: Daggers, Slings)
            {
                BaseTinyWeapons(oTarget, oItem);
                return;
            }
            break;
            case WEAPON_SIZE_SMALL:// Small Weapons (EG short Swords)
            {
                BaseSmallWeapons(oTarget, oItem);
                return;
            }
            break;
            case WEAPON_SIZE_MEDIUM: // Medium weapons (EG long swords)
            {
                BaseMediumWeapons(oTarget, oItem);
                return;
            }
            break;
            case WEAPON_SIZE_LARGE: // Large Weapons (EG greataxes)
            {
                BaseLargeWeapons(oTarget, oItem);
                return;
            }
            break;
        }
    }
}

//::///////////////////////////////////////////////
//:: Name BaseLargeWeapons
//:://////////////////////////////////////////////
/*
    This adds the maximum damage onto the value
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////

void BaseLargeWeapons(object oTarget, object oItem)
{
    // No need for weopen size...we know we can use it!
    switch(nCurrentItemType)
    {
        case BASE_ITEM_DIREMACE:
        {
            // This is the only one that needs documenting. All are similar.
            if(bProfExotic == TRUE)// We are proficient in exotics...
            {
                nCurrentItemDamage = 16;// Set max damage.
                nCurrentItemValue +=     // We add onto the current value some things...
                      (nCurrentItemDamage + // The damage (maximum) done by it.
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_DIRE_MACE)) + // Adds 1 if specailised in it
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_DIRE_MACE) * 2) +// Adds 2 if can do good criticals in it
                      (GetHasFeat(FEAT_WEAPON_FOCUS_DIRE_MACE) * 2));     // Adds 2 if we do +2 damage with it
                // If a very big creature - set as a primary weopen
                if(nCreatureSize >= CREATURE_SIZE_LARGE)//4+
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                // If a medium creature - set as a two-handed weopen
                else if(nCreatureSize == CREATURE_SIZE_MEDIUM)//=3
                {
                    // Add 16 more for a "second" weapon.
                    nCurrentItemValue += nCurrentItemDamage;
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_DOUBLEAXE:
        {
            if(bProfExotic == TRUE)
            {
                nCurrentItemDamage = 16;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_DOUBLE_AXE)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_DOUBLE_AXE) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_DOUBLE_AXE) * 2));
                if(nCreatureSize >= CREATURE_SIZE_LARGE)//4+
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(nCreatureSize == CREATURE_SIZE_MEDIUM)//=3
                {
                    // Add 16 more for a "second" weapon.
                    nCurrentItemValue += 16;
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_TWOBLADEDSWORD:
        {
            if(bProfExotic == TRUE)
            {
                nCurrentItemDamage = 16;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_TWO_BLADED_SWORD)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_TWO_BLADED_SWORD) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_TWO_BLADED_SWORD) * 2));
                if(nCreatureSize >= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(nCreatureSize == CREATURE_SIZE_MEDIUM)
                {
                    nCurrentItemValue += nCurrentItemDamage;
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_GREATAXE:
        {
            if(bProfMartial == TRUE)
            {
                nCurrentItemDamage = 12;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_GREAT_AXE)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_GREAT_AXE) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_GREAT_AXE) * 2));
                if(nCreatureSize >= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(nCreatureSize == CREATURE_SIZE_MEDIUM)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_GREATSWORD:
        {
            if(bProfMartial == TRUE)
            {
                nCurrentItemDamage = 12;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_GREAT_SWORD)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_GREAT_SWORD) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_GREAT_SWORD) * 2));
                if(nCreatureSize >= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(nCreatureSize == CREATURE_SIZE_MEDIUM)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_HALBERD:
        {
            if(bProfMartial == TRUE)
            {
                nCurrentItemDamage = 10;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_HALBERD)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_HALBERD) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_HALBERD) * 2));
                if(nCreatureSize >= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(nCreatureSize == CREATURE_SIZE_MEDIUM)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_HEAVYFLAIL:
        {
            if(bProfMartial == TRUE)
            {
                nCurrentItemDamage = 10;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_HEAVY_FLAIL)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_HEAVY_FLAIL) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_HEAVY_FLAIL) * 2));
                if(nCreatureSize >= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(nCreatureSize == CREATURE_SIZE_MEDIUM)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_SCYTHE:
        {
            if(bProfExotic == TRUE)
            {
                nCurrentItemDamage = 10;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SCYTHE)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_SCYTHE) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_SCYTHE) * 2));
                if(nCreatureSize >= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(nCreatureSize == CREATURE_SIZE_MEDIUM)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_SHORTSPEAR:
        {
            if(bProfSimple == TRUE || bProfDruid == TRUE)
            {
                nCurrentItemDamage = 8;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SPEAR)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_SPEAR) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_SPEAR) * 2));
                if(nCreatureSize >= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(nCreatureSize == CREATURE_SIZE_MEDIUM)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        // Note: Should work, should be the same!!
        case BASE_ITEM_QUARTERSTAFF:
        case BASE_ITEM_MAGICSTAFF:
        {
            if(bProfWizard == TRUE || bProfSimple == TRUE || bProfRogue == TRUE ||
               bProfMonk == TRUE || bProfDruid == TRUE)
            {
                nCurrentItemDamage = 6;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_STAFF)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_STAFF) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_STAFF) * 2));
                if(nCreatureSize >= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(nCreatureSize == CREATURE_SIZE_MEDIUM)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_LONGBOW:
        {
            if(nCreatureSize >= CREATURE_SIZE_MEDIUM &&
              (bProfMartial == TRUE || bProfElf == TRUE))
            {
                nCurrentItemDamage = 8;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (bCurrentItemIsMighty * nCreatureStrength) +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_LONGBOW)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_LONGBOW) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_LONGBOW) * 2));
                StoreRangedWeapon(oTarget, oItem);
            }
        }
        break;
        case BASE_ITEM_TOWERSHIELD:
        {
            if(bProfShield == TRUE &&
               nCreatureSize >= CREATURE_SIZE_MEDIUM)
            {
                nCurrentItemValue += GetItemACValue(oItem);
                StoreShield(oTarget, oItem);
            }
        }
        break;
    }
}

//::///////////////////////////////////////////////
//:: Name BaseMediumWeapons
//:://////////////////////////////////////////////
/*
    Adds the damage to the value
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////

void BaseMediumWeapons(object oTarget, object oItem)
{
    switch(nCurrentItemType)
    {
        case BASE_ITEM_BASTARDSWORD:
        {
            if(bProfExotic == TRUE)
            {
                nCurrentItemDamage = 10;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_BASTARD_SWORD)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_BASTARD_SWORD) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_BASTARD_SWORD) * 2));
                if(nCreatureSize >= CREATURE_SIZE_MEDIUM)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(nCreatureSize == CREATURE_SIZE_SMALL)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_BATTLEAXE:
        {
            if(bProfMartial == TRUE)
            {
                nCurrentItemDamage = 8;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_BATTLE_AXE)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_BATTLE_AXE) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_BATTLE_AXE) * 2));
                if(nCreatureSize >= CREATURE_SIZE_MEDIUM)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(nCreatureSize == CREATURE_SIZE_SMALL)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_DWARVENWARAXE:
        {
            if(bProfExotic == TRUE)
            {
                nCurrentItemDamage = 10;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_DWAXE)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_DWAXE) * 2) +
                      (GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_DWAXE) * 2));
                if(nCreatureSize >= CREATURE_SIZE_MEDIUM)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(nCreatureSize == CREATURE_SIZE_SMALL)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        case BASE_ITEM_CLUB:
        {
            if(bProfWizard == TRUE || bProfSimple == TRUE ||
               bProfMonk == TRUE || bProfDruid == TRUE)
            {
                nCurrentItemDamage = 6;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_CLUB)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_CLUB) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_CLUB) * 2));
                if(nCreatureSize >= CREATURE_SIZE_MEDIUM)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(nCreatureSize == CREATURE_SIZE_SMALL)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_KATANA:
        {
            if(bProfExotic == TRUE)
            {
                nCurrentItemDamage = 10;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_KATANA)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_KATANA) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_KATANA) * 2));
                if(nCreatureSize >= CREATURE_SIZE_MEDIUM)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(nCreatureSize == CREATURE_SIZE_SMALL)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_LIGHTFLAIL:
        {
            if(bProfMartial == TRUE)
            {
                nCurrentItemDamage = 8;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_LIGHT_FLAIL)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_LIGHT_FLAIL) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_FLAIL) * 2));
                if(nCreatureSize >= CREATURE_SIZE_MEDIUM)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(nCreatureSize == CREATURE_SIZE_SMALL)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_LONGSWORD:
        {
            if(bProfMartial == TRUE || bProfElf == TRUE)
            {
                nCurrentItemDamage = 8;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_LONG_SWORD)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_LONG_SWORD) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_LONG_SWORD) * 2));
                if(nCreatureSize >= CREATURE_SIZE_MEDIUM)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(nCreatureSize == CREATURE_SIZE_SMALL)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_MORNINGSTAR:
        {
            if(bProfSimple == TRUE || bProfRogue == TRUE) // Primary only
            {
                nCurrentItemDamage = 8;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_MORNING_STAR)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_MORNING_STAR) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_MORNING_STAR) * 2));
                if(nCreatureSize >= CREATURE_SIZE_MEDIUM)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(nCreatureSize == CREATURE_SIZE_SMALL)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_RAPIER:
        {
            if(bProfRogue == TRUE || bProfMartial == TRUE || bProfElf == TRUE)
            {
                nCurrentItemDamage = 6;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_RAPIER)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_RAPIER) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_RAPIER) * 2));
                if(nCreatureSize >= CREATURE_SIZE_MEDIUM)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(nCreatureSize == CREATURE_SIZE_SMALL)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_SCIMITAR:
        {
            if(bProfMartial == TRUE || bProfDruid == TRUE)
            {
                nCurrentItemDamage = 6;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SCIMITAR)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_SCIMITAR) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_SCIMITAR) * 2));
                if(nCreatureSize >= CREATURE_SIZE_MEDIUM)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(nCreatureSize == CREATURE_SIZE_SMALL)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_WARHAMMER:
        {
            if(bProfMartial == TRUE)
            {
                nCurrentItemDamage = 8;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                       GetHasFeat(FEAT_WEAPON_SPECIALIZATION_WAR_HAMMER) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_WAR_HAMMER) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_WAR_HAMMER) * 2));
                if(nCreatureSize >= CREATURE_SIZE_MEDIUM)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(nCreatureSize == CREATURE_SIZE_SMALL)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_HEAVYCROSSBOW:
        {
            if(nCreatureSize >= CREATURE_SIZE_SMALL &&
              (bProfWizard == TRUE || bProfSimple == TRUE ||
                bProfRogue == TRUE || bProfMonk == TRUE))
            {
                nCurrentItemDamage = 10;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (bCurrentItemIsMighty * nCreatureStrength) +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_HEAVY_CROSSBOW)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_HEAVY_CROSSBOW) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_HEAVY_CROSSBOW) * 2));
                StoreRangedWeapon(oTarget, oItem);
            }
        }
        break;
        case BASE_ITEM_SHORTBOW:
        {
            if(nCreatureSize >= CREATURE_SIZE_SMALL &&
              (bProfRogue == TRUE || bProfMartial == TRUE || bProfElf == TRUE))
            {
                nCurrentItemDamage = 6;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (bCurrentItemIsMighty * nCreatureStrength) +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SHORTBOW)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_SHORTBOW) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_SHORTBOW) * 2));
                StoreRangedWeapon(oTarget, oItem);
            }
        }
        break;
        case BASE_ITEM_LARGESHIELD:
        {
            if(nCreatureSize >= CREATURE_SIZE_SMALL &&
               bProfShield == TRUE)
            {
                nCurrentItemValue += GetItemACValue(oItem);
                StoreShield(oTarget, oItem);
            }
        }
        break;
    }
}

//::///////////////////////////////////////////////
//:: Name BaseSmallWeapons
//:://////////////////////////////////////////////
/*
    Adds the damage to the value...then sets it
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////
void BaseSmallWeapons(object oTarget, object oItem)
{
    switch (nCurrentItemType)
    {
        case BASE_ITEM_HANDAXE:
        {
            if(bProfMonk == TRUE || bProfMartial == TRUE)
            {
                nCurrentItemDamage = 6;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_HAND_AXE)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_HAND_AXE) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_HAND_AXE) * 2));
                if(nCreatureSize >= CREATURE_SIZE_SMALL &&
                   nCreatureSize <= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(nCreatureSize == CREATURE_SIZE_TINY)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_KAMA:
        {
            if(bProfMonk == TRUE || bProfExotic == TRUE)
            {
                nCurrentItemDamage = 6;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_KAMA)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_KAMA) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_KAMA) * 2));
                if(nCreatureSize >= CREATURE_SIZE_SMALL &&
                   nCreatureSize <= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(nCreatureSize == CREATURE_SIZE_TINY)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_LIGHTHAMMER:
        {
            if(bProfMartial == TRUE)
            {
                nCurrentItemDamage = 4;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                       GetHasFeat(FEAT_WEAPON_SPECIALIZATION_LIGHT_HAMMER) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_LIGHT_HAMMER) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_HAMMER) * 2));
                if(nCreatureSize >= CREATURE_SIZE_SMALL &&
                   nCreatureSize <= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(nCreatureSize == CREATURE_SIZE_TINY)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_LIGHTMACE:
        {
            if(bProfSimple == TRUE || bProfRogue == TRUE)
            {
                nCurrentItemDamage = 6;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_LIGHT_MACE)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_LIGHT_MACE) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_MACE) * 2));
                if(nCreatureSize >= CREATURE_SIZE_SMALL &&
                   nCreatureSize <= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(nCreatureSize == CREATURE_SIZE_TINY)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_SHORTSWORD:
        {
            if(bProfRogue == TRUE || bProfMartial == TRUE)
            {
                nCurrentItemDamage = 6;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SHORT_SWORD)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_SHORT_SWORD) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_SHORT_SWORD) * 2));
                if(nCreatureSize >= CREATURE_SIZE_SMALL &&
                   nCreatureSize <= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(nCreatureSize == CREATURE_SIZE_TINY)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_WHIP:
        {
            if(bProfExotic == TRUE)
            {
                nCurrentItemDamage = 2;// Set max damage.
                nCurrentItemValue += nCurrentItemDamage;
                // We add a special amount, 10, as it is only used as a secondary
                // weapon, and only in the offhand.
                nCurrentItemValue += 10;
                if(nCreatureSize >= CREATURE_SIZE_SMALL &&
                   nCreatureSize <= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_SICKLE:
        {
            if(bProfSimple == TRUE || bProfDruid == TRUE)
            {
                nCurrentItemDamage = 6;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SICKLE)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_SICKLE) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_SICKLE) * 2));
                if(nCreatureSize >= CREATURE_SIZE_SMALL &&
                   nCreatureSize <= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(nCreatureSize == CREATURE_SIZE_TINY)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_DART:
        {
            // Ranged weapons below
            if(nCreatureSize <= CREATURE_SIZE_LARGE &&
              (bProfSimple == TRUE || bProfRogue == TRUE || bProfDruid == TRUE))
            {
                nCurrentItemDamage = 4;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (bCurrentItemIsMighty * nCreatureStrength) +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_DART)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_DART) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_DART) * 2));
                StoreRangedWeapon(oTarget, oItem);
            }
        }
        break;
        case BASE_ITEM_LIGHTCROSSBOW:
        {
            if(nCreatureSize <= CREATURE_SIZE_LARGE &&
              (bProfWizard == TRUE || bProfSimple == TRUE ||
               bProfRogue == TRUE || bProfMonk == TRUE))
            {
                nCurrentItemDamage = 8;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (bCurrentItemIsMighty * nCreatureStrength) +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_LIGHT_CROSSBOW)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_LIGHT_CROSSBOW) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_CROSSBOW) * 2));
                StoreRangedWeapon(oTarget, oItem);
            }
        }
        break;
        case BASE_ITEM_SLING:
        {
            if(nCreatureSize <= CREATURE_SIZE_LARGE &&
              (bProfSimple == TRUE || bProfMonk == TRUE || bProfDruid == TRUE))
            {
                nCurrentItemDamage = 4;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (bCurrentItemIsMighty * nCreatureStrength) +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SLING)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_SLING) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_SLING) * 2));
                StoreRangedWeapon(oTarget, oItem);
            }
        }
        break;
        case BASE_ITEM_THROWINGAXE:
        {
            if(nCreatureSize <= CREATURE_SIZE_LARGE && bProfMartial == TRUE)
            {
                nCurrentItemDamage = 6;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (nCreatureStrength) +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SLING)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_SLING) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_SLING) * 2));
                StoreRangedWeapon(oTarget, oItem);
            }
        }
        break;
        case BASE_ITEM_SMALLSHIELD:
        {
            if(bProfShield)
            {
                nCurrentItemValue += GetItemACValue(oItem);
                StoreShield(oTarget, oItem);
            }
        }
        break;
    }
}

//::///////////////////////////////////////////////
//:: Name BaseTinyWeapons
//:://////////////////////////////////////////////
/*
    Adds damage to the value, and sets it.
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////

void BaseTinyWeapons(object oTarget, object oItem)
{
    switch (nCurrentItemType)
    {
        case BASE_ITEM_DAGGER:
        {
            if(nCreatureSize <= CREATURE_SIZE_MEDIUM &&
              (bProfWizard == TRUE || bProfSimple == TRUE || bProfRogue == TRUE ||
               bProfMonk == TRUE || bProfDruid == TRUE))
            {
                nCurrentItemDamage = 4;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_DAGGER)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_DAGGER) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_DAGGER) * 2));
                SetPrimaryWeapon(oTarget, oItem);
            }
        }
        break;
        case BASE_ITEM_KUKRI:
        {
            if(nCreatureSize <= CREATURE_SIZE_MEDIUM && bProfExotic == TRUE)
            {
                nCurrentItemDamage = 4;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_KUKRI)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_KUKRI) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_KUKRI) * 2));
                SetPrimaryWeapon(oTarget, oItem);
            }
        }
        break;
        case BASE_ITEM_SHURIKEN:
        {
            // Ranged weapons below
            if(nCreatureSize <= CREATURE_SIZE_MEDIUM &&
              (bProfMonk == TRUE || bProfExotic == TRUE))
            {
                nCurrentItemDamage = 3;// Set max damage.
                nCurrentItemValue += (nCurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SHURIKEN)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_SHURIKEN) * 2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_SHURIKEN) * 2));
                StoreRangedWeapon(oTarget, oItem);
            }
        }
        break;
    }
}
//::///////////////////////////////////////////////
//:: Name SetPrimaryWeapon
//:://////////////////////////////////////////////
/*
    If the value of the object is greater than the
    stored one, set it.
    If the weopen is of lesser value, and can deul
    wield, then set it as a weopen that can be deul wielded.

    Re-written. Sets the objects into an array (at the end).
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////

void SetPrimaryWeapon(object oTarget, object oItem)
{
    // We insert the value into an array of all primary weapons, based
    // on value.
    // * Any weapon can be primary
    ArrayOfWeapons(AI_WEAPON_PRIMARY, oTarget, oItem, nCurrentItemValue);

    // We also set up secondary array for all weapons which can be used well
    // in the off hand.
    // This takes some value off for size of weapon...depending on our size!
    // IE to hit is lower, it is a lower value.
    if(bProfTwoWeapons == TRUE &&
       // 4 = Light flail, 47 = Morningstar - NOT a valid second weapon, for
       //     some bug reason
       nCurrentItemType != BASE_ITEM_LIGHTFLAIL &&
       nCurrentItemType != BASE_ITEM_MORNINGSTAR &&
       nCurrentItemType != BASE_ITEM_WHIP) // Whips are primary only
    {
        ArrayOfWeapons(AI_WEAPON_SECONDARY, oTarget, oItem, nCurrentItemValue, TRUE);
    }
}
//::///////////////////////////////////////////////
//:: Name SetTwoHandedWeapon
//:://////////////////////////////////////////////
/*
    Sets a two-handed weopen to use.
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////

void SetTwoHandedWeapon(object oTarget, object oItem)
{
    // We insert the value into an array of all 2 handed weapons, based
    // on value.
    ArrayOfWeapons(AI_WEAPON_TWO_HANDED, oTarget, oItem, nCurrentItemValue);
}

//::///////////////////////////////////////////////
//:: Name SetRangedWeapon
//:://////////////////////////////////////////////
/*
        Sets a ranged weopen - based on ammo as well
        We only set one (until we don't use it) and in the AI
        checks for ammo. Important - the default AI does't do that
        well, and just equips a HTH weapon instead!
    - Name SetAmmoCounters
        Used to check ammo - for setting ranged weopen
    - Name StoreRangedWeapon
        First part of setting ranged weopen. Stores it!
        It needs to check for ammo when it is set, you see
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////

void StoreRangedWeapon(object oTarget, object oItem)
{
    int nNth = GetLocalInt(oTarget, SETWEP_DISTANCE);
    nNth++;
    string sNth = IntToString(nNth);
    // Special: If unlimited ammo, we will use regardless of ammo.
    SetLocalInt(oItem, SETWEP_IS_UNLIMITED, bCurrentItemIsUnlimited);
    SetLocalInt(oItem, SETWEP_VALUE, nCurrentItemValue);
    SetLocalObject(oTarget, SETWEP_DISTANCE + sNth, oItem);
    SetLocalInt(oTarget, SETWEP_DISTANCE, nNth);
}

void SetAmmoCounters(object oTarget)
{
    switch(nCurrentItemType)
    {
        case BASE_ITEM_ARROW:
        {
            bGotArrows = TRUE;
            return;
        }
        break;
        case BASE_ITEM_BOLT:
        {
            bGotBolts = TRUE;
            return;
        }
        break;
        case BASE_ITEM_BULLET:
        {
            bGotBullets = TRUE;
            return;
        }
        break;
    }
}

void SetRangedWeapon(object oTarget)
{
    // Special: We set 2 weapons. The second just states there is a second
    // and so we re-set weapons if we get round to using it.
    int nNth = 1;
    string sNth = IntToString(nNth);
    object oItem = GetLocalObject(oTarget, SETWEP_DISTANCE + sNth);
    int nBase, nHighestValueWeapon, nValue, bUnlimited, bShield, // TRUE if we can use a shield too
        nNextHighestValueWeapon, bHighestUnlimited, nAmmoSlot;
    object oHighestItem, oNextHighestItem;

    while(GetIsObjectValid(oItem))
    {
        nBase = GetBaseItemType(oItem);
        nValue = GetLocalInt(oItem, SETWEP_VALUE);
        bUnlimited = GetLocalInt(oItem, SETWEP_IS_UNLIMITED);
        if(nBase == BASE_ITEM_DART || nBase == BASE_ITEM_SHURIKEN ||
           nBase == BASE_ITEM_THROWINGAXE)
        // 31 = Dart, 59 = Shuriken, 63 = Throwing axe
        {
            //iHighestValueWeapon starts as 0, so
            if(nValue > nHighestValueWeapon ||
               nHighestValueWeapon == 0)
            {
                nHighestValueWeapon = nValue;
                oHighestItem = oItem;
                bShield = TRUE;
                // We set right hand, because it is a throwing weapon
                nAmmoSlot = INVENTORY_SLOT_RIGHTHAND;
                bHighestUnlimited = bUnlimited;
            }
            else if(nValue > nNextHighestValueWeapon ||
                    nNextHighestValueWeapon == 0)
            {
                nNextHighestValueWeapon = nValue;
                oNextHighestItem = oItem;
            }
        }
        else if(nBase == BASE_ITEM_HEAVYCROSSBOW ||
                nBase == BASE_ITEM_LIGHTCROSSBOW)// 6 = Heavy, 7 = Light X-bow
        {
            if(bGotBolts == TRUE || bUnlimited == TRUE)
            {
                if(nValue > nHighestValueWeapon ||
                   nHighestValueWeapon == 0)
                {
                    nHighestValueWeapon = nValue;
                    oHighestItem = oItem;
                    nAmmoSlot = INVENTORY_SLOT_BOLTS;
                    bShield = FALSE;
                    bHighestUnlimited = bUnlimited;
                }
                else if(nValue > nNextHighestValueWeapon ||
                        nNextHighestValueWeapon == 0)
                {
                    nNextHighestValueWeapon = nValue;
                    oNextHighestItem = oItem;
                }
            }
        }
        else if(nBase == BASE_ITEM_LONGBOW ||
                nBase == BASE_ITEM_SHORTBOW)// 8 = Long, 11 = Short bow
        {
            if(bGotArrows == TRUE || bUnlimited == TRUE)
            {
                if(nValue > nHighestValueWeapon ||
                   nHighestValueWeapon == 0)
                {
                    nHighestValueWeapon = nValue;
                    oHighestItem = oItem;
                    bShield = FALSE;
                    nAmmoSlot = INVENTORY_SLOT_ARROWS;
                    bHighestUnlimited = bUnlimited;
                }
                else if(nValue > nNextHighestValueWeapon ||
                        nNextHighestValueWeapon == 0)
                {
                    nNextHighestValueWeapon = nValue;
                    oNextHighestItem = oItem;
                }
            }
        }
        else if(nBase == BASE_ITEM_SLING)// 61 = Sling
        {
            if(bGotBullets == TRUE || bUnlimited == TRUE)
            {
                if(nValue > nHighestValueWeapon ||
                   nHighestValueWeapon == 0)
                {
                    nHighestValueWeapon = nValue;
                    oHighestItem = oItem;
                    bShield = TRUE;
                    nAmmoSlot = INVENTORY_SLOT_BULLETS;
                    bHighestUnlimited = bUnlimited;
                }
                else if(nValue > nNextHighestValueWeapon ||
                        nNextHighestValueWeapon == 0)
                {
                    nNextHighestValueWeapon = nValue;
                    oNextHighestItem = oItem;
                }
            }
        }
        DeleteLocalInt(oItem, SETWEP_VALUE);
        DeleteLocalInt(oItem, SETWEP_IS_UNLIMITED);
        DeleteLocalObject(oTarget, SETWEP_DISTANCE + sNth);
        nNth++;
        sNth = IntToString(nNth);
        oItem = GetLocalObject(oTarget, SETWEP_DISTANCE + sNth);
    }
    // No setting if not valid!
    if(GetIsObjectValid(oHighestItem))
    {
        SWFinalAIObject(oTarget, AI_WEAPON_RANGED, oHighestItem);
        SWFinalAIInteger(oTarget, AI_WEAPON_RANGED_AMMOSLOT, nAmmoSlot);
        if(bHighestUnlimited)
        {
            SWFinalAIInteger(oTarget, AI_WEAPON_RANGED_IS_UNLIMITED, bHighestUnlimited);
        }
        // Can a shield be used with it? Default is 0, we only set non 0 values.
        if(bShield)
        {
            SWFinalAIInteger(oTarget, AI_WEAPON_RANGED_SHIELD, bShield);
        }
        // No setting if not valid!
        if(GetIsObjectValid(oNextHighestItem))
        {
            SWFinalAIObject(oTarget, AI_WEAPON_RANGED_2, oNextHighestItem);
        }
    }
}

//::///////////////////////////////////////////////
//:: Name SetShield, StoreShield
//:://////////////////////////////////////////////
/*
    V. Simple. If value is higher, set the shield
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////

void StoreShield(object oTarget, object oItem)
{
    int nNth = GetLocalInt(oTarget, SETWEP_SHIELD);
    nNth++;
    string sNth = IntToString(nNth);
    // Set the value, so we can use the top values again.
    SetLocalInt(oItem, SETWEP_VALUE, nCurrentItemValue);
    SetLocalObject(oTarget, SETWEP_SHIELD + sNth, oItem);
    SetLocalInt(oTarget, SETWEP_SHIELD, nNth);
}

void SetShield(object oTarget)
{
    int nNth = 1;
    string sNth = IntToString(nNth);
    object oItem = GetLocalObject(oTarget, SETWEP_SHIELD + sNth);
    int nHighestValueShield, nValue, nNextHighestValueShield;
    object oHighestShield, oNextHighestShield;

    while(GetIsObjectValid(oItem))
    {
        nValue = GetLocalInt(oItem, SETWEP_VALUE);
        if(nValue > nHighestValueShield)
        {
            oHighestShield = oItem;
            nHighestValueShield = nValue;
        }
        else if(nValue > nNextHighestValueShield)
        {
            oNextHighestShield = oItem;
            nNextHighestValueShield = nValue;
        }
        DeleteLocalInt(oItem, SETWEP_VALUE);
        DeleteLocalObject(oTarget, SETWEP_SHIELD + sNth);
        nNth++;
        sNth = IntToString(nNth);
        // Get next shield
        oItem = GetLocalObject(oTarget, SETWEP_SHIELD + sNth);
    }
    if(GetIsObjectValid(oHighestShield))
    {
        SWFinalAIObject(oTarget, AI_WEAPON_SHIELD, oHighestShield);
        // Need original if second
        if(GetIsObjectValid(oNextHighestShield))
        {
            SWFinalAIObject(oTarget, AI_WEAPON_SHIELD_2, oNextHighestShield);
        }
    }
}

//::///////////////////////////////////////////////
//:: Name GetWeoponSize
//:://////////////////////////////////////////////
/*
    Returns the Base Weopen size of oItem
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////

int GetWeaponSize(object oItem)
{
    switch(GetBaseItemType(oItem))
    {
        // Tiny
        // 22, 42, 59.
        case BASE_ITEM_DAGGER:
        case BASE_ITEM_KUKRI:
        case BASE_ITEM_SHURIKEN:
            return WEAPON_SIZE_TINY;
        break;
        // Small
        // 0, 7, 9, 14, 31, 37, 38, 40, 60, 61, 63
        case BASE_ITEM_SHORTSWORD:
        case BASE_ITEM_LIGHTCROSSBOW:
        case BASE_ITEM_LIGHTMACE:
        case BASE_ITEM_SMALLSHIELD:
        case BASE_ITEM_DART:
        case BASE_ITEM_LIGHTHAMMER:
        case BASE_ITEM_HANDAXE:
        case BASE_ITEM_KAMA:
        case BASE_ITEM_SICKLE:
        case BASE_ITEM_SLING:
        case BASE_ITEM_THROWINGAXE:
        case BASE_ITEM_WHIP:    // Hordes
            return WEAPON_SIZE_SMALL;
        break;
        // Medium
        // 1, 2, 3, 4, 5, 6, 11, 28, 41, 47, 51, 53, 56
        // 1-6 =
        // BASE_ITEM_LONGSWORD, BASE_ITEM_BATTLEAXE, BASE_ITEM_BASTARDSWORD
        // BASE_ITEM_LIGHTFLAIL, BASE_ITEM_WARHAMMER, BASE_ITEM_HEAVYCROSSBOW
        case BASE_ITEM_LONGSWORD:
        case BASE_ITEM_BATTLEAXE:
        case BASE_ITEM_BASTARDSWORD:
        case BASE_ITEM_LIGHTFLAIL:
        case BASE_ITEM_WARHAMMER:
        case BASE_ITEM_HEAVYCROSSBOW:
        case BASE_ITEM_SHORTBOW:
        case BASE_ITEM_CLUB:
        case BASE_ITEM_KATANA:
        case BASE_ITEM_MORNINGSTAR:
        case BASE_ITEM_RAPIER:
        case BASE_ITEM_SCIMITAR:
        case BASE_ITEM_LARGESHIELD:
        case BASE_ITEM_DWARVENWARAXE: // Hordes
            return WEAPON_SIZE_MEDIUM;
        break;
        // Large weapons
        // 8, 10, 12, 13, 18, 32, 33, 35, 45, 50, 55, 57, 58
        case BASE_ITEM_LONGBOW:
        case BASE_ITEM_HALBERD:
        case BASE_ITEM_TWOBLADEDSWORD:
        case BASE_ITEM_GREATSWORD:
        case BASE_ITEM_GREATAXE:
        case BASE_ITEM_DIREMACE:
        case BASE_ITEM_DOUBLEAXE:
        case BASE_ITEM_HEAVYFLAIL:
        case BASE_ITEM_MAGICSTAFF:
        case BASE_ITEM_QUARTERSTAFF:
        case BASE_ITEM_SCYTHE:
        case BASE_ITEM_TOWERSHIELD:
        case BASE_ITEM_SHORTSPEAR:
            return WEAPON_SIZE_LARGE;
        break;
    }
    return FALSE;
}

//::///////////////////////////////////////////////
//:: Name DeleteInts
//:://////////////////////////////////////////////
/*
    Deletes everything, like what weopen they are using
    and what proficiencies they have that may be stored.
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////
void DeleteInts(object oTarget)
{
    // Deletes the INT's, for values, in the array's.
    DeleteValueInts(oTarget, AI_WEAPON_PRIMARY);
    DeleteValueInts(oTarget, AI_WEAPON_SECONDARY);
    DeleteValueInts(oTarget, AI_WEAPON_TWO_HANDED);
    // Missile and shield ones.
    DeleteLocalInt(oTarget, SETWEP_DISTANCE);
    DeleteLocalInt(oTarget, SETWEP_SHIELD);
}

//::///////////////////////////////////////////////
//:: Name ArrayOfWeapons, MoveArrayBackOne
//:://////////////////////////////////////////////
/*
    This is the arrays, IE sets up what weapons
    we have value first, good for searching through
    later and
*/
//:://////////////////////////////////////////////
//:: Created By: Yrean
//:: Modified By: Jasperre
//:://////////////////////////////////////////////
// Sets the weapon to the array, in the right spot...
// If bSecondary is TRUE, it uses the weapon size, and creature size to modifiy
// the value, IE: Sets it as the secondary weapon.
void ArrayOfWeapons(string sArray, object oTarget, object oItem, int nValue, int bSecondary = FALSE)
{
    // Check for if it is secondary.
    // We add some value based on the creature size against weapon size.
    // - We also may take away some.
    int nSetValue = nValue;
    if(bSecondary == TRUE)
    {
        // We take 2 or add 2 for different sizes. Not too much...but enough?
        nSetValue += ((nCreatureSize - nCurrentItemSize) * 2);
    }
    int nOtherItemsValues, nCnt, bBreak;
    int nMax = GetLocalInt(oTarget, MAXINT_ + sArray);
    string sArrayStore;
    // Special - no max items!
    if(nMax < 1)
    {
        sArrayStore = sArray + "1";
        SetLocalInt(oTarget, sArrayStore, nSetValue);
        SetLocalInt(oTarget, sArrayStore + WEAP_SIZE, nCurrentItemSize);
        SetLocalInt(oTarget, sArrayStore + WEAP_DAMAGE, nCurrentItemDamage);
        SetLocalObject(oTarget, sArrayStore, oItem);
        nMax++;
        SetLocalInt(oTarget, MAXINT_ + sArray, nMax);
    }
    // Else, we will set it in the array.
    else
    {
        // Loop through the items stored already.
        for(nCnt = 1; (nCnt <= nMax && bBreak != TRUE); nCnt++)
        {
            // Get the value of the item.
            nOtherItemsValues = GetLocalInt(oTarget, sArray + IntToString(nCnt));
            // If imput is greater than stored...move all of them back one.
            if(nValue > nOtherItemsValues)
            {
                // Set weapon size as well.
                sArrayStore = sArray + IntToString(nCnt);
                MoveArrayBackOne(sArray, nCnt, oTarget, nMax);
                SetLocalInt(oTarget, sArrayStore, nSetValue);
                SetLocalInt(oTarget, sArrayStore + WEAP_SIZE, nCurrentItemSize);
                SetLocalInt(oTarget, sArrayStore + WEAP_DAMAGE, nCurrentItemDamage);
                SetLocalObject(oTarget, sArrayStore, oItem);
                nMax++;
                SetLocalInt(oTarget, MAXINT_ + sArray, nMax);
                bBreak = TRUE;
            }
            // If end, we set to the end :-)
            else if(nCnt == nMax)
            {
                // Set weapon size as well. Add one to i to be at the end.
                sArrayStore = sArray + IntToString(nCnt + 1);
                SetLocalInt(oTarget, sArrayStore, nSetValue);
                SetLocalInt(oTarget, sArrayStore + WEAP_SIZE, nCurrentItemSize);
                SetLocalInt(oTarget, sArrayStore + WEAP_DAMAGE, nCurrentItemDamage);
                SetLocalObject(oTarget, sArrayStore, oItem);
                nMax++;
                SetLocalInt(oTarget, MAXINT_ + sArray, nMax);
                bBreak = TRUE;
            }
        }
    }
}
// This moves the values from nMax to nNumberStart back one in the list.
void MoveArrayBackOne(string sArray, int nNumberStart, object oTarget, int nMax)
{
    // Get the first item...
    object oItemAtNumber;
    string sCurrentName, sNewName;
    int nItemAtNumberValue, nCnt, nCurrentItemSize, nCurrentItemDamage;
    // Move it from the back, back one, then then next...
    for(nCnt = nMax; nCnt >= nNumberStart; nCnt--)
    {
        // Sets the name up right.
        sCurrentName = sArray + IntToString(nCnt);
        sNewName = sArray + IntToString(nCnt + 1);

        //  Set the things up in the right parts.
        oItemAtNumber = GetLocalObject(oTarget, sCurrentName);
        nItemAtNumberValue = GetLocalInt(oTarget, sCurrentName);
        nCurrentItemSize = GetLocalInt(oTarget, sCurrentName + WEAP_SIZE);
        nCurrentItemDamage = GetLocalInt(oTarget, sCurrentName + WEAP_DAMAGE);

        // To the NEW name - we add one to the nCnt value.
        SetLocalObject(oTarget, sNewName, oItemAtNumber);
        SetLocalInt(oTarget, sNewName, nItemAtNumberValue);
        SetLocalInt(oTarget, sNewName + WEAP_SIZE, nCurrentItemSize);
        SetLocalInt(oTarget, sNewName + WEAP_DAMAGE, nCurrentItemSize);
    }
}
void DeleteDatabase(object oTarget, string sArray)
{
    int nMax = GetLocalInt(oTarget, MAXINT_ + sArray);
    int nCnt;
    string sNewName;
    if(nMax > 0)
    {
        for(nCnt = 1; nCnt <= nMax; nCnt++)
        {
            sNewName = sArray + IntToString(nCnt);
            DeleteLocalObject(oTarget, sNewName);// Object
            DeleteLocalInt(oTarget, sNewName);// Value
            DeleteLocalInt(oTarget, sNewName + WEAP_SIZE);// Size
            DeleteLocalInt(oTarget, sNewName + WEAP_DAMAGE);// Damage
        }
    }
    // Here, we do delete the max
    DeleteLocalInt(oTarget, MAXINT_ + sArray);
}
void DeleteValueInts(object oTarget, string sArray)
{
    int nMax = GetLocalInt(oTarget, MAXINT_ + sArray);
    int nCnt;
    if(nMax)
    {
        for(nCnt = 1; nCnt <= nMax; nCnt++)
        {
            DeleteLocalInt(oTarget, sArray + IntToString(nCnt));
        }
    }
    // Note: We keep the size...
}
// Uses right prefix to store the object to oTarget.
void SWFinalAIObject(object oTarget, string sName, object oObject)
{
    SetLocalObject(oTarget, AI_OBJECT + sName, oObject);
}
// Uses right prefix to store the iInt to oTarget.
void SWFinalAIInteger(object oTarget, string sName, int nInt)
{
    SetLocalInt(oTarget, AI_INTEGER + sName, nInt);
}
// Deletes object with Prefix
void SWDeleteAIObject(object oTarget, string sName)
{
    DeleteLocalObject(oTarget, AI_OBJECT + sName);
}
// Deletes integer with Prefix
void SWDeleteAIInteger(object oTarget, string sName)
{
    DeleteLocalInt(oTarget, AI_INTEGER + sName);
}

// reset healing kits only on oTarget.
void ResetHealingKits(object oTarget)
{
    object oItem, oHighestKit;
    int nHealingKitsAmount, nItemValue;
    int nRunningValue = 0; // For kits
    // The inventory
    oItem = GetFirstItemInInventory(oTarget);
    while(GetIsObjectValid(oItem))
    {
        if(GetBaseItemType(oItem) == BASE_ITEM_HEALERSKIT)
        {
            nHealingKitsAmount++;
            nItemValue = GetGoldPieceValue(oItem);
            // Stacked kits be worth what they should be seperatly.
            nItemValue = nItemValue/GetNumStackedItems(oItem);
            if(nItemValue > nRunningValue)
            {
                nRunningValue = nItemValue;
                oHighestKit = oItem;
            }
        }
        oItem = GetNextItemInInventory(oTarget);
    }
    // Need some, any!
    if(nHealingKitsAmount > 0)
    {
        // set healing kits (if any)
        SWFinalAIObject(oTarget, AI_VALID_HEALING_KIT_OBJECT, oHighestKit);
        // Set amount left
        SWFinalAIInteger(oTarget, AI_VALID_HEALING_KITS, nHealingKitsAmount);
    }
}

void DeleteAllPreviousWeapons(object oTarget)
{
    DeleteDatabase(oTarget, AI_WEAPON_PRIMARY);
    DeleteDatabase(oTarget, AI_WEAPON_SECONDARY);
    DeleteDatabase(oTarget, AI_WEAPON_TWO_HANDED);

    SWDeleteAIInteger(oTarget, AI_WEAPON_RANGED_SHIELD);
    SWDeleteAIInteger(oTarget, AI_WEAPON_RANGED_IS_UNLIMITED);
    SWDeleteAIInteger(oTarget, AI_WEAPON_RANGED_AMMOSLOT);
    SWDeleteAIObject(oTarget, AI_WEAPON_RANGED);
    SWDeleteAIObject(oTarget, AI_WEAPON_RANGED_2);
    SWDeleteAIObject(oTarget, AI_WEAPON_SHIELD);
    SWDeleteAIObject(oTarget, AI_WEAPON_SHIELD_2);
}

// Debug: To compile this script full, uncomment all of the below.
/* - Add two "/"'s at the start of this line
void main()
{
    return;
}
//*/
