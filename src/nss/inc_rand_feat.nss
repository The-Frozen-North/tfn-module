#include "inc_array"
#include "inc_debug"
#include "util_i_math"
#include "nwnx_creature"

// This is an include full of functions that support adding of random feats
// The chances of adding each feat is by default weighted to try to make
// the resulting builds "good".

// This isn't a random creature generator.
// A carefully planned build will always do better.
// This is just meant to add a bit of variance to otherwise static creatures.

// Epic feats not included. This is a low level PW. You could probably add them
// to this system though.


// Feats are divided up into "lists" based on creature type
// This is so that say wizards don't even consider getting attacking feats when they have
// garbage BAB, and saves the run time of processing all that.

const int RAND_FEAT_LIST_RANDOM = 0;
const int RAND_FEAT_LIST_FIGHTER_BONUS = 1;
const int RAND_FEAT_LIST_CASTER = 2;
const int RAND_FEAT_LIST_ROGUE_BONUS = 3;
const int RAND_FEAT_LIST_GENERAL = 4;
const int RAND_FEAT_LIST_RANGED = 5;
const int RAND_FEAT_LIST_MELEE = 6;


// Adds nCount total random feats to oCreature drawn from nFeatList.
// nFeatList should be a RAND_FEAT_LIST_* constant.
// Note that RAND_FEAT_LIST_CASTER is special.
// This is because inc_rand_spell needs to govern spellcaster feats depending on spell selection.
// If inc_rand_spell is not used on this creature within 10 seconds, random caster feats will be added instead
// (but these might not be too sensible)
void AddRandomFeats(object oCreature, int nFeatList, int nCount);

// Sets the weight multiplier for nFeat for oCreature.
// This is a flat multiplier to the internal weights used.
// For instance, using SetRandomFeatWeight(oCreature, FEAT_AMBIDEXTERITY, 100)
// would make ambidexterity 100x more likely to be selected.
// Using a weight of 0 will forbid a feat.
void SetRandomFeatWeight(object oCreature, int nFeat, int nWeight);

/////////

const string RAND_FEAT_TEMP_ARRAY = "rand_feat_temp";
const string RAND_FEAT_TEMP_WEIGHT_ARRAY = "rand_feat_temp_weights";


int _RandomFeatIsRangedCharacter(object oCreature)
{
    return (GetLocalInt(oCreature, "rand_equip_give_ranged") || GetWeaponRanged(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCreature)));
}

int _SelectFeatList(object oCreature)
{
    if (Random(100) < 7)
    {
        return RAND_FEAT_LIST_GENERAL;
    }

    int bRanged = _RandomFeatIsRangedCharacter(oCreature);

    int nBAB = GetBaseAttackBonus(oCreature);
    float fHD = IntToFloat(GetHitDice(oCreature));
    float fAdditionalBAB = (IntToFloat(nBAB)/fHD) - 0.5;

    int nCaster = GetLevelByClass(CLASS_TYPE_WIZARD, oCreature)
                + GetLevelByClass(CLASS_TYPE_SORCERER, oCreature)
                + (GetLevelByClass(CLASS_TYPE_CLERIC, oCreature)/2)
                + (GetLevelByClass(CLASS_TYPE_DRUID, oCreature)/2)
                + GetLevelByClass(CLASS_TYPE_PALE_MASTER, oCreature)
                + (GetLevelByClass(CLASS_TYPE_BARD, oCreature)/2);

    float fCasterProportion = IntToFloat(nCaster)/fHD;

    if (fCasterProportion >= 0.8)
    {
        return RAND_FEAT_LIST_CASTER;
    }
    
    if (Random(100) < FloatToInt(fCasterProportion * 100))
    {
        return RAND_FEAT_LIST_CASTER;
    }

    if (fAdditionalBAB >= 0.4)
    {
        if (bRanged) { return RAND_FEAT_LIST_RANGED; }
        return RAND_FEAT_LIST_MELEE;
    }
    
    if (fAdditionalBAB >= 0.25 && Random(100) < 50)
    {
        if (bRanged) { return RAND_FEAT_LIST_RANGED; }
        return RAND_FEAT_LIST_MELEE;
    }

    if (Random(100) < 50)
    {
        return RAND_FEAT_LIST_GENERAL;
    }
    
    if (bRanged) { return RAND_FEAT_LIST_RANGED; }
    return RAND_FEAT_LIST_MELEE;
}


int _GetRandomFeatWeight(object oCreature, int nFeat)
{
    return (1 + GetLocalInt(oCreature, "rand_feat_weight_" + IntToString(nFeat)));
}


void SetRandomFeatWeight(object oCreature, int nFeat, int nWeight)
{
    SetLocalInt(oCreature, "rand_feat_weight_" + IntToString(nFeat), nWeight - 1);
}

