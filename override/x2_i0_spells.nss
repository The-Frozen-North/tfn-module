//::///////////////////////////////////////////////
//:: x2_i0_spells
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Expansion 2 and above include file for spells
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 2002
//:: Updated On: 2003/09/10 - Georg Zoeller
//:://////////////////////////////////////////////
#include "x2_inc_itemprop"
#include "x0_i0_spells"

//------------------------------------------------------------------------------
// GZ: These constants are used with for the AOE behavior AI
//------------------------------------------------------------------------------
const int X2_SPELL_AOEBEHAVIOR_FLEE = 0;
const int X2_SPELL_AOEBEHAVIOR_IGNORE = 1;
const int X2_SPELL_AOEBEHAVIOR_GUST = 2;
const int X2_SPELL_AOEBEHAVIOR_DISPEL_L = SPELL_LESSER_DISPEL;
const int X2_SPELL_AOEBEHAVIOR_DISPEL_N = SPELL_DISPEL_MAGIC;
const int X2_SPELL_AOEBEHAVIOR_DISPEL_G = SPELL_GREATER_DISPELLING;
const int X2_SPELL_AOEBEHAVIOR_DISPEL_M = SPELL_MORDENKAINENS_DISJUNCTION;
const int X2_SPELL_AOEBEHAVIOR_DISPEL_C = 727;


// * Will pass back a linked effect for all of the bad tide of battle effects.
effect CreateBadTideEffectsLink();
// * Will pass back a linked effect for all of the good tide of battle effects.
effect CreateGoodTideEffectsLink();
// * Passes in the slashing weapon type
int GetSlashingWeapon(object oItem);
// * Passes in the melee weapon type
int GetMeleeWeapon(object oItem);
// * Passes in if the item is magical or not.
int GetIsMagicalItem(object oItem);
// * Passes back the stat bonus of the characters magical stat, if any.
int GetIsMagicStatBonus(object oCaster);

// * Save DC against Epic Spells is the relevant ability score of the caster
// * + 20. The hightest ability score of the casting relevants is 99.99% identical
// * with the one that is used for casting, so we just take it.
// * if used by a placeable, it is equal to the placeables WILL save field.
int GetEpicSpellSaveDC(object oCaster);

// * Checks the character for the thundering rage feat and will apply temporary massive critical
// * to the worn weapons
// * Checks and runs Terrifying Rage feat
void CheckAndApplyEpicRageFeats(int nRounds);

// * Do a mind blast
// nDC      - DC of the Save to resist
// nRounds  - Rounds the stun effect holds
// fRange   - Range of the EffectCone
void DoMindBlast(int nDC, int nDuration, float fRange);


//::///////////////////////////////////////////////
//:: CreateBadTideEffectsLink
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creates the linked bad effects for Battletide.
*/
//:://////////////////////////////////////////////
//:: Created By:
//:: Created On:
//:://////////////////////////////////////////////
effect CreateBadTideEffectsLink()
{
    //Declare major variables
    effect eSaves = EffectSavingThrowDecrease(SAVING_THROW_ALL, 2);
    effect eAttack = EffectAttackDecrease(2);
    effect eDamage = EffectDamageDecrease(2, DAMAGE_TYPE_SLASHING);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    //Link the effects
    effect eLink = EffectLinkEffects(eAttack, eDamage);
    eLink = EffectLinkEffects(eLink, eSaves);
    eLink = EffectLinkEffects(eLink, eDur);
    return eLink;
}

//::///////////////////////////////////////////////
//:: CreateGoodTideEffectsLink
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creates the linked good effects for Battletide.
*/
//:://////////////////////////////////////////////
//:: Created By:
//:: Created On:
//:://////////////////////////////////////////////
effect CreateGoodTideEffectsLink()
{
    //Declare major variables
    effect eSaves = EffectSavingThrowIncrease(SAVING_THROW_ALL, 2);
    effect eAttack = EffectAttackIncrease(2);
    effect eDamage = EffectDamageIncrease(2);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    //Link the effects
    effect eLink = EffectLinkEffects(eAttack, eDamage);
    eLink = EffectLinkEffects(eLink, eSaves);
    eLink = EffectLinkEffects(eLink, eDur);
    return eLink;
}

