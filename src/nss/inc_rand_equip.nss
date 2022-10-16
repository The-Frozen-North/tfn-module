// Note to self: using the pushback methods results in zero-indexed arrays
#include "inc_array"
#include "util_i_math"
#include "x2_inc_itemprop"
#include "nwnx_creature"
#include "nwnx_item"
#include "70_inc_itemprop"
#include "inc_treasure"

// Suggested order:
// Weapons
// Apparel
// Armor

// Doing this means that any dex bonuses from weapons/apparel can be taken into account for AC calcuations


// This is an include full of functions that make randomising humanoids
// hopefully a whole lot less laborious.

// Return the base AC of the best armour type that the creature can sensibly equip, up to a max of nMaxAC.
int GetACOfArmorToEquip(object oCreature, int nMaxAC=8);

// Return a BASE_ITEM_* constant of a "light" weapon, suitable for
// wielding in the offhand without penalty.
// Creatures with more advanced proficiencies will be significantly more likely
// to try to make use of that.
int SelectLightMeleeWeaponType(object oCreature);

// Return a BASE_ITEM_* constant of a ONEHANDED melee weapon, suitable
// for wielding in the mainhand.
// Creatures with more advanced proficiencies will be significantly more likely
// to try to make use of that.
int SelectMainHandMeleeWeaponType(object oCreature);

// Return a BASE_ITEM_* constant of a TWOHANDED melee weapon, suitable
// for wielding in both hands only.
// Creatures with more advanced proficiencies will be significantly more likely
// to try to make use of that.
// if bDoubleSided, only double sided weapons will be considered.
// if !bDoubleSided, double sided weapons will never be considered.
// returns BASE_ITEM_INVALID if nothing suitable was found
int SelectTwoHandedMeleeWeaponType(object oCreature, int bDoubleSided=0);

// Return a BASE_ITEM_* constant of a ranged weapon suitable for oCreature
// Creatures with more advanced proficiencies will be significantly more likely
// to try to make use of that.
// Tries to respect rapid shot/rapid reload.
int SelectRangedWeaponType(object oCreature);

// Returns the resref of a nonmagical weapon (or shield) of the given BASE_ITEM_* constant
// For item types where a mundane version does nothing, returns "".
string GetMundaneWeaponOfType(int nBaseItem);

// Makes a copy of oSourceItem on oCreature and attempts to equip it to nSlot via NWNX.
// The copied item is set undroppable and unpickpocketable.
// Returns the newly created item.
// If there was an item already in the slot, destroys it.
// If the equip of the new item fails, the new item is destroyed.
object CopyAndEquipUndroppableItem(object oCreature, object oSourceItem, int nSlot);

// Return a reference of a random tiered item of the given type
// Factors in equivalents such as BASE_ITEM_BRACER vs BASE_ITEM_GLOVES.
// nUniqueChance is a chance in percent to roll for unique items. If no unique items were found, a nonunique is found again.
// Upon failure, drops down tiers, returning OBJECT_INVALID if nothing was found at t1.
// If the item is useless when mundane (eg a ring), may return OBJECT_INVALID
// Do NOT use for body armour.
object GetTieredItemOfType(int nBaseItem, int nTier, int nUniqueChance=0);

// Return a reference of a random tiered armour of the given base AC
// nUniqueChance is a chance in percent to roll for unique items. If no unique items were found, a nonunique is found again.
// Upon failure, drops down tiers, returning OBJECT_INVALID if nothing was found at t1.
object GetTieredArmorOfType(int nAC, int nTier, int nUniqueChance=0);

// An amalgamation of GetTieredItemOfType and CopyAndEquipUndroppableItem.
// Also sets local int "unique" to 1 on the returned object if it was from a unique chest
// Pass nSlot = -1 to not try equipping the item (useful for backup melees for archers)
// nTries is the number of attempts to find one of these items that can be successfully equipped
object TryEquippingRandomItemOfTier(int nBaseItem, int nTier, int nUniqueChance, object oCreature, int nSlot, int nTries=5, int bCheckSuitability=1);

// Like TryEquippingRandomItemOfTier but without the equipping part.
// Use this for cases like backup melee weapons for ranged creatures
object AddRandomItemOfTierToInventory(int nBaseItem, int nTier, int nUniqueChance, object oCreature);

// An amalgamation of GetTieredArmorOfType and CopyAndEquipUndroppableItem.
// Also sets local int "unique" to 1 on the returned object if it was from a unique chest
// Will equip mundane armor of nAC if searching the chests didn't find anything.
// nTries is the number of attempts to find one of these items that can be successfully equipped
object TryEquippingRandomArmorOfTier(int nAC, int nTier, int nUniqueChance, object oCreature, int nSlot=INVENTORY_SLOT_CHEST, int nTries=10);


// Convenience function that runs TryEquippingRandomItemOfTier for:
// Ring1, Ring2, Head, Hands, Neck, Belt, Feet, Cloak
// In this case, nUniqueChance is the chance of filling each slot, as all of these item types are uniques
void TryEquippingRandomApparelOfTier(int nTier, int nUniqueChance, object oCreature);

// Sets the weighting for a random weapon type on a creature.
// For example, SetRandomEquipWeaponTypeWeight(oCreature, BASE_ITEM_DAGGER, 5);
// Means that daggers (if eligible) will be added to the random pool five times instead of 1
// And so will be much more likely to be selected
// The relative increase depends on the size of the weapon pool, which depends on the creature
// Weapons can be excluded entirely by setting a weight of zero.
void SetRandomEquipWeaponTypeWeight(object oCreature, int nBaseItem, int nWeight);

int IsItemSuitableForCreature(object oCreature, object oItem);


struct RandomWeaponResults
{
    int nMainHand;
    int nOffHand;
    int nBackupMeleeWeapon;
};

// Returns a struct containing BASE_ITEM_* constants for suitable main and offhand items of oCreature.
// The members are BASE_TYPE constants
// nMainHand, nOffHand, nBackupMeleeWeapon
struct RandomWeaponResults RollRandomWeaponTypesForCreature(object oCreature);

const string RAND_EQUIP_GIVE_RANGED = "rand_equip_give_ranged";


const string RAND_EQUIP_TEMP_ARRAY = "rand_equip_temp";

struct CreatureProficiencies
{
    int bMartial;
    int bExotic;
    int bDruid;
    int bElf;
    int bMonk;
    int bRogue;
    int bSimple;
    int bWizard;
};

struct CreatureProficiencies GetCreatureWeaponProficiencies(object oCreature);



//////////////////////////////

struct CreatureProficiencies GetCreatureWeaponProficiencies(object oCreature)
{
    struct CreatureProficiencies cpOut;
    cpOut.bMartial = GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL, oCreature);
    cpOut.bDruid = GetHasFeat(FEAT_WEAPON_PROFICIENCY_DRUID, oCreature);
    cpOut.bExotic = GetHasFeat(FEAT_WEAPON_PROFICIENCY_EXOTIC, oCreature);
    cpOut.bElf = GetHasFeat(FEAT_WEAPON_PROFICIENCY_ELF, oCreature);
    cpOut.bMonk = GetHasFeat(FEAT_WEAPON_PROFICIENCY_MONK, oCreature);
    cpOut.bRogue = GetHasFeat(FEAT_WEAPON_PROFICIENCY_ROGUE, oCreature);
    cpOut.bSimple = GetHasFeat(FEAT_WEAPON_PROFICIENCY_SIMPLE, oCreature);
    cpOut.bWizard = GetHasFeat(FEAT_WEAPON_PROFICIENCY_WIZARD, oCreature);
    return cpOut;
}

// 38 total, these are weapon types enumerated to 0-37 inclusive
const int RAND_EQUIP_NUM_WEAPONTYPES = 38;

