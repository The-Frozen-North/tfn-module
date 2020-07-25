//:://////////////////////////////////////////////////
//:: X0_I0_MATCH
/*
  Library for 'matching' functions. These functions
  check to see whether a given value matches one of a long
  set of constants, so they're simple but big and ugly.
 */
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 01/21/2003
//:: Updated By: Georg Zoeller, 2003/10/20
//:://////////////////////////////////////////////////

/**********************************************************************
 * CONSTANTS
 **********************************************************************/

//Talent Type Constants
const int NW_TALENT_PROTECT = 1;
const int NW_TALENT_ENHANCE = 2;

/**********************************************************************
 * FUNCTION PROTOTYPES
 **********************************************************************/


// Used to break protections into 3 categories:
// COMBAT, SPELL and ELEMENTAL.
// sClass should be one of: FIGHTER, CLERIC, MAGE, MONSTER
// nType should always be:  NW_TALENT_PROTECT
int GetMatchCompatibility(talent tUse, string sClass, int nType);

// * Do I have any effect on me that came from a mind affecting spell?
int MatchDoIHaveAMindAffectingSpellOnMe(object oTarget);

// * if the passed in spell is an area of effect spell of any kind
int MatchAreaOfEffectSpell(int nSpell);

// * Is this spell a combat protection spells?
int MatchCombatProtections(talent tUse);

// * Is this talent a protection against spells?
int MatchSpellProtections(talent tUse);

// * Is this talent a protection against elemental damage?
int MatchElementalProtections(talent tUse);

// * Is this item a single-handed weapon?
int MatchSingleHandedWeapon(object oItem);

// TRUE if the item is a double-handed weapon
int MatchDoubleHandedWeapon(object oItem);

// TRUE if the item is a melee weapon
int MatchMeleeWeapon(object oItem);

// TRUE if the item is a shield
int MatchShield(object oItem);

// True if the item is a crossbow
int MatchCrossbow(object oItem);

// True if the item is a longbow or shortbow
int MatchNormalBow(object oItem);

// * is this a mind affecting spell?
int MatchMindAffectingSpells(int iSpell);

// * is this a charm type spell?
int MatchPersonSpells(int iSpell);

// True if this spell is one of the Reverse Healing touch Attacks
int MatchInflictTouchAttack(int nSpell);
// True if the creature is an elemental, undead, or golem
int MatchNonliving(int nRacialType);


//    Checks that the melee talent being used
//    is Disarm and if so then if the target has a
//    weapon.
//
//    This should return TRUE if:
//    - we are not trying to use disarm
//    - we are using disarm appropriately
//
//    This should return FALSE if:
//    - we are trying to use disarm on an inappropriate target
//    - we are using disarm too frequently
//
//    If this returns FALSE, we will fall back to a standard
//    melee attack instead.
int VerifyDisarm(talent tUse, object oTarget);

//     Makes sure that certain talents are not used
//     on Elementals, Undead or Constructs
int VerifyCombatMeleeTalent(talent tUse, object oTarget);

// Checks the target for a specific EFFECT_TYPE constant value
int GetHasEffect(int nEffectType, object oTarget = OBJECT_SELF);

// Returns a potential removal spell that might be useful in
// this situation.
// This is not yet defined.
// int GetRemovalSpell();


/**********************************************************************
 * FUNCTION DEFINITIONS
 **********************************************************************/

//::///////////////////////////////////////////////
//:: Protection Matching Functions
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    These three functions break protections into
    3 categories COMBAT, SPELL and ELEMENTAL
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: April 4, 2002
//:://////////////////////////////////////////////

int GetMatchCompatibility(talent tUse, string sClass, int nType)
{
    if(nType == NW_TALENT_PROTECT)
    {
        if(sClass == "FIGHTER")
        {
            return MatchCombatProtections(tUse);
        }
        else if(sClass == "MAGE")
        {
            return MatchSpellProtections(tUse) || MatchElementalProtections(tUse);
        }
        else if(sClass == "CLERIC" || sClass == "MONSTER")
        {
            return MatchCombatProtections(tUse) || MatchElementalProtections(tUse);
        }
    }
    return FALSE;
}