//------------------------------------------------------------------------------
// AN, 2003
// Returns TRUE if oItem is a slashing weapon
// 1.70: made the function custom content weapons compatible
//------------------------------------------------------------------------------
int GetSlashingWeapon(object oItem)
{
    int nBaseItem = GetBaseItemType(oItem);
    if(nBaseItem == BASE_ITEM_INVALID)
        return FALSE;
    switch(StringToInt(Get2DAString("baseitems","WeaponType",nBaseItem)))
    {
    case 3://slashing
    case 4://slashing+piercing
        return TRUE;
    }
    return FALSE;
}


//------------------------------------------------------------------------------
// AN, 2003
// Returns TRUE if oItem is a ranged weapon
//------------------------------------------------------------------------------
int GetIsRangedWeapon(object oItem)
{
    // GZ: replaced if statement with engine function
    return GetWeaponRanged(oItem);
}

//------------------------------------------------------------------------------
// AN, 2003
// Returns TRUE, if oItem is a melee weapon
// 1.70: made the function custom content weapons compatible
//------------------------------------------------------------------------------
int GetMeleeWeapon(object oItem)
{
    int nBaseItem = GetBaseItemType(oItem);
    if(nBaseItem == BASE_ITEM_INVALID || GetWeaponRanged(oItem))
        return FALSE;
    return StringToInt(Get2DAString("baseitems","WeaponType",nBaseItem)) > 0;
}

//------------------------------------------------------------------------------
// AN, 2003
// Returns TRUE if oItem has any item property that classifies it as magical item
// 1.70: negative item properties, thieves tool and trap are not considered
// anymore and added arcane spell failure and bonus spell slots into consideration
//------------------------------------------------------------------------------
int GetIsMagicalItem(object oItem)
{
    itemproperty ip = GetFirstItemProperty(oItem);
    while(GetIsItemPropertyValid(ip))
    {
        switch(GetItemPropertyType(ip))
        {
        case ITEM_PROPERTY_ABILITY_BONUS:
        case ITEM_PROPERTY_AC_BONUS:
        case ITEM_PROPERTY_AC_BONUS_VS_ALIGNMENT_GROUP:
        case ITEM_PROPERTY_AC_BONUS_VS_DAMAGE_TYPE:
        case ITEM_PROPERTY_AC_BONUS_VS_RACIAL_GROUP:
        case ITEM_PROPERTY_AC_BONUS_VS_SPECIFIC_ALIGNMENT:
        case ITEM_PROPERTY_ATTACK_BONUS:
        case ITEM_PROPERTY_ATTACK_BONUS_VS_ALIGNMENT_GROUP:
        case ITEM_PROPERTY_ATTACK_BONUS_VS_RACIAL_GROUP:
        case ITEM_PROPERTY_ATTACK_BONUS_VS_SPECIFIC_ALIGNMENT:
        case ITEM_PROPERTY_BASE_ITEM_WEIGHT_REDUCTION:
        case ITEM_PROPERTY_BONUS_FEAT:
        case ITEM_PROPERTY_CAST_SPELL:
        case ITEM_PROPERTY_DAMAGE_BONUS:
        case ITEM_PROPERTY_DAMAGE_BONUS_VS_ALIGNMENT_GROUP:
        case ITEM_PROPERTY_DAMAGE_BONUS_VS_RACIAL_GROUP:
        case ITEM_PROPERTY_DAMAGE_BONUS_VS_SPECIFIC_ALIGNMENT:
        case ITEM_PROPERTY_DAMAGE_REDUCTION:
        case ITEM_PROPERTY_DAMAGE_RESISTANCE:
        case ITEM_PROPERTY_DAMAGE_VULNERABILITY:
        case ITEM_PROPERTY_DARKVISION:
//      case ITEM_PROPERTY_DECREASED_ABILITY_SCORE:
//      case ITEM_PROPERTY_DECREASED_AC:
//      case ITEM_PROPERTY_DECREASED_ATTACK_MODIFIER:
//      case ITEM_PROPERTY_DECREASED_DAMAGE:
//      case ITEM_PROPERTY_DECREASED_ENHANCEMENT_MODIFIER:
//      case ITEM_PROPERTY_DECREASED_SAVING_THROWS:
//      case ITEM_PROPERTY_DECREASED_SAVING_THROWS_SPECIFIC:
//      case ITEM_PROPERTY_DECREASED_SKILL_MODIFIER:
        case ITEM_PROPERTY_ENHANCED_CONTAINER_REDUCED_WEIGHT:
        case ITEM_PROPERTY_ENHANCEMENT_BONUS:
        case ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_ALIGNMENT_GROUP:
        case ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_RACIAL_GROUP:
        case ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_SPECIFIC_ALIGNEMENT:
        case ITEM_PROPERTY_EXTRA_MELEE_DAMAGE_TYPE:
        case ITEM_PROPERTY_EXTRA_RANGED_DAMAGE_TYPE:
        case ITEM_PROPERTY_FREEDOM_OF_MOVEMENT:
        case ITEM_PROPERTY_HASTE:
        case ITEM_PROPERTY_HOLY_AVENGER:
        case ITEM_PROPERTY_IMMUNITY_DAMAGE_TYPE:
        case ITEM_PROPERTY_IMMUNITY_MISCELLANEOUS:
        case ITEM_PROPERTY_IMMUNITY_SPECIFIC_SPELL:
        case ITEM_PROPERTY_IMMUNITY_SPELL_SCHOOL:
        case ITEM_PROPERTY_IMMUNITY_SPELLS_BY_LEVEL:
        case ITEM_PROPERTY_IMPROVED_EVASION:
        case ITEM_PROPERTY_KEEN:
        case ITEM_PROPERTY_LIGHT:
        case ITEM_PROPERTY_MASSIVE_CRITICALS:
        case ITEM_PROPERTY_MIGHTY:
        case ITEM_PROPERTY_MIND_BLANK://never implemented itemproperty, but nvm
        case ITEM_PROPERTY_MONSTER_DAMAGE:
//      case ITEM_PROPERTY_NO_DAMAGE:
        case ITEM_PROPERTY_ON_HIT_PROPERTIES:
        case ITEM_PROPERTY_ON_MONSTER_HIT:
        case ITEM_PROPERTY_POISON://never implemented itemproperty, but nvm
        case ITEM_PROPERTY_REGENERATION:
        case ITEM_PROPERTY_REGENERATION_VAMPIRIC:
        case ITEM_PROPERTY_SAVING_THROW_BONUS:
        case ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC:
        case ITEM_PROPERTY_SKILL_BONUS:
        case ITEM_PROPERTY_SPELL_RESISTANCE:
//      case ITEM_PROPERTY_THIEVES_TOOLS:
//      case ITEM_PROPERTY_TRAP:
        case ITEM_PROPERTY_TRUE_SEEING:
        case ITEM_PROPERTY_TURN_RESISTANCE:
        case ITEM_PROPERTY_UNLIMITED_AMMUNITION:
        case ITEM_PROPERTY_ONHITCASTSPELL:
        case ITEM_PROPERTY_ARCANE_SPELL_FAILURE:
        case ITEM_PROPERTY_BONUS_SPELL_SLOT_OF_LEVEL_N:
            return TRUE;
        }
        ip = GetNextItemProperty(oItem);
    }
    return FALSE;
}


