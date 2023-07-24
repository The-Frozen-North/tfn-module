/************************ [Include - Set Weapons] ******************************
    Filename: J_Inc_Setweapons
************************* [Include - Set Weapons] ******************************
    This holds all the stuff for setting up local objects for weapons we have
    or have not got - normally the best to worst.
************************* [History] ********************************************
    1.0 - Put in include
    1.3 - Fixed minor things, added arrays of weapons (for deul wielding) and
          heal kits and stuff added.
          Added to OnSpawn.
************************* [Workings] *******************************************
    This is included in "j_ai_setweapons" and executed from other places VIA it.

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
************************* [Arguments] ******************************************
    Arguments: N/A
************************* [Include - Set Weapons] *****************************/

#include "j_inc_constants"

/*****Structure******/
// Things we use throughout, saves time (and Get's) putting them here.

int ProfWizard, ProfDruid, ProfMonk, ProfElf, ProfRogue, ProfSimple,
    ProfMartial, ProfExotic, ProfShield,
/*
int ProfWizard = FALSE;
int ProfDruid = FALSE;
int ProfMonk = FALSE;
int ProfElf = FALSE;
int ProfRogue = FALSE;
int ProfSimple = FALSE;
int ProfMartial = FALSE;
int ProfExotic = FALSE;
int ProfShield = FALSE;
*/
// If we set have the right two-weapon fighting feats, this is set
/*int*/ProfTwoWeapons, // = FALSE;
// This contains our current size.
/*int*/CreatureSize,
/*int*/CreatureStrength, // = FALSE;
// This tracks the current item value (so less Get/Set).
/*int*/CurrentItemValue, // = FALSE;
/*int*/CurrentItemIsMighty, // = FALSE;
/*int*/CurrentItemIsUnlimited, // = FALSE;
/*int*/CurrentItemSize, // = FALSE;
/*int*/CurrentItemDamage, // = FALSE;  // Special - Damage is set in the bigger arrays.
/*int*/CurrentItemType, // = -1; // Set to -1 in loop anyway.
// I'm scripting, not doing grammer here!
/*int*/HasArrows, // = FALSE;
/*int*/HasBolts, // = FALSE;
/*int*/HasBullets; // = FALSE;

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
void SWFinalAIInteger(object oTarget, string sName, int iInt);
// Deletes object with Prefix
void SWDeleteAIObject(object oTarget, string sName);
// Deletes integer with Prefix
void SWDeleteAIInteger(object oTarget, string sName);