int MatchCombatProtections(talent tUse)
{
    switch(GetIdFromTalent(tUse))
    {
    case SPELL_PREMONITION:
    case SPELL_ELEMENTAL_SHIELD:
    case SPELL_GREATER_STONESKIN:
    case SPELL_SHADOW_SHIELD:
    case SPELL_ETHEREAL_VISAGE:
    case SPELL_STONESKIN:
    case SPELL_GHOSTLY_VISAGE:
    case SPELL_MESTILS_ACID_SHEATH:
    case SPELL_DEATH_ARMOR:
    case 695: // epic warding
        return TRUE;
    }
    return FALSE;
}

int MatchSpellProtections(talent tUse)
{
    switch(GetIdFromTalent(tUse))
    {
    case SPELL_GREATER_SPELL_MANTLE:
    case SPELL_SPELL_MANTLE:
    case SPELL_LESSER_SPELL_MANTLE:
    case SPELL_SHADOW_SHIELD:
    case SPELL_GLOBE_OF_INVULNERABILITY:
    case SPELL_MINOR_GLOBE_OF_INVULNERABILITY:
    case SPELL_ETHEREAL_VISAGE:
    case SPELL_GHOSTLY_VISAGE:
    case SPELL_SPELL_RESISTANCE:
    case SPELL_PROTECTION_FROM_SPELLS:
    case SPELL_NEGATIVE_ENERGY_PROTECTION:
        return TRUE;
    }
    return FALSE;
}

// * if the passed in spell is an area of effect spell of any kind
int MatchAreaOfEffectSpell(int nSpell)
{
    switch(nSpell)
    {
    case SPELL_ACID_FOG:
    case SPELL_MIND_FOG:
    case SPELL_STORM_OF_VENGEANCE:
//  case SPELL_WEB:
    case SPELL_GREASE:
    case SPELL_CREEPING_DOOM:
//  case SPELL_DARKNESS:
    case SPELL_SILENCE:
    case SPELL_BLADE_BARRIER:
    case SPELL_CLOUDKILL:
    case SPELL_STINKING_CLOUD:
    case SPELL_WALL_OF_FIRE:
    case SPELL_INCENDIARY_CLOUD:
    case SPELL_ENTANGLE:
    case SPELL_EVARDS_BLACK_TENTACLES:
    case SPELL_CLOUD_OF_BEWILDERMENT:
    case SPELL_STONEHOLD:
    case SPELL_VINE_MINE:
    case SPELL_SPIKE_GROWTH:
    case SPELL_DIRGE:
    case SPELL_VINE_MINE_CAMOUFLAGE:
    case SPELL_VINE_MINE_ENTANGLE:
    case SPELL_VINE_MINE_HAMPER_MOVEMENT:
        return TRUE;
    }
    return FALSE;
}

int MatchElementalProtections(talent tUse)
{
    switch(GetIdFromTalent(tUse))
    {
    case SPELL_ENERGY_BUFFER:
    case SPELL_PROTECTION_FROM_ELEMENTS:
    case SPELL_RESIST_ELEMENTS:
    case SPELL_ENDURE_ELEMENTS:
        return TRUE;
    }
    return FALSE;
}

// * Returns a potential removal spell that might be useful in this situation
int GetRemovalSpell()
{
   if(GetHasSpell(SPELL_DISPEL_MAGIC)) return SPELL_DISPEL_MAGIC;
   else if(GetHasSpell(SPELL_LESSER_DISPEL)) return SPELL_LESSER_DISPEL;
   else if(GetHasSpell(SPELL_GREATER_DISPELLING)) return SPELL_GREATER_DISPELLING;
   else if(GetHasSpell(SPELL_MORDENKAINENS_DISJUNCTION)) return SPELL_MORDENKAINENS_DISJUNCTION;
   return -1;
}