int _GetWeaponTypeByIndex(int nIndex)
{
    // This is a bit of a hack, and assumes normal baseitems.2da
    if (nIndex <= 13)
    {
        // 14: smallshield is the first nonweapon item
        return nIndex;
    }
    if (nIndex == 14)
    {
        return BASE_ITEM_GREATAXE;
    }
    if (nIndex == 15)
    {
        return BASE_ITEM_DAGGER;
    }
    if (nIndex == 16)
    {
        return BASE_ITEM_CLUB;
    }
    if (nIndex >= 17 && nIndex <= 19)
    {
        // Dart (31) to doubleaxe (33)
        return (nIndex + 14);
    }
    if (nIndex == 20)
    {
        return BASE_ITEM_HEAVYFLAIL;
    }
    if (nIndex == 21)
    {
        return BASE_ITEM_LIGHTHAMMER;
    }
    if (nIndex == 22)
    {
        return BASE_ITEM_HANDAXE;
    }
    if (nIndex >= 23 && nIndex <= 25)
    {
        // Kama (40) to kukri (42)
        return (nIndex + 17);
    }
    if (nIndex == 26)
    {
        return BASE_ITEM_MORNINGSTAR;
    }
    if (nIndex == 27)
    {
        return BASE_ITEM_QUARTERSTAFF;
    }
    if (nIndex == 28)
    {
        return BASE_ITEM_RAPIER;
    }
    if (nIndex == 29)
    {
        return BASE_ITEM_SCIMITAR;
    }
    if (nIndex == 30)
    {
        return BASE_ITEM_SCYTHE;
    }
    if (nIndex >= 31 && nIndex <= 34)
    {
        // Spear (58) to sling (61)
        return (nIndex + 27);
    }
    if (nIndex == 35)
    {
        return BASE_ITEM_TRIDENT;
    }
    if (nIndex == 36)
    {
        return BASE_ITEM_DWARVENWARAXE;
    }
    if (nIndex == 37)
    {
        return BASE_ITEM_WHIP;
    }
    return BASE_ITEM_INVALID;
}

int _GetWeaponSize(int nBaseItem)
{
    return StringToInt(Get2DAString("baseitems", "WeaponSize", nBaseItem));
}


// I don't know how fast 2da lookups are these days, so much of this is hardcoded
// TFN is meant to be mostly vanilla anyways...

// Internal function, returns how "good" a weapon type is
// The picker is heavily biased towards bigger numbers
// Essentially, setting "high proficiency required" weapons with bigger numbers
// makes them show up most of the time on the few creatures able to use them
int _GetScoreForWeaponType(int nBaseItem, object oCreature)
{
    // For now, this just makes diagonal stripes across a table of proficiencies vs sizes
    // I'm assuming 2h weapons get a -1 to their scores due to being 2h
    // or anything with exotic would be virtually guaranteed to have a diremace/scythe/2bsword etc
    int nScore = 0;
    int nWeaponSize = _GetWeaponSize(nBaseItem);
    int nCreatureSize = GetCreatureSize(oCreature);
    int nSizeDiff = nWeaponSize - nCreatureSize;
    if (nSizeDiff > 1)
    {
        return -1;
    }
    if (nSizeDiff == 1)
    {
        nScore -= 1;
    }
    switch (nBaseItem)
    {
        case BASE_ITEM_DAGGER:
        case BASE_ITEM_DART:
        {
            nScore += 1;
            break;
        }
        case BASE_ITEM_LIGHTCROSSBOW:
        case BASE_ITEM_LIGHTMACE:
        case BASE_ITEM_SICKLE:
        case BASE_ITEM_SLING:
        {
            nScore += 2;
            break;
        }
        case BASE_ITEM_KUKRI:
        case BASE_ITEM_SHURIKEN:
        case BASE_ITEM_HANDAXE:
        case BASE_ITEM_LIGHTHAMMER:
        case BASE_ITEM_SHORTSWORD:
        case BASE_ITEM_THROWINGAXE:
        case BASE_ITEM_CLUB:
        case BASE_ITEM_HEAVYCROSSBOW:
        case BASE_ITEM_MORNINGSTAR:
        {
            nScore += 3;
            break;
        }
        case BASE_ITEM_KAMA:
        case BASE_ITEM_WHIP:
        case BASE_ITEM_BATTLEAXE:
        case BASE_ITEM_LIGHTFLAIL:
        case BASE_ITEM_LONGSWORD:
        case BASE_ITEM_RAPIER:
        case BASE_ITEM_SCIMITAR:
        case BASE_ITEM_SHORTBOW:
        case BASE_ITEM_WARHAMMER:
        case BASE_ITEM_SHORTSPEAR:
        case BASE_ITEM_QUARTERSTAFF:
        {
            nScore += 4;
            break;
        }
        case BASE_ITEM_BASTARDSWORD:
        case BASE_ITEM_DWARVENWARAXE:
        case BASE_ITEM_KATANA:
        case BASE_ITEM_GREATAXE:
        case BASE_ITEM_GREATSWORD:
        case BASE_ITEM_HALBERD:
        case BASE_ITEM_HEAVYFLAIL:
        case BASE_ITEM_LONGBOW:
        case BASE_ITEM_TRIDENT:
        {
            nScore += 5;
            break;
        }
        case BASE_ITEM_DIREMACE:
        case BASE_ITEM_DOUBLEAXE:
        case BASE_ITEM_SCYTHE:
        case BASE_ITEM_TWOBLADEDSWORD:
        {
            nScore += 6;
            break;
        }
    }
    return nScore;
}

int _CanUseWeaponTypeWithProficiencies(struct CreatureProficiencies cpCreature, int nBaseItem)
{
    if (cpCreature.bSimple)
    {
        if (nBaseItem == BASE_ITEM_DAGGER || nBaseItem == BASE_ITEM_DART ||
            nBaseItem == BASE_ITEM_LIGHTCROSSBOW || nBaseItem == BASE_ITEM_LIGHTMACE ||
            nBaseItem == BASE_ITEM_SICKLE || nBaseItem == BASE_ITEM_SLING ||
            nBaseItem == BASE_ITEM_CLUB || nBaseItem == BASE_ITEM_HEAVYCROSSBOW ||
            nBaseItem == BASE_ITEM_MORNINGSTAR || nBaseItem == BASE_ITEM_QUARTERSTAFF ||
            nBaseItem == BASE_ITEM_SHORTSPEAR)
        {
            return 1;
        }
    }
    if (cpCreature.bMartial)
    {
        if (nBaseItem == BASE_ITEM_HANDAXE || nBaseItem == BASE_ITEM_LIGHTHAMMER ||
            nBaseItem == BASE_ITEM_SHORTSWORD || nBaseItem == BASE_ITEM_THROWINGAXE ||
            nBaseItem == BASE_ITEM_LONGSWORD || nBaseItem == BASE_ITEM_RAPIER ||
            nBaseItem == BASE_ITEM_SCIMITAR || nBaseItem == BASE_ITEM_SHORTBOW ||
            nBaseItem == BASE_ITEM_WARHAMMER || nBaseItem == BASE_ITEM_GREATAXE ||
            nBaseItem == BASE_ITEM_GREATSWORD || nBaseItem == BASE_ITEM_HALBERD ||
            nBaseItem == BASE_ITEM_HEAVYFLAIL || nBaseItem == BASE_ITEM_LONGBOW ||
            nBaseItem == BASE_ITEM_TRIDENT)
        {
            return 1;
        }
    }
    if (cpCreature.bExotic)
    {
        if (nBaseItem == BASE_ITEM_KUKRI || nBaseItem == BASE_ITEM_SHURIKEN ||
            nBaseItem == BASE_ITEM_KAMA || nBaseItem == BASE_ITEM_WHIP ||
            nBaseItem == BASE_ITEM_BASTARDSWORD || nBaseItem == BASE_ITEM_DWARVENWARAXE ||
            nBaseItem == BASE_ITEM_KATANA || nBaseItem == BASE_ITEM_DIREMACE ||
            nBaseItem == BASE_ITEM_DOUBLEAXE || nBaseItem == BASE_ITEM_SCYTHE ||
            nBaseItem == BASE_ITEM_TWOBLADEDSWORD)
        {
            return 1;
        }
    }
    if (cpCreature.bDruid)
    {
        if (nBaseItem == BASE_ITEM_CLUB || nBaseItem == BASE_ITEM_DAGGER ||
            nBaseItem == BASE_ITEM_DART || nBaseItem == BASE_ITEM_QUARTERSTAFF ||
            nBaseItem == BASE_ITEM_SCIMITAR || nBaseItem == BASE_ITEM_SICKLE ||
            nBaseItem == BASE_ITEM_SHORTSPEAR || nBaseItem == BASE_ITEM_SLING)
        {
            return 1;
        }
    }
    if (cpCreature.bElf)
    {
        if (nBaseItem == BASE_ITEM_LONGSWORD || nBaseItem == BASE_ITEM_RAPIER ||
            nBaseItem == BASE_ITEM_LONGBOW || nBaseItem == BASE_ITEM_SHORTBOW)
        {
            return 1;
        }
    }
    if (cpCreature.bMonk)
    {
        if (nBaseItem == BASE_ITEM_CLUB || nBaseItem == BASE_ITEM_DAGGER ||
            nBaseItem == BASE_ITEM_HANDAXE || nBaseItem == BASE_ITEM_QUARTERSTAFF ||
            nBaseItem == BASE_ITEM_LIGHTCROSSBOW || nBaseItem == BASE_ITEM_HEAVYCROSSBOW ||
            nBaseItem == BASE_ITEM_SHURIKEN || nBaseItem == BASE_ITEM_SLING ||
            nBaseItem == BASE_ITEM_KAMA)
        {
            return 1;
        }
    }
    if (cpCreature.bRogue)
    {
        if (nBaseItem == BASE_ITEM_DAGGER || nBaseItem == BASE_ITEM_DART ||
            nBaseItem == BASE_ITEM_LIGHTCROSSBOW || nBaseItem == BASE_ITEM_LIGHTMACE ||
            nBaseItem == BASE_ITEM_HANDAXE || nBaseItem == BASE_ITEM_SLING ||
            nBaseItem == BASE_ITEM_CLUB || nBaseItem == BASE_ITEM_HEAVYCROSSBOW ||
            nBaseItem == BASE_ITEM_MORNINGSTAR || nBaseItem == BASE_ITEM_QUARTERSTAFF ||
            nBaseItem == BASE_ITEM_RAPIER || nBaseItem == BASE_ITEM_SHORTSWORD ||
            nBaseItem == BASE_ITEM_SHORTBOW)
        {
            return 1;
        }
    }
    if (cpCreature.bWizard)
    {
        if (nBaseItem == BASE_ITEM_CLUB || nBaseItem == BASE_ITEM_DAGGER ||
            nBaseItem == BASE_ITEM_QUARTERSTAFF ||
            nBaseItem == BASE_ITEM_LIGHTCROSSBOW || nBaseItem == BASE_ITEM_HEAVYCROSSBOW)
        {
            return 1;
        }
    }
    return 0;
}