int _EvaluateRandomFeat_Melee(object oCreature, int nFeat)
{
    if (!NWNX_Creature_GetMeetsFeatRequirements(oCreature, nFeat))
    {
        return 0;
    }
    if (GetHasFeat(nFeat, oCreature))
    {
        return 0;
    }
    // 374 = ranger dual wield feat
    if (nFeat == FEAT_AMBIDEXTERITY)
    {
        if (GetHasFeat(374, oCreature)) { return 0; }
        // Get 2 weapon fighting first, not this
        if (!GetHasFeat(FEAT_TWO_WEAPON_FIGHTING, oCreature)) { return 0; }
        return 180;
    }
    if (nFeat == FEAT_TWO_WEAPON_FIGHTING)
    {
        if (GetHasFeat(374, oCreature)) { return 0; }
        if (GetAbilityScore(oCreature, ABILITY_DEXTERITY) >= 15)
        {
            return 40;
        }
        // This is the threshold where inc_rand_equip accepts dual wield without ambidexterity
        if (GetHitDice(oCreature) <= 4)
        {
            return 30;
        }
        return 0;
    }
    if (nFeat == FEAT_ARMOR_PROFICIENCY_HEAVY)
    {
        if (GetLevelByClass(CLASS_TYPE_RANGER, oCreature) || GetLevelByClass(CLASS_TYPE_ROGUE) ||
            GetLevelByClass(CLASS_TYPE_MONK, oCreature) || GetLevelByClass(CLASS_TYPE_WIZARD) ||
            GetLevelByClass(CLASS_TYPE_SORCERER, oCreature) || GetLevelByClass(CLASS_TYPE_ROGUE))
        {
            return 0;
        }
        if (GetAbilityModifier(ABILITY_DEXTERITY, oCreature) >= 2)
        {
            return 0;
        }
        return 80;
    }
    if (nFeat == FEAT_ARMOR_PROFICIENCY_MEDIUM)
    {
        if (GetLevelByClass(CLASS_TYPE_RANGER, oCreature) || GetLevelByClass(CLASS_TYPE_ROGUE) ||
            GetLevelByClass(CLASS_TYPE_MONK, oCreature) || GetLevelByClass(CLASS_TYPE_WIZARD) ||
            GetLevelByClass(CLASS_TYPE_SORCERER, oCreature) || GetLevelByClass(CLASS_TYPE_ROGUE))
        {
            return 0;
        }
        if (GetAbilityModifier(ABILITY_DEXTERITY, oCreature) >= 4)
        {
            return 0;
        }
        return 80;
    }
    if (nFeat == FEAT_ARMOR_PROFICIENCY_LIGHT)
    {
        if (GetLevelByClass(CLASS_TYPE_MONK, oCreature) || GetLevelByClass(CLASS_TYPE_WIZARD) ||
            GetLevelByClass(CLASS_TYPE_SORCERER, oCreature))
        {
            return 0;
        }
        if (GetAbilityModifier(ABILITY_DEXTERITY, oCreature) >= 6)
        {
            return 0;
        }
        return 80;
    }
    if (nFeat == FEAT_BLIND_FIGHT) { return 60; }
    if (nFeat == FEAT_CALLED_SHOT) { return 30; }
    if (nFeat == FEAT_CLEAVE) {  return 60; }
    if (nFeat == FEAT_CIRCLE_KICK) { return 150; }
    if (nFeat == FEAT_DISARM) { return 40; }
    if (nFeat == FEAT_DODGE) { return 30; }
    if (nFeat == FEAT_EXPERTISE) { return 40; }
    if (nFeat == FEAT_EXTRA_SMITING) { return 40; }
    if (nFeat == FEAT_EXTRA_STUNNING_ATTACK) { return 20; }
    if (nFeat == FEAT_GREAT_CLEAVE) { return 40; }
    if (nFeat == FEAT_IMPROVED_CRITICAL_DAGGER) { return 300; }
    if (nFeat == FEAT_IMPROVED_DISARM) { return 70; }
    if (nFeat == FEAT_IMPROVED_EXPERTISE) { return 40; }
    if (nFeat == FEAT_IMPROVED_INITIATIVE) { return 10; }
    if (nFeat == FEAT_IMPROVED_KNOCKDOWN) { return 90; }
    if (nFeat == FEAT_IMPROVED_POWER_ATTACK) { return 50; }
    if (nFeat == FEAT_IMPROVED_TWO_WEAPON_FIGHTING) { return 200; }
    if (nFeat == FEAT_KNOCKDOWN) { return 80; }
    if (nFeat == FEAT_MOBILITY) { return 50; }
    if (nFeat == FEAT_POWER_ATTACK) { return 100; }
    if (nFeat == FEAT_SPRING_ATTACK) { return 100; }
    if (nFeat == FEAT_TOUGHNESS) { return 30; }
    if (nFeat == FEAT_WEAPON_FINESSE)
    {
        int nModDiff = GetAbilityModifier(ABILITY_DEXTERITY, oCreature) - GetAbilityModifier(ABILITY_STRENGTH, oCreature);
        return max(0, 50*nModDiff);
    }
    if (nFeat == FEAT_WEAPON_FOCUS_DAGGER)
    {
        if (GetLevelByClass(CLASS_TYPE_FIGHTER, oCreature))
        {
            return 200;
        }
        return 40;
    }
    if (nFeat == FEAT_WEAPON_PROFICIENCY_MARTIAL)
    {
        return 80;
    }
    if (nFeat == FEAT_WEAPON_PROFICIENCY_EXOTIC)
    {
        return 60;
    }
    if (nFeat == FEAT_WEAPON_SPECIALIZATION_DAGGER)
    {
        return 200;
    }
    if (nFeat == FEAT_WHIRLWIND_ATTACK)
    {
        return 200;
    }
    return 0;
}