//::///////////////////////////////////////////////
//:: GetIsMagicStatBonus
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Returns the modifier from the ability
    score that matters for this caster
*/
//:://////////////////////////////////////////////
//:: Created By:
//:: Created On:
//:://////////////////////////////////////////////

int GetIsMagicStatBonus(object oCaster)
{
    //Declare major variables
    int nClass;
    int nAbility;

    if(nClass = GetLevelByClass(CLASS_TYPE_WIZARD, oCaster))
    {
        if(nClass > 0)
        {
            nAbility = ABILITY_INTELLIGENCE;
        }
    }
    if(nClass = GetLevelByClass(CLASS_TYPE_BARD, oCaster) || GetLevelByClass(CLASS_TYPE_SORCERER, oCaster))
    {
        if(nClass > 0)
        {
            nAbility = ABILITY_CHARISMA;
        }
    }
    else if(nClass = GetLevelByClass(CLASS_TYPE_CLERIC, oCaster) || GetLevelByClass(CLASS_TYPE_DRUID, oCaster)
         || GetLevelByClass(CLASS_TYPE_PALADIN, oCaster) || GetLevelByClass(CLASS_TYPE_RANGER, oCaster))
    {
        if(nClass > 0)
        {
            nAbility = ABILITY_WISDOM;
        }
    }

    return GetAbilityModifier(nAbility, oCaster);
}