int _GetRandomEquipWeaponTypeWeight(object oCreature, int nBaseItem)
{
    // Saving (weight - 1) is deliberate
    // We add 1 when retrieving these, because an unset var in GetLocalInt returns 0 -> becomes 1, normal weighting
    return (1 + GetLocalInt(oCreature, "rand_equip_weapon_weight_" + IntToString(nBaseItem)));
}

int _IsWeaponTypeFinessable(int nBaseItem)
{
    if (nBaseItem == BASE_ITEM_DAGGER || nBaseItem == BASE_ITEM_HANDAXE ||
        nBaseItem == BASE_ITEM_KAMA || nBaseItem == BASE_ITEM_KUKRI ||
        nBaseItem == BASE_ITEM_LIGHTHAMMER || nBaseItem == BASE_ITEM_LIGHTMACE ||
        nBaseItem == BASE_ITEM_RAPIER || nBaseItem == BASE_ITEM_SHORTSWORD ||
        nBaseItem == BASE_ITEM_SICKLE || nBaseItem == BASE_ITEM_WHIP ||
        nBaseItem == BASE_ITEM_CPIERCWEAPON || nBaseItem == BASE_ITEM_CSLASHWEAPON ||
        nBaseItem == BASE_ITEM_CBLUDGWEAPON || nBaseItem == BASE_ITEM_CSLSHPRCWEAP)
    {
        // Also: unarmed strike
        return 1;
    }
    return 0;
}

int _IsWeaponTypeRanged(int nBaseItem)
{
    if (nBaseItem == BASE_ITEM_LIGHTCROSSBOW || nBaseItem == BASE_ITEM_HEAVYCROSSBOW ||
        nBaseItem == BASE_ITEM_SHORTBOW || nBaseItem == BASE_ITEM_LONGBOW ||
        nBaseItem == BASE_ITEM_SLING || nBaseItem == BASE_ITEM_DART ||
        nBaseItem == BASE_ITEM_THROWINGAXE || nBaseItem == BASE_ITEM_SHURIKEN)
        {
            return 1;
        }
    return 0;
}

int _IsWeaponTypeDoubleSided(int nBaseItem)
{
    if (nBaseItem == BASE_ITEM_DIREMACE || nBaseItem == BASE_ITEM_DOUBLEAXE ||
        nBaseItem == BASE_ITEM_TWOBLADEDSWORD)
    {
        return 1;
    }
    return 0;
}

int _SelectFromRandEquipTempArray(int nMaxScore, object oCreature)
{
    Array_Shuffle(RAND_EQUIP_TEMP_ARRAY, GetModule());
    int nLength = Array_Size(RAND_EQUIP_TEMP_ARRAY, GetModule());
    int i;
    int j;
    int bAllowed;
    int nBaseItem;
    for (i=0; i<nLength; i++)
    {
        bAllowed = 1;
        nBaseItem = Array_At_Int(RAND_EQUIP_TEMP_ARRAY, i, GetModule());
        int nScoreDiff = nMaxScore - _GetScoreForWeaponType(nBaseItem, oCreature);
        if (nScoreDiff > 0)
        {
            for (j=0; j<nScoreDiff; j++)
            {
                if (Random(100) < 80)
                {
                    bAllowed = 0;
                    break;
                }
            }
        }
        if (!bAllowed)
        {
          continue;
        }
        return nBaseItem;
    }
    if (nLength == 0)
    {
        return BASE_ITEM_INVALID;
    }
    return Array_At_Int(RAND_EQUIP_TEMP_ARRAY, 0, GetModule());
}


int SelectLightMeleeWeaponType(object oCreature)
{
    if (!GetIsObjectValid(oCreature))
    {
        return BASE_ITEM_INVALID;
    }
    int nCreatureSize = GetCreatureSize(oCreature);
    struct CreatureProficiencies cpProfs = GetCreatureWeaponProficiencies(oCreature);
    int bFinesse = 0;
    if (GetHasFeat(FEAT_WEAPON_FINESSE, oCreature) &&
        GetAbilityModifier(ABILITY_DEXTERITY, oCreature) > GetAbilityModifier(ABILITY_STRENGTH, oCreature))
    {
        bFinesse = 1;
    }
    Array_Clear(RAND_EQUIP_TEMP_ARRAY, GetModule());
    int nIndex = 0;
    int nMaxScore = 0;
    int nBaseItem;
    for (nIndex = 0; nIndex < RAND_EQUIP_NUM_WEAPONTYPES; nIndex++)
    {
        nBaseItem = _GetWeaponTypeByIndex(nIndex);
        if (_CanUseWeaponTypeWithProficiencies(cpProfs, nBaseItem) && !_IsWeaponTypeRanged(nBaseItem))
        {
            if (!bFinesse || _IsWeaponTypeFinessable(nBaseItem))
            {
                int nWeaponSize = _GetWeaponSize(nBaseItem);
                // Light: wpn size is 1+ smaller than creature
                if (nCreatureSize - nWeaponSize > 0)
                {
                    // Whips, morningstars, light flails cannot be offhand weapons
                    if (nBaseItem != BASE_ITEM_WHIP && nBaseItem != BASE_ITEM_MORNINGSTAR && nBaseItem != BASE_ITEM_LIGHTFLAIL)
                    {
                        nMaxScore = max(nMaxScore, _GetScoreForWeaponType(nBaseItem, oCreature));
                        int i;
                        int nWeight = _GetRandomEquipWeaponTypeWeight(oCreature, nBaseItem);
                        for (i=0; i<nWeight; i++)
                        {
                            Array_PushBack_Int(RAND_EQUIP_TEMP_ARRAY, nBaseItem, GetModule());
                        }
                    }
                }
            }
        }
    }
    return _SelectFromRandEquipTempArray(nMaxScore, oCreature);
}