int _EvaluateRandomFeat_Caster(object oCreature, int nFeat)
{
    if (!NWNX_Creature_GetMeetsFeatRequirements(oCreature, nFeat))
    {
        return 0;
    }
    if (GetHasFeat(nFeat, oCreature))
    {
        return 0;
    }
    if (nFeat >= FEAT_ARCANE_DEFENSE_ABJURATION && nFeat <= FEAT_ARCANE_DEFENSE_TRANSMUTATION)
    {
        return 10;
    }

    if (nFeat == FEAT_COMBAT_CASTING) { return 30; }
    if (nFeat == FEAT_EXTRA_TURNING) { return 5; }
    if (nFeat == FEAT_GREATER_SPELL_PENETRATION) { return 60; }
    if (nFeat == FEAT_SPELL_PENETRATION) { return 80; }
    // Metamagic feats should be up to the random spell distributor
    // or the creature designer if it's not being used
    if (nFeat == FEAT_EMPOWER_SPELL) { return 0; }
    if (nFeat == FEAT_EXTEND_SPELL) { return 0; }
    if (nFeat >= FEAT_GREATER_SPELL_FOCUS_ABJURATION && nFeat <= FEAT_GREATER_SPELL_FOCUS_TRANSMUTATION) { return 0; }
    if (nFeat == FEAT_MAXIMIZE_SPELL) { return 0; }
    if (nFeat == FEAT_QUICKEN_SPELL) { return 0; }
    if (nFeat == FEAT_SILENCE_SPELL) { return 0; }
    if (nFeat >= FEAT_SPELL_FOCUS_ABJURATION && nFeat <= FEAT_SPELL_FOCUS_TRANSMUTATION) { return 0; }
    if (nFeat == FEAT_STILL_SPELL) { return 0; }

    if (nFeat == FEAT_TOUGHNESS) { return 30; }
    return 0;
}

int _EvaluateRandomFeat_RogueBonus(object oCreature, int nFeat)
{
    if (!NWNX_Creature_GetMeetsFeatRequirements(oCreature, nFeat))
    {
        return 0;
    }
    if (GetHasFeat(nFeat, oCreature))
    {
        return 0;
    }
    if (nFeat == FEAT_CRIPPLING_STRIKE) { return 50; }
    if (nFeat == FEAT_DEFENSIVE_ROLL) { return 50; }
    if (nFeat == FEAT_IMPROVED_EVASION) { return 50; }
    if (nFeat == FEAT_OPPORTUNIST) { return 50; }
    if (nFeat == FEAT_SLIPPERY_MIND) { return 50; }
    return 0;
}

int _EvaluateRandomFeat_Ranged(object oCreature, int nFeat)
{
    if (!NWNX_Creature_GetMeetsFeatRequirements(oCreature, nFeat))
    {
        return 0;
    }
    if (GetHasFeat(nFeat, oCreature))
    {
        return 0;
    }
    if (nFeat == FEAT_BLIND_FIGHT) { return 50; }
    if (nFeat == FEAT_CALLED_SHOT) { return 90; }
    if (nFeat == FEAT_POINT_BLANK_SHOT) { return 150; }
    if (nFeat == FEAT_RAPID_SHOT)
    {
        if (GetHasFeat(FEAT_RAPID_RELOAD, oCreature)) { return 0;}
        return 1000;
    }
    if (nFeat == FEAT_RAPID_RELOAD)
    {
        if (GetHasFeat(FEAT_RAPID_SHOT, oCreature)) { return 0;}
        return 100;
    }
    if (nFeat == FEAT_DODGE) { return 30; }
    if (nFeat == FEAT_MOBILITY) { return 50; }
    if (nFeat == FEAT_SPRING_ATTACK) { return 100; }
    if (nFeat == FEAT_WEAPON_FOCUS_DAGGER)
    {
        if (GetLevelByClass(CLASS_TYPE_FIGHTER, oCreature))
        {
            return 150;
        }
        return 20;
    }
    if (nFeat == FEAT_WEAPON_SPECIALIZATION_DAGGER)
    {
        return 200;
    }
    if (nFeat == FEAT_ZEN_ARCHERY)
    {
        return max(0, 20*(GetAbilityModifier(ABILITY_WISDOM, oCreature) - GetAbilityModifier(ABILITY_DEXTERITY, oCreature)));
    }
    return 0;
}

int _EvaluateRandomFeat_General(object oCreature, int nFeat)
{
    if (!NWNX_Creature_GetMeetsFeatRequirements(oCreature, nFeat))
    {
        return 0;
    }
    if (GetHasFeat(nFeat, oCreature))
    {
        return 0;
    }
    if (nFeat == FEAT_ALERTNESS) { return 3; }
    if (nFeat == FEAT_IRON_WILL) { return 5; }
    if (nFeat == FEAT_LIGHTNING_REFLEXES) { return 5; }
    if (nFeat == FEAT_RESIST_ENERGY_FIRE) { return 2; }
    if (nFeat == FEAT_RESIST_ENERGY_COLD) { return 2; }
    if (nFeat == FEAT_RESIST_ENERGY_ELECTRICAL) { return 2; }
    if (nFeat == FEAT_RESIST_ENERGY_ACID) { return 2; }
    if (nFeat == FEAT_RESIST_ENERGY_SONIC) { return 1; }
    if (nFeat == FEAT_TOUGHNESS) { return 10; }
    return 0;
}