//------------------------------------------------------------------------------
// Patch 1.71:
// - when thundering rage is activated with ranged weapon, the onhit property
// is applied on ammunition because this property doesn't work on ranged weapon
// Patch 1.70:
// -both additional functions were deleted and joined into this one
// -thundering rage try to apply bonuses to creature weapons, if barbarian doesn't have weapons
// and if he haven't got even creature one, then this feat add deafness onhit to gloves (if exists)
//------------------------------------------------------------------------------
void CheckAndApplyEpicRageFeats(int nRounds)
{
    SetLocalInt(OBJECT_SELF,"EPIC_RAGE_ROUNDS",nRounds);
    ExecuteScript("70_s2_epicrage",OBJECT_SELF);
}

//------------------------------------------------------------------------------
//Keith Warner
//   Do a mind blast
//   nHitDice - HitDice/Caster Level of the creator
//   nDC      - DC of the Save to resist
//   nRounds  - Rounds the stun effect holds
//   fRange   - Range of the EffectCone
//------------------------------------------------------------------------------
void DoMindBlast(int nDC, int nDuration, float fRange)
{
    int nStunTime;
    float fDelay;

    location lTargetLocation = GetSpellTargetLocation();
    object oTarget;
    effect eCone;
    effect eVis = EffectVisualEffect(VFX_IMP_SONIC);

    oTarget = FIX_GetFirstObjectInShape(SHAPE_SPELLCONE, fRange, lTargetLocation, TRUE);

    while(GetIsObjectValid(oTarget))
    {
        int nApp = GetAppearanceType(oTarget);
        int bImmune = FALSE;
        //----------------------------------------------------------------------
        // Hack to make mind flayers immune to their psionic attacks...
        //----------------------------------------------------------------------
        if (nApp == 413 ||nApp== 414 || nApp == 415)
        {
            bImmune = TRUE;
        }

        if(!bImmune && oTarget != OBJECT_SELF && spellsIsTarget(oTarget,SPELL_TARGET_STANDARDHOSTILE,OBJECT_SELF))
        {
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId()));
            fDelay = GetDistanceBetween(OBJECT_SELF, oTarget)/20;
            // already stunned
            if (GetHasSpellEffect(GetSpellId(),oTarget))
            {
                 // only affects the targeted object
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_STUN), oTarget);
                int nDamage;
                if (GetLevelByClass(CLASS_TYPE_SHIFTER,OBJECT_SELF)>0)
                {
                    nDamage = d6(GetLevelByClass(CLASS_TYPE_SHIFTER,OBJECT_SELF)/3);
                }
                else
                {
                    nDamage = d6(GetHitDice(OBJECT_SELF)/2);
                }
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage), oTarget);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_BIGBYS_FORCEFUL_HAND), oTarget);
            }
            else if (!MySavingThrow(SAVING_THROW_WILL, oTarget, nDC, SAVING_THROW_TYPE_MIND_SPELLS, OBJECT_SELF, fDelay))
            {       //saving throw VFX added
                //Calculate the length of the stun
                nStunTime = nDuration;
                //Set stunned effect
                eCone = EffectStunned();
                //Apply the VFX impact and effects
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eCone, oTarget, RoundsToSeconds(nStunTime)));
            }
        }
        //Get next target in spell area
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPELLCONE, fRange, lTargetLocation, TRUE);
    }
}


// * Gelatinous Cube Paralyze attack
int DoCubeParalyze(object oTarget, object oSource, int nSaveDC = 16)
{
    if(!MySavingThrow(SAVING_THROW_FORT, oTarget, nSaveDC, /*SAVING_THROW_TYPE_PARALYSE*/20, oSource))
    {
        effect ePara = EffectParalyze();
        effect eDur = EffectVisualEffect(VFX_DUR_PARALYZED);
        ePara = EffectLinkEffects(eDur,ePara);
        ePara = EffectLinkEffects(EffectVisualEffect(VFX_DUR_FREEZE_ANIMATION),ePara);
        ePara = ExtraordinaryEffect(ePara);//1.72: paralyze made undispellable
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY,ePara,oTarget,RoundsToSeconds(3+d3())); // not 3 d6, thats not fun
        return TRUE;
    }
    return FALSE;
}