// Sets the weapon to the array, in the right spot...
// If iSecondary is TRUE, it uses the weapon size, and creature size to modifiy
// the value.
void ArrayOfWeapons(string sArray, object oTarget, object oItem, int iValue, int iSecondary = FALSE);
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
// This moves the values from iMax to iNumberStart back one in the list.
void MoveArrayBackOne(string sArray, int iNumberStart, object oTarget, int iMax);
// Special: Apply EffectCutsceneImmobilize
void AI_SpecialActionApplyItem(object oTarget);
// Special: Remove EffectCutsceneImmobilize
void AI_SpecialActionRemoveItem(object oTarget);
// Gets a item talent value, no applying of EffectCutsceneImmobilize.
// - iTalent, 1-21.
void AI_SetItemTalentValue(int iTalent);

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
    CreatureSize = GetCreatureSize(oTarget);
    // No need to take off strength. It is pulrey for mighty weapons, we
    // add on this bonus to the value.
    CreatureStrength = GetAbilityModifier(ABILITY_STRENGTH, oTarget);
    if(CreatureStrength < i0)
    {
        CreatureStrength = i0;
    }
    // Ints, globally set.
    if(GetHasFeat(FEAT_WEAPON_PROFICIENCY_DRUID, oTarget))
        ProfDruid = TRUE;
    if(GetHasFeat(FEAT_WEAPON_PROFICIENCY_ELF, oTarget))
        ProfElf = TRUE;
    if(GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oTarget))
        ProfExotic = TRUE;
    if(GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oTarget))
        ProfMartial = TRUE;
    if(GetHasFeat(FEAT_WEAPON_PROFICIENCY_MONK, oTarget))
        ProfMonk = TRUE;
    if(GetHasFeat(FEAT_WEAPON_PROFICIENCY_ROGUE, oTarget))
        ProfRogue = TRUE;
    if(GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oTarget))
        ProfSimple = TRUE;
    if(GetHasFeat(FEAT_WEAPON_PROFICIENCY_WIZARD, oTarget))
        ProfWizard = TRUE;
    if(GetHasFeat(FEAT_SHIELD_PROFICIENCY, oTarget))
        ProfShield = TRUE;
    if(GetHasFeat(FEAT_TWO_WEAPON_FIGHTING, oTarget) ||
       GetHasFeat(FEAT_AMBIDEXTERITY, oTarget) ||
       GetHasFeat(FEAT_IMPROVED_TWO_WEAPON_FIGHTING, oTarget))
    {
        ProfTwoWeapons = TRUE;
    }
    // Sorts the inventory, on oTarget, with CreatureSize of creature
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
    int nBase, nWeaponSize, iCnt;
    object oItem, oHighestKit;
    int iHealingKitsAmount, iItemValue;
    int iRunningValue = i0; // For kits

    // Onto the slots - if we are checking them!
    // Slots 4 and 5. (HTH weapons)
    for(iCnt = INVENTORY_SLOT_RIGHTHAND; // 4
        iCnt <= INVENTORY_SLOT_LEFTHAND; // 5
        iCnt++)
    {
        oItem  = GetItemInSlot(iCnt, oTarget);
        if(GetIsObjectValid(oItem))
        {
            CurrentItemType = GetBaseItemType(oItem);
            CurrentItemSize = GetWeaponSize(oItem);
            CurrentItemDamage = FALSE;// Reset
            if(CurrentItemSize)// Is over 0
            {
                DoEffectsOf(oTarget, oItem);
            }
        }
    }
    // Slots 11, 12 and 13. (some ammo slots)
    for(iCnt = INVENTORY_SLOT_ARROWS; //11
        iCnt <= INVENTORY_SLOT_BOLTS; //13
        iCnt++)
    {
        oItem  = GetItemInSlot(iCnt, oTarget);
        if(GetIsObjectValid(oItem))
        {
            CurrentItemType = GetBaseItemType(oItem);
            CurrentItemSize = GetWeaponSize(oItem);
            CurrentItemDamage = FALSE;// Reset
            if(CurrentItemSize)
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
        CurrentItemType = GetBaseItemType(oItem);
        if(CurrentItemType == BASE_ITEM_HEALERSKIT)
        {
            iHealingKitsAmount++;
            iItemValue = GetGoldPieceValue(oItem);
            // Stacked kits be worth what they should be seperatly.
            iItemValue = iItemValue/GetNumStackedItems(oItem);
            if(iItemValue > iRunningValue)
            {
                iRunningValue = iItemValue;
                oHighestKit = oItem;
            }
        }
        // Else, is it a arrow, bolt or bullet?
        else if(CurrentItemType == BASE_ITEM_ARROW ||
                CurrentItemType == BASE_ITEM_BOLT ||
                CurrentItemType == BASE_ITEM_BULLET)
        {
            SetAmmoCounters(oTarget);
        }
        else
        // else it isn't a healing kit, or ammo...what is it?
        // Likely a weapon, so we check
        {
            // Only need current item size, if it is a weapon!
            CurrentItemSize = GetWeaponSize(oItem);
            CurrentItemDamage = FALSE;// Reset
            if(CurrentItemSize)// Is over 0 (valid weapon)
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
    if(iHealingKitsAmount > i0)
    {
        // set healing kits (if any)
        SWFinalAIObject(oTarget, AI_VALID_HEALING_KIT_OBJECT, oHighestKit);
        // Set amount left
        SWFinalAIInteger(oTarget, AI_VALID_HEALING_KITS, iHealingKitsAmount);
    }
    // Added in item setting functions. apply EffectCutsceneImmobilize, remove at end, but
    // in the middle we do item talents.
    if(!GetSpawnInCondition(AI_FLAG_OTHER_LAG_NO_ITEMS, AI_OTHER_MASTER, oTarget))
    {
        AI_SpecialActionApplyItem(oTarget);

        // Loop talents (not ones we won't set however)
        for(iCnt = i1; iCnt <= i15; iCnt++)
        {
            // Ignore healing ones.
            if(iCnt != i4 && iCnt != i5)
            {
                AI_SetItemTalentValue(iCnt);
            }
        }

        AI_SpecialActionRemoveItem(oTarget);
    }
    // Delete things, FINALLY. really! I mean, this is it, it runs, as it is,
    // and the other things run off it as things are met...!
    DelayCommand(0.1, DeleteInts(oTarget));
}

void DoEffectsOf(object oTarget, object oItem)
{
    // 1.3 = changed to switch statement.
    // Note: Anything not done BaseEffects of cannot even be used by the character.
    switch(CurrentItemSize)
    {
        // Tiny weapons - If we are under large size, and is a dagger or similar
        case WEAPON_SIZE_TINY:
        {
            if(CreatureSize < CREATURE_SIZE_LARGE) BaseEffects(oTarget, oItem);
        }
        break;
        // Small Weapons - If we are large (not giant) and size is like a shortsword
        case CREATURE_SIZE_SMALL:
        {
            if(CreatureSize < CREATURE_SIZE_HUGE) BaseEffects(oTarget, oItem);
        }
        break;
        // Medium weapons - If we are over tiny, and size is like a longsword
        case WEAPON_SIZE_MEDIUM:
        {
            if(CreatureSize > CREATURE_SIZE_TINY) BaseEffects(oTarget, oItem);
        }
        break;
        // Large weapons - anything that is over small, and the size is like a spear
        case WEAPON_SIZE_LARGE:
        {
            if(CreatureSize > WEAPON_SIZE_SMALL) BaseEffects(oTarget, oItem);
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
    CurrentItemValue = i0;
    if(GetIsObjectValid(oItem))
    {
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ABILITY_BONUS))
            CurrentItemValue += i8;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_AC_BONUS))
            CurrentItemValue += i5;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_AC_BONUS_VS_ALIGNMENT_GROUP))
            CurrentItemValue += i4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_AC_BONUS_VS_DAMAGE_TYPE))
            CurrentItemValue += i4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_AC_BONUS_VS_RACIAL_GROUP))
            CurrentItemValue += i4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_AC_BONUS_VS_SPECIFIC_ALIGNMENT))
            CurrentItemValue += i3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ATTACK_BONUS))
            CurrentItemValue += i4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ATTACK_BONUS_VS_ALIGNMENT_GROUP))
            CurrentItemValue += i3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ATTACK_BONUS_VS_RACIAL_GROUP))
            CurrentItemValue += i3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ATTACK_BONUS_VS_SPECIFIC_ALIGNMENT))
            CurrentItemValue += i3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_BASE_ITEM_WEIGHT_REDUCTION))
            CurrentItemValue += i3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_BONUS_FEAT))
            CurrentItemValue += i6;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_BONUS_SPELL_SLOT_OF_LEVEL_N))
            CurrentItemValue += i2;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_CAST_SPELL))
            CurrentItemValue += i5;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DAMAGE_BONUS))
            CurrentItemValue += i6;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DAMAGE_BONUS_VS_ALIGNMENT_GROUP))
            CurrentItemValue += i4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DAMAGE_BONUS_VS_RACIAL_GROUP))
            CurrentItemValue += i4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DAMAGE_BONUS_VS_SPECIFIC_ALIGNMENT))
            CurrentItemValue += i4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DAMAGE_REDUCTION))
            CurrentItemValue += i8;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DAMAGE_RESISTANCE))
            CurrentItemValue += i8;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DAMAGE_VULNERABILITY))
            CurrentItemValue -= i3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DARKVISION))
            CurrentItemValue += i3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DECREASED_ABILITY_SCORE))
            CurrentItemValue -= i4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DECREASED_AC))
            CurrentItemValue -= i4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DECREASED_ATTACK_MODIFIER))
            CurrentItemValue -= i3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DECREASED_DAMAGE))
            CurrentItemValue -= i3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DECREASED_ENHANCEMENT_MODIFIER))
            CurrentItemValue -= i5;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DECREASED_SAVING_THROWS))
            CurrentItemValue -= i4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DECREASED_SAVING_THROWS_SPECIFIC))
            CurrentItemValue -= i3;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_DECREASED_SKILL_MODIFIER))
            CurrentItemValue -= i2;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ENHANCEMENT_BONUS))
            CurrentItemValue += i7;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_ALIGNMENT_GROUP))
            CurrentItemValue += i6;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_RACIAL_GROUP))
            CurrentItemValue += i6;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_SPECIFIC_ALIGNEMENT))
            CurrentItemValue += i5;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_EXTRA_MELEE_DAMAGE_TYPE))
            CurrentItemValue += i1;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_EXTRA_RANGED_DAMAGE_TYPE))
            CurrentItemValue += i1;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_FREEDOM_OF_MOVEMENT))
            CurrentItemValue += i5;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_HASTE))
            CurrentItemValue += i12;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_HOLY_AVENGER))
            CurrentItemValue += i10;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_IMMUNITY_DAMAGE_TYPE))
            CurrentItemValue += i8;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_IMMUNITY_MISCELLANEOUS))
            CurrentItemValue += i10;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_IMMUNITY_SPECIFIC_SPELL))
            CurrentItemValue += i8;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_IMMUNITY_SPELL_SCHOOL))
            CurrentItemValue += i12;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_IMPROVED_EVASION))
            CurrentItemValue += i10;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_KEEN))
            CurrentItemValue += i7;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_LIGHT))
            CurrentItemValue += i1;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_MASSIVE_CRITICALS))
            CurrentItemValue += i2;