int _AddToChoiceArray(int nFeatID, int nBaseWeight, object oCreature)
{
    int nWeight = nBaseWeight * _GetRandomFeatWeight(oCreature, nFeatID);
    if (nWeight <= 0)
    {
        return 0;
    }
    Array_PushBack_Int(RAND_FEAT_TEMP_ARRAY, nFeatID, GetModule());
    Array_PushBack_Int(RAND_FEAT_TEMP_WEIGHT_ARRAY, nWeight, GetModule());
    return nWeight;
}

int _BuildFeatChoiceArray_General(object oCreature)
{
    Array_Clear(RAND_FEAT_TEMP_ARRAY, GetModule());
    Array_Clear(RAND_FEAT_TEMP_WEIGHT_ARRAY, GetModule());
    int nTotalWeight = 0;
    nTotalWeight += _AddToChoiceArray(FEAT_ALERTNESS, _EvaluateRandomFeat_General(oCreature, FEAT_ALERTNESS), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_IRON_WILL, _EvaluateRandomFeat_General(oCreature, FEAT_IRON_WILL), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_LIGHTNING_REFLEXES, _EvaluateRandomFeat_General(oCreature, FEAT_LIGHTNING_REFLEXES), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_RESIST_ENERGY_FIRE, _EvaluateRandomFeat_General(oCreature, FEAT_RESIST_ENERGY_FIRE), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_RESIST_ENERGY_COLD, _EvaluateRandomFeat_General(oCreature, FEAT_RESIST_ENERGY_COLD), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_RESIST_ENERGY_ELECTRICAL, _EvaluateRandomFeat_General(oCreature, FEAT_RESIST_ENERGY_ELECTRICAL), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_RESIST_ENERGY_ACID, _EvaluateRandomFeat_General(oCreature, FEAT_RESIST_ENERGY_ACID), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_RESIST_ENERGY_SONIC, _EvaluateRandomFeat_General(oCreature, FEAT_RESIST_ENERGY_SONIC), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_TOUGHNESS, _EvaluateRandomFeat_General(oCreature, FEAT_TOUGHNESS), oCreature);
    return nTotalWeight;
}

int _BuildFeatChoiceArray_Ranged(object oCreature)
{
    Array_Clear(RAND_FEAT_TEMP_ARRAY, GetModule());
    Array_Clear(RAND_FEAT_TEMP_WEIGHT_ARRAY, GetModule());
    int nTotalWeight = 0;
    nTotalWeight += _AddToChoiceArray(FEAT_BLIND_FIGHT, _EvaluateRandomFeat_Ranged(oCreature, FEAT_BLIND_FIGHT), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_CALLED_SHOT, _EvaluateRandomFeat_Ranged(oCreature, FEAT_CALLED_SHOT), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_POINT_BLANK_SHOT, _EvaluateRandomFeat_Ranged(oCreature, FEAT_POINT_BLANK_SHOT), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_RAPID_SHOT, _EvaluateRandomFeat_Ranged(oCreature, FEAT_RAPID_SHOT), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_RAPID_RELOAD, _EvaluateRandomFeat_Ranged(oCreature, FEAT_RAPID_RELOAD), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_DODGE, _EvaluateRandomFeat_Ranged(oCreature, FEAT_DODGE), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_MOBILITY, _EvaluateRandomFeat_Ranged(oCreature, FEAT_MOBILITY), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_SPRING_ATTACK, _EvaluateRandomFeat_Ranged(oCreature, FEAT_SPRING_ATTACK), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_WEAPON_FOCUS_DAGGER, _EvaluateRandomFeat_Ranged(oCreature, FEAT_WEAPON_FOCUS_DAGGER), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_WEAPON_SPECIALIZATION_DAGGER, _EvaluateRandomFeat_Ranged(oCreature, FEAT_WEAPON_SPECIALIZATION_DAGGER), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_ZEN_ARCHERY, _EvaluateRandomFeat_Ranged(oCreature, FEAT_ZEN_ARCHERY), oCreature);

    return nTotalWeight;
}