int SelectMainHandMeleeWeaponType(object oCreature)
{
    if (!GetIsObjectValid(oCreature))
    {
        return BASE_ITEM_INVALID;
    }
    int nCreatureSize = GetCreatureSize(oCreature);
    struct CreatureProficiencies cpProfs = GetCreatureWeaponProficiencies(oCreature);
    int bFinesse = 0;
    if (GetHasFeat(FEAT_WEAPON_FINESSE, oCreature) &&
        GetAbilityModifier(ABILITY_DEXTERITY, oCreature) > GetAbilityModifier(ABILITY_STRENGTH, oCreature))
    {
        bFinesse = 1;
    }
    Array_Clear(RAND_EQUIP_TEMP_ARRAY, GetModule());
    int nIndex = 0;
    int nMaxScore = 0;
    int nBaseItem;
    for (nIndex = 0; nIndex < RAND_EQUIP_NUM_WEAPONTYPES; nIndex++)
    {
        nBaseItem = _GetWeaponTypeByIndex(nIndex);
        if (_CanUseWeaponTypeWithProficiencies(cpProfs, nBaseItem) && !_IsWeaponTypeRanged(nBaseItem))
        {
            if (!bFinesse || _IsWeaponTypeFinessable(nBaseItem))
            {
                int nWeaponSize = _GetWeaponSize(nBaseItem);
                // Onehanded: weapon can't be bigger than creature
                if (nCreatureSize - nWeaponSize >= 0)
                {
                    nMaxScore = max(nMaxScore, _GetScoreForWeaponType(nBaseItem, oCreature));
                    int i;
                    int nWeight = _GetRandomEquipWeaponTypeWeight(oCreature, nBaseItem);
                    for (i=0; i<nWeight; i++)
                    {
                        Array_PushBack_Int(RAND_EQUIP_TEMP_ARRAY, nBaseItem, GetModule());
                    }
                }
            }
        }
    }
    return _SelectFromRandEquipTempArray(nMaxScore, oCreature);
}

int SelectTwoHandedMeleeWeaponType(object oCreature, int bDoubleSided=0)
{
    if (!GetIsObjectValid(oCreature))
    {
        return BASE_ITEM_INVALID;
    }
    int nCreatureSize = GetCreatureSize(oCreature);
    struct CreatureProficiencies cpProfs = GetCreatureWeaponProficiencies(oCreature);
    Array_Clear(RAND_EQUIP_TEMP_ARRAY, GetModule());
    int nIndex = 0;
    int nMaxScore = 0;
    int nBaseItem;
    for (nIndex = 0; nIndex < RAND_EQUIP_NUM_WEAPONTYPES; nIndex++)
    {
        nBaseItem = _GetWeaponTypeByIndex(nIndex);
        if (_CanUseWeaponTypeWithProficiencies(cpProfs, nBaseItem) && !_IsWeaponTypeRanged(nBaseItem))
        {
            if (!bDoubleSided ^ _IsWeaponTypeDoubleSided(nBaseItem))
            {
                int nWeaponSize = _GetWeaponSize(nBaseItem);
                // Twohanded: weapon must be exactly 1 bigger than creature
                if (nCreatureSize - nWeaponSize == -1)
                {
                    nMaxScore = max(nMaxScore, _GetScoreForWeaponType(nBaseItem, oCreature));
                    int i;
                    int nWeight = _GetRandomEquipWeaponTypeWeight(oCreature, nBaseItem);
                    for (i=0; i<nWeight; i++)
                    {
                        Array_PushBack_Int(RAND_EQUIP_TEMP_ARRAY, nBaseItem, GetModule());
                    }
                }
            }
        }
    }
    return _SelectFromRandEquipTempArray(nMaxScore, oCreature);
}

int SelectRangedWeaponType(object oCreature)
{
    if (!GetIsObjectValid(oCreature))
    {
        return BASE_ITEM_INVALID;
    }
    int bRapidShot = GetHasFeat(FEAT_RAPID_SHOT, oCreature);
    int bRapidReload = GetHasFeat(FEAT_RAPID_RELOAD, oCreature);
    int nCreatureSize = GetCreatureSize(oCreature);
    struct CreatureProficiencies cpProfs = GetCreatureWeaponProficiencies(oCreature);
    Array_Clear(RAND_EQUIP_TEMP_ARRAY, GetModule());
    int nIndex = 0;
    int nMaxScore = 0;
    int nBaseItem;
    for (nIndex = 0; nIndex < RAND_EQUIP_NUM_WEAPONTYPES; nIndex++)
    {
        nBaseItem = _GetWeaponTypeByIndex(nIndex);
        if (_CanUseWeaponTypeWithProficiencies(cpProfs, nBaseItem) && _IsWeaponTypeRanged(nBaseItem))
        {
            int nWeaponSize = _GetWeaponSize(nBaseItem);
            // Size restriction, no giving longbows to halflings
            if (nCreatureSize - nWeaponSize >= -1)
            {
                // Arcane Archer only works on bows
                if (GetLevelByClass(CLASS_TYPE_ARCANE_ARCHER, oCreature))
                {
                    if (nBaseItem != BASE_ITEM_LONGBOW && nBaseItem != BASE_ITEM_SHORTBOW)
                    {
                        continue;
                    }
                }
                // Rapid shot/reload: if you have exactly one of these two feats, only try to get that kind of weapon
                else if (bRapidShot ^ bRapidReload)
                {
                    if (bRapidShot && (nBaseItem == BASE_ITEM_LIGHTCROSSBOW || nBaseItem == BASE_ITEM_HEAVYCROSSBOW))
                    {
                        continue;
                    }
                    if (bRapidReload && !(nBaseItem == BASE_ITEM_LIGHTCROSSBOW || nBaseItem == BASE_ITEM_HEAVYCROSSBOW))
                    {
                        continue;
                    }
                }
                nMaxScore = max(nMaxScore, _GetScoreForWeaponType(nBaseItem, oCreature));
                int i;
                int nWeight = _GetRandomEquipWeaponTypeWeight(oCreature, nBaseItem);
                for (i=0; i<nWeight; i++)
                {
                    Array_PushBack_Int(RAND_EQUIP_TEMP_ARRAY, nBaseItem, GetModule());
                }
            }
        }
    }
    return _SelectFromRandEquipTempArray(nMaxScore, oCreature);
}

//struct RandomWeaponResults
//{
//    int nMainHand;
//    int nOffHand;
//    int nBackupMeleeWeapon;
//};

int _IsArmorCheckPenaltyAConcern(object oCreature)
{
    // hide, move silently, parry, pick pocket, set trap, and tumble
    if (!GetLocalInt(oCreature, "no_stealth") && GetSkillRank(SKILL_HIDE, oCreature, TRUE) > 0)
    {
        return 1;
    }
    return 0;
}

// Returns a struct containing BASE_ITEM_* constants for suitable main and offhand items of oCreature.
struct RandomWeaponResults RollRandomWeaponTypesForCreature(object oCreature)
{
    struct RandomWeaponResults rwrOut;
    rwrOut.nMainHand = BASE_ITEM_INVALID;
    rwrOut.nOffHand = BASE_ITEM_INVALID;
    rwrOut.nBackupMeleeWeapon = BASE_ITEM_INVALID;
    // Do we even WANT weapons?
    
    // Give ranged and a random one handed backup melee weapon if something signalled to
    int bGiveRanged = GetLocalInt(oCreature, RAND_EQUIP_GIVE_RANGED);
    
    // Melee: figure out what we want (one handed + shield, two weapons, two handers)
    int bShieldProficiency = GetHasFeat(FEAT_SHIELD_PROFICIENCY, oCreature);
    int bDualWield = 0;
    int bTwoHanded = 0;
    int bShield = 0;
    // Dual wielding decision making:
    // 374 = ranger dual-wield feat (seemingly missing constant)
    // At low HD, you might not necessarily have ambidexterity if not ranger
    // and going from 1APR to 2APR at -2/-6 MIGHT be worth it... sometimes
    if (GetHasFeat(FEAT_IMPROVED_TWO_WEAPON_FIGHTING, oCreature) ||
        GetHasFeat(374, oCreature) ||
        (GetHasFeat(FEAT_TWO_WEAPON_FIGHTING, oCreature) &&
        (GetHitDice(oCreature) <= 4 || GetHasFeat(FEAT_AMBIDEXTERITY, oCreature))))
    {
        bDualWield = 1;
    }
    
    if (GetLevelByClass(CLASS_TYPE_MONK, oCreature) > 0)
    {
        if (bDualWield && !bGiveRanged)
        {
            rwrOut.nMainHand = BASE_ITEM_KAMA;
            rwrOut.nOffHand = BASE_ITEM_KAMA;
            return rwrOut;
        }
        int bNoFists = 1;
        if (GetHitDice(oCreature) * 3 >= GetLevelByClass(CLASS_TYPE_MONK, oCreature) * 2)
        {
            bNoFists = 0;
        }
        if (bGiveRanged || Random(100) < 66 || bNoFists)
        {
            if (bGiveRanged)
            {
                rwrOut.nMainHand = BASE_ITEM_SHURIKEN;
                rwrOut.nBackupMeleeWeapon = d2() == 1 ? BASE_ITEM_QUARTERSTAFF : BASE_ITEM_KAMA;
            }
            else
            {
                rwrOut.nMainHand = d2() == 1 ? BASE_ITEM_QUARTERSTAFF : BASE_ITEM_KAMA;
            }
            
            return rwrOut;
        }
        // Otherwise, punchy punchy time
        return rwrOut;
    }