// * Do I have any effect on me that came from a mind affecting spell?
int MatchDoIHaveAMindAffectingSpellOnMe(object oTarget)
{
    return GetHasSpellEffect(SPELL_SLEEP, oTarget) ||
        GetHasSpellEffect(SPELL_DAZE, oTarget) ||
        GetHasSpellEffect(SPELL_HOLD_ANIMAL, oTarget) ||
        GetHasSpellEffect(SPELL_HOLD_MONSTER, oTarget) ||
        GetHasSpellEffect(SPELL_HOLD_PERSON, oTarget) ||
        GetHasSpellEffect(SPELL_CHARM_MONSTER, oTarget) ||
        GetHasSpellEffect(SPELL_CHARM_PERSON, oTarget) ||
        GetHasSpellEffect(SPELL_CHARM_PERSON_OR_ANIMAL, oTarget) ||
        GetHasSpellEffect(SPELL_MASS_CHARM, oTarget) ||
        GetHasSpellEffect(SPELL_DOMINATE_ANIMAL, oTarget) ||
        GetHasSpellEffect(SPELL_DOMINATE_MONSTER, oTarget) ||
        GetHasSpellEffect(SPELL_DOMINATE_PERSON, oTarget) ||
        GetHasSpellEffect(SPELL_CONFUSION, oTarget)  ||
        GetHasSpellEffect(SPELL_MIND_FOG, oTarget)   ||
        GetHasSpellEffect(SPELL_CLOUD_OF_BEWILDERMENT, oTarget)   ||
        GetHasSpellEffect(SPELLABILITY_BOLT_DOMINATE,oTarget) ||
        GetHasSpellEffect(SPELLABILITY_BOLT_CHARM,oTarget) ||
        GetHasSpellEffect(SPELLABILITY_BOLT_CONFUSE,oTarget) ||
        GetHasSpellEffect(SPELLABILITY_BOLT_DAZE,oTarget);
}

// Paus
int MatchMindAffectingSpells(int iSpell)
{
    switch(iSpell)
    {
    case SPELL_SLEEP:
    case SPELL_DAZE:
    case SPELL_HOLD_ANIMAL:
    case SPELL_HOLD_MONSTER:
    case SPELL_HOLD_PERSON:
    case SPELL_CHARM_MONSTER:
    case SPELL_CHARM_PERSON:
    case SPELL_CHARM_PERSON_OR_ANIMAL:
    case SPELL_MASS_CHARM:
    case SPELL_DOMINATE_ANIMAL:
    case SPELL_DOMINATE_MONSTER:
    case SPELL_DOMINATE_PERSON:
    case SPELL_CONFUSION:
    case SPELL_SPHERE_OF_CHAOS:
    case SPELL_CLOAK_OF_CHAOS:
    case SPELL_MIND_FOG:
    case SPELL_CLOUD_OF_BEWILDERMENT:
    case SPELL_TASHAS_HIDEOUS_LAUGHTER://1.72: added Tasha Hideous Laughter
        return TRUE;
    }
    return FALSE;
}
// Paus
int MatchPersonSpells(int iSpell)
{
    switch(iSpell)
    {
    case SPELL_HOLD_PERSON:
    case SPELL_CHARM_PERSON:
    case SPELL_DOMINATE_PERSON:
        return TRUE;
    }
    return FALSE;
}


int MatchSingleHandedWeapon(object oItem)
{
    switch(GetBaseItemType(oItem))
    {
    case BASE_ITEM_BATTLEAXE:
    case BASE_ITEM_CLUB:
    case BASE_ITEM_DAGGER:
    case BASE_ITEM_HANDAXE:
    case BASE_ITEM_KAMA:
    case BASE_ITEM_KATANA:
    case BASE_ITEM_KUKRI:
    case BASE_ITEM_LIGHTFLAIL:
    case BASE_ITEM_LIGHTHAMMER:
    case BASE_ITEM_LIGHTMACE:
    case BASE_ITEM_LONGSWORD:
    case BASE_ITEM_MORNINGSTAR:
    case BASE_ITEM_BASTARDSWORD:
    case BASE_ITEM_RAPIER:
    case BASE_ITEM_SICKLE:
    case BASE_ITEM_DWARVENWARAXE:
    case BASE_ITEM_SCIMITAR:
    case BASE_ITEM_WHIP:
    case BASE_ITEM_SHORTSWORD:
    case BASE_ITEM_WARHAMMER:
        return TRUE;
    }
    return FALSE;
}