int _BuildFeatChoiceArray_Melee(object oCreature)
{
    Array_Clear(RAND_FEAT_TEMP_ARRAY, GetModule());
    Array_Clear(RAND_FEAT_TEMP_WEIGHT_ARRAY, GetModule());
    int nTotalWeight = 0;
    nTotalWeight += _AddToChoiceArray(FEAT_WHIRLWIND_ATTACK, _EvaluateRandomFeat_Melee(oCreature, FEAT_WHIRLWIND_ATTACK), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_WEAPON_SPECIALIZATION_DAGGER, _EvaluateRandomFeat_Melee(oCreature, FEAT_WEAPON_SPECIALIZATION_DAGGER), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_WEAPON_PROFICIENCY_EXOTIC, _EvaluateRandomFeat_Melee(oCreature, FEAT_WEAPON_PROFICIENCY_EXOTIC), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_WEAPON_PROFICIENCY_MARTIAL, _EvaluateRandomFeat_Melee(oCreature, FEAT_WEAPON_PROFICIENCY_MARTIAL), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_WEAPON_FOCUS_DAGGER, _EvaluateRandomFeat_Melee(oCreature, FEAT_WEAPON_FOCUS_DAGGER), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_WEAPON_FINESSE, _EvaluateRandomFeat_Melee(oCreature, FEAT_WEAPON_FINESSE), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_TOUGHNESS, _EvaluateRandomFeat_Melee(oCreature, FEAT_TOUGHNESS), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_SPRING_ATTACK, _EvaluateRandomFeat_Melee(oCreature, FEAT_SPRING_ATTACK), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_POWER_ATTACK, _EvaluateRandomFeat_Melee(oCreature, FEAT_POWER_ATTACK), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_MOBILITY, _EvaluateRandomFeat_Melee(oCreature, FEAT_MOBILITY), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_KNOCKDOWN, _EvaluateRandomFeat_Melee(oCreature, FEAT_KNOCKDOWN), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_IMPROVED_TWO_WEAPON_FIGHTING, _EvaluateRandomFeat_Melee(oCreature, FEAT_IMPROVED_TWO_WEAPON_FIGHTING), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_IMPROVED_POWER_ATTACK, _EvaluateRandomFeat_Melee(oCreature, FEAT_IMPROVED_POWER_ATTACK), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_IMPROVED_KNOCKDOWN, _EvaluateRandomFeat_Melee(oCreature, FEAT_IMPROVED_KNOCKDOWN), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_IMPROVED_INITIATIVE, _EvaluateRandomFeat_Melee(oCreature, FEAT_IMPROVED_INITIATIVE), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_IMPROVED_DISARM, _EvaluateRandomFeat_Melee(oCreature, FEAT_IMPROVED_DISARM), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_IMPROVED_CRITICAL_DAGGER, _EvaluateRandomFeat_Melee(oCreature, FEAT_IMPROVED_CRITICAL_DAGGER), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_GREAT_CLEAVE, _EvaluateRandomFeat_Melee(oCreature, FEAT_GREAT_CLEAVE), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_EXTRA_STUNNING_ATTACK, _EvaluateRandomFeat_Melee(oCreature, FEAT_EXTRA_STUNNING_ATTACK), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_EXTRA_SMITING, _EvaluateRandomFeat_Melee(oCreature, FEAT_EXTRA_SMITING), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_EXPERTISE, _EvaluateRandomFeat_Melee(oCreature, FEAT_EXPERTISE), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_DODGE, _EvaluateRandomFeat_Melee(oCreature, FEAT_DODGE), oCreature);
    //nTotalWeight += _AddToChoiceArray(FEAT_DISARM, _EvaluateRandomFeat_Melee(oCreature, FEAT_DISARM), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_CIRCLE_KICK, _EvaluateRandomFeat_Melee(oCreature, FEAT_CIRCLE_KICK), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_CLEAVE, _EvaluateRandomFeat_Melee(oCreature, FEAT_CLEAVE), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_CALLED_SHOT, _EvaluateRandomFeat_Melee(oCreature, FEAT_CALLED_SHOT), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_BLIND_FIGHT, _EvaluateRandomFeat_Melee(oCreature, FEAT_BLIND_FIGHT), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_ARMOR_PROFICIENCY_LIGHT, _EvaluateRandomFeat_Melee(oCreature, FEAT_ARMOR_PROFICIENCY_LIGHT), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_ARMOR_PROFICIENCY_MEDIUM, _EvaluateRandomFeat_Melee(oCreature, FEAT_ARMOR_PROFICIENCY_MEDIUM), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_ARMOR_PROFICIENCY_HEAVY, _EvaluateRandomFeat_Melee(oCreature, FEAT_ARMOR_PROFICIENCY_HEAVY), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_TWO_WEAPON_FIGHTING, _EvaluateRandomFeat_Melee(oCreature, FEAT_TWO_WEAPON_FIGHTING), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_AMBIDEXTERITY, _EvaluateRandomFeat_Melee(oCreature, FEAT_AMBIDEXTERITY), oCreature);

    return nTotalWeight;
}

int _BuildFeatChoiceArray_Caster(object oCreature)
{
    Array_Clear(RAND_FEAT_TEMP_ARRAY, GetModule());
    Array_Clear(RAND_FEAT_TEMP_WEIGHT_ARRAY, GetModule());
    int nTotalWeight = 0;
    int nSchool = 0;
    for (nSchool=0; nSchool<8; nSchool++)
    {
        nTotalWeight += _AddToChoiceArray(FEAT_ARCANE_DEFENSE_ABJURATION + nSchool, _EvaluateRandomFeat_Caster(oCreature, FEAT_ARCANE_DEFENSE_ABJURATION + nSchool), oCreature);
        nTotalWeight += _AddToChoiceArray(FEAT_GREATER_SPELL_FOCUS_ABJURATION + nSchool, _EvaluateRandomFeat_Caster(oCreature, FEAT_GREATER_SPELL_FOCUS_ABJURATION + nSchool), oCreature);
        nTotalWeight += _AddToChoiceArray(FEAT_SPELL_FOCUS_ABJURATION + nSchool, _EvaluateRandomFeat_Caster(oCreature, FEAT_SPELL_FOCUS_ABJURATION + nSchool), oCreature);
    }
    nTotalWeight += _AddToChoiceArray(FEAT_TOUGHNESS, _EvaluateRandomFeat_Caster(oCreature, FEAT_TOUGHNESS), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_STILL_SPELL, _EvaluateRandomFeat_Caster(oCreature, FEAT_STILL_SPELL), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_SILENCE_SPELL, _EvaluateRandomFeat_Caster(oCreature, FEAT_SILENCE_SPELL), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_QUICKEN_SPELL, _EvaluateRandomFeat_Caster(oCreature, FEAT_QUICKEN_SPELL), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_MAXIMIZE_SPELL, _EvaluateRandomFeat_Caster(oCreature, FEAT_MAXIMIZE_SPELL), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_EXTEND_SPELL, _EvaluateRandomFeat_Caster(oCreature, FEAT_EXTEND_SPELL), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_EMPOWER_SPELL, _EvaluateRandomFeat_Caster(oCreature, FEAT_EMPOWER_SPELL), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_SPELL_PENETRATION, _EvaluateRandomFeat_Caster(oCreature, FEAT_SPELL_PENETRATION), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_GREATER_SPELL_PENETRATION, _EvaluateRandomFeat_Caster(oCreature, FEAT_GREATER_SPELL_PENETRATION), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_EXTRA_TURNING, _EvaluateRandomFeat_Caster(oCreature, FEAT_EXTRA_TURNING), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_COMBAT_CASTING, _EvaluateRandomFeat_Caster(oCreature, FEAT_COMBAT_CASTING), oCreature);

    return nTotalWeight;
}