    // If the creature has creatureweapons, don't give it normal stuff
    int nSlot;
    for (nSlot = INVENTORY_SLOT_CWEAPON_L; nSlot <= INVENTORY_SLOT_CWEAPON_B; nSlot++)
    {
        if (GetIsObjectValid(GetItemInSlot(nSlot, oCreature)))
        {
            return rwrOut;
        }
    }
    
    if (bGiveRanged)
    {
        rwrOut.nMainHand = SelectRangedWeaponType(oCreature);
        rwrOut.nBackupMeleeWeapon = SelectMainHandMeleeWeaponType(oCreature);
        return rwrOut;
    }


    if (!(bDualWield) && !(bShieldProficiency))
    {
        // It seems silly to go with offhand empty.
        // I'm not sure there's anything in vanilla that gives you benefit for doing so
        bTwoHanded = 1;
    }
    else if (!bDualWield)
    {
        if (bShieldProficiency && Random(100) < 50)
        {
            bShield = 1;
        }
        else
        {
            bTwoHanded = 1;
        }
    }

    if (bTwoHanded)
    {
        rwrOut.nMainHand = SelectTwoHandedMeleeWeaponType(oCreature);
        if (rwrOut.nMainHand == BASE_ITEM_INVALID)
        {
            bTwoHanded = 0;
            bShield = 1;
        }
        else
        {
            return rwrOut;
        }
    }

    if (bDualWield)
    {
        // Attempt a double sided weapon, most of the time this will fail
        if (Random(100) < 50)
        {
            rwrOut.nMainHand = SelectTwoHandedMeleeWeaponType(oCreature, 1);
            if (rwrOut.nMainHand != BASE_ITEM_INVALID)
            {
                return rwrOut;
            }
        }
        rwrOut.nMainHand = SelectMainHandMeleeWeaponType(oCreature);
        rwrOut.nOffHand = SelectLightMeleeWeaponType(oCreature);
        return rwrOut;
    }

    if (bShield)
    {
        rwrOut.nMainHand = SelectMainHandMeleeWeaponType(oCreature);
        if (!_IsArmorCheckPenaltyAConcern(oCreature) && bShieldProficiency)
        {
            if (GetAbilityScore(oCreature, ABILITY_STRENGTH) > 14 && GetCreatureSize(oCreature) > CREATURE_SIZE_SMALL)
            {
                rwrOut.nOffHand = BASE_ITEM_TOWERSHIELD;
                if (Random(100) < 50)
                {
                    rwrOut.nOffHand = BASE_ITEM_LARGESHIELD;
                }
            }
            else
            {
                rwrOut.nOffHand = BASE_ITEM_LARGESHIELD;
                if (Random(100) < 50)
                {
                    rwrOut.nOffHand = BASE_ITEM_SMALLSHIELD;
                }
            }
        }
    }
    return rwrOut;
}

string GetMundaneWeaponOfType(int nBaseItem)
{
    string sOut = "";

    switch (nBaseItem)
    {
       case BASE_ITEM_SMALLSHIELD: { sOut = "nw_ashsw001"; break; } 
       case BASE_ITEM_HELMET: { sOut = "nw_arhe006"; break; }
       case BASE_ITEM_LARGESHIELD: { sOut = "nw_ashlw001"; break; }
       case BASE_ITEM_TOWERSHIELD: { sOut = "nw_ashto001"; break; }
       case BASE_ITEM_BASTARDSWORD: { sOut = "nw_wswbs001"; break; }
       case BASE_ITEM_BATTLEAXE: { sOut = "nw_waxbt001"; break; }
       case BASE_ITEM_CLUB: { sOut = "nw_wblcl001"; break; }
       case BASE_ITEM_DAGGER: { sOut = "nw_wswdg001"; break; }
       case BASE_ITEM_LONGSWORD: { sOut = "nw_wswls001"; break; }
       case BASE_ITEM_SHORTSWORD: { sOut = "nw_wswss001"; break; }
       case BASE_ITEM_WARHAMMER: { sOut = "nw_wblhw001"; break; }
       case BASE_ITEM_LIGHTMACE: { sOut = "nw_wblml001"; break; }
       case BASE_ITEM_HANDAXE: { sOut = "nw_waxhn001"; break; }
       case BASE_ITEM_QUARTERSTAFF: { sOut = "nw_wdbqs001"; break; }
       case BASE_ITEM_LONGBOW: { sOut = "nw_wbwln001"; break; }
       case BASE_ITEM_SHORTBOW: { sOut = "nw_wbwsh001"; break; }
       case BASE_ITEM_LIGHTFLAIL: { sOut = "nw_wblfl001"; break; }
       case BASE_ITEM_LIGHTHAMMER: { sOut = "nw_wblhl001"; break; }
       case BASE_ITEM_HALBERD: { sOut = "nw_wplhb001"; break; }
       case BASE_ITEM_SHORTSPEAR: { sOut = "nw_wplss001"; break; }
       case BASE_ITEM_GREATSWORD: { sOut = "nw_wswgs001"; break; }
       case BASE_ITEM_GREATAXE: { sOut = "nw_waxgr001"; break; }
       case BASE_ITEM_HEAVYFLAIL: { sOut = "nw_wblfh001"; break; }
       case BASE_ITEM_DWARVENWARAXE: { sOut = "x2_wdwraxe00"; break; }
       case BASE_ITEM_MORNINGSTAR: { sOut = "nw_wblms001"; break; }
       case BASE_ITEM_HEAVYCROSSBOW: { sOut = "nw_wbwxh001"; break; }
       case BASE_ITEM_LIGHTCROSSBOW: { sOut = "nw_wbwxl001"; break; }
       case BASE_ITEM_DIREMACE: { sOut = "nw_wdbma001"; break; }
       case BASE_ITEM_DOUBLEAXE: { sOut = "nw_wdbax001"; break; }
       case BASE_ITEM_RAPIER: { sOut = "nw_wswrp001"; break; }
       case BASE_ITEM_SCIMITAR: { sOut = "nw_wswsc001"; break; }
       case BASE_ITEM_KATANA: { sOut = "nw_wswka001"; break; }
       case BASE_ITEM_KAMA: { sOut = "nw_wspka001"; break; }
       case BASE_ITEM_SCYTHE: { sOut = "nw_wplsc001"; break; }
       case BASE_ITEM_TWOBLADEDSWORD: { sOut = "nw_wdbsw001"; break; }
       case BASE_ITEM_WHIP: { sOut = "x2_it_wpwhip"; break; }
       case BASE_ITEM_TRIDENT: { sOut = "nw_wpltr001"; break; }
       case BASE_ITEM_KUKRI: { sOut = "nw_wspku001"; break; }
       case BASE_ITEM_SICKLE: { sOut = "nw_wspsc001"; break; }
       case BASE_ITEM_SLING: { sOut = "nw_wbwsl001"; break; }
    }
    return sOut;
}

string GetMundaneArmorOfAC(int nAC)
{
    string sOut = "";
    int nRoll;
    switch (nAC)
    {
        case 0:
        {
            nRoll = Random(3);
            if (nRoll == 0) { sOut = "nw_cloth022"; }
            else if (nRoll == 1) { sOut = "nw_cloth006"; }
            else if (nRoll == 2) { sOut = "nw_cloth001"; }
            break;
        }
        case 1: { sOut = "nw_aarcl009"; break; }
        case 2: { sOut = "nw_aarcl001"; break; }
        case 3:
        {
            nRoll = Random(2);
            if (nRoll == 0) { sOut = "nw_aarcl002"; }
            else { sOut = "nw_aarcl008"; }
            break;
        }
        case 4:
        {
            nRoll = Random(2);
            if (nRoll == 0) { sOut = "nw_aarcl012"; }
            else { sOut = "nw_aarcl003"; }
            break;
        } 
        case 5:
        {
            nRoll = Random(2);
            if (nRoll == 0) { sOut = "nw_aarcl010"; }
            else { sOut = "nw_aarcl004"; }
            break;
        } 
        case 6:
        {
            nRoll = Random(2);
            if (nRoll == 0) { sOut = "nw_aarcl011"; }
            else { sOut = "nw_aarcl005"; }
            break;
        }
        case 7: { sOut = "nw_aarcl006"; break; }
        case 8: { sOut = "nw_aarcl007"; break; }
    }
    //WriteTimestampedLogEntry("Mundane base AC " + IntToString(nAC) + " = " + sOut);
    return sOut;
}