// TRUE if the item is a double-handed weapon
int MatchDoubleHandedWeapon(object oItem)
{
    switch(GetBaseItemType(oItem))
    {
    case BASE_ITEM_DIREMACE:
    case BASE_ITEM_DOUBLEAXE:
    case BASE_ITEM_GREATAXE:
    case BASE_ITEM_GREATSWORD:
    case BASE_ITEM_HALBERD:
    case BASE_ITEM_HEAVYFLAIL:
    case BASE_ITEM_MAGICSTAFF:
    case BASE_ITEM_QUARTERSTAFF:
    case BASE_ITEM_SCYTHE:
    case BASE_ITEM_SHORTSPEAR:
    case BASE_ITEM_TWOBLADEDSWORD:
    case BASE_ITEM_TRIDENT:
        return TRUE;
    }
    return FALSE;
}

// TRUE if the item is a melee weapon
int MatchMeleeWeapon(object oItem)
{
    return MatchSingleHandedWeapon(oItem) || MatchDoubleHandedWeapon(oItem);
}

// TRUE if the item is a shield
int MatchShield(object oItem)
{
    switch(GetBaseItemType(oItem))
    {
    case BASE_ITEM_SMALLSHIELD:
    case BASE_ITEM_LARGESHIELD:
    case BASE_ITEM_TOWERSHIELD:
        return TRUE;
    }
    return FALSE;
}

// True if the item is a crossbow
int MatchCrossbow(object oItem)
{
    switch(GetBaseItemType(oItem))
    {
    case BASE_ITEM_HEAVYCROSSBOW:
    case BASE_ITEM_LIGHTCROSSBOW:
        return TRUE;
    }
    return FALSE;
}

// True if the item is a longbow or shortbow
int MatchNormalBow(object oItem)
{
    switch(GetBaseItemType(oItem))
    {
    case BASE_ITEM_LONGBOW:
    case BASE_ITEM_SHORTBOW:
        return TRUE;
    }
    return FALSE;
}

// True if this spell is one of the Reverse Healing touch Attacks
int MatchInflictTouchAttack(int nSpell)
{
    switch(nSpell)
    {
    case SPELL_INFLICT_CRITICAL_WOUNDS:
    case SPELL_INFLICT_LIGHT_WOUNDS:
    case SPELL_INFLICT_MINOR_WOUNDS:
    case SPELL_INFLICT_MODERATE_WOUNDS:
    case SPELL_INFLICT_SERIOUS_WOUNDS:
    case SPELL_HARM:
        return TRUE;
   }
   return FALSE;
}

// True if the creature is an elemental, undead, or golem
int MatchNonliving(int nRacialType)
{
    switch(nRacialType)
    {
    case RACIAL_TYPE_CONSTRUCT:
    case RACIAL_TYPE_ELEMENTAL:
    case RACIAL_TYPE_UNDEAD:
        return TRUE;
    }
    return FALSE;
}

//::///////////////////////////////////////////////
//:: Verify Disarm
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
//    Checks that the melee talent being used
//    is Disarm and if so then if the target has a
//    weapon.
//
//    This should return TRUE if:
//    - we are not trying to use disarm
//    - we are using disarm appropriately
//
//    This should return FALSE if:
//    - we are trying to use disarm on an inappropriate target
//    - we are using disarm too frequently
//
//    If this returns FALSE, we will fall back to a standard
//    melee attack instead.
int VerifyDisarm(talent tUse, object oTarget)
{
    if(GetTypeFromTalent(tUse) == TALENT_TYPE_FEAT && (GetIdFromTalent(tUse) == FEAT_DISARM || GetIdFromTalent(tUse) == FEAT_IMPROVED_DISARM))
    {
        if(GetWeaponRanged(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND))) return FALSE;//1.71: disarm can't be used with ranged weapon
        // * If the creature is not capable of being disarmed
        // * don't waste time trying to do so
        // * October 3, Brent
        if (!GetIsCreatureDisarmable(oTarget))
        {
            return FALSE;
        }

        // * the associates given Disarm were given it intentionally
        // * they try to use this ability as often as possible

        // * disarm happens infrequently
        if (d10() > 4 && !GetIsObjectValid(GetMaster()))
        {
            return FALSE;
        }

        return GetIsObjectValid(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTarget));
    }
    // We're not trying to use disarm, everything's OK
    return TRUE;
}