// --------------------------------------------------------------------------------
// GZ: Gel. Cube special abilities
// --------------------------------------------------------------------------------
void EngulfAndDamage(object oTarget, object oSource)
{
  int nDC = 13 + GetHitDice(oSource) - 4;
  if (!MySavingThrow(SAVING_THROW_REFLEX, oTarget, nDC, SAVING_THROW_TYPE_NONE, oSource))
  {
      FloatingTextStrRefOnCreature(84610,oTarget); // * Engulfed
      int nDamage = d6(1);

      effect eDamage = EffectDamage(nDamage, DAMAGE_TYPE_ACID);
      effect eVis = EffectVisualEffect(VFX_IMP_ACID_S);
      ApplyEffectToObject(DURATION_TYPE_INSTANT,eDamage,oTarget);
      ApplyEffectToObject(DURATION_TYPE_INSTANT,eVis,oTarget);
      if (!GetIsImmune(oTarget,IMMUNITY_TYPE_PARALYSIS, oSource))
      {
          if (DoCubeParalyze(oTarget,oSource,16))
          {
               FloatingTextStrRefOnCreature(84609,oTarget);
          }
      }
  }
}
// --------------------------------------------------------------------------------
// Georg Zoeller, 2003-09-19
// Save DC against Epic Spells is the relevant ability score of the caster
// + 20. The hightest ability score of the casting relevants is 99.99% identical
// with the one that is used for casting, so we just take it.
// if used by a placeable, it is equal to the placeables WILL save field.
// --------------------------------------------------------------------------------
int GetEpicSpellSaveDC(object oCaster)
{

    // * Placeables use their WILL Save field as caster level
    if (GetObjectType(oCaster) == OBJECT_TYPE_PLACEABLE)
    {
        return GetWillSavingThrow(oCaster);
    }

    int nWis = GetAbilityModifier(ABILITY_WISDOM,oCaster);
    int nInt = GetAbilityModifier(ABILITY_INTELLIGENCE,oCaster);
    int nCha = GetAbilityModifier(ABILITY_CHARISMA,oCaster);

    int nHigh = nWis;
    if (nHigh < nInt)
    {
        nHigh = nInt;
    }
    if (nHigh < nCha)
    {
        nHigh = nCha;
    }
    int nRet = 20 + nHigh;
    return nRet;
}

// --------------------------------------------------------------------------------
// GZ: Sept 2003
// Determines the optimal behavior against AoESpell nSpellId for a NPC
// use in OnSpellCastAt
// 1.70: made the function more elaborated with more cases of ignore behavior
// --------------------------------------------------------------------------------
int GetBestAOEBehavior(int nSpellID)
{
    if(GetLocalInt(OBJECT_SELF,"IGNORE_AOE")) return X2_SPELL_AOEBEHAVIOR_IGNORE;
    switch(nSpellID)
    {
    case SPELL_EVARDS_BLACK_TENTACLES:
        if(GetCreatureSize(OBJECT_SELF) < CREATURE_SIZE_MEDIUM)
            return X2_SPELL_AOEBEHAVIOR_IGNORE;
    break;
    case SPELL_GREASE:
        if(GetIsImmune(OBJECT_SELF,IMMUNITY_TYPE_KNOCKDOWN) || GetHasFeat(FEAT_WOODLAND_STRIDE))
            return X2_SPELL_AOEBEHAVIOR_IGNORE;
    case SPELL_SPIKE_GROWTH:
        if(spellsIsFlying(OBJECT_SELF) || GetCreatureFlag(OBJECT_SELF, CREATURE_VAR_IS_INCORPOREAL))
            return X2_SPELL_AOEBEHAVIOR_IGNORE;
    break;
    case SPELL_ENTANGLE:
    case SPELL_VINE_MINE_ENTANGLE:
    case SPELL_WEB:
        if(GetIsImmune(OBJECT_SELF,IMMUNITY_TYPE_ENTANGLE) || GetHasFeat(FEAT_WOODLAND_STRIDE) || GetCreatureFlag(OBJECT_SELF, CREATURE_VAR_IS_INCORPOREAL))
            return X2_SPELL_AOEBEHAVIOR_IGNORE;
    break;
    case SPELL_STINKING_CLOUD:
        if(GetIsImmune(OBJECT_SELF,IMMUNITY_TYPE_DAZED))
            return X2_SPELL_AOEBEHAVIOR_IGNORE;
    case SPELL_STONEHOLD:
        if(nSpellID == SPELL_STONEHOLD && GetIsImmune(OBJECT_SELF,IMMUNITY_TYPE_PARALYSIS))
            return X2_SPELL_AOEBEHAVIOR_IGNORE;
    case SPELL_MIND_FOG:
        if(GetIsImmune(OBJECT_SELF,IMMUNITY_TYPE_MIND_SPELLS))
            return X2_SPELL_AOEBEHAVIOR_IGNORE;
    case SPELL_CLOUD_OF_BEWILDERMENT:
        if(nSpellID == SPELL_CLOUD_OF_BEWILDERMENT && (GetIsImmune(OBJECT_SELF,IMMUNITY_TYPE_POISON) || (GetIsImmune(OBJECT_SELF,IMMUNITY_TYPE_BLINDNESS) && (GetIsImmune(OBJECT_SELF,IMMUNITY_TYPE_MIND_SPELLS) || GetIsImmune(OBJECT_SELF,IMMUNITY_TYPE_STUN)))))
            return X2_SPELL_AOEBEHAVIOR_IGNORE;
    case SPELL_CLOUDKILL:
    case SPELL_CREEPING_DOOM:
    case SPELL_INCENDIARY_CLOUD:
    case SPELL_ACID_FOG:
        if(GetHasSpell(SPELL_GUST_OF_WIND))
            return X2_SPELL_AOEBEHAVIOR_GUST;
    break;
    }

    if(GetModuleSwitchValue(MODULE_SWITCH_DISABLE_AI_DISPEL_AOE) == 0)
    {
        if(d100() > GetLocalInt(GetModule(),MODULE_VAR_AI_NO_DISPEL_AOE_CHANCE))
        {
            if(GetHasSpell(SPELL_LESSER_DISPEL))
                return X2_SPELL_AOEBEHAVIOR_DISPEL_L;
            if(GetHasSpell(SPELL_DISPEL_MAGIC))
                return X2_SPELL_AOEBEHAVIOR_DISPEL_N;
            if(GetHasSpell(SPELL_GREATER_DISPELLING))
                return X2_SPELL_AOEBEHAVIOR_DISPEL_G;
            if(GetHasSpell(SPELL_MORDENKAINENS_DISJUNCTION))
                return X2_SPELL_AOEBEHAVIOR_DISPEL_M;
        }
    }
    return X2_SPELL_AOEBEHAVIOR_FLEE;
}