object _GetRandomItemFromChest(object oChest)
{
    int nRandom = Random(StringToInt(GetDescription(oChest)));
    object oItem = GetFirstItemInInventory(oChest);
    while (nRandom)
    {
        nRandom--;
        oItem = GetNextItemInInventory(oChest);
    }
    // Update scale
    InitializeItem(oItem);
    return (oItem);
}

object GetTieredItemOfType(int nBaseItem, int nTier, int nUniqueChance=0)
{
    if (nBaseItem == BASE_ITEM_BRACER)
    {
        nBaseItem = BASE_ITEM_GLOVES;
    }
    int bTryUnique = Random(100) < nUniqueChance;
    string sChestName = "_BaseItem" + IntToString(nBaseItem) + "T" + IntToString(nTier);
    object oChest;
    object oOut;
    int i;
    for (i=0; i<2; i++)
    {
        if (i == 0 && !bTryUnique)
        {
            continue;
        }
        if (i == 1)
        {
            sChestName += "NonUnique";
        }
        oChest = GetObjectByTag(sChestName);
        oOut = _GetRandomItemFromChest(oChest);
        if (GetIsObjectValid(oOut))
        {
            return (oOut);
        }
    }
    if (nTier > 1)
    {
        return GetTieredItemOfType(nBaseItem, nTier-1, nUniqueChance);
    }
    return OBJECT_INVALID;
}

object GetTieredArmorOfType(int nAC, int nTier, int nUniqueChance=0)
{
    int bTryUnique = Random(100) < nUniqueChance;
    string sChestName = "_BaseItem" + IntToString(BASE_ITEM_ARMOR) + "T" + IntToString(nTier) + "AC" + IntToString(nAC);
    object oChest;
    object oOut;
    int i;
    for (i=0; i<2; i++)
    {
        if (i == 0 && !bTryUnique)
        {
            continue;
        }
        if (i == 1)
        {
            sChestName += "NonUnique";
        }
        oChest = GetObjectByTag(sChestName);
        oOut = _GetRandomItemFromChest(oChest);
        if (GetIsObjectValid(oOut))
        {
            return (oOut);
        }
    }
    if (nTier > 1)
    {
        return GetTieredArmorOfType(nAC, nTier-1, nUniqueChance);
    }
    return OBJECT_INVALID;
}

object _EquipUndroppableItem(object oCreature, object oNew, int nSlot)
{
    if (!GetIsObjectValid(oNew))
    {
        return OBJECT_INVALID;
    }
    object oOldOffhand = OBJECT_INVALID;
    if (nSlot == INVENTORY_SLOT_RIGHTHAND)
    {
        oOldOffhand = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oCreature);
    }
    object oOld = GetItemInSlot(nSlot, oCreature);
    SetPickpocketableFlag(oNew, FALSE);
    SetDroppableFlag(oNew, FALSE);
    SetIdentified(oNew, TRUE);
    if (nSlot == -1)
    {
        return oNew;
    }
    int nSuccess = NWNX_Creature_RunEquip(oCreature, oNew, nSlot);
    if (nSuccess)
    {
        DestroyObject(oOld);
        //SendMessageToAllDMs("Destroy old item in slot : " + GetName(oOld));
        if (GetIsObjectValid(oOldOffhand) && oOldOffhand != GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oCreature))
        {
            DestroyObject(oOldOffhand);
        }
        
        return oNew;
    }
    else
    {
        DestroyObject(oNew);
        return OBJECT_INVALID;
    }
    return OBJECT_INVALID;
}

object CopyAndEquipUndroppableItem(object oCreature, object oSourceItem, int nSlot)
{
    if (oSourceItem == OBJECT_INVALID)
    {
        return OBJECT_INVALID;
    }
    object oNew = CopyItem(oSourceItem, oCreature, TRUE);
    return _EquipUndroppableItem(oCreature, oNew, nSlot);
}

object TryEquippingRandomItemOfTier(int nBaseItem, int nTier, int nUniqueChance, object oCreature, int nSlot, int nTries=5, int bCheckSuitability=1)
{
    if (nBaseItem == BASE_ITEM_INVALID)
    {
        return OBJECT_INVALID;
    }
    if (Random(100) < nUniqueChance)
    {
        nUniqueChance = 100;
    }
    else
    {
        nUniqueChance = 0;
    }
    object oNew;
    int i;
    int bIsUnique;
    int nThisTier = nTier;
    while (nThisTier > 0)
    {
        for (i=0; i<nTries; i++)
        {
            object oSource = GetTieredItemOfType(nBaseItem, nThisTier, nUniqueChance);
            if (!GetIsObjectValid(oSource)) { continue; }
            if (bCheckSuitability)
            {
                if (!IsItemSuitableForCreature(oCreature, oSource))
                {
                    continue;
                }
            }
            bIsUnique = FindSubString(GetTag(GetItemPossessor(oSource)), "NonUnique") == -1;
            oNew = CopyAndEquipUndroppableItem(oCreature, oSource, nSlot);
            if (GetIsObjectValid(oNew))
            {
                break;
            }
        }
        if (GetIsObjectValid(oNew))
        {
            break;
        }
        nThisTier--;
    }
    if (!GetIsObjectValid(oNew))
    {
        oNew = CreateItemOnObject(GetMundaneWeaponOfType(nBaseItem), oCreature);
        _EquipUndroppableItem(oCreature, oNew, nSlot);
        bIsUnique = 0;
    }
    if (bIsUnique)
    {
        SetLocalInt(oNew, "unique", 1);
    }
    object oAmmo;
    if (nBaseItem == BASE_ITEM_BULLET || nBaseItem == BASE_ITEM_ARROW || nBaseItem == BASE_ITEM_BOLT || nBaseItem == BASE_ITEM_SHURIKEN || nBaseItem == BASE_ITEM_DART || nBaseItem == BASE_ITEM_THROWINGAXE)
    {
        oAmmo = oNew;
        SetItemStackSize(oNew, 99);
    }
    else if (nBaseItem == BASE_ITEM_SLING)
    {
        oAmmo = TryEquippingRandomItemOfTier(BASE_ITEM_BULLET, nTier, nUniqueChance, oCreature, INVENTORY_SLOT_BULLETS);
    }
    else if (nBaseItem == BASE_ITEM_LIGHTCROSSBOW || nBaseItem == BASE_ITEM_HEAVYCROSSBOW)
    {
        oAmmo = TryEquippingRandomItemOfTier(BASE_ITEM_BOLT, nTier, nUniqueChance, oCreature, INVENTORY_SLOT_BOLTS);
    }
    else if (nBaseItem == BASE_ITEM_SHORTBOW || nBaseItem == BASE_ITEM_LONGBOW)
    {
        oAmmo = TryEquippingRandomItemOfTier(BASE_ITEM_ARROW, nTier, nUniqueChance, oCreature, INVENTORY_SLOT_ARROWS);
    }
    if (GetIsObjectValid(oAmmo))
    {
        AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyBoomerang(), oAmmo);
    }
    return oNew;
}

object AddRandomItemOfTierToInventory(int nBaseItem, int nTier, int nUniqueChance, object oCreature)
{
    object oSource = GetTieredItemOfType(nBaseItem, nTier, nUniqueChance);
    int bIsUnique = 0;
    object oNew;
    if (!GetIsObjectValid(oSource))
    {
        oNew = CreateItemOnObject(GetMundaneWeaponOfType(nBaseItem), oCreature);
    }
    else
    {
        bIsUnique = FindSubString(GetTag(GetItemPossessor(oSource)), "NonUnique") == -1;
        oNew = CopyItem(oSource, oCreature, TRUE);
        if (bIsUnique)
        {
            SetLocalInt(oNew, "unique", 1);
        }
    }
    
    SetPickpocketableFlag(oNew, FALSE);
    SetDroppableFlag(oNew, FALSE);
    SetIdentified(oNew, TRUE);
    return oNew;
}