//::///////////////////////////////////////////////
//:: Verify Melee Talent Use
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Makes sure that certain talents are not used
    on Elementals, Undead or Constructs

    - December 18 2002: Do not use smite evil on good people
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 23, 2002
//:://////////////////////////////////////////////
int VerifyCombatMeleeTalent(talent tUse, object oTarget)
{
    object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);
    switch(GetIdFromTalent(tUse))
    {
    case FEAT_PRESTIGE_IMBUE_ARROW:
    case FEAT_PRESTIGE_DARKNESS:
        DecrementRemainingFeatUses(OBJECT_SELF,FEAT_PRESTIGE_IMBUE_ARROW);
        return FALSE;//safety check as AI cannot handle these feats
    case FEAT_PRESTIGE_ARROW_OF_DEATH:
    case FEAT_PRESTIGE_HAIL_OF_ARROWS:
    case FEAT_PRESTIGE_SEEKER_ARROW_1:
    case FEAT_PRESTIGE_SEEKER_ARROW_2:
        switch(GetBaseItemType(oWeapon))
        {//1.70: don't use AA arrow feats with wrong weapon
        case BASE_ITEM_SHORTBOW:
        case BASE_ITEM_LONGBOW:
            return TRUE;
        }
        return FALSE;
    case FEAT_FLURRY_OF_BLOWS://1.71: flurry with ranged also stucks the creature
        if(GetWeaponRanged(oWeapon))
            return FALSE;
    break;
    case FEAT_QUIVERING_PALM://1.71: do not waste quivering palm on wrong enemies
     if(GetHitDice(oTarget) >= GetHitDice(OBJECT_SELF))
        return FALSE;
    case FEAT_SAP:
    case FEAT_STUNNING_FIST:
        switch(GetRacialType(oTarget))
        {
        case RACIAL_TYPE_CONSTRUCT:
        case RACIAL_TYPE_UNDEAD:
        case RACIAL_TYPE_ELEMENTAL:
      //case RACIAL_TYPE_VERMIN://1.70: vermins are not naturally immune
            return FALSE;
        }
    break;
    case FEAT_SMITE_EVIL:
        if(GetAlignmentGoodEvil(oTarget) != ALIGNMENT_EVIL)
            return FALSE;//1.70: don't waste smite on wrong target
    break;
    case FEAT_SMITE_GOOD:
        if(GetAlignmentGoodEvil(oTarget) != ALIGNMENT_GOOD)
            return FALSE;//1.70: don't waste smite on wrong target
    break;
    case FEAT_RAPID_SHOT:
        if(!GetWeaponRanged(oWeapon) || MatchCrossbow(oWeapon))
            return FALSE;//1.70: don't use rapid shot with wrong weapon
    break;
    case FEAT_KNOCKDOWN:
    case FEAT_IMPROVED_KNOCKDOWN:
        if(d100() < 16)//15% chance that KD won't be used
            return FALSE;//1.70: do not spam KD so much
    break;
    }
    return TRUE;
}

//::///////////////////////////////////////////////
//:: Get Has Effect
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Checks to see if the target has a given
    spell effect
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 26, 2001
//:://////////////////////////////////////////////
int GetHasEffect(int nEffectType, object oTarget = OBJECT_SELF)
{
    effect eCheck = GetFirstEffect(oTarget);
    while(GetIsEffectValid(eCheck))
    {
        if(GetEffectType(eCheck) == nEffectType)
        {
             return TRUE;
        }
        eCheck = GetNextEffect(oTarget);
    }
    return FALSE;
}