int _BuildFeatChoiceArray_RogueBonus(object oCreature)
{
    Array_Clear(RAND_FEAT_TEMP_ARRAY, GetModule());
    Array_Clear(RAND_FEAT_TEMP_WEIGHT_ARRAY, GetModule());
    int nTotalWeight = 0;
    nTotalWeight += _AddToChoiceArray(FEAT_CRIPPLING_STRIKE, _EvaluateRandomFeat_RogueBonus(oCreature, FEAT_CRIPPLING_STRIKE), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_DEFENSIVE_ROLL, _EvaluateRandomFeat_RogueBonus(oCreature, FEAT_DEFENSIVE_ROLL), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_IMPROVED_EVASION, _EvaluateRandomFeat_RogueBonus(oCreature, FEAT_IMPROVED_EVASION), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_OPPORTUNIST, _EvaluateRandomFeat_RogueBonus(oCreature, FEAT_OPPORTUNIST), oCreature);
    nTotalWeight += _AddToChoiceArray(FEAT_SLIPPERY_MIND, _EvaluateRandomFeat_RogueBonus(oCreature, FEAT_SLIPPERY_MIND), oCreature);
    return nTotalWeight;
}

int _BuildFeatChoiceArray_FighterBonus(object oCreature)
{
    Array_Clear(RAND_FEAT_TEMP_ARRAY, GetModule());
    Array_Clear(RAND_FEAT_TEMP_WEIGHT_ARRAY, GetModule());
    int nTotalWeight = 0;
    if (!_RandomFeatIsRangedCharacter(oCreature))
    {
        nTotalWeight += _AddToChoiceArray(FEAT_AMBIDEXTERITY, _EvaluateRandomFeat_Melee(oCreature, FEAT_AMBIDEXTERITY), oCreature);
        nTotalWeight += _AddToChoiceArray(FEAT_BLIND_FIGHT, _EvaluateRandomFeat_Melee(oCreature, FEAT_BLIND_FIGHT), oCreature);
        nTotalWeight += _AddToChoiceArray(FEAT_CALLED_SHOT, _EvaluateRandomFeat_Melee(oCreature, FEAT_CALLED_SHOT), oCreature);
        //nTotalWeight += _AddToChoiceArray(FEAT_DISARM, _EvaluateRandomFeat_Melee(oCreature, FEAT_DISARM), oCreature);
        nTotalWeight += _AddToChoiceArray(FEAT_DODGE, _EvaluateRandomFeat_Melee(oCreature, FEAT_DODGE), oCreature);
        nTotalWeight += _AddToChoiceArray(FEAT_MOBILITY, _EvaluateRandomFeat_Melee(oCreature, FEAT_MOBILITY), oCreature);
        nTotalWeight += _AddToChoiceArray(FEAT_SPRING_ATTACK, _EvaluateRandomFeat_Melee(oCreature, FEAT_SPRING_ATTACK), oCreature);
        nTotalWeight += _AddToChoiceArray(FEAT_EXPERTISE, _EvaluateRandomFeat_Melee(oCreature, FEAT_EXPERTISE), oCreature);
        nTotalWeight += _AddToChoiceArray(FEAT_CLEAVE, _EvaluateRandomFeat_Melee(oCreature, FEAT_CLEAVE), oCreature);
        nTotalWeight += _AddToChoiceArray(FEAT_GREAT_CLEAVE, _EvaluateRandomFeat_Melee(oCreature, FEAT_GREAT_CLEAVE), oCreature);
        nTotalWeight += _AddToChoiceArray(FEAT_IMPROVED_CRITICAL_DAGGER, _EvaluateRandomFeat_Melee(oCreature, FEAT_IMPROVED_CRITICAL_DAGGER), oCreature);
        nTotalWeight += _AddToChoiceArray(FEAT_IMPROVED_EXPERTISE, _EvaluateRandomFeat_Melee(oCreature, FEAT_IMPROVED_EXPERTISE), oCreature);
        nTotalWeight += _AddToChoiceArray(FEAT_IMPROVED_KNOCKDOWN, _EvaluateRandomFeat_Melee(oCreature, FEAT_IMPROVED_KNOCKDOWN), oCreature);
        nTotalWeight += _AddToChoiceArray(FEAT_IMPROVED_POWER_ATTACK, _EvaluateRandomFeat_Melee(oCreature, FEAT_IMPROVED_POWER_ATTACK), oCreature);
        //nTotalWeight += _AddToChoiceArray(FEAT_IMPROVED_DISARM, _EvaluateRandomFeat_Melee(oCreature, FEAT_IMPROVED_DISARM), oCreature);
        nTotalWeight += _AddToChoiceArray(FEAT_IMPROVED_TWO_WEAPON_FIGHTING, _EvaluateRandomFeat_Melee(oCreature, FEAT_IMPROVED_TWO_WEAPON_FIGHTING), oCreature);
        nTotalWeight += _AddToChoiceArray(FEAT_WEAPON_FINESSE, _EvaluateRandomFeat_Melee(oCreature, FEAT_WEAPON_FINESSE), oCreature);
        nTotalWeight += _AddToChoiceArray(FEAT_WEAPON_FOCUS_DAGGER, _EvaluateRandomFeat_Melee(oCreature, FEAT_WEAPON_FOCUS_DAGGER), oCreature);
        nTotalWeight += _AddToChoiceArray(FEAT_KNOCKDOWN, _EvaluateRandomFeat_Melee(oCreature, FEAT_KNOCKDOWN), oCreature);
        nTotalWeight += _AddToChoiceArray(FEAT_POWER_ATTACK, _EvaluateRandomFeat_Melee(oCreature, FEAT_POWER_ATTACK), oCreature);
        nTotalWeight += _AddToChoiceArray(FEAT_TWO_WEAPON_FIGHTING, _EvaluateRandomFeat_Melee(oCreature, FEAT_TWO_WEAPON_FIGHTING), oCreature);
    }
    else
    {
         nTotalWeight += _AddToChoiceArray(FEAT_BLIND_FIGHT, _EvaluateRandomFeat_Ranged(oCreature, FEAT_BLIND_FIGHT), oCreature);
         nTotalWeight += _AddToChoiceArray(FEAT_CALLED_SHOT, _EvaluateRandomFeat_Ranged(oCreature, FEAT_CALLED_SHOT), oCreature);
         nTotalWeight += _AddToChoiceArray(FEAT_DODGE, _EvaluateRandomFeat_Ranged(oCreature, FEAT_DODGE), oCreature);
         nTotalWeight += _AddToChoiceArray(FEAT_MOBILITY, _EvaluateRandomFeat_Ranged(oCreature, FEAT_MOBILITY), oCreature);
         nTotalWeight += _AddToChoiceArray(FEAT_DODGE, _EvaluateRandomFeat_Ranged(oCreature, FEAT_DODGE), oCreature);
         nTotalWeight += _AddToChoiceArray(FEAT_IMPROVED_CRITICAL_DAGGER, _EvaluateRandomFeat_Ranged(oCreature, FEAT_IMPROVED_CRITICAL_DAGGER), oCreature);
         nTotalWeight += _AddToChoiceArray(FEAT_WEAPON_FOCUS_DAGGER, _EvaluateRandomFeat_Ranged(oCreature, FEAT_WEAPON_FOCUS_DAGGER), oCreature);
         nTotalWeight += _AddToChoiceArray(FEAT_POINT_BLANK_SHOT, _EvaluateRandomFeat_Ranged(oCreature, FEAT_POINT_BLANK_SHOT), oCreature);
         nTotalWeight += _AddToChoiceArray(FEAT_RAPID_SHOT, _EvaluateRandomFeat_Ranged(oCreature, FEAT_RAPID_SHOT), oCreature);
    }
    return nTotalWeight;
}