//--------------------------------------------------------------------------
// GZ: 2003-Oct-15
// Removes all effects from nID without paying attention to the caster as
// the spell can from only one caster anyway
// By default, it will only cancel magical effects
//--------------------------------------------------------------------------
void GZRemoveSpellEffects(int nID,object oTarget, int bMagicalEffectsOnly = TRUE)
{
    effect eEff = GetFirstEffect(oTarget);
    while (GetIsEffectValid(eEff))
    {
        if (GetEffectSpellId(eEff) == nID)
        {
            if (GetEffectSubType(eEff) != SUBTYPE_MAGICAL && bMagicalEffectsOnly)
            {
                // ignore
            }
            else
            {
                RemoveEffect(oTarget,eEff);
            }
        }
        eEff = GetNextEffect(oTarget);
    }
}

//------------------------------------------------------------------------------
// GZ: 2003-Oct-15
// A different approach for timing these spells that has the positive side
// effects of making the spell dispellable as well.
// I am using the VFX applied by the spell to track the remaining duration
// instead of adding the remaining runtime on the stack
//
// This function returns FALSE if a delayed Spell effect from nSpell_ID has
// expired. See x2_s0_bigby4.nss for details
//------------------------------------------------------------------------------
int GZGetDelayedSpellEffectsExpired(int nSpell_ID, object oTarget, object oCaster)
{

    if (!GetHasSpellEffect(nSpell_ID,oTarget) )
    {
        DeleteLocalInt(oTarget,"XP2_L_SPELL_SAVE_DC_" + IntToString (nSpell_ID));
        return TRUE;
    }

    //--------------------------------------------------------------------------
    // GZ: 2003-Oct-15
    // If the caster is dead or no longer there, cancel the spell, as it is
    // directed
    //--------------------------------------------------------------------------
    if( !GetIsObjectValid(oCaster))
    {
        GZRemoveSpellEffects(nSpell_ID, oTarget);
        DeleteLocalInt(oTarget,"XP2_L_SPELL_SAVE_DC_" + IntToString (nSpell_ID));
        return TRUE;
    }

    if (GetIsDead(oCaster))
    {
        DeleteLocalInt(oTarget,"XP2_L_SPELL_SAVE_DC_" + IntToString (nSpell_ID));
        GZRemoveSpellEffects(nSpell_ID, oTarget);
        return TRUE;
    }

    return FALSE;

}