int GetACOfArmorToEquip(object oCreature, int nMaxAC=8)
{
    if (nMaxAC == 0) { return 0; }
    if (!GetHasFeat(FEAT_ARMOR_PROFICIENCY_HEAVY, oCreature) && nMaxAC > 5) { nMaxAC = 5; }
    if (!GetHasFeat(FEAT_ARMOR_PROFICIENCY_MEDIUM, oCreature) && nMaxAC > 3) { nMaxAC = 3; }
    if (!GetHasFeat(FEAT_ARMOR_PROFICIENCY_LIGHT, oCreature)) { return 0; }
    if (GetLevelByClass(CLASS_TYPE_MONK, oCreature)) { return 0; }
    if (GetLevelByClass(CLASS_TYPE_WIZARD, oCreature)) { return 0; }
    if (GetLevelByClass(CLASS_TYPE_SORCERER, oCreature)) { return 0; }
    if (GetLevelByClass(CLASS_TYPE_RANGER, oCreature) && nMaxAC > 3) { nMaxAC = 3; }
    if (GetLevelByClass(CLASS_TYPE_ROGUE, oCreature)  && nMaxAC > 3) { nMaxAC = 3; }
    int nBestArmorAC = 0;
    int nDexMod = GetAbilityModifier(ABILITY_DEXTERITY, oCreature);
    int nBestAC = nDexMod;
    int nThisAC = 1 + min(8, nDexMod);
    if (nThisAC > nBestAC)
    {
        nBestArmorAC = 1;
        nBestAC = nThisAC;
    }
    if (nMaxAC >= 2)
    {
        nThisAC = 2 + min(6, nDexMod);
        if (nThisAC > nBestAC)
        {
            nBestArmorAC = 2;
            nBestAC = nThisAC;
        }
        if (nMaxAC >= 3)
        {  
            nThisAC = 3 + min(4, nDexMod);
            if (nThisAC > nBestAC)
            {
                nBestArmorAC = 3;
                nBestAC = nThisAC;
            }
            if (nMaxAC >= 4)
            {  
                nThisAC = 4 + min(4, nDexMod);
                if (nThisAC > nBestAC)
                {
                    nBestArmorAC = 4;
                    nBestAC = nThisAC;
                }
                if (nMaxAC >= 5)
                {  
                    nThisAC = 5 + min(2, nDexMod);
                    if (nThisAC > nBestAC)
                    {
                        nBestArmorAC = 5;
                        nBestAC = nThisAC;
                    }
                    if (nMaxAC >= 6)
                    {  
                        nThisAC = 6 + min(1, nDexMod);
                        if (nThisAC > nBestAC)
                        {
                            nBestArmorAC = 6;
                            nBestAC = nThisAC;
                        }
                        if (nMaxAC >= 7)
                        {  
                            nThisAC = 7 + min(1, nDexMod);
                            if (nThisAC > nBestAC)
                            {
                                nBestArmorAC = 7;
                                nBestAC = nThisAC;
                            }
                            if (nMaxAC >= 8)
                            {  
                                nThisAC = 8 + min(1, nDexMod);
                                if (nThisAC > nBestAC)
                                {
                                    nBestArmorAC = 8;
                                    nBestAC = nThisAC;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return nBestArmorAC;
}

object TryEquippingRandomArmorOfTier(int nAC, int nTier, int nUniqueChance, object oCreature, int nSlot=INVENTORY_SLOT_CHEST, int nTries=10)
{
    if (Random(100) < nUniqueChance)
    {
        nUniqueChance = 100;
    }
    else
    {
        nUniqueChance = 0;
    }
    if (nAC == 0)
    {
        nUniqueChance = 100;
    }
    int i;
    int bIsUnique;
    int nThisTier = nTier;
    object oNew;
    while (nThisTier > 0)
    {
        for (i=0; i<=nTries; i++)
        {
            object oSource = GetTieredArmorOfType(nAC, nTier, nUniqueChance);
            if (!GetIsObjectValid(oSource)) { continue; }
            bIsUnique = FindSubString(GetTag(GetItemPossessor(oSource)), "NonUnique") == -1;
            oNew = CopyAndEquipUndroppableItem(oCreature, oSource, nSlot);
            if (GetIsObjectValid(oNew))
            {
                break;
            }
        }
        if (GetIsObjectValid(oNew))
        {
            break;
        }
        nThisTier--;
    }
    if (!GetIsObjectValid(oNew))
    {
        oNew = CreateItemOnObject(GetMundaneArmorOfAC(nAC), oCreature);
        _EquipUndroppableItem(oCreature, oNew, nSlot);
        bIsUnique = 0;
    }
    if (bIsUnique)
    {
        SetLocalInt(oNew, "unique", 1);
    }
    return oNew;
}

void TryEquippingRandomApparelOfTier(int nTier, int nUniqueChance, object oCreature)
{
    if (Random(100) < nUniqueChance)
    {
        TryEquippingRandomItemOfTier(BASE_ITEM_HELMET, nTier, 100, oCreature, INVENTORY_SLOT_HEAD);
    }
    if (Random(100) < nUniqueChance)
    {
        TryEquippingRandomItemOfTier(BASE_ITEM_GLOVES, nTier, 100, oCreature, INVENTORY_SLOT_ARMS);
    }
    if (Random(100) < nUniqueChance)
    {
        TryEquippingRandomItemOfTier(BASE_ITEM_RING, nTier, 100, oCreature, INVENTORY_SLOT_LEFTRING);
    }
    if (Random(100) < nUniqueChance)
    {
        TryEquippingRandomItemOfTier(BASE_ITEM_RING, nTier, 100, oCreature, INVENTORY_SLOT_RIGHTRING);
    }
    if (Random(100) < nUniqueChance)
    {
        TryEquippingRandomItemOfTier(BASE_ITEM_AMULET, nTier, 100, oCreature, INVENTORY_SLOT_NECK);
    }
    if (Random(100) < nUniqueChance)
    {
        TryEquippingRandomItemOfTier(BASE_ITEM_BELT, nTier, 100, oCreature, INVENTORY_SLOT_BELT);
    }
    if (Random(100) < nUniqueChance)
    {
        TryEquippingRandomItemOfTier(BASE_ITEM_BOOTS, nTier, 100, oCreature, INVENTORY_SLOT_BOOTS);
    }
    if (Random(100) < nUniqueChance)
    {
        TryEquippingRandomItemOfTier(BASE_ITEM_CLOAK, nTier, 100, oCreature, INVENTORY_SLOT_CLOAK);
    }
}

void SetRandomEquipWeaponTypeWeight(object oCreature, int nBaseItem, int nWeight)
{
    // Saving (weight - 1) is deliberate
    // We add 1 when retrieving these, because an unset var in GetLocalInt returns 0 -> becomes 1, normal weighting
    SetLocalInt(oCreature, "rand_equip_weapon_weight_" + IntToString(nBaseItem), nWeight - 1);
}


int IsItemSuitableForCreature(object oCreature, object oItem)
{
    // Respect ILR
    if (NWNX_Item_GetMinEquipLevel(oItem) > GetHitDice(oCreature))
    {
        return 0;
    }
    // Only deal in certain kinds of items
    int nBaseItem = GetBaseItemType(oItem);
    if (nBaseItem == BASE_ITEM_HELMET || nBaseItem == BASE_ITEM_AMULET || nBaseItem == BASE_ITEM_RING || nBaseItem == BASE_ITEM_BOOTS || nBaseItem == BASE_ITEM_BELT || nBaseItem == BASE_ITEM_CLOAK || nBaseItem == BASE_ITEM_GLOVES || nBaseItem == BASE_ITEM_BRACER || nBaseItem == BASE_ITEM_ARMOR || nBaseItem == BASE_ITEM_SMALLSHIELD || nBaseItem == BASE_ITEM_LARGESHIELD || nBaseItem == BASE_ITEM_TOWERSHIELD)
    {
        int bSuitable = 0;
        int bIsUnarmedMonk = GetLevelByClass(CLASS_TYPE_MONK, oCreature) && !GetIsObjectValid(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCreature));
        itemproperty ipTest = GetFirstItemProperty(oItem);
        if (!GetIsItemPropertyValid(ipTest))
        {
            // It does nothing, so I guess it's as good as anything...
            bSuitable = 1;
        }
        while (GetIsItemPropertyValid(ipTest))
        {
            int nItemPropertyType = GetItemPropertyType(ipTest);
            // Unarmed Monks need attack and/or damage bonus on their gloves
            // It is after all the difference between anyone else having a mundane vs enchanted weapon
            if (bIsUnarmedMonk && (nBaseItem == BASE_ITEM_GLOVES || nBaseItem == BASE_ITEM_BRACER))
            {
                if (nItemPropertyType == ITEM_PROPERTY_ATTACK_BONUS || nItemPropertyType == ITEM_PROPERTY_DAMAGE_BONUS)
                {
                    bSuitable = 1;
                }
            }
            else
            {
                // These are okay on anyone.
                if (nItemPropertyType == ITEM_PROPERTY_AC_BONUS || 
                    nItemPropertyType == ITEM_PROPERTY_AC_BONUS_VS_ALIGNMENT_GROUP ||
                    nItemPropertyType == ITEM_PROPERTY_AC_BONUS_VS_DAMAGE_TYPE ||
                    nItemPropertyType == ITEM_PROPERTY_AC_BONUS_VS_RACIAL_GROUP ||
                    nItemPropertyType == ITEM_PROPERTY_AC_BONUS_VS_SPECIFIC_ALIGNMENT ||
                    nItemPropertyType == ITEM_PROPERTY_DAMAGE_REDUCTION ||
                    nItemPropertyType == ITEM_PROPERTY_DAMAGE_RESISTANCE ||
                    nItemPropertyType == ITEM_PROPERTY_IMMUNITY_DAMAGE_TYPE ||
                    nItemPropertyType == ITEM_PROPERTY_IMMUNITY_MISCELLANEOUS ||
                    nItemPropertyType == ITEM_PROPERTY_IMMUNITY_SPECIFIC_SPELL ||
                    nItemPropertyType == ITEM_PROPERTY_LIGHT ||
                    nItemPropertyType == ITEM_PROPERTY_REGENERATION ||
                    nItemPropertyType == ITEM_PROPERTY_SAVING_THROW_BONUS ||
                    nItemPropertyType == ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC ||
                    nItemPropertyType == ITEM_PROPERTY_SPELL_RESISTANCE)
                {
                    bSuitable = 1;
                }
                // Ignored because they probably should never exist in TFN and checking against these is just pointless instructions
                // ITEM_PROPERTY_FREEDOM_OF_MOVEMENT
                // ITEM_PROPERTY_HASTE
                // ITEM_PROPERTY_IMMUNITY_SPELL_SCHOOL
                // ITEM_PROPERTY_IMMUNITY_SPELLS_BY_LEVEL
                // ITEM_PROPERTY_IMPROVED_EVASION
                // ITEM_PROPERTY_MIND_BLANK
                // ITEM_PROPERTY_TRUE_SEEING
                // ITEM_PROPERTY_TURN_RESISTANCE
                
                
                else if (nItemPropertyType == ITEM_PROPERTY_ABILITY_BONUS)
                {
                    int nAbility = GetItemPropertySubType(ipTest);
                    if (nAbility == ABILITY_STRENGTH)
                    {
                        // Strength doesn't help with casting or throwing shurikens
                        // It does help with just about everything else in TFN though
                        if (!GetLevelByClass(CLASS_TYPE_WIZARD, oCreature) && !GetLevelByClass(CLASS_TYPE_SORCERER, oCreature) && GetBaseItemType(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCreature)) != BASE_ITEM_SHURIKEN)
                        {
                            bSuitable = 1;
                        }
                    }
                    else if (nAbility == ABILITY_DEXTERITY)
                    {
                        // Not helpful if we are likely to get heavy armor and don't have weapon finesse
                        if (GetHasFeat(FEAT_WEAPON_FINESSE, oCreature) || GetACOfArmorToEquip(oCreature) < 5)
                        {
                            bSuitable = 1;
                        }
                    }
                    else if (nAbility == ABILITY_CONSTITUTION)
                    {
                        // Health. Everyone has it.
                        bSuitable = 1;
                    }
                    else if (nAbility == ABILITY_INTELLIGENCE)
                    {
                        if (GetLevelByClass(CLASS_TYPE_WIZARD, oCreature))
                        {
                            bSuitable = 1;
                        }
                    }
                    else if (nAbility == ABILITY_WISDOM)
                    {
                       if (GetLevelByClass(CLASS_TYPE_CLERIC, oCreature) || GetLevelByClass(CLASS_TYPE_DRUID, oCreature) || GetLevelByClass(CLASS_TYPE_MONK, oCreature))
                        {
                            bSuitable = 1;
                        } 
                    }
                    else if (nAbility == ABILITY_CHARISMA)
                    {
                        // AI clerics won't do anything useful with CHA except blow more turn undeads on things that don't need it
                        if (GetLevelByClass(CLASS_TYPE_SORCERER, oCreature) || GetLevelByClass(CLASS_TYPE_PALADIN, oCreature) || GetLevelByClass(CLASS_TYPE_BARD, oCreature))
                        {
                            bSuitable = 1;
                        } 
                    }
                }
                else if (nItemPropertyType == ITEM_PROPERTY_BONUS_FEAT)
                {
                    int nIPRPFeatConst = GetItemPropertySubType(ipTest);
                    int nFeat = StringToInt(Get2DAString("iprp_feats", "FeatIndex", nIPRPFeatConst));
                    // If we have the feat already it's useless!
                    if (!GetHasFeat(nFeat, oCreature))
                    {
                        // A few feats that I think pop up on TFN items
                        object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCreature);
                        if (nFeat == FEAT_EXTRA_TURNING && GetHasFeat(FEAT_TURN_UNDEAD, oCreature))
                        {
                            bSuitable = 1;
                        }
                        else if (nFeat == FEAT_POINT_BLANK_SHOT && IPGetIsRangedWeapon(oWeapon))
                        {
                            bSuitable = 1;
                        }
                        else if (nFeat == FEAT_RAPID_SHOT && (GetBaseItemType(oWeapon) == BASE_ITEM_LONGBOW || GetBaseItemType(oWeapon) == BASE_ITEM_SHORTBOW))
                        {
                            bSuitable = 1;
                        }
                        else if (nFeat == FEAT_WEAPON_SPECIALIZATION_UNARMED_STRIKE && bIsUnarmedMonk)
                        {
                            bSuitable = 1;
                        }
                    }
                }
                else if (nItemPropertyType == ITEM_PROPERTY_BONUS_SPELL_SLOT_OF_LEVEL_N)
                {
                    // Spell slots are useless unless you have the class for them
                    int nClass = GetItemPropertySubType(ipTest);
                    if (GetLevelByClass(nClass, oCreature))
                    {
                        bSuitable = 1;
                    }
                }
                else if (nItemPropertyType == ITEM_PROPERTY_ONHITCASTSPELL)
                {
                    
                    // This is fine so long as it's not on gloves
                    if (nBaseItem != BASE_ITEM_GLOVES && nBaseItem != BASE_ITEM_BRACER)
                    {
                        bSuitable = 1;
                    }
                }
                else if (nItemPropertyType == ITEM_PROPERTY_SKILL_BONUS)
                {
                    int nSkill = GetItemPropertySubType(ipTest);
                    // If we have ranks in the skill, it's probably useful
                    if (GetSkillRank(nSkill, oCreature, TRUE) > 0)
                    {
                        bSuitable = 1;
                    }
                    else if (nSkill == SKILL_DISCIPLINE || nSkill == SKILL_SPOT || nSkill == SKILL_SEARCH || nSkill == SKILL_LISTEN)
                    {
                        // I don't think anyone would mind getting a bit more of this
                        bSuitable = 1;
                    }
                    else if (nSkill == SKILL_CONCENTRATION && (GetLevelByClass(CLASS_TYPE_WIZARD, oCreature) || GetLevelByClass(CLASS_TYPE_SORCERER, oCreature) || GetLevelByClass(CLASS_TYPE_CLERIC, oCreature) || GetLevelByClass(CLASS_TYPE_DRUID, oCreature) || GetLevelByClass(CLASS_TYPE_BARD, oCreature)))
                    {
                        // Casters probably don't mind concentration
                        bSuitable = 1;
                    }
                }
            }
            
            
            if (bSuitable)
            {
                break;
            }
            ipTest = GetNextItemProperty(oItem);
        }
        
        
        return bSuitable;
    }
    return 1;
}

//void main() {}