int _BuildFeatChoiceArray(int nFeatList, object oCreature)
{
    if (nFeatList == RAND_FEAT_LIST_RANDOM)
    {
        nFeatList = _SelectFeatList(oCreature);
    }
    switch (nFeatList)
    {
        case RAND_FEAT_LIST_FIGHTER_BONUS:
        {
            return _BuildFeatChoiceArray_FighterBonus(oCreature);
        }
        case RAND_FEAT_LIST_CASTER:
        {
            return _BuildFeatChoiceArray_Caster(oCreature);
        }
        case RAND_FEAT_LIST_ROGUE_BONUS:
        {
            return _BuildFeatChoiceArray_RogueBonus(oCreature);
        }
        case RAND_FEAT_LIST_GENERAL:
        {
            return _BuildFeatChoiceArray_General(oCreature);
        }
        case RAND_FEAT_LIST_RANGED:
        {
            return _BuildFeatChoiceArray_Ranged(oCreature);
        }
        case RAND_FEAT_LIST_MELEE:
        {
            return _BuildFeatChoiceArray_Melee(oCreature);

        }
    }
    return 0;
}

int _PickFromChoiceArray(int nTotalWeight, object oCreature)
{
    int i = 0;
    int nWeightRemaining = 1 + Random(nTotalWeight);
    int nArrayLength = Array_Size(RAND_FEAT_TEMP_ARRAY, GetModule());
    for (i=0; i<nArrayLength; i++)
    {
        int nThisWeight = Array_At_Int(RAND_FEAT_TEMP_WEIGHT_ARRAY, i, GetModule());
        nWeightRemaining -= nThisWeight;
        if (nWeightRemaining <= 0)
        {
            return Array_At_Int(RAND_FEAT_TEMP_ARRAY, i, GetModule());
        }
    }
    return -1;

}