//        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_MIND_BLANK))
//            CurrentItemValue += i4;// Do not think It exsists.
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_MONSTER_DAMAGE))
            CurrentItemValue += i1;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_NO_DAMAGE))
            CurrentItemValue -= i10;// EEEKK! Bad bad bad!!
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ON_HIT_PROPERTIES))
            CurrentItemValue += i8;// Includes all vorpal and so on!
//        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_ON_MONSTER_HIT))
//            CurrentItemValue += i8;// Can't be on a weapon
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_POISON))
            CurrentItemValue += i5;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_REGENERATION))
            CurrentItemValue += i8;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_REGENERATION_VAMPIRIC))
            CurrentItemValue += i6;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_SAVING_THROW_BONUS))
            CurrentItemValue += i5;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC))
            CurrentItemValue += i4;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_SKILL_BONUS))
            CurrentItemValue += i2;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_SPELL_RESISTANCE))
            CurrentItemValue += i7;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_TRUE_SEEING))
            CurrentItemValue += i11;
        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_TURN_RESISTANCE))
            CurrentItemValue += i8;
//        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_VORPAL))
//            CurrentItemValue += i8;// Removed as Bioware will remove this constant. Doesn't exsist.
//        if(GetItemHasItemProperty(oItem, ITEM_PROPERTY_WOUNDING))
//            CurrentItemValue += i8;// Removed as Bioware will remove this constant. Doesn't exsist.
        // Special cases
        // Set is unlimited to TRUE or FALSE, add 10 if TRUE.
        CurrentItemIsUnlimited = GetItemHasItemProperty(oItem, ITEM_PROPERTY_UNLIMITED_AMMUNITION);
        if(CurrentItemIsUnlimited) CurrentItemValue += i10;
        // Same as above, for mighty
        CurrentItemIsMighty = GetItemHasItemProperty(oItem, ITEM_PROPERTY_MIGHTY);
        if(CurrentItemIsMighty) CurrentItemValue += i3;

        switch (CurrentItemSize)
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
    switch(CurrentItemType)
    {
        case BASE_ITEM_DIREMACE:
        {
            // This is the only one that needs documenting. All are similar.
            if(ProfExotic == TRUE)// We are proficient in exotics...
            {
                CurrentItemDamage = i16;// Set max damage.
                CurrentItemValue +=     // We add onto the current value some things...
                      (CurrentItemDamage + // The damage (maximum) done by it.
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_DIRE_MACE)) + // Adds 1 if specailised in it
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_DIRE_MACE) * i2) +// Adds 2 if can do good criticals in it
                      (GetHasFeat(FEAT_WEAPON_FOCUS_DIRE_MACE) * i2));     // Adds 2 if we do +2 damage with it
                // If a very big creature - set as a primary weopen
                if(CreatureSize >= CREATURE_SIZE_LARGE)//4+
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                // If a medium creature - set as a two-handed weopen
                else if(CreatureSize == CREATURE_SIZE_MEDIUM)//=3
                {
                    // Add 16 more for a "second" weapon.
                    CurrentItemValue += CurrentItemDamage;
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_DOUBLEAXE:
        {
            if(ProfExotic == TRUE)
            {
                CurrentItemDamage = i16;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_DOUBLE_AXE)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_DOUBLE_AXE) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_DOUBLE_AXE) * i2));
                if(CreatureSize >= CREATURE_SIZE_LARGE)//4+
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(CreatureSize == CREATURE_SIZE_MEDIUM)//=3
                {
                    // Add 16 more for a "second" weapon.
                    CurrentItemValue += i16;
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_TWOBLADEDSWORD:
        {
            if(ProfExotic == TRUE)
            {
                CurrentItemDamage = i16;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_TWO_BLADED_SWORD)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_TWO_BLADED_SWORD) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_TWO_BLADED_SWORD) * i2));
                if(CreatureSize >= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(CreatureSize == CREATURE_SIZE_MEDIUM)
                {
                    CurrentItemValue += CurrentItemDamage;
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_GREATAXE:
        {
            if(ProfMartial == TRUE)
            {
                CurrentItemDamage = i12;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_GREAT_AXE)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_GREAT_AXE) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_GREAT_AXE) * i2));
                if(CreatureSize >= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(CreatureSize == CREATURE_SIZE_MEDIUM)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_GREATSWORD:
        {
            if(ProfMartial == TRUE)
            {
                CurrentItemDamage = i12;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_GREAT_SWORD)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_GREAT_SWORD) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_GREAT_SWORD) * i2));
                if(CreatureSize >= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(CreatureSize == CREATURE_SIZE_MEDIUM)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_HALBERD:
        {
            if(ProfMartial == TRUE)
            {
                CurrentItemDamage = i10;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_HALBERD)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_HALBERD) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_HALBERD) * i2));
                if(CreatureSize >= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(CreatureSize == CREATURE_SIZE_MEDIUM)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_HEAVYFLAIL:
        {
            if(ProfMartial == TRUE)
            {
                CurrentItemDamage = i10;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_HEAVY_FLAIL)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_HEAVY_FLAIL) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_HEAVY_FLAIL) * i2));
                if(CreatureSize >= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(CreatureSize == CREATURE_SIZE_MEDIUM)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_SCYTHE:
        {
            if(ProfExotic == TRUE)
            {
                CurrentItemDamage = i10;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SCYTHE)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_SCYTHE) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_SCYTHE) * i2));
                if(CreatureSize >= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(CreatureSize == CREATURE_SIZE_MEDIUM)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_SHORTSPEAR:
        {
            if(ProfSimple == TRUE || ProfDruid == TRUE)
            {
                CurrentItemDamage = i8;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SPEAR)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_SPEAR) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_SPEAR) * i2));
                if(CreatureSize >= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(CreatureSize == CREATURE_SIZE_MEDIUM)
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
            if(ProfWizard == TRUE || ProfSimple == TRUE || ProfRogue == TRUE ||
               ProfMonk == TRUE || ProfDruid == TRUE)
            {
                CurrentItemDamage = i6;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_STAFF)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_STAFF) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_STAFF) * i2));
                if(CreatureSize >= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(CreatureSize == CREATURE_SIZE_MEDIUM)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_LONGBOW:
        {
            if(CreatureSize >= CREATURE_SIZE_MEDIUM &&
              (ProfMartial == TRUE || ProfElf == TRUE))
            {
                CurrentItemDamage = i8;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (CurrentItemIsMighty * CreatureStrength) +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_LONGBOW)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_LONGBOW) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_LONGBOW) * i2));
                StoreRangedWeapon(oTarget, oItem);
            }
        }
        break;
        case BASE_ITEM_TOWERSHIELD:
        {
            if(ProfShield == TRUE &&
               CreatureSize >= CREATURE_SIZE_MEDIUM)
            {
                CurrentItemValue += GetItemACValue(oItem);
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
    switch (CurrentItemType)
    {
        case BASE_ITEM_BASTARDSWORD:
        {
            if(ProfExotic == TRUE)
            {
                CurrentItemDamage = i10;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_BASTARD_SWORD)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_BASTARD_SWORD) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_BASTARD_SWORD) * i2));
                if(CreatureSize >= CREATURE_SIZE_MEDIUM)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(CreatureSize == CREATURE_SIZE_SMALL)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_BATTLEAXE:
        {
            if(ProfMartial == TRUE)
            {
                CurrentItemDamage = i8;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_BATTLE_AXE)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_BATTLE_AXE) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_BATTLE_AXE) * i2));
                if(CreatureSize >= CREATURE_SIZE_MEDIUM)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(CreatureSize == CREATURE_SIZE_SMALL)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_DWARVENWARAXE:
        {
            if(ProfExotic == TRUE)
            {
                CurrentItemDamage = i10;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_DWAXE)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_DWAXE) * i2) +
                      (GetHasFeat(FEAT_EPIC_WEAPON_FOCUS_DWAXE) * i2));
                if(CreatureSize >= CREATURE_SIZE_MEDIUM)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(CreatureSize == CREATURE_SIZE_SMALL)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        case BASE_ITEM_CLUB:
        {
            if(ProfWizard == TRUE || ProfSimple == TRUE ||
               ProfMonk == TRUE || ProfDruid == TRUE)
            {
                CurrentItemDamage = i6;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_CLUB)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_CLUB) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_CLUB) * i2));
                if(CreatureSize >= CREATURE_SIZE_MEDIUM)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(CreatureSize == CREATURE_SIZE_SMALL)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_KATANA:
        {
            if(ProfExotic == TRUE)
            {
                CurrentItemDamage = i10;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_KATANA)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_KATANA) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_KATANA) * i2));
                if(CreatureSize >= CREATURE_SIZE_MEDIUM)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(CreatureSize == CREATURE_SIZE_SMALL)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_LIGHTFLAIL:
        {
            if(ProfMartial == TRUE)
            {
                CurrentItemDamage = i8;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_LIGHT_FLAIL)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_LIGHT_FLAIL) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_FLAIL) * i2));
                if(CreatureSize >= CREATURE_SIZE_MEDIUM)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(CreatureSize == CREATURE_SIZE_SMALL)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_LONGSWORD:
        {
            if(ProfMartial == TRUE || ProfElf == TRUE)
            {
                CurrentItemDamage = i8;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_LONG_SWORD)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_LONG_SWORD) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_LONG_SWORD) * i2));
                if(CreatureSize >= CREATURE_SIZE_MEDIUM)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(CreatureSize == CREATURE_SIZE_SMALL)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_MORNINGSTAR:
        {
            if(ProfSimple == TRUE || ProfRogue == TRUE) // Primary only
            {
                CurrentItemDamage = i8;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_MORNING_STAR)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_MORNING_STAR) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_MORNING_STAR) * i2));
                if(CreatureSize >= CREATURE_SIZE_MEDIUM)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(CreatureSize == CREATURE_SIZE_SMALL)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_RAPIER:
        {
            if(ProfRogue == TRUE || ProfMartial == TRUE || ProfElf == TRUE)
            {
                CurrentItemDamage = i6;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_RAPIER)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_RAPIER) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_RAPIER) * i2));
                if(CreatureSize >= CREATURE_SIZE_MEDIUM)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(CreatureSize == CREATURE_SIZE_SMALL)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_SCIMITAR:
        {
            if(ProfMartial == TRUE || ProfDruid == TRUE)
            {
                CurrentItemDamage = i6;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SCIMITAR)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_SCIMITAR) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_SCIMITAR) * i2));
                if(CreatureSize >= CREATURE_SIZE_MEDIUM)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(CreatureSize == CREATURE_SIZE_SMALL)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_WARHAMMER:
        {
            if(ProfMartial == TRUE)
            {
                CurrentItemDamage = i8;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                       GetHasFeat(FEAT_WEAPON_SPECIALIZATION_WAR_HAMMER) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_WAR_HAMMER) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_WAR_HAMMER) * i2));
                if(CreatureSize >= CREATURE_SIZE_MEDIUM)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(CreatureSize == CREATURE_SIZE_SMALL)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_HEAVYCROSSBOW:
        {
            if(CreatureSize >= CREATURE_SIZE_SMALL &&
              (ProfWizard == TRUE || ProfSimple == TRUE ||
                ProfRogue == TRUE || ProfMonk == TRUE))
            {
                CurrentItemDamage = i10;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (CurrentItemIsMighty * CreatureStrength) +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_HEAVY_CROSSBOW)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_HEAVY_CROSSBOW) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_HEAVY_CROSSBOW) * i2));
                StoreRangedWeapon(oTarget, oItem);
            }
        }
        break;
        case BASE_ITEM_SHORTBOW:
        {
            if(CreatureSize >= CREATURE_SIZE_SMALL &&
              (ProfRogue == TRUE || ProfMartial == TRUE || ProfElf == TRUE))
            {
                CurrentItemDamage = i6;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (CurrentItemIsMighty * CreatureStrength) +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SHORTBOW)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_SHORTBOW) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_SHORTBOW) * i2));
                StoreRangedWeapon(oTarget, oItem);
            }
        }
        break;
        case BASE_ITEM_LARGESHIELD:
        {
            if(CreatureSize >= CREATURE_SIZE_SMALL &&
               ProfShield == TRUE)
            {
                CurrentItemValue += GetItemACValue(oItem);
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
    switch (CurrentItemType)
    {
        case BASE_ITEM_HANDAXE:
        {
            if(ProfMonk == TRUE || ProfMartial == TRUE)
            {
                CurrentItemDamage = i6;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_HAND_AXE)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_HAND_AXE) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_HAND_AXE) * i2));
                if(CreatureSize >= CREATURE_SIZE_SMALL &&
                   CreatureSize <= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(CreatureSize == CREATURE_SIZE_TINY)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_KAMA:
        {
            if(ProfMonk == TRUE || ProfExotic == TRUE)
            {
                CurrentItemDamage = i6;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_KAMA)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_KAMA) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_KAMA) * i2));
                if(CreatureSize >= CREATURE_SIZE_SMALL &&
                   CreatureSize <= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(CreatureSize == CREATURE_SIZE_TINY)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_LIGHTHAMMER:
        {
            if(ProfMartial == TRUE)
            {
                CurrentItemDamage = i4;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                       GetHasFeat(FEAT_WEAPON_SPECIALIZATION_LIGHT_HAMMER) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_LIGHT_HAMMER) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_HAMMER) * i2));
                if(CreatureSize >= CREATURE_SIZE_SMALL &&
                   CreatureSize <= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(CreatureSize == CREATURE_SIZE_TINY)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_LIGHTMACE:
        {
            if(ProfSimple == TRUE || ProfRogue == TRUE)
            {
                CurrentItemDamage = i6;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_LIGHT_MACE)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_LIGHT_MACE) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_MACE) * i2));
                if(CreatureSize >= CREATURE_SIZE_SMALL &&
                   CreatureSize <= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(CreatureSize == CREATURE_SIZE_TINY)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_SHORTSWORD:
        {
            if(ProfRogue == TRUE || ProfMartial == TRUE)
            {
                CurrentItemDamage = i6;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SHORT_SWORD)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_SHORT_SWORD) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_SHORT_SWORD) * i2));
                if(CreatureSize >= CREATURE_SIZE_SMALL &&
                   CreatureSize <= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(CreatureSize == CREATURE_SIZE_TINY)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_WHIP:
        {
            if(ProfExotic == TRUE)
            {
                CurrentItemDamage = i2;// Set max damage.
                CurrentItemValue += CurrentItemDamage;
                // We add a special amount, 10, as it is only used as a secondary
                // weapon, and only in the offhand.
                CurrentItemValue += i10;
                if(CreatureSize >= CREATURE_SIZE_SMALL &&
                   CreatureSize <= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_SICKLE:
        {
            if(ProfSimple == TRUE || ProfDruid == TRUE)
            {
                CurrentItemDamage = i6;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SICKLE)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_SICKLE) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_SICKLE) * i2));
                if(CreatureSize >= CREATURE_SIZE_SMALL &&
                   CreatureSize <= CREATURE_SIZE_LARGE)
                {
                    SetPrimaryWeapon(oTarget, oItem);
                }
                else if(CreatureSize == CREATURE_SIZE_TINY)
                {
                    SetTwoHandedWeapon(oTarget, oItem);
                }
            }
        }
        break;
        case BASE_ITEM_DART:
        {
            // Ranged weapons below
            if(CreatureSize <= CREATURE_SIZE_LARGE &&
              (ProfSimple == TRUE || ProfRogue == TRUE || ProfDruid == TRUE))
            {
                CurrentItemDamage = i4;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (CurrentItemIsMighty * CreatureStrength) +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_DART)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_DART) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_DART) * i2));
                StoreRangedWeapon(oTarget, oItem);
            }
        }
        break;
        case BASE_ITEM_LIGHTCROSSBOW:
        {
            if(CreatureSize <= CREATURE_SIZE_LARGE &&
              (ProfWizard == TRUE || ProfSimple == TRUE ||
               ProfRogue == TRUE || ProfMonk == TRUE))
            {
                CurrentItemDamage = i8;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (CurrentItemIsMighty * CreatureStrength) +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_LIGHT_CROSSBOW)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_LIGHT_CROSSBOW) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_LIGHT_CROSSBOW) * i2));
                StoreRangedWeapon(oTarget, oItem);
            }
        }
        break;
        case BASE_ITEM_SLING:
        {
            if(CreatureSize <= CREATURE_SIZE_LARGE &&
              (ProfSimple == TRUE || ProfMonk == TRUE || ProfDruid == TRUE))
            {
                CurrentItemDamage = i4;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (CurrentItemIsMighty * CreatureStrength) +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SLING)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_SLING) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_SLING) * i2));
                StoreRangedWeapon(oTarget, oItem);
            }
        }
        break;
        case BASE_ITEM_THROWINGAXE:
        {
            if(CreatureSize <= CREATURE_SIZE_LARGE && ProfMartial == TRUE)
            {
                CurrentItemDamage = i6;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (CreatureStrength) +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SLING)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_SLING) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_SLING) * i2));
                StoreRangedWeapon(oTarget, oItem);
            }
        }
        break;
        case BASE_ITEM_SMALLSHIELD:
        {
            if(ProfShield)
            {
                CurrentItemValue += GetItemACValue(oItem);
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
    switch (CurrentItemType)
    {
        case BASE_ITEM_DAGGER:
        {
            if(CreatureSize <= CREATURE_SIZE_MEDIUM &&
              (ProfWizard == TRUE || ProfSimple == TRUE || ProfRogue == TRUE ||
               ProfMonk == TRUE || ProfDruid == TRUE))
            {
                CurrentItemDamage = i4;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_DAGGER)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_DAGGER) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_DAGGER) * i2));
                SetPrimaryWeapon(oTarget, oItem);
            }
        }
        break;
        case BASE_ITEM_KUKRI:
        {
            if(CreatureSize <= CREATURE_SIZE_MEDIUM && ProfExotic == TRUE)
            {
                CurrentItemDamage = i4;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_KUKRI)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_KUKRI) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_KUKRI) * i2));
                SetPrimaryWeapon(oTarget, oItem);
            }
        }
        break;
        case BASE_ITEM_SHURIKEN:
        {
            // Ranged weapons below
            if(CreatureSize <= CREATURE_SIZE_MEDIUM &&
              (ProfMonk == TRUE || ProfExotic == TRUE))
            {
                CurrentItemDamage = i3;// Set max damage.
                CurrentItemValue += (CurrentItemDamage +
                      (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SHURIKEN)) +
                      (GetHasFeat(FEAT_IMPROVED_CRITICAL_SHURIKEN) * i2) +
                      (GetHasFeat(FEAT_WEAPON_FOCUS_SHURIKEN) * i2));
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
    if(CurrentItemType != BASE_ITEM_WHIP)   // WHIPs are secondary only
    {
        ArrayOfWeapons(AI_WEAPON_PRIMARY, oTarget, oItem, CurrentItemValue);
    }
    // We also set up secondary array for all weapons which can be used well
    // in the off hand.
    // This takes some value off for size of weapon...depending on our size!
    // IE to hit is lower, it is a lower value.
    if(ProfTwoWeapons == TRUE &&
       // 4 = Light flail, 47 = Morningstar - NOT a valid second weapon.
       CurrentItemType != BASE_ITEM_LIGHTFLAIL &&
       CurrentItemType != BASE_ITEM_MORNINGSTAR)
    {
        ArrayOfWeapons(AI_WEAPON_SECONDARY, oTarget, oItem, CurrentItemValue, TRUE);
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
    ArrayOfWeapons(AI_WEAPON_TWO_HANDED, oTarget, oItem, CurrentItemValue);
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
    SetLocalInt(oItem, SETWEP_IS_UNLIMITED, CurrentItemIsUnlimited);
    SetLocalInt(oItem, SETWEP_VALUE, CurrentItemValue);
    SetLocalObject(oTarget, SETWEP_DISTANCE + sNth, oItem);
    SetLocalInt(oTarget, SETWEP_DISTANCE, nNth);
}

void SetAmmoCounters(object oTarget)
{
    switch(CurrentItemType)
    {
        case BASE_ITEM_ARROW:
        {
            HasArrows = TRUE;
            return;
        }
        break;
        case BASE_ITEM_BOLT:
        {
            HasBolts = TRUE;
            return;
        }
        break;
        case BASE_ITEM_BULLET:
        {
            HasBullets = TRUE;
            return;
        }
        break;
    }
}

void SetRangedWeapon(object oTarget)
{
    // Special: We set 2 weapons. The second just states there is a second
    // and so we re-set weapons if we get round to using it.
    int nNth = i1;
    string sNth = IntToString(nNth);
    object oItem = GetLocalObject(oTarget, SETWEP_DISTANCE + sNth);
    int nBase, iHighestValueWeapon, iValue, iUnlimited, iShield,
        iNextHighestValueWeapon, iHighestUnlimited, iAmmoSlot;
    object oHighestItem, oNextHighestItem;

    while(GetIsObjectValid(oItem))
    {
        nBase = GetBaseItemType(oItem);
        iValue = GetLocalInt(oItem, SETWEP_VALUE);
        iUnlimited = GetLocalInt(oItem, SETWEP_IS_UNLIMITED);
        if(nBase == BASE_ITEM_DART || nBase == BASE_ITEM_SHURIKEN ||
           nBase == BASE_ITEM_THROWINGAXE)
        // 31 = Dart, 59 = Shuriken, 63 = Throwing axe
        {
            //iHighestValueWeapon starts as 0, so
            if(iValue > iHighestValueWeapon ||
               iHighestValueWeapon == i0)
            {
                iHighestValueWeapon = iValue;
                oHighestItem = oItem;
                iShield = TRUE;
                // We set right hand, because it is a throwing weapon
                iAmmoSlot = INVENTORY_SLOT_RIGHTHAND;
                iHighestUnlimited = iUnlimited;
            }
            else if(iValue > iNextHighestValueWeapon ||
                    iNextHighestValueWeapon == i0)
            {
                iNextHighestValueWeapon = iValue;
                oNextHighestItem = oItem;
            }
        }
        else if(nBase == BASE_ITEM_HEAVYCROSSBOW ||
                nBase == BASE_ITEM_LIGHTCROSSBOW)// 6 = Heavy, 7 = Light X-bow
        {
            if(HasBolts == TRUE || iUnlimited == TRUE)
            {
                if(iValue > iHighestValueWeapon ||
                   iHighestValueWeapon == i0)
                {
                    iHighestValueWeapon = iValue;
                    oHighestItem = oItem;
                    iAmmoSlot = INVENTORY_SLOT_BOLTS;
                    iShield = FALSE;
                    iHighestUnlimited = iUnlimited;
                }
                else if(iValue > iNextHighestValueWeapon ||
                        iNextHighestValueWeapon == i0)
                {
                    iNextHighestValueWeapon = iValue;
                    oNextHighestItem = oItem;
                }
            }
        }
        else if(nBase == BASE_ITEM_LONGBOW ||
                nBase == BASE_ITEM_SHORTBOW)// 8 = Long, 11 = Short bow
        {
            if(HasArrows == TRUE || iUnlimited == TRUE)
            {
                if(iValue > iHighestValueWeapon ||
                   iHighestValueWeapon == i0)
                {
                    iHighestValueWeapon = iValue;
                    oHighestItem = oItem;
                    iShield = FALSE;
                    iAmmoSlot = INVENTORY_SLOT_ARROWS;
                    iHighestUnlimited = iUnlimited;
                }
                else if(iValue > iNextHighestValueWeapon ||
                        iNextHighestValueWeapon == i0)
                {
                    iNextHighestValueWeapon = iValue;
                    oNextHighestItem = oItem;
                }
            }
        }
        else if(nBase == BASE_ITEM_SLING)// 61 = Sling
        {
            if(HasBullets == TRUE || iUnlimited == TRUE)
            {
                if(iValue > iHighestValueWeapon ||
                   iHighestValueWeapon == i0)
                {
                    iHighestValueWeapon = iValue;
                    oHighestItem = oItem;
                    iShield = TRUE;
                    iAmmoSlot = INVENTORY_SLOT_BULLETS;
                    iHighestUnlimited = iUnlimited;
                }
                else if(iValue > iNextHighestValueWeapon ||
                        iNextHighestValueWeapon == i0)
                {
                    iNextHighestValueWeapon = iValue;
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
        SWFinalAIInteger(oTarget, AI_WEAPON_RANGED_AMMOSLOT, iAmmoSlot);
        if(iHighestUnlimited)
        {
            SWFinalAIInteger(oTarget, AI_WEAPON_RANGED_IS_UNLIMITED, iHighestUnlimited);
        }
        // Can a shield be used with it? Default is 0, we only set non 0 values.
        if(iShield)
        {
            SWFinalAIInteger(oTarget, AI_WEAPON_RANGED_SHIELD, iShield);
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
    SetLocalInt(oItem, SETWEP_VALUE, CurrentItemValue);
    SetLocalObject(oTarget, SETWEP_SHIELD + sNth, oItem);
    SetLocalInt(oTarget, SETWEP_SHIELD, nNth);
}

void SetShield(object oTarget)
{
    int nNth = i1;
    string sNth = IntToString(nNth);
    object oItem = GetLocalObject(oTarget, SETWEP_SHIELD + sNth);
    int iHighestValueShield, iValue, iNextHighestValueShield;
    object oHighestShield, oNextHighestShield;

    while(GetIsObjectValid(oItem))
    {
        iValue = GetLocalInt(oItem, SETWEP_VALUE);
        if(iValue > iHighestValueShield)
        {
            oHighestShield = oItem;
            iHighestValueShield = iValue;
        }
        else if(iValue > iNextHighestValueShield)
        {
            oNextHighestShield = oItem;
            iNextHighestValueShield = iValue;
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
void ArrayOfWeapons(string sArray, object oTarget, object oItem, int iValue, int iSecondary = FALSE)
{
    // Check for if it is secondary.
    // We add some value based on the creature size against weapon size.
    // - We also may take away some.
    int iSetValue = iValue;
    if(iSecondary == TRUE)
    {
        // We take 2 or add 2 for different sizes. Not too much...but enough?
        iSetValue += ((CreatureSize - CurrentItemSize) * i2);
    }
    int iOtherItemsValues, i, iBreak;
    int iMax = GetLocalInt(oTarget, MAXINT_ + sArray);
    string sArrayStore;
    // Special - no max items!
    if(iMax < i1)
    {
        sArrayStore = sArray + s1;
        SetLocalInt(oTarget, sArrayStore, iSetValue);
        SetLocalInt(oTarget, sArrayStore + WEAP_SIZE, CurrentItemSize);
        SetLocalInt(oTarget, sArrayStore + WEAP_DAMAGE, CurrentItemDamage);
        SetLocalObject(oTarget, sArrayStore, oItem);
        iMax++;
        SetLocalInt(oTarget, MAXINT_ + sArray, iMax);
    }
    // Else, we will set it in the array.
    else
    {
        // Loop through the items stored already.
        for(i = i1; (i <= iMax && iBreak != TRUE); i++)
        {
            // Get the value of the item.
            iOtherItemsValues = GetLocalInt(oTarget, sArray + IntToString(i));
            // If imput is greater than stored...move all of them back one.
            if(iValue > iOtherItemsValues)
            {
                // Set weapon size as well.
                sArrayStore = sArray + IntToString(i);
                MoveArrayBackOne(sArray, i, oTarget, iMax);
                SetLocalInt(oTarget, sArrayStore, iSetValue);
                SetLocalInt(oTarget, sArrayStore + WEAP_SIZE, CurrentItemSize);
                SetLocalInt(oTarget, sArrayStore + WEAP_DAMAGE, CurrentItemDamage);
                SetLocalObject(oTarget, sArrayStore, oItem);
                iMax++;
                SetLocalInt(oTarget, MAXINT_ + sArray, iMax);
                iBreak = TRUE;
            }
            // If end, we set to the end :-)
            else if(i == iMax)
            {
                // Set weapon size as well. Add one to i to be at the end.
                sArrayStore = sArray + IntToString(i + i1);
                SetLocalInt(oTarget, sArrayStore, iSetValue);
                SetLocalInt(oTarget, sArrayStore + WEAP_SIZE, CurrentItemSize);
                SetLocalInt(oTarget, sArrayStore + WEAP_DAMAGE, CurrentItemDamage);
                SetLocalObject(oTarget, sArrayStore, oItem);
                iMax++;
                SetLocalInt(oTarget, MAXINT_ + sArray, iMax);
                iBreak = TRUE;
            }
        }
    }
}

void MoveArrayBackOne(string sArray, int iNumberStart, object oTarget, int iMax)
{
    // Get the first item...
    object oItemAtNumber;
    string sCurrentName, sNewName;
    int iItemAtNumberValue, i, iCurrentItemSize, iCurrentItemDamage;
    // Move it from the back, back one, then then next...
    for(i = iMax; i >= iNumberStart; i--)
    {
        // Sets the name up right.
        sCurrentName = sArray + IntToString(i);
        sNewName = sArray + IntToString(i + i1);
        //  Set the things up in the right parts.
        oItemAtNumber = GetLocalObject(oTarget, sCurrentName);
        iItemAtNumberValue = GetLocalInt(oTarget, sCurrentName);
        iCurrentItemSize = GetLocalInt(oTarget, sCurrentName + WEAP_SIZE);
        iCurrentItemDamage = GetLocalInt(oTarget, sCurrentName + WEAP_DAMAGE);
        // To the NEW name - we add one to the i value.
        SetLocalObject(oTarget, sNewName, oItemAtNumber);
        SetLocalInt(oTarget, sNewName, iItemAtNumberValue);
        SetLocalInt(oTarget, sNewName + WEAP_SIZE, iCurrentItemSize);
        SetLocalInt(oTarget, sNewName + WEAP_DAMAGE, iCurrentItemSize);
    }
}
void DeleteDatabase(object oTarget, string sArray)
{
    int iMax = GetLocalInt(oTarget, MAXINT_ + sArray);
    int i;
    string sNewName;
    if(iMax)
    {
        for(i = i1; i <= iMax; i++)
        {
            sNewName = sArray + IntToString(i);
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
    int iMax = GetLocalInt(oTarget, MAXINT_ + sArray);
    int i;
    if(iMax)
    {
        for(i = i1; i <= iMax; i++)
        {
            DeleteLocalInt(oTarget, sArray + IntToString(i));
        }
    }
    // Note: We keep the size...
}

void SWFinalAIObject(object oTarget, string sName, object oObject)
{
    SetLocalObject(oTarget, AI_OBJECT + sName, oObject);
}
void SWFinalAIInteger(object oTarget, string sName, int iInt)
{
    SetLocalInt(oTarget, AI_INTEGER + sName, iInt);
}
void SWDeleteAIObject(object oTarget, string sName)
{
    DeleteLocalObject(oTarget, AI_OBJECT + sName);
}
void SWDeleteAIInteger(object oTarget, string sName)
{
    DeleteLocalInt(oTarget, AI_INTEGER + sName);
}

// reset healing kits only on oTarget.
void ResetHealingKits(object oTarget)
{
    object oItem, oHighestKit;
    int iHealingKitsAmount, iItemValue;
    int iRunningValue = i0; // For kits
    // The inventory
    oItem = GetFirstItemInInventory(oTarget);
    while(GetIsObjectValid(oItem))
    {
        if(GetBaseItemType(oItem) == BASE_ITEM_HEALERSKIT)
        {
            iHealingKitsAmount++;
            iItemValue = GetGoldPieceValue(oItem);
            // Stacked kits be worth what they should be seperatly.
            iItemValue = iItemValue/GetNumStackedItems(oItem);
            if(iItemValue > iRunningValue)
            {
                iRunningValue = iItemValue;
                oHighestKit = oItem;
            }
        }
        oItem = GetNextItemInInventory(oTarget);
    }
    // Need some, any!
    if(iHealingKitsAmount > i0)
    {
        // set healing kits (if any)
        SWFinalAIObject(oTarget, AI_VALID_HEALING_KIT_OBJECT, oHighestKit);
        // Set amount left
        SWFinalAIInteger(oTarget, AI_VALID_HEALING_KITS, iHealingKitsAmount);
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

// Special: Apply EffectCutsceneImmobilize
void AI_SpecialActionApplyItem(object oTarget)
{
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectCutsceneImmobilize(), oTarget);
}
// Special: Remove EffectCutsceneImmobilize
void AI_SpecialActionRemoveItem(object oTarget)
{
    effect eCheck = GetFirstEffect(oTarget);
    while(GetIsEffectValid(eCheck))
    {
        if(GetEffectType(eCheck) == EFFECT_TYPE_CUTSCENEIMMOBILIZE &&
           GetEffectSpellId(eCheck) == iM1) RemoveEffect(oTarget, eCheck);
        eCheck = GetNextEffect(oTarget);
    }
}
// Gets a item talent value
// - iTalent, 1-21.
void AI_SetItemTalentValue(int iTalent)
{
    // We are already EffectCutsceneImmobilized

    // Simply get the best.
    talent tCheck = GetCreatureTalentBest(iTalent, i20);
    int iValue = GetIdFromTalent(tCheck);

    // Set to value.
    SetAIConstant(ITEM_TALENT_VALUE + IntToString(iTalent), iValue);
}

//void main(){ SetWeapons(); }