void _DelayedAddCasterListFeats(object oCreature)
{
    int nCount = GetLocalInt(oCreature, "rand_feat_caster");
    if (nCount <= 0) { return; }
    int i;
    for (i=0; i<nCount; i++)
    {
        int nTotalWeight = _BuildFeatChoiceArray(RAND_FEAT_LIST_CASTER, oCreature);
        if (nTotalWeight == 0)
        {
            nTotalWeight = _BuildFeatChoiceArray(RAND_FEAT_LIST_GENERAL, oCreature);
        }
        if (nTotalWeight == 0)
        {
            return;
        }
        int nFeat = _PickFromChoiceArray(nTotalWeight, oCreature);
        if (nFeat == -1)
        {
            continue;
        }
        NWNX_Creature_AddFeat(oCreature, nFeat);
    }
}

void _DelayedFixWeaponSpecificFeats(object oCreature)
{
    object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCreature);
    if (!GetIsObjectValid(oWeapon))
    {
        int nSlot;
        for (nSlot=INVENTORY_SLOT_CWEAPON_L; nSlot <= INVENTORY_SLOT_CWEAPON_B; nSlot++)
        {
            oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCreature);
            if (GetIsObjectValid(oWeapon))
            {
                break;
            }
        }
    }
    int nBaseItem = GetBaseItemType(oWeapon);
    if (GetHasFeat(FEAT_WEAPON_FOCUS_DAGGER, oCreature))
    {
        int nRealWeaponFocus;
        if (!GetIsObjectValid(oWeapon))
        {
            nRealWeaponFocus = FEAT_WEAPON_FOCUS_UNARMED_STRIKE;
        }
        else
        {
            nRealWeaponFocus = StringToInt(Get2DAString("baseitems", "WeaponFocusFeat", nBaseItem));
        }
        NWNX_Creature_RemoveFeat(oCreature, FEAT_WEAPON_FOCUS_DAGGER);
        NWNX_Creature_AddFeat(oCreature, nRealWeaponFocus);
    }
    if (GetHasFeat(FEAT_IMPROVED_CRITICAL_DAGGER, oCreature))
    {
        int nRealWeaponFocus;
        if (!GetIsObjectValid(oWeapon))
        {
            nRealWeaponFocus = FEAT_IMPROVED_CRITICAL_UNARMED_STRIKE;
        }
        else
        {
            nRealWeaponFocus = StringToInt(Get2DAString("baseitems", "WeaponImprovedCriticalFeat", nBaseItem));
        }
        NWNX_Creature_RemoveFeat(oCreature, FEAT_IMPROVED_CRITICAL_DAGGER);
        NWNX_Creature_AddFeat(oCreature, nRealWeaponFocus);
    }
    if (GetHasFeat(FEAT_WEAPON_SPECIALIZATION_DAGGER, oCreature))
    {
        int nRealWeaponFocus;
        if (!GetIsObjectValid(oWeapon))
        {
            nRealWeaponFocus = FEAT_WEAPON_SPECIALIZATION_UNARMED_STRIKE;
        }
        else
        {
            nRealWeaponFocus = StringToInt(Get2DAString("baseitems", "WeaponSpecializationFeat", nBaseItem));
        }
        NWNX_Creature_RemoveFeat(oCreature, FEAT_WEAPON_SPECIALIZATION_DAGGER);
        NWNX_Creature_AddFeat(oCreature, nRealWeaponFocus);
    }
    if (GetLevelByClass(CLASS_TYPE_WEAPON_MASTER, oCreature))
    {
        if (GetIsObjectValid(oWeapon))
        {
            int nRealWeaponFocus = StringToInt(Get2DAString("baseitems", "WeaponOfChoiceFeat", nBaseItem));
            if (nRealWeaponFocus > 0 && !GetHasFeat(nRealWeaponFocus, oCreature))
            {
                NWNX_Creature_AddFeat(oCreature, nRealWeaponFocus);
            }
        }
    }
}

void AddRandomFeats(object oCreature, int nFeatList, int nCount)
{
    int i;
    int bStartedCasterDelay = 0;
    for (i=0; i<nCount; i++)
    {
        int nFeatListForThisFeat = nFeatList;
        if (nFeatList == RAND_FEAT_LIST_RANDOM)
        {
            nFeatListForThisFeat = _SelectFeatList(oCreature);
        }
        if (nFeatList == RAND_FEAT_LIST_CASTER)
        {
            SetLocalInt(oCreature, "rand_feat_caster", GetLocalInt(oCreature, "rand_feat_caster") + 1);
            if (!bStartedCasterDelay)
            {
                DelayCommand(10.0, _DelayedAddCasterListFeats(oCreature));
                bStartedCasterDelay = 1;
            }
            continue;
        }
        int nTotalWeight =_BuildFeatChoiceArray(nFeatListForThisFeat, oCreature);
        if (nTotalWeight == 0)
        {
            nTotalWeight = _BuildFeatChoiceArray(RAND_FEAT_LIST_GENERAL, oCreature);
        }
        if (nTotalWeight == 0)
        {
            return;
        }
        int nFeat = _PickFromChoiceArray(nTotalWeight, oCreature);
        //SendDebugMessage("Add feat from list " + IntToString(nFeatList) + ": " + IntToString(nFeat) + ", total weight = " + IntToString(nTotalWeight), TRUE);
        if (nFeat == -1)
        {
            continue;
        }
        NWNX_Creature_AddFeat(oCreature, nFeat);
        if (nFeat == FEAT_TOUGHNESS)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(GetHitDice(oCreature)), oCreature);
        }
    }
    AssignCommand(GetModule(), DelayCommand(10.0, _DelayedFixWeaponSpecificFeats(oCreature)));
}

//void main(){}
