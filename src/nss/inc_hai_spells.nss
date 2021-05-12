/*

    Henchman Inventory And Battle AI

    This file contains the main functions used in spellcasting.

*/

#include "inc_hai_itemsp"
#include "inc_hai_melee"
#include "x2_i0_spells"
//#include "x3_inc_horse"

// void main() {    }

// checks if creature should polymorph
int HenchTalentPolymorph();


struct sPersistSpellInfo
{
    object oPersistSpell;
    int bDisableMoveAway;
};

// determine if creatures is in a harmful AOE spell
struct sPersistSpellInfo GetAOEProblem();

// checks if in AOE spell and if so what to do
int CheckAOEForSelf();

// determines the maximum spell protection of target
// (what level of spell is required to work against target
int GetMaxSpellProtLevel(object oTarget);

// determines if target has an enhancement that should be
// dispelled or breached
int Jug_GetHasBeneficialEnhancement(object oTarget, int bForce = FALSE);

// activates creature's persistent aura's - does quick cast for them
int HenchTalentPersistentAbilities();


// tells what type of spell and what the target is
const int TARGET_SPELL_AT_LOCATION = 1;
const int TARGET_SPELL_AREA_ON_OBJECT = 2;
const int TARGET_SPELLABILITY_AT_LOCATION = 3;
const int TARGET_SPELLABILITY_AREA_ON_OBJECT = 4;
const int TARGET_FEAT_ON_OBJECT = 5;
const int TARGET_FEAT_SPELL_AREA_ON_OBJECT = 6;
const int TARGET_FEAT_SPELL_AT_LOCATION = 7;

// returns the general action performed for spellcasting
const int TK_NOSPELL = 0;
const int TK_ATTACK = 1;
const int TK_SUMMON = 2;
const int TK_BUFFSELF = 3;
const int TK_BUFFOTHER = 4;
const int TK_DOMINATE = 5;


const int HENCH_CHECK_SR_FLAG =             0x1;
const int HENCH_CHECK_FORT_SAVE_FLAG =      0x2;
const int HENCH_CHECK_WILL_SAVE_FLAG =      0x4;
const int HENCH_CHECK_REFLEX_SAVE_FLAG =    0x8;
const int HENCH_CHECK_REFLEX_EVASION_SAVE_FLAG = 0x10;


const int HENCH_CHECK_NO_SAVE =                 0x0;
const int HENCH_CHECK_SR_NO_SAVE =              0x1;
const int HENCH_CHECK_FORT_SAVE =               0x2;
const int HENCH_CHECK_WILL_SAVE =               0x4;
const int HENCH_CHECK_REFLEX_SAVE =             0x8;
const int HENCH_CHECK_REFLEX_EVASION_SAVE =     0x10;
const int HENCH_CHECK_FORT_AND_WILL_SAVE =      0x6;
const int HENCH_CHECK_SR_FORT_SAVE =            0x3;
const int HENCH_CHECK_SR_WILL_SAVE =            0x5;
const int HENCH_CHECK_SR_REFLEX_SAVE =          0x9;
const int HENCH_CHECK_SR_FORT_AND_WILL_SAVE =   0x7;
const int HENCH_CHECK_SR_REFLEX_EVASION_SAVE =  0x11;


// missing or wrong numbered spell and feat definitions in nwscript
const int SPELL_HENCH_AuraOfGlory_X2 = 562;
const int SPELL_HENCH_Haste_Slow_X2 = 563;
const int SPELL_HENCH_Summon_Shadow_X2 = 564;
const int SPELL_HENCH_Tide_of_Battle = 565;
const int SPELL_HENCH_Evil_Blight = 566;
const int SPELL_HENCH_Cure_Critical_Wounds_Others = 567;
const int SPELL_HENCH_Restoration_Others = 568;
const int SPELL_HENCH_RedDragonDiscipleBreath = 690;
const int SPELL_HENCH_Harpysong = 686;
const int SPELL_HENCH_Epic_Warding = 695;
const int SPELL_HENCH_EyeballRay0 = 710;
const int SPELL_HENCH_EyeballRay1 = 711;
const int SPELL_HENCH_EyeballRay2 = 712;
const int SPELL_HENCH_Mindflayer_Mindblast_10 = 713;
const int SPELL_HENCH_Golem_Ranged_Slam = 715;
const int SPELL_HENCH_Bebelith_Web = 731;
const int SPELL_HENCH_Psionic_Inertial_Barrier = 741;
const int SPELL_HENCH_ShadowBlend = 757;
const int SPELL_HENCH_UndeadSelfHarm = 759;
const int SPELL_HENCH_Aura_of_Hellfire = 761;
const int SPELL_HENCH_Hell_Inferno = 762;
const int SPELL_HENCH_Psionic_Mass_Concussion = 763;
const int SPELL_HENCH_GlyphOfWardingDefault = 764;
const int SPELL_HENCH_Shadow_Attack = 769;
const int SPELL_HENCH_Slaad_Chaos_Spittle = 770;
const int SPELL_HENCH_DRAGON_BREATH_Prismatic = 771;
const int SPELL_HENCH_Battle_Boulder_Toss = 773;
const int SPELL_HENCH_Deflecting_Force = 774;
const int SPELL_HENCH_Giant_hurl_rock = 775;
const int SPELL_HENCH_Illithid_Mindblast = 789;
const int SPELL_HENCH_Grenade_FireBomb = 744;
const int SPELL_HENCH_Grenade_AcidBomb = 745;
const int SPELL_HENCH_Beholder_Anti_Magic_Cone = 727;
const int SPELL_HENCH_Beholder_Special_Spell_AI = 736;
const int SPELL_HENCH_HarperSleep = 480;


int GetMaxSpellProtLevel(object oTarget)
{
    int iSpellLevelProt = -1;
    object oCreatureHide = GetItemInSlot(INVENTORY_SLOT_CARMOUR, OBJECT_SELF);
    if (GetIsObjectValid(oCreatureHide))
    {
        itemproperty curItemProp = GetFirstItemProperty(oCreatureHide);
        int iCostTableValue;
        while(GetIsItemPropertyValid(curItemProp))
        {
            if (GetItemPropertyType(curItemProp) == ITEM_PROPERTY_IMMUNITY_SPELLS_BY_LEVEL)
            {
                iCostTableValue = GetItemPropertyCostTableValue(curItemProp);
                if (iCostTableValue > iSpellLevelProt)
                {
                    iSpellLevelProt = iCostTableValue;
                }
            }
            curItemProp = GetNextItemProperty(oCreatureHide);
        }
    }
    if (iSpellLevelProt >= 4)
    {
        return iSpellLevelProt;
    }
    if (GetHasSpellEffect(SPELL_GLOBE_OF_INVULNERABILITY, oTarget))
    {
        return 4;
    }
    if (iSpellLevelProt == 3 || GetHasSpellEffect(SPELL_MINOR_GLOBE_OF_INVULNERABILITY, oTarget) ||
         GetHasSpellEffect(SPELL_GREATER_SHADOW_CONJURATION_MINOR_GLOBE, oTarget))
    {
        return 3;
    }
    if (iSpellLevelProt == 2 || GetHasSpellEffect(SPELL_ETHEREAL_VISAGE, oTarget))
    {
        return 2;
    }
    if (iSpellLevelProt == 1 || GetHasSpellEffect(SPELL_GHOSTLY_VISAGE, oTarget) ||
        GetHasSpellEffect(SPELL_GREATER_SHADOW_CONJURATION_MIRROR_IMAGE, oTarget))
    {
        return 1;
    }
    return -1;
}


void CastSetLastSpellOnObject(int nSpell, object oTarget, int nSpellLevel)
{
    CastFixedSpellOnObject(nSpell, oTarget, nSpellLevel);
    HenchSetLastGenericSpellCast(nSpell);
}


void CastSetLastSpellAtLocation(int nSpell, location loc, int nSpellLevel)
{
    CastFixedSpellAtLocation(nSpell, loc, nSpellLevel);
    HenchSetLastGenericSpellCast(nSpell);
}


void CastSetLastFeatSpellOnObject(int nFeat, int nSpell, object oTarget)
{
    SetLocalObject(OBJECT_SELF, sLastSpellTargetObject, oTarget);
    CheckDefense(FALSE);
    ActionCastSpellAtObject(nSpell, oTarget, METAMAGIC_ANY, TRUE);
    ActionDoCommand(DecrementRemainingFeatUses(OBJECT_SELF, nFeat));
    HenchSetLastGenericSpellCast(nSpell);
}


void CastSetLastFeatSpellAtLocation(int nFeat, int nSpell, location loc)
{
    CheckDefense(FALSE);
    ActionCastSpellAtLocation(nSpell, loc, METAMAGIC_ANY, TRUE);
    ActionDoCommand(DecrementRemainingFeatUses(OBJECT_SELF, nFeat));
    HenchSetLastGenericSpellCast(nSpell);
}


void CastSpellAbilityOnObject(int nSpell, object oTarget)
{
    SetLocalObject(OBJECT_SELF, sLastSpellTargetObject, oTarget);
    CheckDefense(FALSE);
    ActionCastSpellAtObject(nSpell, oTarget);
}


void CastSpellAbilityAtLocation(int nSpell, location loc)
{
    CheckDefense(FALSE);
    ActionCastSpellAtLocation(nSpell, loc);
}


void CastFeatOnObject(int nFeat, object oTarget)
{
    SetLocalObject(OBJECT_SELF, sLastSpellTargetObject, oTarget);
    CheckDefense(FALSE);
    ActionUseFeat(nFeat, oTarget);
}


// Jugalator Script Additions Start -------------------------------------------


// Return 1 if target is enhanced with a beneficial
// spell that can be dispelled (= from a spell script), 2 if the
// effects can be breached, 0 otherwise.
// TK changed to not look for magical effects only
int Jug_GetHasBeneficialEnhancement(object oTarget, int bForce = FALSE)
{
    int benEffectCount = 0;
    int spellBreachEffect = FALSE;
    effect eCheck = GetFirstEffect(oTarget);
    while (GetIsEffectValid(eCheck))
    {
        int iSpell = GetEffectSpellId(eCheck);
        if (iSpell != -1 && GetEffectSubType(eCheck) == SUBTYPE_MAGICAL)
        {
            switch(iSpell)
            {
            case SPELL_GREATER_SPELL_MANTLE:
            case SPELL_PREMONITION:
            case SPELL_SPELL_MANTLE:
            case SPELL_SHADOW_SHIELD:
            case SPELL_GREATER_STONESKIN:
            case SPELL_ETHEREAL_VISAGE:
            case SPELL_GLOBE_OF_INVULNERABILITY:
            case SPELL_MINOR_GLOBE_OF_INVULNERABILITY:
            case SPELL_STONESKIN:
            case SPELL_LESSER_SPELL_MANTLE:
            case SPELL_ELEMENTAL_SHIELD:
            case SPELL_PROTECTION_FROM_ELEMENTS:
            case SPELL_RESIST_ELEMENTS:
            case SPELL_GHOSTLY_VISAGE:
            case SPELL_ENDURE_ELEMENTS:
            case SPELL_MAGE_ARMOR:
            case SPELL_SHIELD:
            case SPELL_ENERGY_BUFFER:
            case SPELL_ETHEREALNESS: // greater sanctuary
            case SPELL_SPELL_RESISTANCE:
            case SPELL_MESTILS_ACID_SHEATH:
            case SPELL_MIND_BLANK:
            case SPELL_PROTECTION_FROM_SPELLS:
            case SPELL_DEATH_ARMOR:
            case SPELL_SHADOW_CONJURATION_MAGE_ARMOR:
            case SPELL_NEGATIVE_ENERGY_PROTECTION:
            case SPELL_SANCTUARY:
            case SPELL_STONE_BONES:
            case SPELL_SHIELD_OF_FAITH:
            case SPELL_LESSER_MIND_BLANK:
            case SPELL_IRONGUTS:
            case SPELL_RESISTANCE:
                spellBreachEffect = TRUE;
                break;
            }
            // Found an effect applied by a spell script - check the effect type
            // Ignore invisibility effects since that's a special case taken
            // care of elsewhere
            int iType = GetEffectType(eCheck);

            switch(iType)
            {
            case EFFECT_TYPE_REGENERATE:
            case EFFECT_TYPE_SANCTUARY:
            case EFFECT_TYPE_IMMUNITY:
            case EFFECT_TYPE_INVULNERABLE:
            case EFFECT_TYPE_HASTE:
            case EFFECT_TYPE_ELEMENTALSHIELD:
            case EFFECT_TYPE_SPELL_IMMUNITY:
            case EFFECT_TYPE_SPELLLEVELABSORPTION:
            case EFFECT_TYPE_DAMAGE_IMMUNITY_INCREASE:
            case EFFECT_TYPE_DAMAGE_INCREASE:
            case EFFECT_TYPE_DAMAGE_REDUCTION:
            case EFFECT_TYPE_DAMAGE_RESISTANCE:
            case EFFECT_TYPE_POLYMORPH:
            case EFFECT_TYPE_ETHEREAL:
// removed handled in cure condition case EFFECT_TYPE_DOMINATED:
                benEffectCount += 10;
                break;
            case EFFECT_TYPE_ABILITY_INCREASE:
            case EFFECT_TYPE_AC_INCREASE:
            case EFFECT_TYPE_ATTACK_INCREASE:
            case EFFECT_TYPE_CONCEALMENT:
            case EFFECT_TYPE_ENEMY_ATTACK_BONUS:
            case EFFECT_TYPE_MOVEMENT_SPEED_INCREASE:
            case EFFECT_TYPE_SAVING_THROW_INCREASE:
            case EFFECT_TYPE_SEEINVISIBLE:
            case EFFECT_TYPE_SKILL_INCREASE:
            case EFFECT_TYPE_SPELL_RESISTANCE_INCREASE:
            case EFFECT_TYPE_TEMPORARY_HITPOINTS:
            case EFFECT_TYPE_TRUESEEING:
            case EFFECT_TYPE_ULTRAVISION:
                benEffectCount ++;
                break;
            case EFFECT_TYPE_PARALYZE:
            case EFFECT_TYPE_STUNNED:
            case EFFECT_TYPE_FRIGHTENED:
            case EFFECT_TYPE_SLEEP:
            case EFFECT_TYPE_DAZED:
            case EFFECT_TYPE_CONFUSED:
            case EFFECT_TYPE_TURNED:
            case EFFECT_TYPE_PETRIFY:
            case EFFECT_TYPE_CUTSCENEIMMOBILIZE:
                // if disabled don't dispel
                return 0;
            }
        }
        eCheck = GetNextEffect(oTarget);
    }
        // check if target has summons
    object oSummon = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oTarget);
    if (GetIsObjectValid(oSummon))
    {

        if (GetTag(oSummon) != "X2_S_DRGRED001" && GetTag(oSummon) != "X2_S_MUMMYWARR")
        {
            int iLevelDiff = GetHitDice(oSummon) - GetHitDice(OBJECT_SELF) + 4;
            if (iLevelDiff < 1)
            {
                iLevelDiff = 1;
            }
            benEffectCount += iLevelDiff;
        }
    }
    if (!benEffectCount)
    {
        return 0;
    }
    if (bForce || (d10() <= benEffectCount))
    {
        return spellBreachEffect ? 2 : 1;
    }
    return 0;
}


// limit is 1 to 20 (1d20 roll)
float Getd20Chance(int limit)
{
    limit += 21;
    if (limit <= 0)
    {
        return 0.0;
    }
    if (limit >= 20)
    {
        return 1.0;
    }
    return IntToFloat(limit) / 20.0;
}

// limit is -19 to 19 (1d20 opposed rolls)
float Get2d20Chance(int limit)
{
    if (limit <= -20)
    {
        return 0.0;
    }
    if (limit >= 19)
    {
        return 1.0;
    }
    if (limit <= 0)
    {
        limit += 20;
        return IntToFloat((limit + 1) * limit) / 800.0;
    }
    limit = 19 - limit;
    return 1.0 - IntToFloat((limit + 1) * limit) / 800.0;
}


const int GRAPPLE_CHECK_HIT = 0x1;
const int GRAPPLE_CHECK_HOLD = 0x2;
const int GRAPPLE_CHECK_RUSH = 0x4;
const int GRAPPLE_CHECK_STR = 0x8;

// grapple check, assumes large object (Bigby's and Evard's)
int CheckGrappleResult(object oTarget, int nCasterCheck, int nCheckType)
{
    float fResult = 1.0;

    // grapple hit check
    if (nCheckType & GRAPPLE_CHECK_HIT)
    {
        int nGrappleCheck = nCasterCheck - 1 /* large size */ - GetAC(oTarget);
        fResult *= Getd20Chance(nGrappleCheck);
    }
     // grapple hold check
    if (nCheckType & GRAPPLE_CHECK_HOLD)
    {
        int nGrappleCheck = nCasterCheck + 4 /* large size */ -
            (GetBaseAttackBonus(oTarget) + GetSizeModifier(oTarget) + GetAbilityModifier(ABILITY_STRENGTH, oTarget));
        fResult *= Get2d20Chance(nGrappleCheck);
    }
    // bull rush
    if (nCheckType & GRAPPLE_CHECK_RUSH)
    {
        int nRushCheck = nCasterCheck -
            (GetAbilityModifier(ABILITY_STRENGTH, oTarget) + GetSizeModifier(oTarget));
        fResult *= Get2d20Chance(nRushCheck);
    }
    // strength
    if (nCheckType & GRAPPLE_CHECK_STR)
    {
        int nStrCheck = nCasterCheck - GetAbilityScore(oTarget, ABILITY_STRENGTH);
        fResult *= Get2d20Chance(nStrCheck);
    }
    return FloatToInt(fResult * 20.0) >= d4(2) - 1;
}

// poison DC taken from spell code
int GetCreaturePoisonDC()
{
    int nRacial = GetRacialType(OBJECT_SELF);
    int nHD = GetHitDice(OBJECT_SELF);

    //Determine the poison type based on the Racial Type and HD
    switch (nRacial)
    {
        case RACIAL_TYPE_OUTSIDER:
            if (nHD <= 9)
            {
                return 13; // POISON_QUASIT_VENOM;
            }
            if (nHD < 13)
            {
                return 20; // POISON_BEBILITH_VENOM;
            }
            return 21; // POISON_PIT_FIEND_ICHOR;
        case RACIAL_TYPE_VERMIN:
            if (nHD < 3)
            {
                return 11; // POISON_TINY_SPIDER_VENOM;
            }
            if (nHD < 6)
            {
                return 11; // POISON_SMALL_SPIDER_VENOM;
            }
            if (nHD < 9)
            {
                return 14; // POISON_MEDIUM_SPIDER_VENOM;
            }
            if (nHD < 12)
            {
                return 18; // POISON_LARGE_SPIDER_VENOM;
            }
            if (nHD < 15)
            {
                return 26; // POISON_HUGE_SPIDER_VENOM;
            }
            if (nHD < 18)
            {
                return 36; // POISON_GARGANTUAN_SPIDER_VENOM;
            }
            return 35;  // POISON_COLOSSAL_SPIDER_VENOM;
        default:
            if (nHD < 3)
            {
                return 10; // POISON_NIGHTSHADE;
            }
            if (nHD < 6)
            {
                return 15; // POISON_BLADE_BANE;
            }
            if (nHD < 9)
            {
                return 12; // POISON_BLOODROOT;
            }
            if (nHD < 12)
            {
                return 18; // POISON_LARGE_SPIDER_VENOM;
            }
            if (nHD < 15)
            {
                return 17; // POISON_LICH_DUST;
            }
            if (nHD < 18)
            {
                return 18; // POISON_DARK_REAVER_POWDER;
            }
            return 20; //  POISON_BLACK_LOTUS_EXTRACT;
    }
    return 10;
}

const int DISEASE_CHECK_BOLT = 1;
const int DISEASE_CHECK_CONE = 2;
const int DISEASE_CHECK_PULSE = 3;

// disease DC taken from spell code
int GetCreatureDiseaseDC(int checkType)
{
    //Determine the disease type based on the Racial Type and HD
    int nRacial = GetRacialType(OBJECT_SELF);
    if (checkType == DISEASE_CHECK_CONE)
    {
        int nHD = GetHitDice(OBJECT_SELF);
        switch (nRacial)
        {
            case RACIAL_TYPE_OUTSIDER:
                return 18; // DISEASE_DEMON_FEVER
            case RACIAL_TYPE_VERMIN:
                return 13; // DISEASE_VERMIN_MADNESS
            case RACIAL_TYPE_UNDEAD:
                if(nHD <= 3)
                {
                    return 15; // DISEASE_ZOMBIE_CREEP;
                }
                else if (nHD > 3 && nHD <= 10)
                {
                    return 18; // DISEASE_GHOUL_ROT
                }
                else
                {
                    return 20; // DISEASE_MUMMY_ROT
                }
        }
        if(nHD <= 3)
        {
           return 12; // DISEASE_MINDFIRE
        }
        else if (nHD > 3 && nHD <= 10)
        {
            return 15; // DISEASE_RED_ACHE
        }
        return 13; // DISEASE_SHAKES
    }

    switch (nRacial)
    {
        case RACIAL_TYPE_VERMIN:
            return 13; // DISEASE_VERMIN_MADNESS
        case RACIAL_TYPE_UNDEAD:
            return 12; // DISEASE_FILTH_FEVER
        case RACIAL_TYPE_OUTSIDER:
            if(checkType == DISEASE_CHECK_BOLT && GetTag(OBJECT_SELF) == "NW_SLAADRED")
            {
                return 17; // DISEASE_RED_SLAAD_EGGS
            }
            return 18; // DISEASE_DEMON_FEVER
        case RACIAL_TYPE_MAGICAL_BEAST:
            return 25; // DISEASE_SOLDIER_SHAKES
        case RACIAL_TYPE_ABERRATION:
            return 16; // DISEASE_BLINDING_SICKNESS
    }

    if(checkType == DISEASE_CHECK_BOLT)
    {
        return 25; // DISEASE_SOLDIER_SHAKES
    }
    return 12; // DISEASE_MINDFIRE
}


// globals for spells
int nAreaSpellExtraTargets;
location areaSpellTargetLoc;
object oAreaSpellTarget;


const string sCreatureSaveResultStr = "HENCH_CREATURE_SAVE";

const int HENCH_CREATURE_SAVE_UNKNOWN   = 0;
const int HENCH_CREATURE_SAVE_ENEMY     = 1;
const int HENCH_CREATURE_NOSAVE_ENEMY   = 2;
const int HENCH_CREATURE_SAVE_FRIEND    = 3;
const int HENCH_CREATURE_NOSAVE_FRIEND  = 4;
const int HENCH_CREATURE_BENEFIT_FRIEND = 5;
const int HENCH_CREATURE_OTHER_IGNORE   = 6;


const int HENCH_AREA_NO_CHECK               = 0;
const int HENCH_AREA_CHECK_SLOW             = 1;
const int HENCH_AREA_CHECK_ABLDEC           = 2;
const int HENCH_AREA_CHECK_SLEEP_AND_MIND   = 3;
const int HENCH_AREA_CHECK_DEATH            = 4;
const int HENCH_AREA_CHECK_MIND_AND_FEAR    = 5;
const int HENCH_AREA_CHECK_BLIND            = 6;
const int HENCH_AREA_CHECK_BLIND_AND_DEAF   = 7;
const int HENCH_AREA_CHECK_NEGLVL           = 8;
const int HENCH_AREA_CHECK_POISON           = 9;
const int HENCH_AREA_CHECK_CONF_AND_MIND    = 10;
const int HENCH_AREA_CHECK_STUN_AND_MIND    = 11;
const int HENCH_AREA_CHECK_MIND             = 12;
const int HENCH_AREA_CHECK_DISEASE          = 13;
const int HENCH_AREA_CHECK_PARA_AND_MIND    = 14;
const int HENCH_AREA_CHECK_DAZE_AND_MIND    = 15;
const int HENCH_AREA_CHECK_POISON_DAZE_AND_MIND = 16;
const int HENCH_AREA_CHECK_KNOCKDOWN        = 17;
const int HENCH_AREA_CHECK_SILENCE          = 18;
const int HENCH_AREA_CHECK_ENTANGLE         = 19;
const int HENCH_AREA_CHECK_ATTDEC           = 20;
const int HENCH_AREA_CHECK_PETRIFY          = 21;
const int HENCH_AREA_CHECK_CHARM_AND_MIND   = 22;
const int HENCH_AREA_CHECK_HORRID           = 23;
const int HENCH_AREA_CHECK_SLEEP            = 24;
const int HENCH_AREA_CHECK_NEGLEVEL         = 25;
const int HENCH_AREA_CHECK_HEAL             = 26;
const int HENCH_AREA_CHECK_DARKNESS         = 27;
const int HENCH_AREA_CHECK_UNDEAD           = 28;
const int HENCH_AREA_CHECK_MINDBLAST        = 29;
const int HENCH_AREA_CHECK_HUMANIOD         = 30;
const int HENCH_AREA_CHECK_CURSE            = 31;
const int HENCH_AREA_CHECK_CURSE_SONG       = 32;
const int HENCH_AREA_CHECK_METEOR_SWARM     = 33;
const int HENCH_AREA_CHECK_MASS_CHARM       = 34;
const int HENCH_AREA_CHECK_DROWN            = 35;
const int HENCH_AREA_CHECK_NOT_SELF         = 36;
const int HENCH_AREA_CHECK_EVARDS_TENTACLES = 37;
const int HENCH_AREA_CHECK_MOVE_SPEED_DEC   = 38;
const int HENCH_AREA_CHECK_GREASE           = 39;
const int HENCH_AREA_CHECK_THUNDERCLAP      = 40;
const int HENCH_AREA_CHECK_IRONHORN         = 41;
const int HENCH_AREA_CHECK_PRISM            = 42;


int GetTotalEnemyCount(object oTarget, int checkFriendly, int shape, float size, float range,
    int spellLevel, int saveDC, int saveType, int checkType)
{
    int nResultExtraTargets = -1;
    location resultTargetLoc;
    object oResultTarget;

    int iDoLoop = FALSE;
    int curLoopCount = 1;
    float testRange;

    location testTargetLoc;
    int extraEnemyCount;
    object oCurTarget;
    object oTestTarget;
    int bRequireTarget;
    int bTargetFound;

    int bIsEnemy;
    int bIsFriend;
    int bIsBeneficial = checkType == HENCH_AREA_CHECK_NEGLEVEL || checkType == HENCH_AREA_CHECK_HEAL;
    int associateBenefit;

    int nSaveResult;
    int nTempResult;

    int bCheckSR = saveType & HENCH_CHECK_SR_FLAG;
    int bCheckFortSave = saveType & HENCH_CHECK_FORT_SAVE_FLAG;
    int bCheckWillSave = saveType & HENCH_CHECK_WILL_SAVE_FLAG;
    int bCheckReflexSave = saveType & HENCH_CHECK_REFLEX_SAVE_FLAG;
    int bCheckReflexEvasionSave = saveType & HENCH_CHECK_REFLEX_EVASION_SAVE_FLAG;

    int nCasterLevel;
    if (bCheckSR)
    {
        nCasterLevel = bFoundItemSpell ? (spellLevel * 2) + d4(2) + 2 : nMySpellCasterSpellPenetration;
//        Jug_Debug(GetName(OBJECT_SELF) + " caster level check " + IntToString(nCasterLevel) + " is item " + IntToString(bFoundItemSpell));
    }
        // -1000 indicates this is a normal spell
    if (saveDC == -1000)
    {
        saveDC = bFoundItemSpell ? (spellLevel * 3) / 2 + 10 + nMySpellCasterDCAdjust : nMySpellCasterDC + spellLevel;
    }
    if (shape == SHAPE_CUBE || shape == SHAPE_SPHERE)
    {
        testRange = range;
    }
    else
    {
        testRange = size;
    }
    if (testRange < 1.0)
    {
        oCurTarget = OBJECT_SELF;
    }
    else
    {
        iDoLoop = TRUE;
        oCurTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY,
            OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN,
            CREATURE_TYPE_IS_ALIVE, TRUE);
        // reset flag on nearby creatures
        testTargetLoc = GetLocation(OBJECT_SELF);
        oTestTarget = GetFirstObjectInShape(SHAPE_SPHERE, range + size, testTargetLoc, FALSE, OBJECT_TYPE_CREATURE);
        while (GetIsObjectValid(oTestTarget))
        {
            SetLocalInt(oTestTarget, sCreatureSaveResultStr, 0);
            oTestTarget = GetNextObjectInShape(SHAPE_SPHERE, range + size, testTargetLoc, FALSE, OBJECT_TYPE_CREATURE);
        }

        if (GetDistanceToObject(oTarget) <= 5.0)
        {
            bRequireTarget = TRUE;
        }
    }
    while (GetIsObjectValid(oCurTarget) && curLoopCount <= 10)
    {
        if (GetDistanceToObject(oCurTarget) > testRange)
        {
            break;
        }
        testTargetLoc = GetLocation(oCurTarget);
        extraEnemyCount = -1;
        associateBenefit = 0;
        bTargetFound = !bRequireTarget;

        // Declare the spell shape, size and the location.  Capture the first target object in the shape.
        // note: GetPosition is needed for SHAPE_SPELLCYLINDER
        oTestTarget = GetFirstObjectInShape(shape, size, testTargetLoc, TRUE, OBJECT_TYPE_CREATURE, GetPosition(OBJECT_SELF));
        //Cycle through the targets within the spell shape until an invalid object is captured.
        while (GetIsObjectValid(oTestTarget))
        {
            if (iDoLoop)
            {
                nSaveResult = GetLocalInt(oTestTarget, sCreatureSaveResultStr);
            }
            else
            {
                nSaveResult = HENCH_CREATURE_SAVE_UNKNOWN;
            }
            if (nSaveResult == HENCH_CREATURE_SAVE_UNKNOWN)
            {
                bIsEnemy = GetIsEnemy(oTestTarget);
                bIsFriend = GetIsFriend(oTestTarget);
                nTempResult = FALSE;
                // note (testRange < 1.0 && oTestTarget == OBJECT_SELF) - self target spells don't hurt you
                if (GetIsDead(oTestTarget) || (bIsFriend && !(checkFriendly || bIsBeneficial)) || (!bIsFriend && !bIsEnemy) ||
                    (testRange < 1.0 && oTestTarget == OBJECT_SELF) || (!GetObjectSeen(oTestTarget) && !GetObjectHeard(oTestTarget)))
                {
                    nSaveResult = HENCH_CREATURE_OTHER_IGNORE;
                    SetLocalInt(oTestTarget, sCreatureSaveResultStr, nSaveResult);
                }
            }
            if (nSaveResult == HENCH_CREATURE_SAVE_UNKNOWN)
            {
                if (bIsEnemy || (bIsFriend && (checkFriendly && !bIsBeneficial)))
                {
                    // note: cone spells do not affect yourself
                    if ((oTestTarget == OBJECT_SELF) && ((shape == SHAPE_SPELLCONE) || (shape == SHAPE_CONE) || (shape == SHAPE_SPELLCYLINDER)))
                    {
                        nTempResult = TRUE;
                    }
                    if (bCheckSR && !nTempResult)
                    {
                        nTempResult = (GetSpellResistance(oTestTarget) - (bIsEnemy ? 0 : 10)) > nCasterLevel;
                    }
                    if (bCheckWillSave && !nTempResult)
                    {
                        nTempResult = (GetWillSavingThrow(oTestTarget) - (bIsEnemy ? 0 : 10)) > saveDC;
                    }
                    if (bCheckFortSave && !nTempResult)
                    {
                        nTempResult = (GetFortitudeSavingThrow(oTestTarget) - (bIsEnemy ? 0 : 10)) > saveDC;
                    }
                    if (bCheckReflexSave && !nTempResult)
                    {
                        nTempResult = (GetReflexSavingThrow(oTestTarget) - (bIsEnemy ? 0 : 10)) > saveDC;
                    }
                    if (bCheckReflexEvasionSave && !nTempResult)
                    {
                        nTempResult = (GetHasFeat(FEAT_EVASION, oTestTarget) || GetHasFeat(FEAT_IMPROVED_EVASION, oTestTarget)) &&
                            ((GetReflexSavingThrow(oTestTarget) - (bIsEnemy ? 0 : 10)) > saveDC);
                    }
                }
                if (!nTempResult)
                {
                    switch (checkType)
                    {
                    case HENCH_AREA_NO_CHECK:
                        break;
                    case HENCH_AREA_CHECK_SLOW:
                        nTempResult = GetIsImmune(oTestTarget, IMMUNITY_TYPE_SLOW, OBJECT_SELF) ||
                            GetIsDisabled1(EFFECT_TYPE_SLOW, oTestTarget);
                        break;
                    case HENCH_AREA_CHECK_ABLDEC:
                        nTempResult = GetIsImmune(oTestTarget, IMMUNITY_TYPE_ABILITY_DECREASE, OBJECT_SELF) ||
                            GetIsDisabled1(EFFECT_TYPE_ABILITY_DECREASE, oTestTarget);
                        break;
                    case HENCH_AREA_CHECK_SLEEP_AND_MIND:
                        nTempResult = GetIsImmune(oTestTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) ||
                            GetIsImmune(oTestTarget, IMMUNITY_TYPE_SLEEP, OBJECT_SELF) ||
                            GetIsDisabled(oTestTarget);
                        break;
                    case HENCH_AREA_CHECK_DEATH:
                        nTempResult = GetIsImmune(oTestTarget, IMMUNITY_TYPE_DEATH, OBJECT_SELF);
                        break;
                    case HENCH_AREA_CHECK_MIND_AND_FEAR:
                        nTempResult = GetIsImmune(oTestTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) ||
                            GetIsImmune(oTestTarget, IMMUNITY_TYPE_FEAR, OBJECT_SELF) ||
                            GetIsDisabled(oTestTarget);
                        break;
                    case HENCH_AREA_CHECK_BLIND:
                        nTempResult = GetIsImmune(oTestTarget, IMMUNITY_TYPE_BLINDNESS, OBJECT_SELF) ||
                            GetIsDisabled1(EFFECT_TYPE_BLINDNESS, oTestTarget);
                        break;
                    case HENCH_AREA_CHECK_BLIND_AND_DEAF:
                        nTempResult = (GetIsImmune(oTestTarget, IMMUNITY_TYPE_BLINDNESS, OBJECT_SELF) &&
                            GetIsImmune(oTestTarget, IMMUNITY_TYPE_DEAFNESS, OBJECT_SELF)) ||
                            GetIsDisabled2(EFFECT_TYPE_BLINDNESS, EFFECT_TYPE_DEAF, oTestTarget);
                        break;
                    case HENCH_AREA_CHECK_NEGLVL:
                        nTempResult = GetIsImmune(oTestTarget, IMMUNITY_TYPE_NEGATIVE_LEVEL, OBJECT_SELF);
                        break;
                    case HENCH_AREA_CHECK_POISON:
                        nTempResult = GetIsImmune(oTestTarget, IMMUNITY_TYPE_POISON, OBJECT_SELF) ||
                            GetIsDisabled1(EFFECT_TYPE_POISON, oTestTarget);
                        break;
                    case HENCH_AREA_CHECK_CONF_AND_MIND:
                        nTempResult = GetIsImmune(oTestTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) ||
                            GetIsImmune(oTestTarget, IMMUNITY_TYPE_CONFUSED, OBJECT_SELF) ||
                            GetIsDisabled(oTestTarget);
                        break;
                    case HENCH_AREA_CHECK_STUN_AND_MIND:
                        nTempResult = GetIsImmune(oTestTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) ||
                            GetIsImmune(oTestTarget, IMMUNITY_TYPE_STUN, OBJECT_SELF) ||
                            GetIsDisabled(oTestTarget);
                        break;
                    case HENCH_AREA_CHECK_MIND:
                        nTempResult = GetIsImmune(oTestTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF);
                        break;
                    case HENCH_AREA_CHECK_DISEASE:
                        nTempResult = GetIsImmune(oTestTarget, IMMUNITY_TYPE_DISEASE, OBJECT_SELF) ||
                            GetIsDisabled1(EFFECT_TYPE_DISEASE, oTestTarget);
                        break;
                    case HENCH_AREA_CHECK_PARA_AND_MIND:
                        nTempResult = GetIsImmune(oTestTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) ||
                            GetIsImmune(oTestTarget, IMMUNITY_TYPE_PARALYSIS, OBJECT_SELF) ||
                            GetIsDisabled(oTestTarget);
                        break;
                    case HENCH_AREA_CHECK_DAZE_AND_MIND:
                        nTempResult = GetIsImmune(oTestTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) ||
                            GetIsImmune(oTestTarget, IMMUNITY_TYPE_DAZED, OBJECT_SELF) ||
                            GetIsDisabled(oTestTarget);
                        break;
                    case HENCH_AREA_CHECK_POISON_DAZE_AND_MIND:
                        nTempResult = GetIsImmune(oTestTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) ||
                            GetIsImmune(oTestTarget, IMMUNITY_TYPE_DAZED, OBJECT_SELF) ||
                            GetIsImmune(oTestTarget, IMMUNITY_TYPE_POISON, OBJECT_SELF) ||
                            GetIsDisabled1(EFFECT_TYPE_POISON, oTestTarget);
                        break;
                    case HENCH_AREA_CHECK_KNOCKDOWN:
                        nTempResult = GetIsImmune(oTestTarget, IMMUNITY_TYPE_KNOCKDOWN, OBJECT_SELF) ||
                            GetIsDisabled(oTestTarget);
                        break;
                    case HENCH_AREA_CHECK_ENTANGLE:
                        nTempResult = GetIsImmune(oTestTarget, IMMUNITY_TYPE_ENTANGLE, OBJECT_SELF) ||
                            GetHasFeat(FEAT_WOODLAND_STRIDE, oTestTarget) ||
                            GetCreatureFlag(oTestTarget, CREATURE_VAR_IS_INCORPOREAL) ||
                            GetIsDisabled1(EFFECT_TYPE_ENTANGLE, oTestTarget);
                        break;
                    case HENCH_AREA_CHECK_ATTDEC:
                        nTempResult = GetIsImmune(oTestTarget, IMMUNITY_TYPE_ATTACK_DECREASE, OBJECT_SELF) ||
                            GetIsDisabled1(EFFECT_TYPE_ATTACK_DECREASE, oTestTarget);
                        break;
                    case HENCH_AREA_CHECK_PETRIFY:
                        nTempResult = spellsIsImmuneToPetrification(oTestTarget) ||
                            GetIsDisabled(oTestTarget);
                        break;
                    case HENCH_AREA_CHECK_CHARM_AND_MIND:
                        nTempResult = GetIsImmune(oTestTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) ||
                            GetIsImmune(oTestTarget, IMMUNITY_TYPE_CHARM, OBJECT_SELF) ||
                            GetIsDisabled1(EFFECT_TYPE_CHARMED, oTestTarget);
                        break;
                    case HENCH_AREA_CHECK_HORRID:
                        nTempResult = GetRacialType(oTestTarget) == RACIAL_TYPE_CONSTRUCT ||
                            GetRacialType(oTestTarget) == RACIAL_TYPE_UNDEAD;
                        break;
                    case HENCH_AREA_CHECK_SLEEP:
                        nTempResult = GetRacialType(oTestTarget) == RACIAL_TYPE_CONSTRUCT ||
                            GetRacialType(oTestTarget) == RACIAL_TYPE_UNDEAD ||
                            GetHitDice(oTestTarget) > 5 || GetIsDisabled(oTestTarget);
                        break;
                    case HENCH_AREA_CHECK_NEGLEVEL:
                        nTempResult = GetRacialType(oTestTarget) == RACIAL_TYPE_UNDEAD ?
                            (bIsEnemy ? 1 : (GetPercentageHPLoss(oTestTarget) < 90 ? 2 : 1)) : 0;
                        break;
                    case HENCH_AREA_CHECK_HEAL:
                        nTempResult = GetRacialType(oTestTarget) != RACIAL_TYPE_UNDEAD ?
                            (bIsEnemy ? 1 : (GetPercentageHPLoss(oTestTarget) < 90 ? 2 : 1)) : 0;
                        break;
                    case HENCH_AREA_CHECK_DARKNESS:
                        nTempResult = GetHasAnyEffect2(EFFECT_TYPE_ULTRAVISION, EFFECT_TYPE_TRUESEEING, oTestTarget) ||
                            GetHasFeat(FEAT_BLINDSIGHT_60_FEET, oTestTarget) ||
                            GetHasFeat(FEAT_BLIND_FIGHT, oTestTarget) ||
                            GetCreatureHasItemProperty(ITEM_PROPERTY_TRUE_SEEING, oTestTarget) ||
                            (bIsFriend && (GetHasSpell(SPELL_TRUE_SEEING, oTestTarget) ||
                            GetHasSpell(SPELL_DARKVISION, oTestTarget)));
                        break;
                    case HENCH_AREA_CHECK_UNDEAD:
                        nTempResult = GetRacialType(oTestTarget) != RACIAL_TYPE_UNDEAD;
                        break;
                    case HENCH_AREA_CHECK_MINDBLAST:
                        {
                            int nApp = GetAppearanceType(oTestTarget);
                            nTempResult = nApp == APPEARANCE_TYPE_MINDFLAYER ||
                                nApp == APPEARANCE_TYPE_MINDFLAYER_2 ||
                                nApp == APPEARANCE_TYPE_MINDFLAYER_ALHOON ||
                                GetIsImmune(oTestTarget, IMMUNITY_TYPE_STUN, OBJECT_SELF) ||
                                GetIsImmune(oTestTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF);
                        }
                        break;
                    case HENCH_AREA_CHECK_HUMANIOD:
                        nTempResult = !GetIsHumanoid(GetRacialType(oTestTarget));
                        break;
                    case HENCH_AREA_CHECK_CURSE:
                        nTempResult = GetIsImmune(oTestTarget, IMMUNITY_TYPE_CURSED, OBJECT_SELF) ||
                            GetIsDisabled1(EFFECT_TYPE_CURSE, oTestTarget);
                        break;
                    case HENCH_AREA_CHECK_CURSE_SONG:
                        nTempResult = GetHasFeatEffect(FEAT_CURSE_SONG, oTestTarget) ||
                            GetHasEffect(EFFECT_TYPE_DEAF, oTestTarget);
                        break;
                    case HENCH_AREA_CHECK_METEOR_SWARM:
                    // add fire resist check if avail
                        nTempResult = oTestTarget == OBJECT_SELF ||
                            GetDistanceBetween(oTestTarget, OBJECT_SELF) <= 2.0;
                        break;
                    case HENCH_AREA_CHECK_SILENCE:
                        nTempResult = GetIsImmune(oTestTarget, IMMUNITY_TYPE_SILENCE, OBJECT_SELF) ||
                            GetIsDisabled1(EFFECT_TYPE_SILENCE, oTestTarget) ||
                            (GetLevelByClass(CLASS_TYPE_WIZARD, oTestTarget) <= 0 &&
                            GetLevelByClass(CLASS_TYPE_SORCERER, oTestTarget) <= 0 &&
                            GetLevelByClass(CLASS_TYPE_BARD, oTestTarget) <= 0);
                        break;
                    case HENCH_AREA_CHECK_MASS_CHARM:
                        nTempResult = GetIsImmune(oTestTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) ||
                            GetIsImmune(oTestTarget, IMMUNITY_TYPE_CHARM, OBJECT_SELF) ||
                            !GetIsHumanoid(GetRacialType(oTestTarget)) ||
                            GetIsDisabled1(EFFECT_TYPE_CHARMED, oTestTarget);
                        break;
                    case HENCH_AREA_CHECK_DROWN:
                        {
                            int nRacialType = GetRacialType(oTestTarget);
                            nTempResult = nRacialType == RACIAL_TYPE_CONSTRUCT || nRacialType == RACIAL_TYPE_UNDEAD || nRacialType == RACIAL_TYPE_ELEMENTAL;
                        }
                        break;
                    case HENCH_AREA_CHECK_NOT_SELF:
                        nTempResult = oTestTarget == OBJECT_SELF;
                        break;
                    case HENCH_AREA_CHECK_EVARDS_TENTACLES:
                        nTempResult = GetCreatureSize(oTestTarget) < CREATURE_SIZE_MEDIUM ||
                             !CheckGrappleResult(oTestTarget, (bFoundItemSpell ? 7 : (nMySpellCasterLevel > 20 ? 20 : nMySpellCasterLevel)) + 4, GRAPPLE_CHECK_HOLD);
                        break;
                    case HENCH_AREA_CHECK_MOVE_SPEED_DEC:
                        nTempResult = GetIsImmune(oTestTarget, IMMUNITY_TYPE_MOVEMENT_SPEED_DECREASE, OBJECT_SELF) ||
                            GetHasEffect(EFFECT_TYPE_MOVEMENT_SPEED_DECREASE, oTestTarget);
                        break;
                    case HENCH_AREA_CHECK_GREASE:
                        nTempResult = GetIsImmune(oTestTarget, IMMUNITY_TYPE_MOVEMENT_SPEED_DECREASE, OBJECT_SELF) ||
                            GetIsImmune(oTestTarget, IMMUNITY_TYPE_KNOCKDOWN, OBJECT_SELF) ||
                            GetHasFeat(FEAT_WOODLAND_STRIDE, oTestTarget) ||
                            GetCreatureFlag(oTestTarget, CREATURE_VAR_IS_INCORPOREAL) ||
                            GetIsDisabled1(EFFECT_TYPE_MOVEMENT_SPEED_DECREASE, oTestTarget);
                        break;
                    case HENCH_AREA_CHECK_THUNDERCLAP:
                         nTempResult = oTestTarget == OBJECT_SELF ||
                            ((((GetFortitudeSavingThrow(oTestTarget) - (bIsEnemy ? 0 : 10)) > saveDC) || GetIsImmune(oTestTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) ||
                            GetIsImmune(oTestTarget, IMMUNITY_TYPE_STUN, OBJECT_SELF)) &&
                            (((GetReflexSavingThrow(oTestTarget) - (bIsEnemy ? 0 : 10)) > saveDC) || GetIsImmune(oTestTarget, IMMUNITY_TYPE_KNOCKDOWN, OBJECT_SELF))) ||
                            GetIsDisabled(oTestTarget);
                        break;
                    case HENCH_AREA_CHECK_IRONHORN:
                        nTempResult = oTestTarget == OBJECT_SELF ||
                             !CheckGrappleResult(oTestTarget, 20, GRAPPLE_CHECK_STR);
                        break;
                    case HENCH_AREA_CHECK_PRISM:
                        {
                            int test = Random(7);
                            if (test < 3)
                            {
                                // fire, acid, electicity
                                nTempResult = (GetHasFeat(FEAT_EVASION, oTestTarget) || GetHasFeat(FEAT_IMPROVED_EVASION, oTestTarget)) &&
                                    ((GetReflexSavingThrow(oTestTarget) - (bIsEnemy ? 0 : 10)) > saveDC);
                            }
                            else if (test == 3)
                            {
                                // poison
                                nTempResult = GetIsImmune(oTestTarget, IMMUNITY_TYPE_POISON, OBJECT_SELF) ||
                                    ((GetFortitudeSavingThrow(oTestTarget) - (bIsEnemy ? 0 : 10)) > 20) ||
                                    GetIsDisabled1(EFFECT_TYPE_POISON, oTestTarget);
                            }
                            else if (test == 4)
                            {
                                // paralyze
                                nTempResult = GetIsImmune(oTestTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) ||
                                    GetIsImmune(oTestTarget, IMMUNITY_TYPE_PARALYSIS, OBJECT_SELF) ||
                                    ((GetFortitudeSavingThrow(oTestTarget) - (bIsEnemy ? 0 : 10)) > saveDC) ||
                                    GetIsDisabled(oTestTarget);
                            }
                            else if (test == 5)
                            {
                                // confusion
                                nTempResult = GetIsImmune(oTestTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) ||
                                    GetIsImmune(oTestTarget, IMMUNITY_TYPE_CONFUSED, OBJECT_SELF) ||
                                    ((GetWillSavingThrow(oTestTarget) - (bIsEnemy ? 0 : 10)) > saveDC) ||
                                    GetIsDisabled(oTestTarget);
                            }
                            else
                            {
                                // death
                                nTempResult = GetIsImmune(oTestTarget, IMMUNITY_TYPE_DEATH, OBJECT_SELF) ||
                                    ((GetWillSavingThrow(oTestTarget) - (bIsEnemy ? 0 : 10)) > saveDC) ||
                                    GetIsDisabled(oTestTarget);
                            }
                        }
                    }
                }
                if (bIsEnemy)
                {
                    nSaveResult = nTempResult ? HENCH_CREATURE_SAVE_ENEMY : HENCH_CREATURE_NOSAVE_ENEMY;
                }
                else if (bIsFriend)
                {
                    if (bIsBeneficial)
                    {
                        if (nTempResult == 0)
                        {
                            nSaveResult = checkFriendly ? HENCH_CREATURE_NOSAVE_FRIEND : HENCH_CREATURE_OTHER_IGNORE;
                        }
                        else if (nTempResult == 1)
                        {
                            nSaveResult = HENCH_CREATURE_OTHER_IGNORE;
                        }
                        else
                        {
                            nSaveResult = HENCH_CREATURE_BENEFIT_FRIEND;
                        }
                    }
                    else if (checkFriendly)
                    {
                        nSaveResult = nTempResult ? HENCH_CREATURE_SAVE_FRIEND : HENCH_CREATURE_NOSAVE_FRIEND;
                    }
                    else
                    {
                        nSaveResult = HENCH_CREATURE_OTHER_IGNORE;
                    }
                }
                SetLocalInt(oTestTarget, sCreatureSaveResultStr, nSaveResult);
            }
            if (nSaveResult == HENCH_CREATURE_NOSAVE_ENEMY)
            {
                extraEnemyCount ++;
                if (oTestTarget == oTarget)
                {
                    bTargetFound = TRUE;
                }
            }
            else if (nSaveResult == HENCH_CREATURE_NOSAVE_FRIEND)
            {
                    // TODO for now don't do spell if any friendly targets
                extraEnemyCount = -100;
                break;
            }
            else if (nSaveResult == HENCH_CREATURE_BENEFIT_FRIEND)
            {
                associateBenefit ++;
            }

            //Select the next target within the spell shape.
            oTestTarget = GetNextObjectInShape(shape, size, testTargetLoc, TRUE, OBJECT_TYPE_CREATURE, GetPosition(OBJECT_SELF));
        }
        if (extraEnemyCount >= 0)
        {
            extraEnemyCount += associateBenefit;
        }
        if (bTargetFound && extraEnemyCount > nResultExtraTargets)
        {
            nResultExtraTargets = extraEnemyCount;
            oResultTarget = oCurTarget;
            resultTargetLoc = testTargetLoc;
        }
        if (!iDoLoop)
        {
            break;
        }
        curLoopCount ++;
        oCurTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY,
            OBJECT_SELF, curLoopCount, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN,
            CREATURE_TYPE_IS_ALIVE, TRUE);
    }
    if (nResultExtraTargets < 0)
    {
        return FALSE;
    }
    if (nResultExtraTargets > nAreaSpellExtraTargets)
    {
        nAreaSpellExtraTargets = nResultExtraTargets;
        oAreaSpellTarget = oResultTarget;
        areaSpellTargetLoc = resultTargetLoc;
        return TRUE;
    }
    return FALSE;
}


int GetDismissalCount(object oTarget, int shape, float size, float range, int bBanish)
{
    int nResultExtraTargets = -1;
    location resultTargetLoc;
    object oResultTarget;

    if (GetDistanceToObject(oTarget) <= 8.0)
    {
        resultTargetLoc = GetLocation(oTarget);
        oResultTarget = oTarget;
    }
    else
    {
        resultTargetLoc = GetLocation(OBJECT_SELF);
        oResultTarget = OBJECT_SELF;
    }

    int spellLevel = bBanish ? 6 : 4;
    int nCasterLevel = bFoundItemSpell ? (spellLevel * 2) + d4(2) + 2 : nMySpellCasterSpellPenetration;
    int saveDC = bFoundItemSpell ? (spellLevel * 3) / 2 + 10 + nMySpellCasterDCAdjust : nMySpellCasterDC + spellLevel;
    if (!bBanish)
    {
        saveDC += 6;
    }

     // adjust challenge so we don't turn very weak enemies
    float fTotalChallenge = 0.0;
    float fTotalThreshold = pow(1.5, (IntToFloat(GetHitDice(OBJECT_SELF)) * HENCH_HITDICE_TO_CR) - 2.0);

   //Declare the spell shape, size and the location.  Capture the first target object in the shape.
    object oTarget = GetFirstObjectInShape(shape, size, resultTargetLoc, TRUE, OBJECT_TYPE_CREATURE);

    //Cycle through the targets within the spell shape until an invalid object is captured.
    while (GetIsObjectValid(oTarget))
    {
        int nAssocType = GetAssociateType(oTarget);
        if (nAssocType == ASSOCIATE_TYPE_SUMMONED ||
            nAssocType == ASSOCIATE_TYPE_FAMILIAR ||
            nAssocType == ASSOCIATE_TYPE_ANIMALCOMPANION ||
            (bBanish && GetRacialType(oTarget) == RACIAL_TYPE_OUTSIDER) ||
            GetLocalInt(oTarget, sHenchPseudoSummon))
        {
            int nBoost = 0;
            if (GetIsFriend(oTarget))
            {
                nBoost = 13;
            }
            if (((GetSpellResistance(oTarget) - nBoost) <= nCasterLevel) &&
                ((GetWillSavingThrow(oTarget) - nBoost) <= saveDC))
            {
                if (GetIsFriend(oTarget))
                {
                    return FALSE;
                }
                if (GetIsEnemy(oTarget) && (GetObjectSeen(oTarget) || GetObjectHeard(oTarget)))
                {
                    fTotalChallenge += pow(1.5, GetChallengeRating(oTarget));
                    if(fTotalChallenge >= fTotalThreshold)
                    {
                        nAreaSpellExtraTargets = 100;
                        oAreaSpellTarget = oResultTarget;
                        areaSpellTargetLoc = resultTargetLoc;
                        return TRUE;
                    }
                }
            }
        }
        //Select the next target within the spell shape.
        oTarget = GetNextObjectInShape(shape, size, resultTargetLoc, TRUE, OBJECT_TYPE_CREATURE);
    }
    return FALSE;
}


// TURN UNDEAD
int GetTurningEnemyCount()
{
    int nResultExtraTargets = -1;

    // don't turn again until five checks have passed
    int combatRoundCount = GetLocalInt(OBJECT_SELF, henchCombatRoundStr);
    int lastTurning = GetLocalInt(OBJECT_SELF, henchLastTurnStr);
    if (lastTurning != 0 && lastTurning > combatRoundCount - 5)
    {
        return FALSE;
    }

    int nClericLevel = GetLevelByClass(CLASS_TYPE_CLERIC);
    int nPaladinLevel = GetLevelByClass(CLASS_TYPE_PALADIN);
    int nBlackguardlevel = GetLevelByClass(CLASS_TYPE_BLACKGUARD);
    int nTotalLevel =  GetHitDice(OBJECT_SELF);
    int nTurnLevel = nClericLevel;
    int nClassLevel = nClericLevel;
    if((nBlackguardlevel - 2) > 0 && (nBlackguardlevel > nPaladinLevel))
    {
        nClassLevel += (nBlackguardlevel - 2);
        nTurnLevel  += (nBlackguardlevel - 2);
    }
    else if((nPaladinLevel - 2) > 0)
    {
        nClassLevel += (nPaladinLevel -2);
        nTurnLevel  += (nPaladinLevel - 2);
    }

    //Flags for bonus turning types
    int nElemental = GetHasFeat(FEAT_AIR_DOMAIN_POWER) || GetHasFeat(FEAT_EARTH_DOMAIN_POWER) ||  GetHasFeat(FEAT_FIRE_DOMAIN_POWER) || GetHasFeat(FEAT_WATER_DOMAIN_POWER);
    int nVermin = GetHasFeat(FEAT_PLANT_DOMAIN_POWER);
    int nConstructs = GetHasFeat(FEAT_DESTRUCTION_DOMAIN_POWER);
    int nOutsider = GetHasFeat(FEAT_GOOD_DOMAIN_POWER) || GetHasFeat(FEAT_EVIL_DOMAIN_POWER);
    int nPlanar = GetHasFeat(854);

    //Flag for improved turning ability
    int nSun = GetHasFeat(FEAT_SUN_DOMAIN_POWER);

    //Make a turning check roll, modify if have the Sun Domain
    int nChrMod = GetAbilityModifier(ABILITY_CHARISMA);
    // normal check is d20 - changed to not try very often for very difficult turn
    int nTurnCheck = d10(2) +  nChrMod;              //The roll to apply to the max HD of undead that can be turned --> nTurnLevel

    if(nSun == TRUE)
    {
        nTurnCheck += d4();
    }

    if (nTurnCheck < 0)
    {
        nTurnCheck = 0;
    }
    else if (nTurnCheck > 22)
    {
        nTurnCheck = 22;
    }
    //Determine the maximum HD of the undead that can be turned.
    nTurnLevel += (nTurnCheck + 2) / 3 - 4;

    // adjust challenge so we don't turn very weak enemies
    float fTotalChallenge = 0.0;
    float fTotalThreshold = pow(1.5, (IntToFloat(GetHitDice(OBJECT_SELF)) * HENCH_HITDICE_TO_CR) - 2.0);

    int nRacial;
    int nHD;

    // note the size of turning is 20.0 allows more to be turned
    int nCnt = 1;
    object oTarget = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE , OBJECT_SELF, nCnt, CREATURE_TYPE_PERCEPTION , PERCEPTION_SEEN);
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while (GetIsObjectValid(oTarget) && GetDistanceToObject(oTarget) <= 20.0)
    {
        if (GetIsEnemy(oTarget))
        {
            nRacial = GetRacialType(oTarget);
            if (nRacial == RACIAL_TYPE_UNDEAD ||
                (nRacial == RACIAL_TYPE_VERMIN && nVermin > 0) ||
                (nRacial == RACIAL_TYPE_ELEMENTAL && nElemental > 0) ||
                (nRacial == RACIAL_TYPE_CONSTRUCT && nConstructs > 0) ||
                (nRacial == RACIAL_TYPE_OUTSIDER && nOutsider > 0))
            {
                if (!GetHasEffect(EFFECT_TYPE_TURNED, oTarget))
                {
                    if (nRacial == RACIAL_TYPE_OUTSIDER )
                    {
                        if (nPlanar)
                        {
                             //Planar turning decreases spell resistance against turning by 1/2
                             nHD = GetHitDice(oTarget) + (GetSpellResistance(oTarget) / 2) + GetTurnResistanceHD(oTarget);
                        }
                        else
                        {
                            nHD = GetHitDice(oTarget) + (GetSpellResistance(oTarget) + GetTurnResistanceHD(oTarget) );
                        }
                    }
                    else //(full turn resistance)
                    {
                          nHD = GetHitDice(oTarget) + GetTurnResistanceHD(oTarget);
                    }
                    if(nHD <= nTurnLevel)
                    {
                        fTotalChallenge += pow(1.5, GetIsPC(oTarget) ||
                            GetAssociateType(oTarget) == ASSOCIATE_TYPE_HENCHMAN ?
                            IntToFloat(GetHitDice(oTarget)) * HENCH_HITDICE_TO_CR :
                            GetChallengeRating(oTarget));
                    }
                    if(fTotalChallenge >= fTotalThreshold || GetHitDice(oTarget) > 9)
                    {
                        nAreaSpellExtraTargets = 100;
                        oAreaSpellTarget = OBJECT_SELF;
                        areaSpellTargetLoc = GetLocation(OBJECT_SELF);
                        SetLocalInt(OBJECT_SELF, henchLastTurnStr, combatRoundCount);
                        return TRUE;
                    }
                }
            }
        }
        //Select the next target within the spell shape.
        nCnt++;
        oTarget = GetNearestCreature(CREATURE_TYPE_IS_ALIVE,TRUE, OBJECT_SELF, nCnt, CREATURE_TYPE_PERCEPTION , PERCEPTION_SEEN);
    }
    return FALSE;
}


int iGlobalTargetType, iGlobalSpell;
int iBestDispel;
int iBestDispelSpellLevel;
int iBestBreach;
int iBestBreachSpellLevel;

int GetBestDispelSpells()
{
    if (GetHasFixedSpell(SPELL_MORDENKAINENS_DISJUNCTION))
    {
        iBestDispel = SPELL_MORDENKAINENS_DISJUNCTION;
        iBestBreach = SPELL_MORDENKAINENS_DISJUNCTION;
        iBestDispelSpellLevel = 9;
        iBestBreachSpellLevel = 9;
    }
    else if (GetHasFixedSpell(SPELL_GREATER_DISPELLING))
    {
        iBestDispel = SPELL_GREATER_DISPELLING;
        iBestBreach = SPELL_GREATER_DISPELLING;
        iBestDispelSpellLevel = 6;
        iBestBreachSpellLevel = 6;
    }
    else
    {
        if (GetHasFixedSpell(SPELL_GREATER_SPELL_BREACH))
        {
            iBestBreach = SPELL_GREATER_SPELL_BREACH;
            iBestBreachSpellLevel = 6;
        }
        if (GetHasFixedSpell(SPELL_DISPEL_MAGIC))
        {
            iBestDispel = SPELL_DISPEL_MAGIC;
            iBestDispelSpellLevel = 3;
            if (!iBestBreach)
            {
                iBestBreach = SPELL_DISPEL_MAGIC;
                iBestBreachSpellLevel = 3;
            }
        }
        if (!iBestBreach)
        {
            if (GetHasFixedSpell(SPELL_LESSER_SPELL_BREACH))
            {
                iBestBreach = SPELL_LESSER_SPELL_BREACH;
                iBestBreachSpellLevel = 4;
            }
            if (GetHasFixedSpell(SPELL_LESSER_DISPEL))
            {
                iBestDispel = SPELL_LESSER_DISPEL;
                iBestDispelSpellLevel = 2;
                if (!iBestBreach)
                {
                    iBestBreach = SPELL_LESSER_DISPEL;
                    iBestBreachSpellLevel = 2;
                }
            }
        }
    }
    return iBestBreach;
}


// if object specified, make sure in range of dispel
// try to minimize friendly targets in dispel area
int globalBestEnemyCount;
location FindBestDispelLocation(object oAOEProblem = OBJECT_INVALID)
{
    location testTargetLoc;
    int curLoopCount = 1;
    object oTestTarget;
    int extraEnemyCount;
    object oResultTarget = OBJECT_INVALID;
    globalBestEnemyCount = -100;
    int bFoundTargetObject;
    int bHasAOEProblem = GetIsObjectValid(oAOEProblem);
    int bFoundAnyTarget;

    object oTarget = GetNearestCreature(CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, OBJECT_SELF, 1);
    while (GetIsObjectValid(oTarget) && curLoopCount <= 10 && GetDistanceToObject(oTarget) <= 9.0)
    {
        testTargetLoc = GetLocation(oTarget);
        extraEnemyCount = 0;
        bFoundTargetObject = FALSE;
        bFoundAnyTarget = FALSE;

        //Declare the spell shape, size and the location.  Capture the first target object in the shape.
        oTestTarget = GetFirstObjectInShape(SHAPE_SPHERE, 5.0, testTargetLoc, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_AREA_OF_EFFECT);
        //Cycle through the targets within the spell shape until an invalid object is captured.
        while (GetIsObjectValid(oTestTarget))
        {
            if (GetObjectType(oTestTarget) == OBJECT_TYPE_AREA_OF_EFFECT)
            {
                if (oTestTarget == oAOEProblem)
                {
                    bFoundTargetObject = TRUE;
                }
                if (GetStringLeft(GetTag(oTestTarget), 8) == "VFX_PER_")
                {
                    if (GetIsEnemy(GetAreaOfEffectCreator(oTestTarget)))
                    {
                        bFoundAnyTarget = TRUE;
                        extraEnemyCount ++;
                    }
                    else if (GetIsFriend(GetAreaOfEffectCreator(oTestTarget)))
                    {
                        if (!bHasAOEProblem)
                        {
                            extraEnemyCount = -100;
                            break;
                        }
                        extraEnemyCount --;
                    }
                }
            }
            else
            {
                    // TODO Jug_GetHasBeneficialEnhancement removed because too many instruction error
                if (GetIsEnemy(oTestTarget) /* && Jug_GetHasBeneficialEnhancement(oTestTarget) */)
                {
                    extraEnemyCount ++;
                }
                else if (GetIsFriend(oTestTarget) /* && Jug_GetHasBeneficialEnhancement(oTestTarget) */)
                {
                    extraEnemyCount --;
                }
            }
            //Select the next target within the spell shape.
            oTestTarget = GetNextObjectInShape(SHAPE_SPHERE, 5.0, testTargetLoc, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_AREA_OF_EFFECT);
        }
        if (bFoundTargetObject || (!bHasAOEProblem && bFoundAnyTarget))
        {
            if (extraEnemyCount > globalBestEnemyCount)
            {
                globalBestEnemyCount = extraEnemyCount;
                oResultTarget = oTarget;
            }
        }
        curLoopCount ++;
        oTarget = GetNearestCreature(CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, OBJECT_SELF, curLoopCount);
    }
    if (globalBestEnemyCount < 0)
    {
        return GetLocation(oAOEProblem);
    }
    return GetLocation(oResultTarget);
}


int GetDispelTarget(object oTarget)
{
        // try to limit the casting of dispel/breach in case it fails
    int combatRoundCount = GetLocalInt(OBJECT_SELF, henchCombatRoundStr);
    int lastDispel = GetLocalInt(OBJECT_SELF, henchLastDispelStr);
    if (lastDispel != 0 && lastDispel >= combatRoundCount - 5)
    {
        return FALSE;
    }
    int nBenTargetEffect = Jug_GetHasBeneficialEnhancement(oTarget);
        // just check target for breach
    if (!iBestDispel)
    {
        if (nBenTargetEffect == 2)
        {
            oAreaSpellTarget = oTarget;
            iGlobalTargetType = TARGET_SPELL_AREA_ON_OBJECT;
            iGlobalSpell = iBestBreach;
            SetLocalInt(OBJECT_SELF, henchLastDispelStr, combatRoundCount);
            return TRUE;
        }
        return FALSE;
    }
    // TODO removed for now
/*
    location dispLoc = FindBestDispelLocation();
    if ((nBenTargetEffect == 0 && globalBestEnemyCount > 0) ||
        (nBenTargetEffect > 0 && globalBestEnemyCount > 2))
    {
        areaSpellTargetLoc = dispLoc;
        nAreaSpellExtraTargets = globalBestEnemyCount;
        iGlobalTargetType = TARGET_SPELL_AT_LOCATION;
        iGlobalSpell = iBestDispel;
        return TRUE;
    } */
    if (nBenTargetEffect == 0)
    {
        return FALSE;
    }
    if (nBenTargetEffect == 2)
    {
        oAreaSpellTarget = oTarget;
        iGlobalTargetType = TARGET_SPELL_AREA_ON_OBJECT;
        iGlobalSpell = iBestBreach;
        SetLocalInt(OBJECT_SELF, henchLastDispelStr, combatRoundCount);
        return TRUE;
    }
    // nBenTargetEffect == 1
    if (iBestDispel)
    {
        oAreaSpellTarget = oTarget;
        iGlobalTargetType = TARGET_SPELL_AREA_ON_OBJECT;
        iGlobalSpell = iBestDispel;
        SetLocalInt(OBJECT_SELF, henchLastDispelStr, combatRoundCount);
        return TRUE;
    }
    return FALSE;
}


int TK_CheckDragonBreath()
{
    int combatRoundCount = GetLocalInt(OBJECT_SELF, henchCombatRoundStr);
    int lastDragonBreath = GetLocalInt(OBJECT_SELF, henchLastDraBrStr);
    if (lastDragonBreath == 0 || lastDragonBreath < combatRoundCount - 2)
    {
        return TRUE;
    }
    return FALSE;
}


int CheckInvisibility(object oInvis)
{
    if (!GetIsObjectValid(oInvis))
    {
        return 0;
    }
    effect eCheck = GetFirstEffect(oInvis);
    while (GetIsEffectValid(eCheck))
    {
        if (GetEffectSubType(eCheck) != SUBTYPE_EXTRAORDINARY)
        {
            int iType = GetEffectType(eCheck);

            if (iType == EFFECT_TYPE_INVISIBILITY ||
                iType == EFFECT_TYPE_IMPROVEDINVISIBILITY)
            {
                return 3;
            }
            if (iType == EFFECT_TYPE_SANCTUARY)
            {
                return 1;
            }
        }
        eCheck = GetNextEffect(oInvis);
    }
    if (GetStealthMode(oInvis) == STEALTH_MODE_ACTIVATED)
    {
        return 2;
    }

    return 0;
}


int GetHasEquippedBow()
{
    int itemType = GetBaseItemType(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND));
    return (itemType == BASE_ITEM_LONGBOW) || (itemType  == BASE_ITEM_SHORTBOW);
}


int bBuffTargetInitDone;
int nNumAlliesFound;

const string henchAllyArrayStr = "HenchAllyList";

void InitializeAllyTargets(int bUseThreshold = TRUE)
{
    if (bBuffTargetInitDone)
    {
        return;
    }
    bBuffTargetInitDone = TRUE;
    object oFriend;
    int curCount = 1;
    int iFriendHD;
    object oFriendMaster;
    int iTestHD;
    int curTestIndex;
    int bSkipTest;
    int iThresholdHD = bUseThreshold ? GetHitDice(OBJECT_SELF) * 3 / 4 : -1000;
    nNumAlliesFound = 0;

    float fDistaceThreshold = nGlobalMeleeAttackers ? 5.0 : 20.0;
    int iMaxNumToFind = bUseThreshold ? 5 : 10;

    while (TRUE)
    {
        oFriend = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND,
            OBJECT_SELF, curCount, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN,
            CREATURE_TYPE_IS_ALIVE, TRUE);
        if (!GetIsObjectValid(oFriend))
        {
            break;
        }
        if (GetDistanceToObject(oFriend) > fDistaceThreshold)
        {
            break;
        }
        bSkipTest = FALSE;
            // boost master, always try them first
        if (GetMaster() == oFriend)
        {
            iFriendHD = 10000;
        }
        else
        {
            // remove dominated, reduce associates except for henchmen
            int nAssocType = GetAssociateType(oFriend);
            if (nAssocType == ASSOCIATE_TYPE_DOMINATED)
            {
                bSkipTest = TRUE;
            }
            else if (nAssocType == ASSOCIATE_TYPE_HENCHMAN)
            {
                iFriendHD = GetHitDice(oFriend);
            }
            else
            {
                iFriendHD = GetHitDice(oFriend) * 3 / 4;
            }
        }
        if (!bSkipTest && !bUseThreshold && !GetIsPC(GetTopMaster(oFriend)))
        {
            // during buff dialog request, only do members in group
            bSkipTest = TRUE;
        }
        if (!bSkipTest && iFriendHD >= iThresholdHD)
        {
            curTestIndex = nNumAlliesFound - 1;
            while (curTestIndex >= 0 && (iTestHD = GetIntArray(OBJECT_SELF, henchAllyArrayStr, curTestIndex)) <= iFriendHD)
            {
                SetObjectArray(OBJECT_SELF, henchAllyArrayStr, curTestIndex + 1, GetObjectArray(OBJECT_SELF, henchAllyArrayStr, curTestIndex));
                SetIntArray(OBJECT_SELF, henchAllyArrayStr, curTestIndex + 1, iTestHD);
                curTestIndex --;
            }
            if (curTestIndex < iMaxNumToFind)
            {
                nNumAlliesFound++;
                SetObjectArray(OBJECT_SELF, henchAllyArrayStr, curTestIndex + 1, oFriend);
                SetIntArray(OBJECT_SELF, henchAllyArrayStr, curTestIndex + 1, iFriendHD);
            }
        }
        curCount++;
        if (curCount > 20)
        {
            break;
        }
    }
}


object oBestBuffTarget;

int GetBestBuffTarget(int nImmuneType1, int nEffect1, int nEffect2, int nItemProp)
{
    InitializeAllyTargets();

    int curCount;
    object oFriend;

    for (curCount = 0; curCount < nNumAlliesFound; curCount++)
    {
        oFriend = GetObjectArray(OBJECT_SELF, henchAllyArrayStr, curCount);
        if (nImmuneType1 < 0 || !GetIsImmune(oFriend, nImmuneType1))
        {
            if ((nEffect1 < 0 && nEffect2 < 0) || !GetHasEffect(nEffect1, oFriend) ||
                (nEffect1 >= 0 && nEffect2 >= 0 && !GetHasEffect(nEffect2, oFriend)))
            {
                if (nItemProp < 0 || !GetCreatureHasItemProperty(nItemProp, oFriend))
                {
                    // found target
                    oBestBuffTarget = oFriend;
                    return TRUE;
                }
            }
        }
    }
    return FALSE;
}


int GetBestElemProtTarget()
{
    InitializeAllyTargets();

    int curCount;
    object oFriend;

    for (curCount = 0; curCount < nNumAlliesFound; curCount++)
    {
        oFriend = GetObjectArray(OBJECT_SELF, henchAllyArrayStr, curCount);

        if (!GetHasSpellEffect(SPELL_PROTECTION_FROM_ELEMENTS, oFriend) &&
            !GetHasSpellEffect(SPELL_ENERGY_BUFFER, oFriend) &&
            !GetHasSpellEffect(SPELL_RESIST_ELEMENTS, oFriend) &&
            !GetHasSpellEffect(SPELL_ENDURE_ELEMENTS, oFriend) &&
            !GetHasSpellEffect(SPELL_ELEMENTAL_SHIELD, oFriend))
        {
            oBestBuffTarget = oFriend;
            return TRUE;
        }
    }

    return FALSE;
}


int GetBestSpellProtTarget(int buffSelf, int buffOthers, int nLastSpellCast)
{
    // determine available spells
    if (!GetHasFixedSpell(SPELL_SPELL_RESISTANCE) || nLastSpellCast == SPELL_SPELL_RESISTANCE)
    {
        return FALSE;
    }
    // prepare for loop counters
    InitializeAllyTargets();
    int curCount = buffSelf ? -1 : 0;
    int nMaxCount = buffOthers ? nNumAlliesFound : 0;
    object oHenchBuffTarget = OBJECT_SELF;

    int estResistance = 12 + bFoundItemSpell ? 9 : nMySpellCasterLevel;
    estResistance *= 2;
    estResistance /= 3;

    for (; curCount < nMaxCount; curCount++)
    {
        if (curCount >= 0)
        {
            oHenchBuffTarget = GetObjectArray(OBJECT_SELF, henchAllyArrayStr, curCount);
        }
        if (!GetHasSpellEffect(SPELL_SPELL_RESISTANCE, oHenchBuffTarget) &&
            (GetSpellResistance(oHenchBuffTarget) < estResistance))
        {
            CastSetLastSpellOnObject(SPELL_SPELL_RESISTANCE, oHenchBuffTarget, 5);
            return curCount >= 0 ? TK_BUFFOTHER : TK_BUFFSELF;
        }
    }
    return FALSE;
}


// TODO temp until level can be determined for all
int iMaxSpellProtLevel;

int CheckSpellSaves(object oTarget, int spellLevel, int saveType)
{
    if (spellLevel <= iMaxSpellProtLevel)
    {
        return FALSE;
    }
    if (saveType & HENCH_CHECK_SR_FLAG)
    {
        int nCasterLevel = bFoundItemSpell ? (spellLevel * 2) + d4(2) + 2 : nMySpellCasterSpellPenetration;

        if (GetSpellResistance(oTarget) > nCasterLevel)
        {
            return FALSE;
        }
    }
    int saveDC = bFoundItemSpell ? (spellLevel * 3) / 2 + 10 + nMySpellCasterDCAdjust : nMySpellCasterDC + spellLevel;
    if (saveType & HENCH_CHECK_WILL_SAVE_FLAG)
    {
        if (GetWillSavingThrow(oTarget) > saveDC)
        {
            return FALSE;
        }
    }
    if (saveType & HENCH_CHECK_FORT_SAVE_FLAG)
    {
        if (GetFortitudeSavingThrow(oTarget) > saveDC)
        {
            return FALSE;
        }
    }
    if (saveType & HENCH_CHECK_REFLEX_SAVE_FLAG)
    {
        if (GetReflexSavingThrow(oTarget) > saveDC)
        {
            return FALSE;
        }
    }
    if (saveType & HENCH_CHECK_REFLEX_EVASION_SAVE_FLAG)
    {
        if ((GetHasFeat(FEAT_EVASION, oTarget) || GetHasFeat(FEAT_IMPROVED_EVASION, oTarget)) &&
            (GetReflexSavingThrow(oTarget) > saveDC))
        {
            return FALSE;
        }
    }
    return TRUE;
}


int bGlobalAttrBuffOver;
int GetBestAttribBuff(int buffSelf, int buffOthers, int nLastSpellCast, int bForceSelf = FALSE)
{
    // determine available spells
    int nEndurance;
    if (GetHasFixedSpell(SPELL_ENDURANCE) && nLastSpellCast != SPELL_ENDURANCE)
    {
        nEndurance = bFoundPotionOnly ? 1 : 2;
    }
    int nCatsGrace;
    int bCGIsFeat;
    if (GetHasFeat(FEAT_HARPER_CATS_GRACE))
    {
        bCGIsFeat = TRUE;
        bFoundSpellGlobal = TRUE;
        nCatsGrace = 2;
    }
    else if (GetHasFixedSpell(SPELL_CATS_GRACE) && nLastSpellCast != SPELL_CATS_GRACE)
    {
        nCatsGrace = bFoundPotionOnly ? 1 : 2;
    }
    int nBullsStrength;
    int bBGIsFeat;
    if (GetHasFeat(FEAT_BULLS_STRENGTH))
    {
        bBGIsFeat = TRUE;
        bFoundSpellGlobal = TRUE;
        nBullsStrength = 1;
    }
    else if (GetHasFixedSpell(SPELL_BULLS_STRENGTH) && nLastSpellCast != SPELL_BULLS_STRENGTH)
    {
        nBullsStrength = bFoundPotionOnly ? 1 : 2;
    }
    // trim possible actions based on available spells
    if (!nBullsStrength && !nCatsGrace && !nEndurance)
    {
        return FALSE;
    }
    if (!buffOthers && !buffSelf)
    {
        return FALSE;
    }
    int bSelfOnly = (nBullsStrength < 2) && (nCatsGrace < 2) && (nEndurance < 2);
    if (bSelfOnly && buffOthers && !buffSelf)
    {
        return FALSE;
    }
    if (bSelfOnly)
    {
        buffOthers = FALSE;
    }
    // prepare for loop counters
    InitializeAllyTargets();
    int curCount = buffSelf ? -1 : 0;
    int nMaxCount = buffOthers ? nNumAlliesFound : 0;
    object oHenchBuffTarget = OBJECT_SELF;
    int nThreshHold = 1;
    int nClass;
    for (; curCount < nMaxCount; curCount++)
    {
        if (curCount >= 0)
        {
            oHenchBuffTarget = GetObjectArray(OBJECT_SELF, henchAllyArrayStr, curCount);
            nThreshHold = 2;
        }

        nClass = HenchDetermineClassToUse(oHenchBuffTarget);
        object oRightWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oHenchBuffTarget);
        int bRanged = GetWeaponRanged(oRightWeapon);
        if (bForceSelf || bGlobalAttrBuffOver || !(nClass == CLASS_TYPE_WIZARD || nClass == CLASS_TYPE_SORCERER) ||
            GetHasEffect(EFFECT_TYPE_POLYMORPH, oHenchBuffTarget))
        {
            if (nEndurance >= nThreshHold && !GetHasSpellEffect(SPELL_ENDURANCE, oHenchBuffTarget) &&
                (bGlobalAttrBuffOver || !bRanged || GetPercentageHPLoss(oHenchBuffTarget) <= 90))
            {
                CastSetLastSpellOnObject(SPELL_ENDURANCE, oHenchBuffTarget, 2);
                return TRUE;
            }
            if (nBullsStrength >= nThreshHold && !GetHasSpellEffect(SPELL_BULLS_STRENGTH, oHenchBuffTarget) &&
                !GetHasFeatEffect(FEAT_BULLS_STRENGTH, oHenchBuffTarget) && !bRanged)
            {
                if (bBGIsFeat)
                {
                    CastFeatOnObject(FEAT_BULLS_STRENGTH, OBJECT_SELF);
                }
                else
                {
                    CastSetLastSpellOnObject(SPELL_BULLS_STRENGTH, oHenchBuffTarget, 2);
                }
                return curCount >= 0 ? TK_BUFFOTHER : TK_BUFFSELF;
            }
        }
        if (nCatsGrace >= nThreshHold && !GetHasSpellEffect(SPELL_CATS_GRACE, oHenchBuffTarget) &&
            !GetHasFeatEffect(FEAT_HARPER_CATS_GRACE) && (bGlobalAttrBuffOver || bRanged ||
            GetAbilityModifier(ABILITY_DEXTERITY, oHenchBuffTarget) > 1 || GetHasFeat(FEAT_WEAPON_FINESSE, oHenchBuffTarget)))
        {
            if (bCGIsFeat)
            {
                CastFeatOnObject(FEAT_HARPER_CATS_GRACE, OBJECT_SELF);
                return curCount >= 0 ? TK_BUFFOTHER : TK_BUFFSELF;
            }
            else
            {
                CastSetLastSpellOnObject(SPELL_CATS_GRACE, oHenchBuffTarget, 2);
            }
            return curCount >= 0 ? TK_BUFFOTHER : TK_BUFFSELF;
        }
    }
    return FALSE;
}


int GetBestUndeadBuff(int buffSelf, int buffOthers, int nLastSpellCast)
{
    // determine available spells
    if (!GetHasFixedSpell(SPELL_STONE_BONES) || nLastSpellCast == SPELL_STONE_BONES)
    {
        return FALSE;
    }
    // prepare for loop counters
    InitializeAllyTargets();
    int curCount = buffSelf ? -1 : 0;
    int nMaxCount = buffOthers ? nNumAlliesFound : 0;
    object oHenchBuffTarget = OBJECT_SELF;

    for (; curCount < nMaxCount; curCount++)
    {
        if (curCount >= 0)
        {
            oHenchBuffTarget = GetObjectArray(OBJECT_SELF, henchAllyArrayStr, curCount);
        }
        if (GetRacialType(oHenchBuffTarget) == RACIAL_TYPE_UNDEAD &&
            !GetHasSpellEffect(SPELL_STONE_BONES, oHenchBuffTarget))
        {
            CastSetLastSpellOnObject(SPELL_STONE_BONES, oHenchBuffTarget, 2);
            return curCount >= 0 ? TK_BUFFOTHER : TK_BUFFSELF;
        }
    }
    return FALSE;
}


void SetLastDominate()
{
    int combatRoundCount = GetLocalInt(OBJECT_SELF, henchCombatRoundStr);
    SetLocalInt(OBJECT_SELF, henchLastDomStr, combatRoundCount);
}


location GetSummonLocation(object oTarget)
{
    if (!GetIsObjectValid(oTarget))
    {
        return GetLocation(OBJECT_SELF);
    }
    vector vTarget = GetPosition(oTarget);
    vector vSource = GetPosition(OBJECT_SELF);
    vector vDirection = vTarget - vSource;
    float fDistance = VectorMagnitude(vDirection);
    // try to get summons just in front of target
    fDistance -= 3.0;
    if (fDistance < 0.5)
    {
        return GetLocation(OBJECT_SELF);
    }
    // maximum distance is 8.0
    if (fDistance > 8.0)
    {
        fDistance = 8.0;
    }
    vector vPoint = VectorNormalize(vDirection) * fDistance + vSource;
    return Location(GetArea(OBJECT_SELF), vPoint, GetFacing(OBJECT_SELF));
}


object HenchDoFakeSummons(string sTemplate, int nLevel, object oTarget, int bHoTUInstalled)
{
    if (nLevel < 1)
    {
        nLevel = GetHitDice(OBJECT_SELF);
    }
    if (!bHoTUInstalled && nLevel > 20)
    {
        nLevel = 20;
    }
    else if (nLevel > 40)
    {
        nLevel = 40;
    }
    if (nLevel < 10)
    {
        sTemplate += "0";
    }
    sTemplate += IntToString(nLevel);

    location summonLocation = GetSummonLocation(oTarget);
    ActionCastFakeSpellAtLocation(318, summonLocation);
    object oCreature = CreateObject(OBJECT_TYPE_CREATURE, sTemplate, summonLocation);
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_FNF_SUMMON_UNDEAD), GetLocation(oCreature));
    ChangeFaction(oCreature, OBJECT_SELF);
    SetLocalInt(oCreature, sHenchPseudoSummon, TRUE);
    SetLocalObject(oCreature, sHenchPseudoSummon, OBJECT_SELF);
    return oCreature;
}


void HenchSummonFamiliar(object oTarget)
{
    if (GetFamiliarName(OBJECT_SELF) != "")
    {
        ActionUseFeat(FEAT_SUMMON_FAMILIAR, OBJECT_SELF);
        return;
    }

    SetLocalInt(OBJECT_SELF, sHenchSummonedFamiliar, TRUE);
    DecrementRemainingFeatUses(OBJECT_SELF, FEAT_SUMMON_FAMILIAR);

    int bSoUInstalled = Get2DAString("hen_familiar", "BASERESREF", 8) == "X0_FM_FDRG";
    int bHoTUInstalled = Get2DAString("hen_familiar", "BASERESREF", 10) == "X2_FM_EYE0";

    int nGoodEvil = GetAlignmentGoodEvil(OBJECT_SELF);
    if (nGoodEvil == ALIGNMENT_NEUTRAL && GetRacialType(OBJECT_SELF) == RACIAL_TYPE_UNDEAD)
    {
        // convert neutral undead to evil for familiar
        nGoodEvil = ALIGNMENT_EVIL;
    }
    string sTemplate;
    if (nGoodEvil == ALIGNMENT_EVIL)
    {
        switch (d4())
        {
        case 1:
            sTemplate = "NW_FM_ICE";
            break;
        case 2:
            sTemplate = "NW_FM_FIRE";
            break;
        default:
            sTemplate = "NW_FM_IMP";
            break;
        }
        if (bHoTUInstalled && d3() == 1)
        {
            sTemplate = "X2_FM_EYE0";
        }
    }
    else if (nGoodEvil == ALIGNMENT_GOOD)
    {
        switch (d6())
        {
        case 1:
            sTemplate = "NW_FM_BAT";
            break;
        case 2:
            sTemplate = "NW_FM_RAVE";
            break;
        case 3:
        case 4:
            sTemplate = "NW_FM_CRAG";
            break;
        default:
            sTemplate = "NW_FM_PIXI";
            break;
        }
        if (d3() == 1 && bSoUInstalled)
        {
            if (d2() == 1)
            {
                sTemplate = "X0_FM_FDRG";
            }
            else
            {
                sTemplate = "X0_FM_PDRG0";
            }
        }
    }
    else    // ALIGNMENT_NEUTRAL
    {
        switch (d6())
        {
        case 1:
            sTemplate = "NW_FM_BAT";
            break;
        case 2:
            sTemplate = "NW_FM_RAVE";
            break;
        case 3:
            sTemplate = "NW_FM_ICE";
            break;
        case 4:
            sTemplate = "NW_FM_FIRE";
            break;
        default:
            sTemplate = "NW_FM_CRAG";
            break;
        }
    }

    object oFam = HenchDoFakeSummons(sTemplate, GetLevelByClass(CLASS_TYPE_WIZARD) +
        GetLevelByClass(CLASS_TYPE_SORCERER), oTarget, bHoTUInstalled);
    SetLocalObject(OBJECT_SELF, sHenchSummonedFamiliar, oFam);
}


void HenchSummonAnimalCompanion(object oTarget)
{
    if (GetAnimalCompanionName(OBJECT_SELF) != "")
    {
        ActionUseFeat(FEAT_ANIMAL_COMPANION, OBJECT_SELF);
        return;
    }

    SetLocalInt(OBJECT_SELF, sHenchSummonedAniComp, TRUE);
    DecrementRemainingFeatUses(OBJECT_SELF, FEAT_ANIMAL_COMPANION);

//    int bSoUInstalled = Get2DAString("hen_companion", "BASERESREF", 8) == "X0_AC_FDRG";
    int bHoTUInstalled = Get2DAString("hen_familiar", "BASERESREF", 10) == "X2_FM_EYE0";

    int nGoodEvil = GetAlignmentGoodEvil(OBJECT_SELF);

    string sTemplate;
    if (nGoodEvil == ALIGNMENT_EVIL)
    {
         sTemplate = "NW_AC_DWLF";
    }
    else
    {
        int nLevel = GetLevelByClass(CLASS_TYPE_DRUID) + GetLevelByClass(CLASS_TYPE_RANGER) - 2;

        nLevel /= 2;

        nLevel += d2(2) - 2;
        if (nLevel < 1)
        {
            nLevel = 1;
        }
        switch (nLevel)
        {
        case 1:
            sTemplate = "NW_AC_BADGER";
            break;
        case 2:
            sTemplate = "NW_AC_BOAR";
            break;
        case 3:
            sTemplate = "NW_AC_HAWK";
            break;
        case 4:
            sTemplate = "NW_AC_WOLF";
            break;
        case 5:
            sTemplate = "NW_AC_SPID";
            break;
        case 6:
            sTemplate = "NW_AC_DWLF";
            break;
        case 7:
        case 8:
            sTemplate = "NW_AC_PANT";
            break;
        default:
            sTemplate = "NW_AC_BEAR";
            break;
        }
    }

    object oAni = HenchDoFakeSummons(sTemplate, GetLevelByClass(CLASS_TYPE_DRUID) +
        GetLevelByClass(CLASS_TYPE_RANGER), oTarget, bHoTUInstalled);
    SetLocalObject(OBJECT_SELF, sHenchSummonedAniComp, oAni);
}


// BARD SONG
// * July 15 2003: Improving so its more likely
// * to work with non creature wizard designed creatures
// * GZ: Capped bardsong at level 20 so we don't overflow into
//       other feats
int HenchTalentBardSong()
{
    int iMyBardFeat;
    int iMyBardLevel = GetLevelByClass(CLASS_TYPE_BARD, OBJECT_SELF);
    if (iMyBardLevel < 1)
    {
        return FALSE;
    }
    if (GetHasSpellEffect(411) || GetHasEffect(EFFECT_TYPE_SILENCE))
    {
        return FALSE;
    }
    //BARD SONG CONSTANT PENDING
    if (iMyBardLevel == 1)
    {
        iMyBardFeat = 257;
    }
    else
    {
        if (iMyBardLevel > 20)
        {
            iMyBardLevel = 20;
        }
        iMyBardFeat = 353 + iMyBardLevel;
    }
    if(GetHasFeat(iMyBardFeat) == TRUE)
    {
        CastFeatOnObject(iMyBardFeat, OBJECT_SELF);
        return TRUE;
    }
    return FALSE;
}


int HenchPerceiveSpellcasterThreat()
{
    int mageThreshold = GetHitDice(OBJECT_SELF) * 2 / 3;
    if (mageThreshold > 15)
    {
        mageThreshold = 15;
    }
    int clericThreshold = GetHitDice(OBJECT_SELF) * 4 / 5;
    if (clericThreshold > 15)
    {
        clericThreshold = 15;
    }
    int curCount = 1;
    object oTarget;
    while (1)
    {
        oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, curCount, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
        if (!GetIsObjectValid(oTarget))
        {
            break;
        }
        if (GetLevelByClass(CLASS_TYPE_WIZARD, oTarget) >= mageThreshold)
        {
            return TRUE;
        }
        if (GetLevelByClass(CLASS_TYPE_SORCERER, oTarget) >= mageThreshold)
        {
            return TRUE;
        }
        if (GetLevelByClass(CLASS_TYPE_CLERIC, oTarget) >= clericThreshold)
        {
            return TRUE;
        }
        if (GetLevelByClass(CLASS_TYPE_DRUID, oTarget) >= clericThreshold)
        {
            return TRUE;
        }
        curCount ++;
    }
    curCount = 1;
    while (1)
    {
        oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, curCount, CREATURE_TYPE_PERCEPTION, PERCEPTION_HEARD_AND_NOT_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
        if (!GetIsObjectValid(oTarget))
        {
            return FALSE;
        }
        if (GetLevelByClass(CLASS_TYPE_WIZARD, oTarget) >= mageThreshold)
        {
            return TRUE;
        }
        if (GetLevelByClass(CLASS_TYPE_SORCERER, oTarget) >= mageThreshold)
        {
            return TRUE;
        }
        if (GetLevelByClass(CLASS_TYPE_CLERIC, oTarget) >= clericThreshold)
        {
            return TRUE;
        }
        if (GetLevelByClass(CLASS_TYPE_DRUID, oTarget) >= clericThreshold)
        {
            return TRUE;
        }
        curCount++;
    }
    return FALSE;
}


const int HENCH_GLOBAL_FLAG_UNCHECKED   = 0;
const int HENCH_GLOBAL_FLAG_TRUE        = 1;
const int HENCH_GLOBAL_FLAG_FALSE       = 2;

int gHenchUseSpellProtectionsChecked;

int HenchUseSpellProtections()
{
// only do the first check
    if (gHenchUseSpellProtectionsChecked)
    {
        return gHenchUseSpellProtectionsChecked == HENCH_GLOBAL_FLAG_TRUE ? TRUE : FALSE;
    }
    if (bGlobalAttrBuffOver || HenchPerceiveSpellcasterThreat())
    {
        gHenchUseSpellProtectionsChecked = HENCH_GLOBAL_FLAG_TRUE;
        return TRUE;
    }
    gHenchUseSpellProtectionsChecked = HENCH_GLOBAL_FLAG_FALSE;
    return FALSE;
}


const int HENCH_WEAPON_STAFF_FLAG      = 0x1;
const int HENCH_WEAPON_SLASH_FLAG      = 0x2;
const int HENCH_WEAPON_HOLY_SWORD      = 0x4;

int GetBestWeaponBuffTarget(int buffSelf, int buffOthers, int nItemProp, int nEnhanceLevel, int nFlags, int nSpell, int nSpellLevel)
{
    // prepare for loop counters
    InitializeAllyTargets();
    int curCount = buffSelf ? -1 : 0;
    int nMaxCount = buffOthers ? nNumAlliesFound : 0;
    object oHenchBuffTarget = OBJECT_SELF;
    int nClass;
    for (; curCount < nMaxCount; curCount++)
    {
        if (curCount >= 0)
        {
            oHenchBuffTarget = GetObjectArray(OBJECT_SELF, henchAllyArrayStr, curCount);
        }
        // get weapon
        object oWeapon1 = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oHenchBuffTarget);
        if (!GetIsObjectValid(oWeapon1))
        {
            oWeapon1 = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oHenchBuffTarget);
            if (!GetIsObjectValid(oWeapon1))
            {
                oWeapon1 = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oHenchBuffTarget);
                if (!GetIsObjectValid(oWeapon1))
                {
                    oWeapon1 = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oHenchBuffTarget);
                }
            }
        }
        if (!GetIsObjectValid(oWeapon1) || !IPGetIsMeleeWeapon(oWeapon1))
        {
            continue;
        }
        if (nFlags & HENCH_WEAPON_STAFF_FLAG)
        {
            if (GetBaseItemType(oWeapon1) != BASE_ITEM_QUARTERSTAFF)
            {
                continue;
            }
        }
        if (nFlags & HENCH_WEAPON_SLASH_FLAG)
        {
            if (!GetSlashingWeapon(oWeapon1))
            {
                continue;
            }
        }
        if (nFlags & HENCH_WEAPON_HOLY_SWORD)
        {
            if (GetLevelByClass(CLASS_TYPE_PALADIN, oHenchBuffTarget) <= 0)
            {
                continue;
            }
        }
        if (nItemProp != -1)
        {
            if (GetItemHasItemProperty(oWeapon1, nItemProp))
            {
                continue;
            }
        }
        if (nEnhanceLevel != -1)
        {
            if (GetItemAttackBonus(OBJECT_INVALID, oWeapon1) >= nEnhanceLevel)
            {
                continue;
            }
        }
        CastSetLastSpellOnObject(nSpell, oHenchBuffTarget, nSpellLevel);
        return curCount >= 0 ? TK_BUFFOTHER : TK_BUFFSELF;
    }
    return FALSE;
}


int TK_UseBestSpell(object oTarget, object oInvis, object oAlly, int useAttackSpells, int allowAttackAbilities,
    int allowUnlimitedAttackAbilities, int allowSummons, int buffSelf, int buffOthers, int allowBuffAbilities,
    int allowWeakOffSpells, int iAmMonster, int bAllowTimeStop = TRUE)
{
//    Jug_Debug(GetName(OBJECT_SELF) + " buffSelf " + IntToString(buffSelf) + " buff others " + IntToString(buffOthers) + " use attack " + IntToString(useAttackSpells));

    if (GetSpellUnknownFlag(HENCH_MAIN_SPELL_SERIES))
    {
        // quick exit for the spell-less
        return FALSE;
    }
        // turn off summoning if already have summoned creature
    if (allowSummons)
    {
        allowSummons = !GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_SUMMONED));
    }

    int allowDominate = allowAttackAbilities && !GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_DOMINATED)) && GetPercentageHPLoss(oTarget) > 50;
    if (allowDominate)
    {
        int lastDominate = GetLocalInt(OBJECT_SELF, henchLastDomStr);
        int combatRoundCount = GetLocalInt(OBJECT_SELF, henchCombatRoundStr);
        if (lastDominate != 0 && lastDominate < combatRoundCount - 7)
        {
            allowDominate = FALSE;
        }
    }

    object oAnimalCompanion = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION);
    int buffAnimalCompanion = buffSelf && GetIsObjectValid(oAnimalCompanion);

        // turn off buffing of others if no ally
    if (!GetIsObjectValid(oAlly))
    {
        buffOthers = 0;
    }

    int iTargetGEAlign = GetAlignmentGoodEvil(oTarget);

    nAreaSpellExtraTargets = -100;
    oAreaSpellTarget = oTarget;

    float nRange = GetDistanceToObject(oTarget);
    iMaxSpellProtLevel = GetMaxSpellProtLevel(oTarget);

    int nRacialType = GetRacialType(oTarget);

    int nLastSpellCast = GetLastGenericSpellCast();
    int nTargetType = 0;

    int nAreaPosition = 500;
    int nSpell = -1;
    int nSpell2;
    int nSpellLevel;
    bFoundSpellGlobal = FALSE;

    int iInvisStatus = CheckInvisibility(oInvis);

    bBuffTargetInitDone = FALSE;

    int bUseMeleeAttackSpells = nGlobalMeleeAttackers;
    int groupBuff = buffSelf;

    while (1)
    {
//$INSERTIONPOINTSTART
        if (GetHasFixedSpell(SPELL_TIME_STOP))
        {
            if (nLastSpellCast != SPELL_TIME_STOP)
            {
                if (buffSelf && !GetHasEffect(EFFECT_TYPE_TIMESTOP, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_TIME_STOP, OBJECT_SELF, 9); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFeat(FEAT_EPIC_BLINDING_SPEED))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_EPIC_SHAPE_DRAGON)
            {
                if (allowBuffAbilities && !GetHasEffect(EFFECT_TYPE_HASTE, OBJECT_SELF) && !GetCreatureHasItemProperty(ITEM_PROPERTY_HASTE, OBJECT_SELF))
                {
                    CastSetLastFeatSpellOnObject(FEAT_EPIC_BLINDING_SPEED, SPELLABILITY_EPIC_SHAPE_DRAGON, OBJECT_SELF); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_MASS_HASTE))
        {
            if (nLastSpellCast != SPELL_MASS_HASTE)
            {
                if (groupBuff && !GetHasEffect(EFFECT_TYPE_HASTE, OBJECT_SELF) && !GetCreatureHasItemProperty(ITEM_PROPERTY_HASTE, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_MASS_HASTE, OBJECT_SELF, 6); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_HASTE))
        {
            if (nLastSpellCast != SPELL_HASTE)
            {
                if (buffSelf && !GetHasEffect(EFFECT_TYPE_HASTE, OBJECT_SELF) && !GetCreatureHasItemProperty(ITEM_PROPERTY_HASTE, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_HASTE, OBJECT_SELF, 3); return TK_BUFFSELF;
                }
                if (!bFoundPotionOnly && buffOthers  && GetBestBuffTarget(-1, EFFECT_TYPE_HASTE, -1, ITEM_PROPERTY_HASTE))
                {
                    CastSetLastSpellOnObject(SPELL_HASTE, oBestBuffTarget, 3); return TK_BUFFOTHER;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_TRUE_SEEING))
        {
            if (nLastSpellCast != SPELL_TRUE_SEEING)
            {
                if ( iInvisStatus && !GetHasSpellEffect(SPELL_TRUE_SEEING, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_TRUE_SEEING, OBJECT_SELF, 5); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_INVISIBILITY_PURGE))
        {
            if (nLastSpellCast != SPELL_INVISIBILITY_PURGE)
            {
                if ( iInvisStatus > 1 && !GetHasSpellEffect(SPELL_INVISIBILITY_PURGE, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_INVISIBILITY_PURGE, OBJECT_SELF, 3); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_SEE_INVISIBILITY))
        {
            if (nLastSpellCast != SPELL_SEE_INVISIBILITY)
            {
                if ( iInvisStatus > 1 && !GetHasSpellEffect(SPELL_SEE_INVISIBILITY, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_SEE_INVISIBILITY, OBJECT_SELF, 2); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE))
        {
            if (nLastSpellCast != SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE)
            {
                if ( iInvisStatus > 1 && !GetHasSpellEffect(SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE, OBJECT_SELF, 3); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFeat(FEAT_EPIC_SPELL_EPIC_WARDING))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELL_HENCH_Epic_Warding)
            {
                if (allowBuffAbilities && !GetHasEffect(EFFECT_TYPE_DAMAGE_REDUCTION, OBJECT_SELF))
                {
                    CastSetLastFeatSpellOnObject(FEAT_EPIC_SPELL_EPIC_WARDING, SPELL_HENCH_Epic_Warding, OBJECT_SELF); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFeat(FEAT_EPIC_SPELL_MAGE_ARMOUR))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELL_EPIC_MAGE_ARMOR)
            {
                if (allowBuffAbilities && !GetHasFeatEffect(FEAT_EPIC_SPELL_MAGE_ARMOUR, OBJECT_SELF))
                {
                    CastSetLastFeatSpellOnObject(FEAT_EPIC_SPELL_MAGE_ARMOUR, SPELL_EPIC_MAGE_ARMOR, OBJECT_SELF); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_GREATER_SPELL_MANTLE))
        {
            if (nLastSpellCast != SPELL_GREATER_SPELL_MANTLE)
            {
                if (buffSelf && HenchUseSpellProtections() && !GetHasEffect(EFFECT_TYPE_SPELLLEVELABSORPTION, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_GREATER_SPELL_MANTLE, OBJECT_SELF, 9); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFeat(FEAT_TURN_UNDEAD))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != FEAT_TURN_UNDEAD && allowAttackAbilities && nRange <= 20.0)
            {
                if (GetTurningEnemyCount())
                {
                    nAreaPosition = 31;
                    nSpell = FEAT_TURN_UNDEAD; nTargetType = TARGET_FEAT_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_BANISHMENT))
        {
            if (nLastSpellCast != SPELL_BANISHMENT && useAttackSpells && nRange <= 8.0 + RADIUS_SIZE_COLOSSAL)
            {
                if (GetDismissalCount(oTarget, SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, 8.0, TRUE))
                {
                    nAreaPosition = 32;
                    nSpell = SPELL_BANISHMENT; nSpellLevel = 6; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_DISMISSAL))
        {
            if (nLastSpellCast != SPELL_DISMISSAL && useAttackSpells && nRange <= 8.0 + RADIUS_SIZE_COLOSSAL)
            {
                if (GetDismissalCount(oTarget, SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, 8.0, FALSE))
                {
                    nAreaPosition = 33;
                    nSpell = SPELL_DISMISSAL; nSpellLevel = 4; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (iBestBreach)
        {
             bFoundSpellGlobal = TRUE;
            if (allowAttackAbilities && GetDispelTarget(oTarget))
            {
                nTargetType = iGlobalTargetType; nSpell = iGlobalSpell; break;
            }
        }
        if (GetHasFeat(FEAT_EPIC_SPELL_HELLBALL))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELL_EPIC_HELLBALL && allowAttackAbilities && nRange <= 20.0 + 20.0f)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, 20.0f, 20.0, 10, GetEpicSpellSaveDC(OBJECT_SELF), HENCH_CHECK_NO_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 35;
                    nSpell = FEAT_EPIC_SPELL_HELLBALL; nSpell2 = SPELL_EPIC_HELLBALL; nTargetType = TARGET_FEAT_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFeat(FEAT_EPIC_SPELL_DRAGON_KNIGHT))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELL_EPIC_DRAGON_KNIGHT && allowSummons)
            {
                CastSetLastFeatSpellAtLocation(FEAT_EPIC_SPELL_DRAGON_KNIGHT, SPELL_EPIC_DRAGON_KNIGHT, GetSummonLocation(oTarget)); return TK_SUMMON;
            }
        }
        if (GetHasFixedSpell(SPELL_GATE))
        {
            if (nLastSpellCast != SPELL_GATE && allowSummons)
            {
                if (TRUE  && (GetHasSpellEffect(SPELL_HOLY_AURA) || GetHasSpellEffect(SPELL_MAGIC_CIRCLE_AGAINST_EVIL) || GetHasSpellEffect(SPELL_PROTECTION_FROM_EVIL)))
                {
                    CastSetLastSpellAtLocation(SPELL_GATE, GetSummonLocation(oTarget), 9); return TK_SUMMON;
                }
                else if (GetHasFixedSpell(SPELL_HOLY_AURA))
                {
                    CastSetLastSpellOnObject(SPELL_HOLY_AURA, OBJECT_SELF, 8); return TK_SUMMON;
                }
                else if (GetHasFixedSpell(SPELL_MAGIC_CIRCLE_AGAINST_EVIL))
                {
                    CastSetLastSpellOnObject(SPELL_MAGIC_CIRCLE_AGAINST_EVIL, OBJECT_SELF, 3); return TK_SUMMON;
                }
                else if (GetHasFixedSpell(SPELL_PROTECTION_FROM_EVIL))
                {
                    CastSetLastSpellOnObject(SPELL_PROTECTION_FROM_EVIL, OBJECT_SELF, 1); return TK_SUMMON;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_HENCH_Tide_of_Battle))
        {
            if (nLastSpellCast != SPELL_HENCH_Tide_of_Battle && useAttackSpells && nRange <= RADIUS_SIZE_COLOSSAL)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, 0.0, 9, -1000, HENCH_CHECK_NO_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 38;
                    nSpell = SPELL_HENCH_Tide_of_Battle; nSpellLevel = 9; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELL_HENCH_Bebelith_Web))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELL_HENCH_Bebelith_Web && allowAttackAbilities && nRange <= 40.0 + 6.7)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, 6.7, 40.0, 9, 20 + nMySpellCasterDCAdjust, HENCH_CHECK_REFLEX_SAVE, HENCH_AREA_CHECK_ENTANGLE))
                {
                    nAreaPosition = 39;
                    nSpell = SPELL_HENCH_Bebelith_Web; nTargetType = TARGET_SPELLABILITY_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (nAreaPosition < 20)
        {
            break;
        }
        if (GetHasFeat(FEAT_DRAGON_DIS_BREATH))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELL_HENCH_RedDragonDiscipleBreath && allowAttackAbilities && nRange <= 10.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 10.0, 4.0, 9, 19 + ((GetLevelByClass(CLASS_TYPE_DRAGON_DISCIPLE, OBJECT_SELF) > 10) ? ((GetLevelByClass(CLASS_TYPE_DRAGON_DISCIPLE, OBJECT_SELF) -10)/4) : 0) + nMySpellCasterDCAdjust, HENCH_CHECK_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 40;
                    nSpell = FEAT_DRAGON_DIS_BREATH; nSpell2 = SPELL_HENCH_RedDragonDiscipleBreath; nTargetType = TARGET_FEAT_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_DRAGON_BREATH_NEGATIVE))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_DRAGON_BREATH_NEGATIVE && allowAttackAbilities && nRange <= 14.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 14.0, 4.0, 9, nMySpellAbilityLevel12 + GetAbilityModifier(ABILITY_CONSTITUTION), HENCH_CHECK_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 41;
                    nSpell = SPELLABILITY_DRAGON_BREATH_NEGATIVE; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELL_HENCH_DRAGON_BREATH_Prismatic))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELL_HENCH_DRAGON_BREATH_Prismatic && allowAttackAbilities && nRange <= 20.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 20.0, 8.0, 9, nMySpellAbilityLevel1, HENCH_CHECK_NO_SAVE, HENCH_AREA_CHECK_PRISM))
                {
                    nAreaPosition = 42;
                    nSpell = SPELL_HENCH_DRAGON_BREATH_Prismatic; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_DRAGON_BREATH_FIRE))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_DRAGON_BREATH_FIRE && allowAttackAbilities && nRange <= 14.0 && TK_CheckDragonBreath())
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 14.0, 4.0, 9, nMySpellAbilityLevel12 + GetAbilityModifier(ABILITY_CONSTITUTION), HENCH_CHECK_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 43;
                    nSpell = SPELLABILITY_DRAGON_BREATH_FIRE; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_DRAGON_BREATH_ACID))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_DRAGON_BREATH_ACID && allowAttackAbilities && nRange <= 14.0 && TK_CheckDragonBreath())
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 14.0, 4.0, 9, nMySpellAbilityLevel12 + GetAbilityModifier(ABILITY_CONSTITUTION), HENCH_CHECK_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 44;
                    nSpell = SPELLABILITY_DRAGON_BREATH_ACID; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_DRAGON_BREATH_COLD))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_DRAGON_BREATH_COLD && allowAttackAbilities && nRange <= 14.0 && TK_CheckDragonBreath())
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 14.0, 4.0, 9, nMySpellAbilityLevel12 + GetAbilityModifier(ABILITY_CONSTITUTION), HENCH_CHECK_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 45;
                    nSpell = SPELLABILITY_DRAGON_BREATH_COLD; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_DRAGON_BREATH_GAS))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_DRAGON_BREATH_GAS && allowAttackAbilities && nRange <= 14.0 && TK_CheckDragonBreath())
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 14.0, 4.0, 9, nMySpellAbilityLevel12 + GetAbilityModifier(ABILITY_CONSTITUTION), HENCH_CHECK_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 46;
                    nSpell = SPELLABILITY_DRAGON_BREATH_GAS; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_DRAGON_BREATH_LIGHTNING))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_DRAGON_BREATH_LIGHTNING && allowAttackAbilities && nRange <= 14.0 && TK_CheckDragonBreath())
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 14.0, 4.0, 9, nMySpellAbilityLevel12 + GetAbilityModifier(ABILITY_CONSTITUTION), HENCH_CHECK_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 47;
                    nSpell = SPELLABILITY_DRAGON_BREATH_LIGHTNING; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_DRAGON_BREATH_PARALYZE))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_DRAGON_BREATH_PARALYZE && allowAttackAbilities && nRange <= 14.0 && TK_CheckDragonBreath())
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 14.0, 4.0, 9, nMySpellAbilityLevel12 + GetAbilityModifier(ABILITY_CONSTITUTION), HENCH_CHECK_FORT_SAVE, HENCH_AREA_CHECK_PARA_AND_MIND))
                {
                    nAreaPosition = 48;
                    nSpell = SPELLABILITY_DRAGON_BREATH_PARALYZE; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_DRAGON_BREATH_SLOW))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_DRAGON_BREATH_SLOW && allowAttackAbilities && nRange <= 14.0 && TK_CheckDragonBreath())
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 14.0, 4.0, 9, nMySpellAbilityLevel12 + GetAbilityModifier(ABILITY_CONSTITUTION), HENCH_CHECK_REFLEX_SAVE, HENCH_AREA_CHECK_SLOW))
                {
                    nAreaPosition = 49;
                    nSpell = SPELLABILITY_DRAGON_BREATH_SLOW; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (nAreaPosition < 30)
        {
            break;
        }
        if (GetHasSpell(SPELLABILITY_DRAGON_BREATH_FEAR))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_DRAGON_BREATH_FEAR && allowAttackAbilities && nRange <= 14.0 && TK_CheckDragonBreath())
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPELLCONE, 14.0, 4.0, 9, nMySpellAbilityLevel12 + GetAbilityModifier(ABILITY_CONSTITUTION), HENCH_CHECK_WILL_SAVE, HENCH_AREA_CHECK_MIND_AND_FEAR))
                {
                    nAreaPosition = 50;
                    nSpell = SPELLABILITY_DRAGON_BREATH_FEAR; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_DRAGON_BREATH_WEAKEN))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_DRAGON_BREATH_WEAKEN && allowAttackAbilities && nRange <= 14.0 && TK_CheckDragonBreath())
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 14.0, 4.0, 9, nMySpellAbilityLevel12 + GetAbilityModifier(ABILITY_CONSTITUTION), HENCH_CHECK_REFLEX_SAVE, HENCH_AREA_CHECK_ABLDEC))
                {
                    nAreaPosition = 51;
                    nSpell = SPELLABILITY_DRAGON_BREATH_WEAKEN; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_DRAGON_BREATH_SLEEP))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_DRAGON_BREATH_SLEEP && allowAttackAbilities && nRange <= 14.0 && TK_CheckDragonBreath())
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 14.0, 4.0, 9, nMySpellAbilityLevel12 + GetAbilityModifier(ABILITY_CONSTITUTION), HENCH_CHECK_WILL_SAVE, HENCH_AREA_CHECK_SLEEP_AND_MIND))
                {
                    nAreaPosition = 52;
                    nSpell = SPELLABILITY_DRAGON_BREATH_SLEEP; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFeat(FEAT_EPIC_SPELL_MUMMY_DUST))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELL_EPIC_MUMMY_DUST && allowSummons)
            {
                CastSetLastFeatSpellAtLocation(FEAT_EPIC_SPELL_MUMMY_DUST, SPELL_EPIC_MUMMY_DUST, GetSummonLocation(oTarget)); return TK_SUMMON;
            }
        }
        if (GetHasFeat(FEAT_EPIC_SPELL_RUIN))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELL_EPIC_RUIN && nRange <= 20.0 && allowAttackAbilities)
            {
                CastSetLastFeatSpellOnObject(FEAT_EPIC_SPELL_RUIN, SPELL_EPIC_RUIN, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasFeat(FEAT_DEATHLESS_MASTER_TOUCH))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_PM_DEATHLESS_MASTER_TOUCH && nRange <= 4.0 && allowAttackAbilities && !GetIsImmune(oTarget, IMMUNITY_TYPE_DEATH, OBJECT_SELF) && GetFortitudeSavingThrow(oTarget) <= 17 + ((GetLevelByClass(CLASS_TYPE_PALEMASTER,OBJECT_SELF) > 10) ? ((GetLevelByClass(CLASS_TYPE_PALEMASTER,OBJECT_SELF) - 10) / 2) : 0) + nMySpellCasterDCAdjust)
            {
                CastSetLastFeatSpellOnObject(FEAT_DEATHLESS_MASTER_TOUCH, SPELLABILITY_PM_DEATHLESS_MASTER_TOUCH, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasFeat(FEAT_CURSE_SONG) && GetHasFeat(FEAT_BARD_SONGS))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != FEAT_CURSE_SONG && allowAttackAbilities && nRange <= RADIUS_SIZE_COLOSSAL && !GetHasEffect(EFFECT_TYPE_SILENCE))
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, 0.0, 1, 20, HENCH_CHECK_NO_SAVE, HENCH_AREA_CHECK_CURSE_SONG))
                {
                    nAreaPosition = 56;
                    nSpell = FEAT_CURSE_SONG; nTargetType = TARGET_FEAT_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_IMPLOSION))
        {
            if (nLastSpellCast != SPELL_IMPLOSION && useAttackSpells && nRange <= 8.0 + RADIUS_SIZE_MEDIUM)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, 8.0, 9, -1000, HENCH_CHECK_SR_FORT_SAVE, HENCH_AREA_CHECK_NOT_SELF))
                {
                    nAreaPosition = 57;
                    nSpell = SPELL_IMPLOSION; nSpellLevel = 9; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_WEIRD))
        {
            if (nLastSpellCast != SPELL_WEIRD && useAttackSpells && nRange <= 8.0 + RADIUS_SIZE_COLOSSAL)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, 8.0, 9, -1000, HENCH_CHECK_SR_WILL_SAVE, HENCH_AREA_CHECK_MIND_AND_FEAR))
                {
                    nAreaPosition = 58;
                    nSpell = SPELL_WEIRD; nSpellLevel = 9; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_METEOR_SWARM))
        {
            if (nLastSpellCast != SPELL_METEOR_SWARM && useAttackSpells && nRange <= RADIUS_SIZE_COLOSSAL)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, 0.0, 9, -1000, HENCH_CHECK_SR_REFLEX_EVASION_SAVE, HENCH_AREA_CHECK_METEOR_SWARM))
                {
                    nAreaPosition = 59;
                    nSpell = SPELL_METEOR_SWARM; nSpellLevel = 9; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (nAreaPosition < 40)
        {
            break;
        }
        if (GetHasFixedSpell(SPELL_HENCH_Hell_Inferno))
        {
            if (nLastSpellCast != SPELL_HENCH_Hell_Inferno && nRange <= 8.0 && useAttackSpells && CheckSpellSaves(oTarget, 9, HENCH_CHECK_SR_NO_SAVE) && !GetHasSpellEffect(SPELL_HENCH_Hell_Inferno, oTarget))
            {
                CastSetLastSpellOnObject(SPELL_HENCH_Hell_Inferno, oTarget, 9); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_ELEMENTAL_SWARM))
        {
            if (nLastSpellCast != SPELL_ELEMENTAL_SWARM && allowSummons)
            {
                CastSetLastSpellAtLocation(SPELL_ELEMENTAL_SWARM, GetSummonLocation(oTarget), 9); return TK_SUMMON;
            }
        }
        if (GetHasFixedSpell(SPELL_BLACK_BLADE_OF_DISASTER))
        {
            if (nLastSpellCast != SPELL_BLACK_BLADE_OF_DISASTER && allowSummons)
            {
                CastSetLastSpellAtLocation(SPELL_BLACK_BLADE_OF_DISASTER, GetSummonLocation(oTarget), 9); return TK_SUMMON;
            }
        }
        if (GetHasFeat(FEAT_SUMMON_GREATER_UNDEAD))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_PM_SUMMON_GREATER_UNDEAD && allowSummons)
            {
                CastSetLastFeatSpellAtLocation(FEAT_SUMMON_GREATER_UNDEAD, SPELLABILITY_PM_SUMMON_GREATER_UNDEAD, GetSummonLocation(oTarget)); return TK_SUMMON;
            }
        }
        if (GetHasFixedSpell(SPELL_UNDEATHS_ETERNAL_FOE))
        {
            if (nLastSpellCast != SPELL_UNDEATHS_ETERNAL_FOE)
            {
                if (groupBuff && (!GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_POISON, OBJECT_SELF) || !GetIsImmune(OBJECT_SELF,  IMMUNITY_TYPE_DISEASE, OBJECT_SELF) || !GetIsImmune(OBJECT_SELF,  IMMUNITY_TYPE_ABILITY_DECREASE, OBJECT_SELF) || !GetIsImmune(OBJECT_SELF,  IMMUNITY_TYPE_NEGATIVE_LEVEL, OBJECT_SELF)))
                {
                    CastSetLastSpellOnObject(SPELL_UNDEATHS_ETERNAL_FOE, OBJECT_SELF, 9); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_BIGBYS_CRUSHING_HAND))
        {
            if (nLastSpellCast != SPELL_BIGBYS_CRUSHING_HAND && nRange <= 40.0 && useAttackSpells && !GetIsDisabled(oTarget) && CheckSpellSaves(oTarget, 9, HENCH_CHECK_SR_NO_SAVE) && !GetHasSpellEffect(SPELL_BIGBYS_CLENCHED_FIST, oTarget) && CheckGrappleResult(oTarget, (bFoundItemSpell ? 17 : nMySpellCasterLevel) + GetCasterAbilityModifier(OBJECT_SELF) + 12, GRAPPLE_CHECK_HIT | GRAPPLE_CHECK_HOLD))
            {
                CastSetLastSpellOnObject(SPELL_BIGBYS_CRUSHING_HAND, oTarget, 9); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_ENERGY_DRAIN))
        {
            if (nLastSpellCast != SPELL_ENERGY_DRAIN && nRange <= 8.0 && useAttackSpells && !GetIsImmune(oTarget, IMMUNITY_TYPE_NEGATIVE_LEVEL, OBJECT_SELF) && CheckSpellSaves(oTarget, 9, HENCH_CHECK_SR_FORT_SAVE))
            {
                CastSetLastSpellOnObject(SPELL_ENERGY_DRAIN, oTarget, 9); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_POWER_WORD_KILL))
        {
            if (nLastSpellCast != SPELL_POWER_WORD_KILL && nRange <= 8.0 && useAttackSpells && !GetIsImmune(oTarget, IMMUNITY_TYPE_DEATH, OBJECT_SELF) && CheckSpellSaves(oTarget, 9, HENCH_CHECK_SR_NO_SAVE) && GetCurrentHitPoints(oTarget) <= 100)
            {
                CastSetLastSpellOnObject(SPELL_POWER_WORD_KILL, oTarget, 9); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_WAIL_OF_THE_BANSHEE))
        {
            if (nLastSpellCast != SPELL_WAIL_OF_THE_BANSHEE && nRange <= 8.0 && useAttackSpells && !GetIsImmune(oTarget, IMMUNITY_TYPE_DEATH, OBJECT_SELF) && CheckSpellSaves(oTarget, 9, HENCH_CHECK_SR_FORT_SAVE))
            {
                CastSetLastSpellOnObject(SPELL_WAIL_OF_THE_BANSHEE, oTarget, 9); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_STORM_OF_VENGEANCE))
        {
            if (nLastSpellCast != SPELL_STORM_OF_VENGEANCE && useAttackSpells && nRange <= 10.0)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, 10.0, 0.0, 9, -1000, HENCH_CHECK_SR_NO_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 69;
                    nSpell = SPELL_STORM_OF_VENGEANCE; nSpellLevel = 9; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (nAreaPosition < 50)
        {
            break;
        }
        if (GetHasFeat(FEAT_DEATH_DOMAIN_POWER))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_NEGATIVE_PLANE_AVATAR && allowSummons)
            {
                CastSetLastFeatSpellAtLocation(FEAT_DEATH_DOMAIN_POWER, SPELLABILITY_NEGATIVE_PLANE_AVATAR, GetSummonLocation(oTarget)); return TK_SUMMON;
            }
        }
        if (GetHasFixedSpell(SPELL_SUMMON_CREATURE_IX))
        {
            if (nLastSpellCast != SPELL_SUMMON_CREATURE_IX && allowSummons)
            {
                CastSetLastSpellAtLocation(SPELL_SUMMON_CREATURE_IX, GetSummonLocation(oTarget), 9); return TK_SUMMON;
            }
        }
        if (GetHasFixedSpell(SPELL_DOMINATE_MONSTER))
        {
            if (nLastSpellCast != SPELL_DOMINATE_MONSTER && allowDominate && nRange <= 20.0 && useAttackSpells && !(GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) || GetIsImmune(oTarget, IMMUNITY_TYPE_DOMINATE, OBJECT_SELF)) && CheckSpellSaves(oTarget, 9, HENCH_CHECK_SR_WILL_SAVE))
            {
                SetLastDominate(); CastSetLastSpellOnObject(SPELL_DOMINATE_MONSTER, oTarget, 9); return TK_DOMINATE;
            }
        }
        if (GetHasFixedSpell(SPELL_PREMONITION))
        {
            if (nLastSpellCast != SPELL_PREMONITION)
            {
                if (buffSelf && !GetHasEffect(EFFECT_TYPE_DAMAGE_REDUCTION, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_PREMONITION, OBJECT_SELF, 8); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_BOMBARDMENT))
        {
            if (nLastSpellCast != SPELL_BOMBARDMENT && useAttackSpells && nRange <= 40.0 + RADIUS_SIZE_COLOSSAL)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, 40.0, 8, -1000, HENCH_CHECK_SR_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 74;
                    nSpell = SPELL_BOMBARDMENT; nSpellLevel = 8; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_EARTHQUAKE))
        {
            if (nLastSpellCast != SPELL_EARTHQUAKE && useAttackSpells && nRange <= RADIUS_SIZE_COLOSSAL)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, 0.0, 8, -1000, HENCH_CHECK_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 75;
                    nSpell = SPELL_EARTHQUAKE; nSpellLevel = 8; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_SUNBURST))
        {
            if (nLastSpellCast != SPELL_SUNBURST && useAttackSpells && nRange <= 20.0 + RADIUS_SIZE_COLOSSAL)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, 20.0, 8, -1000, HENCH_CHECK_SR_REFLEX_EVASION_SAVE, HENCH_AREA_CHECK_BLIND))
                {
                    nAreaPosition = 76;
                    nSpell = SPELL_SUNBURST; nSpellLevel = 8; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_BIGBYS_CLENCHED_FIST))
        {
            if (nLastSpellCast != SPELL_BIGBYS_CLENCHED_FIST && nRange <= 40.0 && useAttackSpells && !(GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) || GetIsImmune(oTarget, IMMUNITY_TYPE_STUN, OBJECT_SELF)) && !GetIsDisabled(oTarget) && CheckSpellSaves(oTarget, 8, HENCH_CHECK_SR_FORT_SAVE) && !GetHasSpellEffect(SPELL_BIGBYS_CLENCHED_FIST, oTarget) && CheckGrappleResult(oTarget, (bFoundItemSpell ? 15 : nMySpellCasterLevel) + GetCasterAbilityModifier(OBJECT_SELF) + 11, GRAPPLE_CHECK_HIT))
            {
                CastSetLastSpellOnObject(SPELL_BIGBYS_CLENCHED_FIST, oTarget, 8); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_INCENDIARY_CLOUD))
        {
            if (nLastSpellCast != SPELL_INCENDIARY_CLOUD && useAttackSpells && nRange <= 40.0 + 5.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, 5.0, 40.0, 8, -1000, HENCH_CHECK_SR_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 78;
                    nSpell = SPELL_INCENDIARY_CLOUD; nSpellLevel = 8; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_HORRID_WILTING))
        {
            if (nLastSpellCast != SPELL_HORRID_WILTING && useAttackSpells && nRange <= 20.0 + RADIUS_SIZE_HUGE)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_HUGE, 20.0, 8, -1000, HENCH_CHECK_SR_NO_SAVE, HENCH_AREA_CHECK_HORRID))
                {
                    nAreaPosition = 79;
                    nSpell = SPELL_HORRID_WILTING; nSpellLevel = 8; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (nAreaPosition < 60)
        {
            break;
        }
        if (GetHasFixedSpell(SPELL_MASS_HEAL))
        {
            if (nLastSpellCast != SPELL_MASS_HEAL && useAttackSpells && nRange <= 4.0 + RADIUS_SIZE_MEDIUM)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, 4.0, 8, -1000, HENCH_CHECK_SR_NO_SAVE, HENCH_AREA_CHECK_HEAL))
                {
                    nAreaPosition = 80;
                    nSpell = SPELL_MASS_HEAL; nSpellLevel = 8; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_MASS_BLINDNESS_AND_DEAFNESS))
        {
            if (nLastSpellCast != SPELL_MASS_BLINDNESS_AND_DEAFNESS && useAttackSpells && nRange <= 20.0 + RADIUS_SIZE_MEDIUM)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, 20.0, 8, -1000, HENCH_CHECK_SR_FORT_SAVE, HENCH_AREA_CHECK_BLIND_AND_DEAF))
                {
                    nAreaPosition = 81;
                    nSpell = SPELL_MASS_BLINDNESS_AND_DEAFNESS; nSpellLevel = 8; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_MASS_CHARM))
        {
            if (nLastSpellCast != SPELL_MASS_CHARM && useAttackSpells && nRange <= 8.0 + RADIUS_SIZE_LARGE)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_LARGE, 8.0, 8, -1000, HENCH_CHECK_SR_WILL_SAVE, HENCH_AREA_CHECK_MASS_CHARM))
                {
                    nAreaPosition = 82;
                    nSpell = SPELL_MASS_CHARM; nSpellLevel = 8; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_CONTROL_UNDEAD))
        {
            if (nLastSpellCast != SPELL_CONTROL_UNDEAD && allowDominate && nRange <= 8.0 && useAttackSpells && !GetIsImmune(oTarget, IMMUNITY_TYPE_DOMINATE, OBJECT_SELF) && CheckSpellSaves(oTarget, 7, HENCH_CHECK_SR_WILL_SAVE) && nRacialType == RACIAL_TYPE_UNDEAD)
            {
                SetLastDominate(); CastSetLastSpellOnObject(SPELL_CONTROL_UNDEAD, oTarget, 7); return TK_DOMINATE;
            }
        }
        if (GetHasFixedSpell(SPELL_CREATE_GREATER_UNDEAD))
        {
            if (nLastSpellCast != SPELL_CREATE_GREATER_UNDEAD && allowSummons)
            {
                CastSetLastSpellAtLocation(SPELL_CREATE_GREATER_UNDEAD, GetSummonLocation(oTarget), 8); return TK_SUMMON;
            }
        }
        if (GetHasFixedSpell(SPELL_GREATER_PLANAR_BINDING))
        {
            if (nLastSpellCast != SPELL_GREATER_PLANAR_BINDING && allowSummons)
            {
                CastSetLastSpellAtLocation(SPELL_GREATER_PLANAR_BINDING, GetSummonLocation(oTarget), 8); return TK_SUMMON;
            }
        }
        if (GetHasSpell(SPELL_HENCH_ShadowBlend))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELL_HENCH_ShadowBlend)
            {
                if (allowBuffAbilities && !GetHasSpellEffect(SPELL_CONTINUAL_FLAME,OBJECT_SELF) && !GetHasEffect(EFFECT_TYPE_CONCEALMENT, OBJECT_SELF))
                {
                    CastSpellAbilityOnObject(SPELL_HENCH_ShadowBlend, OBJECT_SELF); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_HOLY_AURA))
        {
            if (nLastSpellCast != SPELL_HOLY_AURA)
            {
                if (buffSelf && iTargetGEAlign == ALIGNMENT_EVIL && !GetHasSpellEffect(SPELL_HOLY_AURA, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_HOLY_AURA, OBJECT_SELF, 8); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_UNHOLY_AURA))
        {
            if (nLastSpellCast != SPELL_UNHOLY_AURA)
            {
                if (buffSelf && iTargetGEAlign == ALIGNMENT_GOOD && !GetHasSpellEffect(SPELL_UNHOLY_AURA, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_UNHOLY_AURA, OBJECT_SELF, 8); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_MIND_BLANK))
        {
            if (nLastSpellCast != SPELL_MIND_BLANK)
            {
                if (groupBuff && !GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_MIND_BLANK, OBJECT_SELF, 8); return TK_BUFFSELF;
                }
            }
        }
        if (nAreaPosition < 70)
        {
            break;
        }
        if (GetHasFixedSpell(SPELL_NATURES_BALANCE))
        {
            if (nLastSpellCast != SPELL_NATURES_BALANCE)
            {
                if (groupBuff && !GetHasSpellEffect(SPELL_NATURES_BALANCE, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_NATURES_BALANCE, OBJECT_SELF, 8); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_SUMMON_CREATURE_VIII))
        {
            if (nLastSpellCast != SPELL_SUMMON_CREATURE_VIII && allowSummons)
            {
                CastSetLastSpellAtLocation(SPELL_SUMMON_CREATURE_VIII, GetSummonLocation(oTarget), 8); return TK_SUMMON;
            }
        }
        if (GetHasFixedSpell(SPELL_SPELL_MANTLE))
        {
            if (nLastSpellCast != SPELL_SPELL_MANTLE)
            {
                if (buffSelf && HenchUseSpellProtections() && !GetHasEffect(EFFECT_TYPE_SPELLLEVELABSORPTION, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_SPELL_MANTLE, OBJECT_SELF, 7); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_DELAYED_BLAST_FIREBALL))
        {
            if (nLastSpellCast != SPELL_DELAYED_BLAST_FIREBALL && useAttackSpells && nRange <= 20.0 + 6.67f)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, 6.67f, 20.0, 7, -1000, HENCH_CHECK_SR_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 93;
                    nSpell = SPELL_DELAYED_BLAST_FIREBALL; nSpellLevel = 7; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_FIRE_STORM))
        {
            if (nLastSpellCast != SPELL_FIRE_STORM && useAttackSpells && nRange <= RADIUS_SIZE_COLOSSAL)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, 0.0, 7, -1000, HENCH_CHECK_SR_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 94;
                    nSpell = SPELL_FIRE_STORM; nSpellLevel = 7; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_CREEPING_DOOM))
        {
            if (nLastSpellCast != SPELL_CREEPING_DOOM && useAttackSpells && nRange <= 20.0 + 6.7)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, 6.7, 20.0, 7, -1000, HENCH_CHECK_SR_NO_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 95;
                    nSpell = SPELL_CREEPING_DOOM; nSpellLevel = 7; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_GREAT_THUNDERCLAP))
        {
            if (nLastSpellCast != SPELL_GREAT_THUNDERCLAP && useAttackSpells && nRange <= 20.0 + RADIUS_SIZE_GARGANTUAN)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, 20.0, 7, -1000, HENCH_CHECK_NO_SAVE, HENCH_AREA_CHECK_THUNDERCLAP))
                {
                    nAreaPosition = 96;
                    nSpell = SPELL_GREAT_THUNDERCLAP; nSpellLevel = 7; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_DESTRUCTION))
        {
            if (nLastSpellCast != SPELL_DESTRUCTION && nRange <= 8.0 && useAttackSpells && !GetIsImmune(oTarget, IMMUNITY_TYPE_DEATH, OBJECT_SELF) && CheckSpellSaves(oTarget, 7, HENCH_CHECK_SR_NO_SAVE))
            {
                CastSetLastSpellOnObject(SPELL_DESTRUCTION, oTarget, 7); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_FINGER_OF_DEATH))
        {
            if (nLastSpellCast != SPELL_FINGER_OF_DEATH && nRange <= 8.0 && useAttackSpells && !GetIsImmune(oTarget, IMMUNITY_TYPE_DEATH, OBJECT_SELF) && CheckSpellSaves(oTarget, 7, HENCH_CHECK_SR_NO_SAVE))
            {
                CastSetLastSpellOnObject(SPELL_FINGER_OF_DEATH, oTarget, 7); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_SUNBEAM))
        {
            if (nLastSpellCast != SPELL_SUNBEAM && useAttackSpells && nRange <= 20.0 + RADIUS_SIZE_COLOSSAL)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, 20.0, 7, -1000, HENCH_CHECK_SR_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 99;
                    nSpell = SPELL_SUNBEAM; nSpellLevel = 7; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (nAreaPosition < 80)
        {
            break;
        }
        if (GetHasFixedSpell(SPELL_MORDENKAINENS_SWORD))
        {
            if (nLastSpellCast != SPELL_MORDENKAINENS_SWORD && allowSummons)
            {
                CastSetLastSpellAtLocation(SPELL_MORDENKAINENS_SWORD, GetSummonLocation(oTarget), 7); return TK_SUMMON;
            }
        }
        if (GetHasFixedSpell(SPELL_POWER_WORD_STUN))
        {
            if (nLastSpellCast != SPELL_POWER_WORD_STUN && nRange <= 8.0 && useAttackSpells && !(GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) || GetIsImmune(oTarget, IMMUNITY_TYPE_STUN, OBJECT_SELF)) && !GetIsDisabled(oTarget) && CheckSpellSaves(oTarget, 7, HENCH_CHECK_SR_NO_SAVE) && GetCurrentHitPoints(oTarget) <= 150)
            {
                CastSetLastSpellOnObject(SPELL_POWER_WORD_STUN, oTarget, 7); return TK_ATTACK;
            }
        }
        if (GetHasFeat(FEAT_PRESTIGE_ARROW_OF_DEATH))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_AA_ARROW_OF_DEATH && nRange <= 40.0 && allowAttackAbilities && !GetIsImmune(oTarget, IMMUNITY_TYPE_DEATH, OBJECT_SELF) && GetFortitudeSavingThrow(oTarget) <= 20 + nMySpellCasterDCAdjust && GetHasEquippedBow())
            {
                CastSetLastFeatSpellOnObject(FEAT_PRESTIGE_ARROW_OF_DEATH, SPELLABILITY_AA_ARROW_OF_DEATH, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_BIGBYS_GRASPING_HAND))
        {
            if (nLastSpellCast != SPELL_BIGBYS_GRASPING_HAND && nRange <= 40.0 && useAttackSpells && !GetIsDisabled(oTarget) && CheckSpellSaves(oTarget, 7, HENCH_CHECK_SR_NO_SAVE) && !GetHasSpellEffect(SPELL_BIGBYS_CLENCHED_FIST, oTarget) && CheckGrappleResult(oTarget, (bFoundItemSpell ? 13 : nMySpellCasterLevel) + GetCasterAbilityModifier(OBJECT_SELF) + 10, GRAPPLE_CHECK_HIT | GRAPPLE_CHECK_HOLD))
            {
                CastSetLastSpellOnObject(SPELL_BIGBYS_GRASPING_HAND, oTarget, 7); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_PRISMATIC_SPRAY))
        {
            if (nLastSpellCast != SPELL_PRISMATIC_SPRAY && useAttackSpells && nRange <= 11.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 11.0, 8.0, 7, -1000, HENCH_CHECK_SR_NO_SAVE, HENCH_AREA_CHECK_PRISM))
                {
                    nAreaPosition = 104;
                    nSpell = SPELL_PRISMATIC_SPRAY; nSpellLevel = 7; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_PROTECTION_FROM_SPELLS))
        {
            if (nLastSpellCast != SPELL_PROTECTION_FROM_SPELLS)
            {
                if (groupBuff && HenchUseSpellProtections() && !GetHasSpellEffect(SPELL_PROTECTION_FROM_SPELLS, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_PROTECTION_FROM_SPELLS, OBJECT_SELF, 7); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_SHADOW_SHIELD))
        {
            if (nLastSpellCast != SPELL_SHADOW_SHIELD && (d100() <= 50))
            {
                if (buffSelf && HenchUseSpellProtections() && !GetHasEffect(EFFECT_TYPE_DAMAGE_REDUCTION, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_SHADOW_SHIELD, OBJECT_SELF, 7); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_SUMMON_CREATURE_VII))
        {
            if (nLastSpellCast != SPELL_SUMMON_CREATURE_VII && allowSummons)
            {
                CastSetLastSpellAtLocation(SPELL_SUMMON_CREATURE_VII, GetSummonLocation(oTarget), 7); return TK_SUMMON;
            }
        }
        if (GetHasFixedSpell(SPELL_WORD_OF_FAITH))
        {
            if (nLastSpellCast != SPELL_WORD_OF_FAITH && useAttackSpells && nRange <= 20.0 + RADIUS_SIZE_COLOSSAL)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, 20.0, 7, -1000, HENCH_CHECK_SR_NO_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 108;
                    nSpell = SPELL_WORD_OF_FAITH; nSpellLevel = 7; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_HOWL_DEATH))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_HOWL_DEATH && allowAttackAbilities && nRange <= RADIUS_SIZE_COLOSSAL)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, 0.0, 7, nMySpellAbilityLevel14, HENCH_CHECK_WILL_SAVE, HENCH_AREA_CHECK_DEATH))
                {
                    nAreaPosition = 109;
                    nSpell = SPELLABILITY_HOWL_DEATH; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (nAreaPosition < 90)
        {
            break;
        }
        if (GetHasSpell(SPELLABILITY_PULSE_DEATH))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_PULSE_DEATH && allowAttackAbilities && nRange <= RADIUS_SIZE_LARGE)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_LARGE, 0.0, 7, nMySpellAbilityLevel1, HENCH_CHECK_FORT_SAVE, HENCH_AREA_CHECK_DEATH))
                {
                    nAreaPosition = 110;
                    nSpell = SPELLABILITY_PULSE_DEATH; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_PULSE_LEVEL_DRAIN))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_PULSE_LEVEL_DRAIN && allowAttackAbilities && nRange <= RADIUS_SIZE_LARGE)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_LARGE, 0.0, 7, nMySpellAbilityLevel1, HENCH_CHECK_FORT_SAVE, HENCH_AREA_CHECK_NEGLVL))
                {
                    nAreaPosition = 111;
                    nSpell = SPELLABILITY_PULSE_LEVEL_DRAIN; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_ETHEREALNESS))
        {
            if (nLastSpellCast != SPELL_ETHEREALNESS)
            {
                if (buffSelf && !GetHasSpellEffect(SPELL_ETHEREALNESS, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_ETHEREALNESS, OBJECT_SELF, 7); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_AURA_OF_VITALITY))
        {
            if (nLastSpellCast != SPELL_AURA_OF_VITALITY)
            {
                if (groupBuff && !GetHasSpellEffect(SPELL_AURA_OF_VITALITY, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_AURA_OF_VITALITY, OBJECT_SELF, 7); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_REGENERATE))
        {
            if (nLastSpellCast != SPELL_REGENERATE)
            {
                if (buffSelf && !GetHasEffect(EFFECT_TYPE_REGENERATE, OBJECT_SELF) && !GetCreatureHasItemProperty(ITEM_PROPERTY_REGENERATION, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_REGENERATE, OBJECT_SELF, 7); return TK_BUFFSELF;
                }
                if (!bFoundPotionOnly && buffOthers  && GetBestBuffTarget(-1, EFFECT_TYPE_REGENERATE, -1, ITEM_PROPERTY_REGENERATION))
                {
                    CastSetLastSpellOnObject(SPELL_REGENERATE, oBestBuffTarget, 7); return TK_BUFFOTHER;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_UNDEATH_TO_DEATH))
        {
            if (nLastSpellCast != SPELL_UNDEATH_TO_DEATH && useAttackSpells && nRange <= 20.0 + 20.0f)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, 20.0f, 20.0, 6, -1000, HENCH_CHECK_SR_WILL_SAVE, HENCH_AREA_CHECK_UNDEAD))
                {
                    nAreaPosition = 115;
                    nSpell = SPELL_UNDEATH_TO_DEATH; nSpellLevel = 6; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_ISAACS_GREATER_MISSILE_STORM))
        {
            if (nLastSpellCast != SPELL_ISAACS_GREATER_MISSILE_STORM && useAttackSpells && nRange <= 40.0 + RADIUS_SIZE_GARGANTUAN)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, 40.0, 6, -1000, HENCH_CHECK_SR_NO_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 116;
                    nSpell = SPELL_ISAACS_GREATER_MISSILE_STORM; nSpellLevel = 6; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFeat(FEAT_PRESTIGE_HAIL_OF_ARROWS))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_AA_HAIL_OF_ARROWS && nRange <= 0.0 && allowAttackAbilities && GetHasEquippedBow())
            {
                CastSetLastFeatSpellOnObject(FEAT_PRESTIGE_HAIL_OF_ARROWS, SPELLABILITY_AA_HAIL_OF_ARROWS, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_CHAIN_LIGHTNING))
        {
            if (nLastSpellCast != SPELL_CHAIN_LIGHTNING && useAttackSpells && nRange <= 40.0 + RADIUS_SIZE_COLOSSAL)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, 40.0, 6, -1000, HENCH_CHECK_SR_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 118;
                    nSpell = SPELL_CHAIN_LIGHTNING; nSpellLevel = 6; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_ACID_FOG))
        {
            if (nLastSpellCast != SPELL_ACID_FOG && useAttackSpells && nRange <= 40.0 + 5.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, 5.0, 40.0, 6, -1000, HENCH_CHECK_SR_NO_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 119;
                    nSpell = SPELL_ACID_FOG; nSpellLevel = 6; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (nAreaPosition < 100)
        {
            break;
        }
        if (GetHasFixedSpell(SPELL_BLADE_BARRIER))
        {
            if (nLastSpellCast != SPELL_BLADE_BARRIER && useAttackSpells && nRange <= 20.0 + 5.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, 5.0, 20.0, 6, -1000, HENCH_CHECK_SR_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 120;
                    nSpell = SPELL_BLADE_BARRIER; nSpellLevel = 6; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_CIRCLE_OF_DEATH))
        {
            if (nLastSpellCast != SPELL_CIRCLE_OF_DEATH && useAttackSpells && nRange <= 20.0 + RADIUS_SIZE_LARGE)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_LARGE, 20.0, 6, -1000, HENCH_CHECK_SR_FORT_SAVE, HENCH_AREA_CHECK_DEATH))
                {
                    nAreaPosition = 121;
                    nSpell = SPELL_CIRCLE_OF_DEATH; nSpellLevel = 6; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_DIRGE))
        {
            if (nLastSpellCast != SPELL_DIRGE && useAttackSpells && nRange <= 3.3)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, 3.3, 0.0, 6, -1000, HENCH_CHECK_SR_FORT_SAVE, HENCH_AREA_CHECK_ABLDEC))
                {
                    nAreaPosition = 122;
                    nSpell = SPELL_DIRGE; nSpellLevel = 6; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_STONEHOLD))
        {
            if (nLastSpellCast != SPELL_STONEHOLD && useAttackSpells && nRange <= 20.0 + 10.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, 10.0, 20.0, 6, -1000, HENCH_CHECK_SR_WILL_SAVE, HENCH_AREA_CHECK_PARA_AND_MIND))
                {
                    nAreaPosition = 123;
                    nSpell = SPELL_STONEHOLD; nSpellLevel = 6; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_CRUMBLE))
        {
            if (nLastSpellCast != SPELL_CRUMBLE && nRange <= 20.0 && useAttackSpells && nRacialType == RACIAL_TYPE_CONSTRUCT)
            {
                CastSetLastSpellOnObject(SPELL_CRUMBLE, oTarget, 6); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_CREATE_UNDEAD))
        {
            if (nLastSpellCast != SPELL_CREATE_UNDEAD && allowSummons)
            {
                CastSetLastSpellAtLocation(SPELL_CREATE_UNDEAD, GetSummonLocation(oTarget), 6); return TK_SUMMON;
            }
        }
        if (GetHasFixedSpell(SPELL_GLOBE_OF_INVULNERABILITY))
        {
            if (nLastSpellCast != SPELL_GLOBE_OF_INVULNERABILITY)
            {
                if (buffSelf && HenchUseSpellProtections() && !GetHasEffect(EFFECT_TYPE_SPELLLEVELABSORPTION, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_GLOBE_OF_INVULNERABILITY, OBJECT_SELF, 6); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_GREATER_STONESKIN))
        {
            if (nLastSpellCast != SPELL_GREATER_STONESKIN)
            {
                if (buffSelf && !GetHasEffect(EFFECT_TYPE_DAMAGE_REDUCTION, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_GREATER_STONESKIN, OBJECT_SELF, 6); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_DROWN))
        {
            if (nLastSpellCast != SPELL_DROWN && nRange <= 8.0 && useAttackSpells && CheckSpellSaves(oTarget, 6, HENCH_CHECK_SR_FORT_SAVE) && nRacialType != RACIAL_TYPE_CONSTRUCT && nRacialType != RACIAL_TYPE_UNDEAD && nRacialType != RACIAL_TYPE_ELEMENTAL)
            {
                CastSetLastSpellOnObject(SPELL_DROWN, oTarget, 6); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_FLESH_TO_STONE))
        {
            if (nLastSpellCast != SPELL_FLESH_TO_STONE && nRange <= 20.0 && useAttackSpells && !GetIsDisabled(oTarget) && CheckSpellSaves(oTarget, 6, HENCH_CHECK_SR_FORT_SAVE) && !spellsIsImmuneToPetrification(oTarget))
            {
                CastSetLastSpellOnObject(SPELL_FLESH_TO_STONE, oTarget, 6); return TK_ATTACK;
            }
        }
        if (nAreaPosition < 110)
        {
            break;
        }
        if (GetHasFeat(FEAT_UNDEAD_GRAFT_1))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_PM_UNDEAD_GRAFT_1 && nRange <= 4.0 && allowAttackAbilities && !(GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) || GetIsImmune(oTarget, IMMUNITY_TYPE_PARALYSIS, OBJECT_SELF)) && !GetIsDisabled(oTarget) && GetFortitudeSavingThrow(oTarget) <= 14 + GetLevelByClass(CLASS_TYPE_PALEMASTER)/2 + nMySpellCasterDCAdjust && nRacialType != RACIAL_TYPE_ELF)
            {
                CastSetLastFeatSpellOnObject(FEAT_UNDEAD_GRAFT_1, SPELLABILITY_PM_UNDEAD_GRAFT_1, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasFeat(FEAT_UNDEAD_GRAFT_2))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_PM_UNDEAD_GRAFT_2 && nRange <= 4.0 && allowAttackAbilities && !(GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) || GetIsImmune(oTarget, IMMUNITY_TYPE_PARALYSIS, OBJECT_SELF)) && !GetIsDisabled(oTarget) && GetFortitudeSavingThrow(oTarget) <= 14 + GetLevelByClass(CLASS_TYPE_PALEMASTER)/2 + nMySpellCasterDCAdjust && nRacialType != RACIAL_TYPE_ELF)
            {
                CastSetLastFeatSpellOnObject(FEAT_UNDEAD_GRAFT_2, SPELLABILITY_PM_UNDEAD_GRAFT_2, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_HENCH_Golem_Ranged_Slam))
        {
            if (nLastSpellCast != SPELL_HENCH_Golem_Ranged_Slam && nRange <= 40.0 && useAttackSpells)
            {
                CastSetLastSpellOnObject(SPELL_HENCH_Golem_Ranged_Slam, oTarget, 6); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELL_HENCH_Deflecting_Force))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELL_HENCH_Deflecting_Force)
            {
                if (allowBuffAbilities && !GetHasEffect(EFFECT_TYPE_AC_INCREASE, OBJECT_SELF))
                {
                    CastSpellAbilityOnObject(SPELL_HENCH_Deflecting_Force, OBJECT_SELF); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_HARM))
        {
            if (nLastSpellCast != SPELL_HARM && nRange <= 4.0 && useAttackSpells && CheckSpellSaves(oTarget, 6, HENCH_CHECK_SR_NO_SAVE) && nRacialType != RACIAL_TYPE_UNDEAD && GetCurrentHitPoints(oTarget) >= 70)
            {
                CastSetLastSpellOnObject(SPELL_HARM, oTarget, 6); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_HEAL))
        {
            if (nLastSpellCast != SPELL_HEAL && nRange <= 4.0 && useAttackSpells && CheckSpellSaves(oTarget, 6, HENCH_CHECK_SR_NO_SAVE) && nRacialType == RACIAL_TYPE_UNDEAD && GetCurrentHitPoints(oTarget) >= 70)
            {
                CastSetLastSpellOnObject(SPELL_HEAL, oTarget, 6); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_BIGBYS_FORCEFUL_HAND))
        {
            if (nLastSpellCast != SPELL_BIGBYS_FORCEFUL_HAND && nRange <= 40.0 && useAttackSpells && !(GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) || GetIsImmune(oTarget, IMMUNITY_TYPE_DAZED, OBJECT_SELF)) && !GetIsDisabled(oTarget) && CheckSpellSaves(oTarget, 6, HENCH_CHECK_SR_NO_SAVE) && !GetHasSpellEffect(SPELL_BIGBYS_CLENCHED_FIST, oTarget) && CheckGrappleResult(oTarget, 14, GRAPPLE_CHECK_RUSH))
            {
                CastSetLastSpellOnObject(SPELL_BIGBYS_FORCEFUL_HAND, oTarget, 6); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_HENCH_Summon_Shadow_X2))
        {
            if (nLastSpellCast != SPELL_HENCH_Summon_Shadow_X2 && allowSummons)
            {
                CastSetLastSpellAtLocation(SPELL_HENCH_Summon_Shadow_X2, GetSummonLocation(oTarget), 6); return TK_SUMMON;
            }
        }
        if (GetHasFixedSpell(SPELL_PLANAR_BINDING))
        {
            if (nLastSpellCast != SPELL_PLANAR_BINDING && allowSummons)
            {
                CastSetLastSpellAtLocation(SPELL_PLANAR_BINDING, GetSummonLocation(oTarget), 6); return TK_SUMMON;
            }
        }
        if (GetHasFixedSpell(SPELL_SUMMON_CREATURE_VI))
        {
            if (nLastSpellCast != SPELL_SUMMON_CREATURE_VI && allowSummons)
            {
                CastSetLastSpellAtLocation(SPELL_SUMMON_CREATURE_VI, GetSummonLocation(oTarget), 6); return TK_SUMMON;
            }
        }
        if (nAreaPosition < 120)
        {
            break;
        }
        if (GetHasFixedSpell(SPELL_PLANAR_ALLY))
        {
            if (nLastSpellCast != SPELL_PLANAR_ALLY && allowSummons)
            {
                CastSetLastSpellAtLocation(SPELL_PLANAR_ALLY, GetSummonLocation(oTarget), 6); return TK_SUMMON;
            }
        }
        if (GetHasSpell(SPELLABILITY_BOLT_DOMINATE))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_BOLT_DOMINATE && allowDominate && nRange <= 20.0 && allowAttackAbilities && !GetIsImmune(oTarget, IMMUNITY_TYPE_DOMINATE, OBJECT_SELF))
            {
                SetLastDominate(); CastSpellAbilityOnObject(SPELLABILITY_BOLT_DOMINATE, oTarget); return TK_DOMINATE;
            }
        }
        if (GetHasSpell(SPELLABILITY_BOLT_LEVEL_DRAIN))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_BOLT_LEVEL_DRAIN && nRange <= 20.0 && allowAttackAbilities && !GetIsImmune(oTarget, IMMUNITY_TYPE_NEGATIVE_LEVEL, OBJECT_SELF))
            {
                CastSpellAbilityOnObject(SPELLABILITY_BOLT_LEVEL_DRAIN, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELLABILITY_CONE_POISON))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_CONE_POISON && allowAttackAbilities && nRange <= 10.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 10.0, 8.0, 6, GetCreaturePoisonDC() + nMySpellCasterDCAdjust, HENCH_CHECK_FORT_SAVE, HENCH_AREA_CHECK_POISON))
                {
                    nAreaPosition = 144;
                    nSpell = SPELLABILITY_CONE_POISON; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_GAZE_DEATH))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_GAZE_DEATH && allowAttackAbilities && nRange <= 10.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 10.0, 8.0, 6, nMySpellAbilityLevel12, HENCH_CHECK_WILL_SAVE, HENCH_AREA_CHECK_DEATH))
                {
                    nAreaPosition = 145;
                    nSpell = SPELLABILITY_GAZE_DEATH; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_GAZE_DOMINATE))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_GAZE_DOMINATE && allowDominate && nRange <= 8.0 && allowAttackAbilities && !(GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) || GetIsImmune(oTarget, IMMUNITY_TYPE_DOMINATE, OBJECT_SELF)) && GetWillSavingThrow(oTarget) <= nMySpellAbilityLevel12)
            {
                SetLastDominate(); CastSpellAbilityOnObject(SPELLABILITY_GAZE_DOMINATE, oTarget); return TK_DOMINATE;
            }
        }
        if (GetHasSpell(SPELLABILITY_HOWL_CONFUSE))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_HOWL_CONFUSE && allowAttackAbilities && nRange <= RADIUS_SIZE_COLOSSAL)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, 0.0, 6, nMySpellAbilityLevel14, HENCH_CHECK_WILL_SAVE, HENCH_AREA_CHECK_CONF_AND_MIND))
                {
                    nAreaPosition = 147;
                    nSpell = SPELLABILITY_HOWL_CONFUSE; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_HOWL_STUN))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_HOWL_STUN && allowAttackAbilities && nRange <= RADIUS_SIZE_COLOSSAL)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, 0.0, 6, nMySpellAbilityLevel14, HENCH_CHECK_WILL_SAVE, HENCH_AREA_CHECK_STUN_AND_MIND))
                {
                    nAreaPosition = 148;
                    nSpell = SPELLABILITY_HOWL_STUN; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_PULSE_ABILITY_DRAIN_INTELLIGENCE))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_PULSE_ABILITY_DRAIN_INTELLIGENCE && allowAttackAbilities && nRange <= RADIUS_SIZE_LARGE)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_LARGE, 0.0, 6, nMySpellAbilityLevel1, HENCH_CHECK_FORT_SAVE, HENCH_AREA_CHECK_ABLDEC))
                {
                    nAreaPosition = 149;
                    nSpell = SPELLABILITY_PULSE_ABILITY_DRAIN_INTELLIGENCE; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (nAreaPosition < 130)
        {
            break;
        }
        if (GetHasSpell(SPELLABILITY_PULSE_ABILITY_DRAIN_CHARISMA))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_PULSE_ABILITY_DRAIN_CHARISMA && allowAttackAbilities && nRange <= RADIUS_SIZE_LARGE)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_LARGE, 0.0, 6, nMySpellAbilityLevel1, HENCH_CHECK_FORT_SAVE, HENCH_AREA_CHECK_ABLDEC))
                {
                    nAreaPosition = 150;
                    nSpell = SPELLABILITY_PULSE_ABILITY_DRAIN_CHARISMA; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_PULSE_ABILITY_DRAIN_CONSTITUTION))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_PULSE_ABILITY_DRAIN_CONSTITUTION && allowAttackAbilities && nRange <= RADIUS_SIZE_LARGE)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_LARGE, 0.0, 6, nMySpellAbilityLevel1, HENCH_CHECK_FORT_SAVE, HENCH_AREA_CHECK_ABLDEC))
                {
                    nAreaPosition = 151;
                    nSpell = SPELLABILITY_PULSE_ABILITY_DRAIN_CONSTITUTION; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_PULSE_ABILITY_DRAIN_DEXTERITY))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_PULSE_ABILITY_DRAIN_DEXTERITY && allowAttackAbilities && nRange <= RADIUS_SIZE_LARGE)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_LARGE, 0.0, 6, nMySpellAbilityLevel1, HENCH_CHECK_FORT_SAVE, HENCH_AREA_CHECK_ABLDEC))
                {
                    nAreaPosition = 152;
                    nSpell = SPELLABILITY_PULSE_ABILITY_DRAIN_DEXTERITY; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_PULSE_ABILITY_DRAIN_STRENGTH))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_PULSE_ABILITY_DRAIN_STRENGTH && allowAttackAbilities && nRange <= RADIUS_SIZE_LARGE)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_LARGE, 0.0, 6, nMySpellAbilityLevel1, HENCH_CHECK_FORT_SAVE, HENCH_AREA_CHECK_ABLDEC))
                {
                    nAreaPosition = 153;
                    nSpell = SPELLABILITY_PULSE_ABILITY_DRAIN_STRENGTH; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_PULSE_ABILITY_DRAIN_WISDOM))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_PULSE_ABILITY_DRAIN_WISDOM && allowAttackAbilities && nRange <= RADIUS_SIZE_MEDIUM)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, 0.0, 6, nMySpellAbilityLevel1, HENCH_CHECK_FORT_SAVE, HENCH_AREA_CHECK_ABLDEC))
                {
                    nAreaPosition = 154;
                    nSpell = SPELLABILITY_PULSE_ABILITY_DRAIN_WISDOM; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_FIREBRAND))
        {
            if (nLastSpellCast != SPELL_FIREBRAND && useAttackSpells && nRange <= 20.0 + RADIUS_SIZE_GARGANTUAN)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, 20.0, 5, -1000, HENCH_CHECK_SR_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 155;
                    nSpell = SPELL_FIREBRAND; nSpellLevel = 5; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_BALL_LIGHTNING))
        {
            if (nLastSpellCast != SPELL_BALL_LIGHTNING && useAttackSpells && nRange <= 20.0 + RADIUS_SIZE_GARGANTUAN)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, 20.0, 5, -1000, HENCH_CHECK_SR_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 156;
                    nSpell = SPELL_BALL_LIGHTNING; nSpellLevel = 5; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_ETHEREAL_VISAGE))
        {
            if (nLastSpellCast != SPELL_ETHEREAL_VISAGE && (d100() <= 50))
            {
                if (buffSelf && !GetHasEffect(EFFECT_TYPE_DAMAGE_REDUCTION, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_ETHEREAL_VISAGE, OBJECT_SELF, 5); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_CLOUDKILL))
        {
            if (nLastSpellCast != SPELL_CLOUDKILL && useAttackSpells && nRange <= 40.0 + 5.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, 5.0, 40.0, 5, -1000, HENCH_CHECK_SR_NO_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 158;
                    nSpell = SPELL_CLOUDKILL; nSpellLevel = 5; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_ICE_STORM))
        {
            if (nLastSpellCast != SPELL_ICE_STORM && useAttackSpells && nRange <= 40.0 + RADIUS_SIZE_HUGE)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_HUGE, 40.0, 4, -1000, HENCH_CHECK_SR_NO_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 159;
                    nSpell = SPELL_ICE_STORM; nSpellLevel = 4; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (nAreaPosition < 140)
        {
            break;
        }
        if (GetHasFixedSpell(SPELL_INFERNO))
        {
            if (nLastSpellCast != SPELL_INFERNO && nRange <= 8.0 && useAttackSpells && CheckSpellSaves(oTarget, 5, HENCH_CHECK_SR_NO_SAVE) && !GetHasSpellEffect(SPELL_INFERNO, oTarget))
            {
                CastSetLastSpellOnObject(SPELL_INFERNO, oTarget, 5); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELL_HENCH_Psionic_Inertial_Barrier))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELL_HENCH_Psionic_Inertial_Barrier)
            {
                if (allowBuffAbilities && !GetHasEffect(EFFECT_TYPE_DAMAGE_REDUCTION, OBJECT_SELF))
                {
                    CastSpellAbilityOnObject(SPELL_HENCH_Psionic_Inertial_Barrier, OBJECT_SELF); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasSpell(SPELL_HENCH_Psionic_Mass_Concussion))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELL_HENCH_Psionic_Mass_Concussion && allowAttackAbilities && nRange <= 20.0 + RADIUS_SIZE_MEDIUM)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, 20.0, 5, nMySpellAbilityLevel12 + 5, HENCH_CHECK_NO_SAVE, HENCH_AREA_CHECK_MIND))
                {
                    nAreaPosition = 162;
                    nSpell = SPELL_HENCH_Psionic_Mass_Concussion; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_CONE_OF_COLD))
        {
            if (nLastSpellCast != SPELL_CONE_OF_COLD && useAttackSpells && nRange <= 11.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 11.0, 8.0, 5, -1000, HENCH_CHECK_SR_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 163;
                    nSpell = SPELL_CONE_OF_COLD; nSpellLevel = 5; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_SHADES_CONE_OF_COLD))
        {
            if (nLastSpellCast != SPELL_SHADES_CONE_OF_COLD && useAttackSpells && nRange <= 11.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 11.0, 20.0, 6, -1000, HENCH_CHECK_SR_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 164;
                    nSpell = SPELL_SHADES_CONE_OF_COLD; nSpellLevel = 6; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_CIRCLE_OF_DOOM))
        {
            if (nLastSpellCast != SPELL_CIRCLE_OF_DOOM && useAttackSpells && nRange <= 20.0 + RADIUS_SIZE_MEDIUM)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, 20.0, 5, -1000, HENCH_CHECK_SR_NO_SAVE, HENCH_AREA_CHECK_NEGLEVEL))
                {
                    nAreaPosition = 165;
                    nSpell = SPELL_CIRCLE_OF_DOOM; nSpellLevel = 5; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_HENCH_Evil_Blight))
        {
            if (nLastSpellCast != SPELL_HENCH_Evil_Blight && useAttackSpells && nRange <= 20.0 + RADIUS_SIZE_COLOSSAL)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, 20.0, 5, -1000, HENCH_CHECK_SR_WILL_SAVE, HENCH_AREA_CHECK_CURSE))
                {
                    nAreaPosition = 166;
                    nSpell = SPELL_HENCH_Evil_Blight; nSpellLevel = 5; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_BATTLETIDE))
        {
            if (nLastSpellCast != SPELL_BATTLETIDE && useAttackSpells && nRange <= 3.3)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, 3.3, 0.0, 5, -1000, HENCH_CHECK_SR_WILL_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 167;
                    nSpell = SPELL_BATTLETIDE; nSpellLevel = 5; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_FEEBLEMIND))
        {
            if (nLastSpellCast != SPELL_FEEBLEMIND && nRange <= 20.0 && useAttackSpells && !(GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) || GetIsImmune(oTarget, IMMUNITY_TYPE_ABILITY_DECREASE, OBJECT_SELF)) && !GetIsDisabled1(EFFECT_TYPE_ABILITY_DECREASE, oTarget) && CheckSpellSaves(oTarget, 5, HENCH_CHECK_SR_WILL_SAVE))
            {
                CastSetLastSpellOnObject(SPELL_FEEBLEMIND, oTarget, 5); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_HEALING_CIRCLE))
        {
            if (nLastSpellCast != SPELL_HEALING_CIRCLE && useAttackSpells && nRange <= RADIUS_SIZE_LARGE)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_LARGE, 0.0, 5, -1000, HENCH_CHECK_SR_NO_SAVE, HENCH_AREA_CHECK_HEAL))
                {
                    nAreaPosition = 169;
                    nSpell = SPELL_HEALING_CIRCLE; nSpellLevel = 5; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (nAreaPosition < 150)
        {
            break;
        }
        if (GetHasFixedSpell(SPELL_SLAY_LIVING))
        {
            if (nLastSpellCast != SPELL_SLAY_LIVING && nRange <= 4.0 && useAttackSpells && !GetIsImmune(oTarget, IMMUNITY_TYPE_DEATH, OBJECT_SELF) && CheckSpellSaves(oTarget, 5, HENCH_CHECK_SR_NO_SAVE))
            {
                CastSetLastSpellOnObject(SPELL_SLAY_LIVING, oTarget, 5); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_BIGBYS_INTERPOSING_HAND))
        {
            if (nLastSpellCast != SPELL_BIGBYS_INTERPOSING_HAND && nRange <= 40.0 && useAttackSpells && !GetIsImmune(oTarget, IMMUNITY_TYPE_ATTACK_DECREASE, OBJECT_SELF) && !GetIsDisabled1(EFFECT_TYPE_ATTACK_DECREASE, oTarget) && CheckSpellSaves(oTarget, 5, HENCH_CHECK_SR_NO_SAVE) && !GetHasSpellEffect(SPELL_BIGBYS_CLENCHED_FIST, oTarget))
            {
                CastSetLastSpellOnObject(SPELL_BIGBYS_INTERPOSING_HAND, oTarget, 5); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_MONSTROUS_REGENERATION))
        {
            if (nLastSpellCast != SPELL_MONSTROUS_REGENERATION)
            {
                if (buffSelf && !GetHasEffect(EFFECT_TYPE_REGENERATE, OBJECT_SELF) && !GetCreatureHasItemProperty(ITEM_PROPERTY_REGENERATION, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_MONSTROUS_REGENERATION, OBJECT_SELF, 5); return TK_BUFFSELF;
                }
                if (!bFoundPotionOnly && buffOthers  && GetBestBuffTarget(-1, EFFECT_TYPE_REGENERATE, -1, ITEM_PROPERTY_REGENERATION))
                {
                    CastSetLastSpellOnObject(SPELL_MONSTROUS_REGENERATION, oBestBuffTarget, 5); return TK_BUFFOTHER;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_LESSER_MIND_BLANK))
        {
            if (nLastSpellCast != SPELL_LESSER_MIND_BLANK)
            {
                if (buffSelf && !GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_LESSER_MIND_BLANK, OBJECT_SELF, 5); return TK_BUFFSELF;
                }
                if (!bFoundPotionOnly && buffOthers  && GetBestBuffTarget(IMMUNITY_TYPE_MIND_SPELLS, -1, -1, -1))
                {
                    CastSetLastSpellOnObject(SPELL_LESSER_MIND_BLANK, oBestBuffTarget, 5); return TK_BUFFOTHER;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_LESSER_PLANAR_BINDING))
        {
            if (nLastSpellCast != SPELL_LESSER_PLANAR_BINDING && allowSummons)
            {
                CastSetLastSpellAtLocation(SPELL_LESSER_PLANAR_BINDING, GetSummonLocation(oTarget), 5); return TK_SUMMON;
            }
        }
        if (GetHasFixedSpell(SPELL_MESTILS_ACID_SHEATH))
        {
            if (nLastSpellCast != SPELL_MESTILS_ACID_SHEATH)
            {
                if (buffSelf && !GetHasSpellEffect(SPELL_MESTILS_ACID_SHEATH, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_MESTILS_ACID_SHEATH, OBJECT_SELF, 5); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_LESSER_SPELL_MANTLE))
        {
            if (nLastSpellCast != SPELL_LESSER_SPELL_MANTLE)
            {
                if (buffSelf && HenchUseSpellProtections() && !GetHasEffect(EFFECT_TYPE_SPELLLEVELABSORPTION, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_LESSER_SPELL_MANTLE, OBJECT_SELF, 5); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_MIND_FOG))
        {
            if (nLastSpellCast != SPELL_MIND_FOG && useAttackSpells && nRange <= 40.0 + 5.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, 5.0, 40.0, 5, -1000, HENCH_CHECK_SR_WILL_SAVE, HENCH_AREA_CHECK_MIND))
                {
                    nAreaPosition = 177;
                    nSpell = SPELL_MIND_FOG; nSpellLevel = 5; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        {
            int attrResult = GetBestSpellProtTarget(buffSelf, buffOthers, nLastSpellCast);
            if (attrResult)
            {
                return attrResult;
            }
        }
        if (GetHasFixedSpell(SPELL_SUMMON_CREATURE_V))
        {
            if (nLastSpellCast != SPELL_SUMMON_CREATURE_V && allowSummons)
            {
                CastSetLastSpellAtLocation(SPELL_SUMMON_CREATURE_V, GetSummonLocation(oTarget), 5); return TK_SUMMON;
            }
        }
        if (nAreaPosition < 160)
        {
            break;
        }
        if (GetHasSpell(SPELLABILITY_BREATH_PETRIFY))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_BREATH_PETRIFY && allowAttackAbilities && nRange <= 11.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 11.0, 8.0, 5, 17 + nMySpellCasterDCAdjust, HENCH_CHECK_FORT_SAVE, HENCH_AREA_CHECK_PETRIFY))
                {
                    nAreaPosition = 180;
                    nSpell = SPELLABILITY_BREATH_PETRIFY; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_GAZE_PETRIFY))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_GAZE_PETRIFY && allowAttackAbilities && nRange <= 10.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 10.0, 20.0, 5, nMySpellAbilityLevel12, HENCH_CHECK_FORT_SAVE, HENCH_AREA_CHECK_PETRIFY))
                {
                    nAreaPosition = 181;
                    nSpell = SPELLABILITY_GAZE_PETRIFY; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_TOUCH_PETRIFY))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_TOUCH_PETRIFY && nRange <= 4.0 && allowAttackAbilities && !GetIsDisabled(oTarget) && GetFortitudeSavingThrow(oTarget) <= 15 + nMySpellCasterDCAdjust && !spellsIsImmuneToPetrification(oTarget))
            {
                CastSpellAbilityOnObject(SPELLABILITY_TOUCH_PETRIFY, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELLABILITY_MANTICORE_SPIKES))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_MANTICORE_SPIKES && allowAttackAbilities && nRange <= 20.0 + RADIUS_SIZE_GARGANTUAN)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, 20.0, 5, 1000, HENCH_CHECK_NO_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 183;
                    nSpell = SPELLABILITY_MANTICORE_SPIKES; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_BOLT_DAZE))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_BOLT_DAZE && nRange <= 20.0 && allowAttackAbilities && !(GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) || GetIsImmune(oTarget, IMMUNITY_TYPE_DAZED, OBJECT_SELF)) && !GetIsDisabled(oTarget))
            {
                CastSpellAbilityOnObject(SPELLABILITY_BOLT_DAZE, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELLABILITY_BOLT_DEATH))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_BOLT_DEATH && nRange <= 20.0 && allowAttackAbilities && !GetIsImmune(oTarget, IMMUNITY_TYPE_DEATH, OBJECT_SELF))
            {
                CastSpellAbilityOnObject(SPELLABILITY_BOLT_DEATH, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELLABILITY_BOLT_PARALYZE))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_BOLT_PARALYZE && nRange <= 20.0 && allowAttackAbilities && !(GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) || GetIsImmune(oTarget, IMMUNITY_TYPE_PARALYSIS, OBJECT_SELF)) && !GetIsDisabled(oTarget))
            {
                CastSpellAbilityOnObject(SPELLABILITY_BOLT_PARALYZE, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELLABILITY_BOLT_POISON))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_BOLT_POISON && nRange <= 20.0 && allowAttackAbilities && !GetIsImmune(oTarget, IMMUNITY_TYPE_POISON, OBJECT_SELF) && !GetIsDisabled1(EFFECT_TYPE_POISON, oTarget) && GetFortitudeSavingThrow(oTarget) <= GetCreaturePoisonDC() + nMySpellCasterDCAdjust)
            {
                CastSpellAbilityOnObject(SPELLABILITY_BOLT_POISON, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELLABILITY_BOLT_STUN))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_BOLT_STUN && nRange <= 20.0 && allowAttackAbilities && !(GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) || GetIsImmune(oTarget, IMMUNITY_TYPE_STUN, OBJECT_SELF)) && !GetIsDisabled(oTarget))
            {
                CastSpellAbilityOnObject(SPELLABILITY_BOLT_STUN, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELLABILITY_CONE_ACID))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_CONE_ACID && allowAttackAbilities && nRange <= 10.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 10.0, 8.0, 5, nMySpellAbilityLevel12, HENCH_CHECK_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 189;
                    nSpell = SPELLABILITY_CONE_ACID; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (nAreaPosition < 170)
        {
            break;
        }
        if (GetHasSpell(SPELLABILITY_CONE_COLD))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_CONE_COLD && allowAttackAbilities && nRange <= 10.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 10.0, 8.0, 5, nMySpellAbilityLevel12, HENCH_CHECK_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 190;
                    nSpell = SPELLABILITY_CONE_COLD; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_CONE_DISEASE))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_CONE_DISEASE && allowAttackAbilities && nRange <= 10.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 10.0, 8.0, 5, GetCreatureDiseaseDC(DISEASE_CHECK_CONE) + nMySpellCasterDCAdjust, HENCH_CHECK_FORT_SAVE, HENCH_AREA_CHECK_DISEASE))
                {
                    nAreaPosition = 191;
                    nSpell = SPELLABILITY_CONE_DISEASE; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_CONE_FIRE))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_CONE_FIRE && allowAttackAbilities && nRange <= 10.0)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPELLCONE, 10.0, 8.0, 5, nMySpellAbilityLevel12, HENCH_CHECK_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 192;
                    nSpell = SPELLABILITY_CONE_FIRE; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_CONE_LIGHTNING))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_CONE_LIGHTNING && allowAttackAbilities && nRange <= 10.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 10.0, 8.0, 5, nMySpellAbilityLevel12, HENCH_CHECK_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 193;
                    nSpell = SPELLABILITY_CONE_LIGHTNING; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_CONE_SONIC))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_CONE_SONIC && allowAttackAbilities && nRange <= 10.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 10.0, 8.0, 5, nMySpellAbilityLevel12, HENCH_CHECK_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 194;
                    nSpell = SPELLABILITY_CONE_SONIC; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_GAZE_CHARM))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_GAZE_CHARM && allowAttackAbilities && nRange <= 10.0)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPELLCONE, 10.0, 8.0, 5, nMySpellAbilityLevel12, HENCH_CHECK_WILL_SAVE, HENCH_AREA_CHECK_CHARM_AND_MIND))
                {
                    nAreaPosition = 195;
                    nSpell = SPELLABILITY_GAZE_CHARM; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_GAZE_CONFUSION))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_GAZE_CONFUSION && allowAttackAbilities && nRange <= 10.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 10.0, 8.0, 5, nMySpellAbilityLevel12, HENCH_CHECK_WILL_SAVE, HENCH_AREA_CHECK_CONF_AND_MIND))
                {
                    nAreaPosition = 196;
                    nSpell = SPELLABILITY_GAZE_CONFUSION; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_GAZE_DESTROY_CHAOS))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_GAZE_DESTROY_CHAOS && allowAttackAbilities && nRange <= 10.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 10.0, 8.0, 5, nMySpellAbilityLevel12, HENCH_CHECK_WILL_SAVE, HENCH_AREA_CHECK_DEATH))
                {
                    nAreaPosition = 197;
                    nSpell = SPELLABILITY_GAZE_DESTROY_CHAOS; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_GAZE_DESTROY_EVIL))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_GAZE_DESTROY_EVIL && allowAttackAbilities && nRange <= 10.0 && iTargetGEAlign == ALIGNMENT_EVIL)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 10.0, 8.0, 5, nMySpellAbilityLevel12, HENCH_CHECK_WILL_SAVE, HENCH_AREA_CHECK_DEATH))
                {
                    nAreaPosition = 198;
                    nSpell = SPELLABILITY_GAZE_DESTROY_EVIL; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_GAZE_DESTROY_GOOD))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_GAZE_DESTROY_GOOD && allowAttackAbilities && nRange <= 10.0 && iTargetGEAlign == ALIGNMENT_GOOD)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 10.0, 8.0, 5, nMySpellAbilityLevel12, HENCH_CHECK_WILL_SAVE, HENCH_AREA_CHECK_DEATH))
                {
                    nAreaPosition = 199;
                    nSpell = SPELLABILITY_GAZE_DESTROY_GOOD; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (nAreaPosition < 180)
        {
            break;
        }
        if (GetHasSpell(SPELLABILITY_GAZE_DESTROY_LAW))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_GAZE_DESTROY_LAW && allowAttackAbilities && nRange <= 10.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 10.0, 8.0, 5, nMySpellAbilityLevel12, HENCH_CHECK_WILL_SAVE, HENCH_AREA_CHECK_DEATH))
                {
                    nAreaPosition = 200;
                    nSpell = SPELLABILITY_GAZE_DESTROY_LAW; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_GAZE_FEAR))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_GAZE_FEAR && allowAttackAbilities && nRange <= 10.0)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPELLCONE, 10.0, 8.0, 5, nMySpellAbilityLevel12, HENCH_CHECK_WILL_SAVE, HENCH_AREA_CHECK_MIND_AND_FEAR))
                {
                    nAreaPosition = 201;
                    nSpell = SPELLABILITY_GAZE_FEAR; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_GAZE_PARALYSIS))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_GAZE_PARALYSIS && allowAttackAbilities && nRange <= 10.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 10.0, 8.0, 5, nMySpellAbilityLevel12, HENCH_CHECK_WILL_SAVE, HENCH_AREA_CHECK_PARA_AND_MIND))
                {
                    nAreaPosition = 202;
                    nSpell = SPELLABILITY_GAZE_PARALYSIS; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_GAZE_STUNNED))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_GAZE_STUNNED && allowAttackAbilities && nRange <= 10.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 10.0, 8.0, 5, nMySpellAbilityLevel12, HENCH_CHECK_WILL_SAVE, HENCH_AREA_CHECK_STUN_AND_MIND))
                {
                    nAreaPosition = 203;
                    nSpell = SPELLABILITY_GAZE_STUNNED; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_GOLEM_BREATH_GAS))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_GOLEM_BREATH_GAS && allowAttackAbilities && nRange <= 10.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 10.0, 8.0, 5, 17 + nMySpellCasterDCAdjust, HENCH_CHECK_FORT_SAVE, HENCH_AREA_CHECK_POISON))
                {
                    nAreaPosition = 204;
                    nSpell = SPELLABILITY_GOLEM_BREATH_GAS; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_HOWL_FEAR))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_HOWL_FEAR && allowAttackAbilities && nRange <= RADIUS_SIZE_COLOSSAL)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, 0.0, 5, nMySpellAbilityLevel14, HENCH_CHECK_WILL_SAVE, HENCH_AREA_CHECK_MIND_AND_FEAR))
                {
                    nAreaPosition = 205;
                    nSpell = SPELLABILITY_HOWL_FEAR; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_HOWL_PARALYSIS))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_HOWL_PARALYSIS && allowAttackAbilities && nRange <= RADIUS_SIZE_COLOSSAL)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, 0.0, 5, nMySpellAbilityLevel14, HENCH_CHECK_WILL_SAVE, HENCH_AREA_CHECK_PARA_AND_MIND))
                {
                    nAreaPosition = 206;
                    nSpell = SPELLABILITY_HOWL_PARALYSIS; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_HOWL_SONIC))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_HOWL_SONIC && allowAttackAbilities && nRange <= RADIUS_SIZE_COLOSSAL)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, 0.0, 5, nMySpellAbilityLevel14, HENCH_CHECK_NO_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 207;
                    nSpell = SPELLABILITY_HOWL_SONIC; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_INTENSITY_3))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_INTENSITY_3)
            {
                if (allowBuffAbilities && !GetHasSpellEffect(SPELLABILITY_INTENSITY_3, OBJECT_SELF))
                {
                    CastSpellAbilityOnObject(SPELLABILITY_INTENSITY_3, OBJECT_SELF); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_PULSE_FIRE))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_PULSE_FIRE && allowAttackAbilities && nRange <= RADIUS_SIZE_LARGE)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_LARGE, 0.0, 5, nMySpellAbilityLevel1, HENCH_CHECK_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 209;
                    nSpell = SPELLABILITY_PULSE_FIRE; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (nAreaPosition < 190)
        {
            break;
        }
        if (GetHasSpell(SPELLABILITY_PULSE_LIGHTNING))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_PULSE_LIGHTNING && allowAttackAbilities && nRange <= RADIUS_SIZE_LARGE)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_LARGE, 0.0, 5, nMySpellAbilityLevel1, HENCH_CHECK_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 210;
                    nSpell = SPELLABILITY_PULSE_LIGHTNING; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_PULSE_COLD))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_PULSE_COLD && allowAttackAbilities && nRange <= RADIUS_SIZE_LARGE)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_LARGE, 0.0, 5, nMySpellAbilityLevel1, HENCH_CHECK_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 211;
                    nSpell = SPELLABILITY_PULSE_COLD; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_PULSE_NEGATIVE))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_PULSE_NEGATIVE && allowAttackAbilities && nRange <= RADIUS_SIZE_LARGE)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_LARGE, 0.0, 5, nMySpellAbilityLevel1, HENCH_CHECK_REFLEX_EVASION_SAVE, HENCH_AREA_CHECK_NEGLEVEL))
                {
                    nAreaPosition = 212;
                    nSpell = SPELLABILITY_PULSE_NEGATIVE; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_PULSE_HOLY))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_PULSE_HOLY && allowAttackAbilities && nRange <= RADIUS_SIZE_LARGE)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_LARGE, 0.0, 5, nMySpellAbilityLevel1, HENCH_CHECK_REFLEX_EVASION_SAVE, HENCH_AREA_CHECK_HEAL))
                {
                    nAreaPosition = 213;
                    nSpell = SPELLABILITY_PULSE_HOLY; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_PULSE_POISON))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_PULSE_POISON && allowAttackAbilities && nRange <= RADIUS_SIZE_LARGE)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_LARGE, 0.0, 5, GetCreaturePoisonDC() + nMySpellCasterDCAdjust, HENCH_CHECK_FORT_SAVE, HENCH_AREA_CHECK_POISON))
                {
                    nAreaPosition = 214;
                    nSpell = SPELLABILITY_PULSE_POISON; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_PULSE_DISEASE))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_PULSE_DISEASE && allowAttackAbilities && nRange <= RADIUS_SIZE_LARGE)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_LARGE, 0.0, 5, GetCreatureDiseaseDC(DISEASE_CHECK_PULSE) + nMySpellCasterDCAdjust, HENCH_CHECK_FORT_SAVE, HENCH_AREA_CHECK_DISEASE))
                {
                    nAreaPosition = 215;
                    nSpell = SPELLABILITY_PULSE_DISEASE; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_SUMMON_SLAAD))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_SUMMON_SLAAD && allowSummons)
            {
                CastSpellAbilityAtLocation(SPELLABILITY_SUMMON_SLAAD, GetSummonLocation(oTarget)); return TK_SUMMON;
            }
        }
        if (GetHasSpell(SPELLABILITY_SUMMON_TANARRI))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_SUMMON_TANARRI && allowSummons)
            {
                CastSpellAbilityAtLocation(SPELLABILITY_SUMMON_TANARRI, GetSummonLocation(oTarget)); return TK_SUMMON;
            }
        }
        if (GetHasSpell(SPELLABILITY_TRUMPET_BLAST))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_TRUMPET_BLAST && allowAttackAbilities && nRange <= 40.0 + RADIUS_SIZE_COLOSSAL)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, 40.0, 5, nMySpellAbilityLevel14, HENCH_CHECK_WILL_SAVE, HENCH_AREA_CHECK_PARA_AND_MIND))
                {
                    nAreaPosition = 218;
                    nSpell = SPELLABILITY_TRUMPET_BLAST; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_SEAHAG_EVILEYE))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_SEAHAG_EVILEYE && nRange <= 8.0 && allowAttackAbilities && !GetIsImmune(oTarget, IMMUNITY_TYPE_ABILITY_DECREASE, OBJECT_SELF) && !GetIsDisabled1(EFFECT_TYPE_ABILITY_DECREASE, oTarget) && GetFortitudeSavingThrow(oTarget) <= 11 + nMySpellCasterDCAdjust)
            {
                CastSpellAbilityOnObject(SPELLABILITY_SEAHAG_EVILEYE, oTarget); return TK_ATTACK;
            }
        }
        if (nAreaPosition < 200)
        {
            break;
        }
        if (GetHasFixedSpell(SPELL_AWAKEN))
        {
            if (nLastSpellCast != SPELL_AWAKEN && buffAnimalCompanion && GetDistanceToObject(oAnimalCompanion) <= 5.0 && !GetHasSpellEffect(SPELL_AWAKEN, oAnimalCompanion))
            {
                CastSetLastSpellOnObject(SPELL_AWAKEN, oAnimalCompanion, 5); return TK_BUFFOTHER;
            }
        }
        if (GetHasFixedSpell(SPELL_ENERGY_BUFFER))
        {
            if (nLastSpellCast != SPELL_ENERGY_BUFFER)
            {
                if (buffSelf && !GetHasSpellEffect(SPELL_ELEMENTAL_SHIELD, OBJECT_SELF) && !GetHasSpellEffect(SPELL_PROTECTION_FROM_ELEMENTS, OBJECT_SELF) && !GetHasSpellEffect(SPELL_RESIST_ELEMENTS, OBJECT_SELF) && !GetHasSpellEffect(SPELL_ENDURE_ELEMENTS, OBJECT_SELF) && !GetHasSpellEffect(SPELL_ENERGY_BUFFER, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_ENERGY_BUFFER, OBJECT_SELF, 5); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_SUMMON_MEPHIT))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_SUMMON_MEPHIT && allowSummons)
            {
                CastSpellAbilityAtLocation(SPELLABILITY_SUMMON_MEPHIT, GetSummonLocation(oTarget)); return TK_SUMMON;
            }
        }
        if (GetHasFixedSpell(SPELLABILITY_SUMMON_CELESTIAL))
        {
            if (nLastSpellCast != SPELLABILITY_SUMMON_CELESTIAL && allowSummons)
            {
                CastSetLastSpellAtLocation(SPELLABILITY_SUMMON_CELESTIAL, GetSummonLocation(oTarget), 5); return TK_SUMMON;
            }
        }
        if (GetHasFixedSpell(SPELL_STONESKIN))
        {
            if (nLastSpellCast != SPELL_STONESKIN)
            {
                if (buffSelf && !GetHasEffect(EFFECT_TYPE_DAMAGE_REDUCTION, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_STONESKIN, OBJECT_SELF, 4); return TK_BUFFSELF;
                }
                if (!bFoundPotionOnly && buffOthers  && GetBestBuffTarget(-1, EFFECT_TYPE_DAMAGE_REDUCTION, -1, -1))
                {
                    CastSetLastSpellOnObject(SPELL_STONESKIN, oBestBuffTarget, 4); return TK_BUFFOTHER;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_SHADES_STONESKIN))
        {
            if (nLastSpellCast != SPELL_SHADES_STONESKIN)
            {
                if (buffSelf && !GetHasEffect(EFFECT_TYPE_DAMAGE_REDUCTION, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_SHADES_STONESKIN, OBJECT_SELF, 6); return TK_BUFFSELF;
                }
                if (!bFoundPotionOnly && buffOthers  && GetBestBuffTarget(-1, EFFECT_TYPE_DAMAGE_REDUCTION, -1, -1))
                {
                    CastSetLastSpellOnObject(SPELL_SHADES_STONESKIN, oBestBuffTarget, 6); return TK_BUFFOTHER;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_FLAME_STRIKE))
        {
            if (nLastSpellCast != SPELL_FLAME_STRIKE && useAttackSpells && nRange <= 20.0 + RADIUS_SIZE_MEDIUM)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, 20.0, 4, -1000, HENCH_CHECK_SR_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 226;
                    nSpell = SPELL_FLAME_STRIKE; nSpellLevel = 4; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_ISAACS_LESSER_MISSILE_STORM))
        {
            if (nLastSpellCast != SPELL_ISAACS_LESSER_MISSILE_STORM && useAttackSpells && nRange <= 40.0 + RADIUS_SIZE_GARGANTUAN)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, 40.0, 4, -1000, HENCH_CHECK_SR_NO_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 227;
                    nSpell = SPELL_ISAACS_LESSER_MISSILE_STORM; nSpellLevel = 4; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_WALL_OF_FIRE))
        {
            if (nLastSpellCast != SPELL_WALL_OF_FIRE && useAttackSpells && nRange <= 20.0 + 5.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, 5.0, 20.0, 4, -1000, HENCH_CHECK_SR_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 228;
                    nSpell = SPELL_WALL_OF_FIRE; nSpellLevel = 4; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_SHADES_WALL_OF_FIRE))
        {
            if (nLastSpellCast != SPELL_SHADES_WALL_OF_FIRE && useAttackSpells && nRange <= 20.0 + 5.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, 5.0, 20.0, 6, -1000, HENCH_CHECK_SR_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 229;
                    nSpell = SPELL_SHADES_WALL_OF_FIRE; nSpellLevel = 6; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (nAreaPosition < 210)
        {
            break;
        }
        if (GetHasFixedSpell(SPELL_HAMMER_OF_THE_GODS))
        {
            if (nLastSpellCast != SPELL_HAMMER_OF_THE_GODS && useAttackSpells && nRange <= 20.0 + RADIUS_SIZE_HUGE)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_HUGE, 20.0, 4, -1000, HENCH_CHECK_SR_NO_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 230;
                    nSpell = SPELL_HAMMER_OF_THE_GODS; nSpellLevel = 4; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_EVARDS_BLACK_TENTACLES))
        {
            if (nLastSpellCast != SPELL_EVARDS_BLACK_TENTACLES && useAttackSpells && nRange <= 20.0 + 5.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, 5.0, 20.0, 4, -1000, HENCH_CHECK_NO_SAVE, HENCH_AREA_CHECK_EVARDS_TENTACLES))
                {
                    nAreaPosition = 231;
                    nSpell = SPELL_EVARDS_BLACK_TENTACLES; nSpellLevel = 4; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_WAR_CRY))
        {
            if (nLastSpellCast != SPELL_WAR_CRY && useAttackSpells && nRange <= RADIUS_SIZE_COLOSSAL)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, 0.0, 4, -1000, HENCH_CHECK_SR_WILL_SAVE, HENCH_AREA_CHECK_MIND_AND_FEAR))
                {
                    nAreaPosition = 232;
                    nSpell = SPELL_WAR_CRY; nSpellLevel = 4; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELL_HENCH_Harpysong))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELL_HENCH_Harpysong && allowAttackAbilities && nRange <= RADIUS_SIZE_HUGE)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_HUGE, 0.0, 4, 15 + nMySpellCasterDCAdjust, HENCH_CHECK_WILL_SAVE, HENCH_AREA_CHECK_HUMANIOD))
                {
                    nAreaPosition = 233;
                    nSpell = SPELL_HENCH_Harpysong; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELL_HENCH_Slaad_Chaos_Spittle))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELL_HENCH_Slaad_Chaos_Spittle && nRange <= 20.0 && allowAttackAbilities)
            {
                CastSpellAbilityOnObject(SPELL_HENCH_Slaad_Chaos_Spittle, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasFeat(FEAT_SHADOW_DAZE))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != FEAT_SHADOW_DAZE && nRange <= 40.0 && allowAttackAbilities && !(GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) || GetIsImmune(oTarget, IMMUNITY_TYPE_DAZED, OBJECT_SELF)) && !GetIsDisabled(oTarget) && GetWillSavingThrow(oTarget) <= nMySpellAbilityLevel1)
            {
                CastFeatOnObject(FEAT_SHADOW_DAZE, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasCureSpell(SPELL_CURE_CRITICAL_WOUNDS))
        {
            if (nLastSpellCast != SPELL_CURE_CRITICAL_WOUNDS && nRange <= 4.0 && useAttackSpells && CheckSpellSaves(oTarget, 4, HENCH_CHECK_SR_NO_SAVE) && nRacialType == RACIAL_TYPE_UNDEAD)
            {
                CastSetLastSpellOnObject(SPELL_CURE_CRITICAL_WOUNDS, oTarget, 4); return TK_ATTACK;
            }
        }
        if (GetHasFeat(FEAT_INFLICT_CRITICAL_WOUNDS))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != FEAT_INFLICT_CRITICAL_WOUNDS && nRange <= 4.0 && allowAttackAbilities && nRacialType != RACIAL_TYPE_UNDEAD)
            {
                CastFeatOnObject(FEAT_INFLICT_CRITICAL_WOUNDS, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasInflictSpell(SPELL_INFLICT_CRITICAL_WOUNDS))
        {
            if (nLastSpellCast != SPELL_INFLICT_CRITICAL_WOUNDS && nRange <= 4.0 && useAttackSpells && CheckSpellSaves(oTarget, 4, HENCH_CHECK_SR_NO_SAVE) && nRacialType != RACIAL_TYPE_UNDEAD)
            {
                CastSetLastSpellOnObject(SPELL_INFLICT_CRITICAL_WOUNDS, oTarget, 4); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_DEATH_WARD))
        {
            if (nLastSpellCast != SPELL_DEATH_WARD)
            {
                if (buffSelf && !GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_DEATH, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_DEATH_WARD, OBJECT_SELF, 4); return TK_BUFFSELF;
                }
                if (!bFoundPotionOnly && buffOthers  && GetBestBuffTarget(IMMUNITY_TYPE_DEATH, -1, -1, -1))
                {
                    CastSetLastSpellOnObject(SPELL_DEATH_WARD, oBestBuffTarget, 4); return TK_BUFFOTHER;
                }
            }
        }
        if (nAreaPosition < 220)
        {
            break;
        }
        if (GetHasFixedSpell(SPELL_ENERVATION))
        {
            if (nLastSpellCast != SPELL_ENERVATION && nRange <= 8.0 && useAttackSpells && !GetIsImmune(oTarget, IMMUNITY_TYPE_NEGATIVE_LEVEL, OBJECT_SELF) && CheckSpellSaves(oTarget, 4, HENCH_CHECK_SR_FORT_SAVE))
            {
                CastSetLastSpellOnObject(SPELL_ENERVATION, oTarget, 4); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_DOMINATE_PERSON))
        {
            if (nLastSpellCast != SPELL_DOMINATE_PERSON && allowDominate && nRange <= 20.0 && useAttackSpells && !(GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) || GetIsImmune(oTarget, IMMUNITY_TYPE_DOMINATE, OBJECT_SELF)) && CheckSpellSaves(oTarget, 4, HENCH_CHECK_SR_WILL_SAVE) && GetIsPlayableRacialType(oTarget))
            {
                SetLastDominate(); CastSetLastSpellOnObject(SPELL_DOMINATE_PERSON, oTarget, 4); return TK_DOMINATE;
            }
        }
        if (GetHasFixedSpell(SPELL_ELEMENTAL_SHIELD))
        {
            if (nLastSpellCast != SPELL_ELEMENTAL_SHIELD)
            {
                if (buffSelf && !GetHasSpellEffect(SPELL_ENERGY_BUFFER, OBJECT_SELF) && !GetHasSpellEffect(SPELL_PROTECTION_FROM_ELEMENTS, OBJECT_SELF) && !GetHasSpellEffect(SPELL_RESIST_ELEMENTS, OBJECT_SELF) && !GetHasSpellEffect(SPELL_ENDURE_ELEMENTS, OBJECT_SELF) && !GetHasSpellEffect(SPELL_ELEMENTAL_SHIELD, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_ELEMENTAL_SHIELD, OBJECT_SELF, 4); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFeat(FEAT_PRESTIGE_SEEKER_ARROW_1))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_AA_SEEKER_ARROW_1 && nRange <= 40.0 && allowAttackAbilities && GetHasEquippedBow())
            {
                CastSetLastFeatSpellOnObject(FEAT_PRESTIGE_SEEKER_ARROW_1, SPELLABILITY_AA_SEEKER_ARROW_1, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasFeat(FEAT_PRESTIGE_SEEKER_ARROW_2))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_AA_SEEKER_ARROW_2 && nRange <= 40.0 && allowAttackAbilities && GetHasEquippedBow())
            {
                CastSetLastFeatSpellOnObject(FEAT_PRESTIGE_SEEKER_ARROW_2, SPELLABILITY_AA_SEEKER_ARROW_2, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_HOLD_MONSTER))
        {
            if (nLastSpellCast != SPELL_HOLD_MONSTER && nRange <= 20.0 && useAttackSpells && !(GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) || GetIsImmune(oTarget, IMMUNITY_TYPE_PARALYSIS, OBJECT_SELF)) && !GetIsDisabled(oTarget) && CheckSpellSaves(oTarget, 4, HENCH_CHECK_SR_WILL_SAVE))
            {
                CastSetLastSpellOnObject(SPELL_HOLD_MONSTER, oTarget, 4); return TK_ATTACK;
            }
        }
        if (GetHasFeat(FEAT_EMPTY_BODY))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != FEAT_EMPTY_BODY)
            {
                if (allowBuffAbilities && GetLevelByClass(CLASS_TYPE_MONK) > 0 && !GetHasEffect(EFFECT_TYPE_CONCEALMENT, OBJECT_SELF))
                {
                    CastFeatOnObject(FEAT_EMPTY_BODY, OBJECT_SELF); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_MASS_CAMOFLAGE))
        {
            if (nLastSpellCast != SPELL_MASS_CAMOFLAGE)
            {
                if (groupBuff && !GetHasSpellEffect(SPELL_MASS_CAMOFLAGE, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_MASS_CAMOFLAGE, OBJECT_SELF, 4); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFeat(FEAT_SHADOW_EVADE))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != FEAT_SHADOW_EVADE)
            {
                if (allowBuffAbilities && GetLevelByClass(CLASS_TYPE_SHADOWDANCER) && (!GetHasEffect(EFFECT_TYPE_AC_INCREASE, OBJECT_SELF) || !GetHasEffect(EFFECT_TYPE_DAMAGE_REDUCTION, OBJECT_SELF) || !GetHasEffect(EFFECT_TYPE_CONCEALMENT, OBJECT_SELF)))
                {
                    CastFeatOnObject(FEAT_SHADOW_EVADE, OBJECT_SELF); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFeat(FEAT_TYMORAS_SMILE))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != FEAT_TYMORAS_SMILE)
            {
                if (allowBuffAbilities && !GetHasEffect(EFFECT_TYPE_SAVING_THROW_INCREASE, OBJECT_SELF))
                {
                    CastFeatOnObject(FEAT_TYMORAS_SMILE, OBJECT_SELF); return TK_BUFFSELF;
                }
            }
        }
        if (nAreaPosition < 230)
        {
            break;
        }
        if (GetHasFixedSpell(SPELL_PHANTASMAL_KILLER))
        {
            if (nLastSpellCast != SPELL_PHANTASMAL_KILLER && nRange <= 20.0 && useAttackSpells && !(GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) || GetIsImmune(oTarget, IMMUNITY_TYPE_FEAR, OBJECT_SELF)) && CheckSpellSaves(oTarget, 4, HENCH_CHECK_SR_WILL_SAVE))
            {
                CastSetLastSpellOnObject(SPELL_PHANTASMAL_KILLER, oTarget, 4); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_MINOR_GLOBE_OF_INVULNERABILITY))
        {
            if (nLastSpellCast != SPELL_MINOR_GLOBE_OF_INVULNERABILITY)
            {
                if (buffSelf && HenchUseSpellProtections() && !GetHasEffect(EFFECT_TYPE_SPELLLEVELABSORPTION, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_MINOR_GLOBE_OF_INVULNERABILITY, OBJECT_SELF, 4); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_GREATER_SHADOW_CONJURATION_MINOR_GLOBE))
        {
            if (nLastSpellCast != SPELL_GREATER_SHADOW_CONJURATION_MINOR_GLOBE)
            {
                if (buffSelf && HenchUseSpellProtections() && !GetHasEffect(EFFECT_TYPE_SPELLLEVELABSORPTION, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_GREATER_SHADOW_CONJURATION_MINOR_GLOBE, OBJECT_SELF, 5); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFeat(FEAT_SUMMON_UNDEAD))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_PM_SUMMON_UNDEAD && allowSummons)
            {
                CastSetLastFeatSpellAtLocation(FEAT_SUMMON_UNDEAD, SPELLABILITY_PM_SUMMON_UNDEAD, GetSummonLocation(oTarget)); return TK_SUMMON;
            }
        }
        if (GetHasFeat(FEAT_SUMMON_SHADOW))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELL_SUMMON_SHADOW && allowSummons && GetLevelByClass(CLASS_TYPE_SHADOWDANCER) > 0)
            {
                CastSetLastFeatSpellAtLocation(FEAT_SUMMON_SHADOW, SPELL_SUMMON_SHADOW, GetSummonLocation(oTarget)); return TK_SUMMON;
            }
        }
        if (GetHasFixedSpell(SPELL_SHADOW_CONJURATION_SUMMON_SHADOW))
        {
            if (nLastSpellCast != SPELL_SHADOW_CONJURATION_SUMMON_SHADOW && allowSummons)
            {
                CastSetLastSpellAtLocation(SPELL_SHADOW_CONJURATION_SUMMON_SHADOW, GetSummonLocation(oTarget), 4); return TK_SUMMON;
            }
        }
        if (GetHasFixedSpell(SPELL_GREATER_SHADOW_CONJURATION_SUMMON_SHADOW))
        {
            if (nLastSpellCast != SPELL_GREATER_SHADOW_CONJURATION_SUMMON_SHADOW && allowSummons)
            {
                CastSetLastSpellAtLocation(SPELL_GREATER_SHADOW_CONJURATION_SUMMON_SHADOW, GetSummonLocation(oTarget), 5); return TK_SUMMON;
            }
        }
        if (GetHasFixedSpell(SPELL_SHADES_SUMMON_SHADOW))
        {
            if (nLastSpellCast != SPELL_SHADES_SUMMON_SHADOW && allowSummons)
            {
                CastSetLastSpellAtLocation(SPELL_SHADES_SUMMON_SHADOW, GetSummonLocation(oTarget), 6); return TK_SUMMON;
            }
        }
        if (GetHasFeat(FEAT_INFLICT_MODERATE_WOUNDS))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_BG_FIENDISH_SERVANT && allowSummons)
            {
                CastSetLastFeatSpellAtLocation(FEAT_INFLICT_MODERATE_WOUNDS, SPELLABILITY_BG_FIENDISH_SERVANT, GetSummonLocation(oTarget)); return TK_SUMMON;
            }
        }
        if (GetHasFixedSpell(SPELL_SUMMON_CREATURE_IV))
        {
            if (nLastSpellCast != SPELL_SUMMON_CREATURE_IV && allowSummons)
            {
                CastSetLastSpellAtLocation(SPELL_SUMMON_CREATURE_IV, GetSummonLocation(oTarget), 4); return TK_SUMMON;
            }
        }
        if (nAreaPosition < 240)
        {
            break;
        }
        if (GetHasSpell(SPELL_ELEMENTAL_SUMMONING_ITEM))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELL_ELEMENTAL_SUMMONING_ITEM && allowSummons)
            {
                CastSpellAbilityAtLocation(SPELL_ELEMENTAL_SUMMONING_ITEM, GetSummonLocation(oTarget)); return TK_SUMMON;
            }
        }
        if (GetHasSpell(SPELLABILITY_BOLT_ABILITY_DRAIN_CHARISMA))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_BOLT_ABILITY_DRAIN_CHARISMA && nRange <= 20.0 && allowAttackAbilities && !GetIsImmune(oTarget, IMMUNITY_TYPE_ABILITY_DECREASE, OBJECT_SELF) && !GetIsDisabled1(EFFECT_TYPE_ABILITY_DECREASE, oTarget))
            {
                CastSpellAbilityOnObject(SPELLABILITY_BOLT_ABILITY_DRAIN_CHARISMA, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELLABILITY_BOLT_ABILITY_DRAIN_CONSTITUTION))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_BOLT_ABILITY_DRAIN_CONSTITUTION && nRange <= 20.0 && allowAttackAbilities && !GetIsImmune(oTarget, IMMUNITY_TYPE_ABILITY_DECREASE, OBJECT_SELF) && !GetIsDisabled1(EFFECT_TYPE_ABILITY_DECREASE, oTarget))
            {
                CastSpellAbilityOnObject(SPELLABILITY_BOLT_ABILITY_DRAIN_CONSTITUTION, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELLABILITY_BOLT_ABILITY_DRAIN_DEXTERITY))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_BOLT_ABILITY_DRAIN_DEXTERITY && nRange <= 20.0 && allowAttackAbilities && !GetIsImmune(oTarget, IMMUNITY_TYPE_ABILITY_DECREASE, OBJECT_SELF) && !GetIsDisabled1(EFFECT_TYPE_ABILITY_DECREASE, oTarget))
            {
                CastSpellAbilityOnObject(SPELLABILITY_BOLT_ABILITY_DRAIN_DEXTERITY, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELLABILITY_BOLT_ABILITY_DRAIN_INTELLIGENCE))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_BOLT_ABILITY_DRAIN_INTELLIGENCE && nRange <= 20.0 && allowAttackAbilities && !GetIsImmune(oTarget, IMMUNITY_TYPE_ABILITY_DECREASE, OBJECT_SELF) && !GetIsDisabled1(EFFECT_TYPE_ABILITY_DECREASE, oTarget))
            {
                CastSpellAbilityOnObject(SPELLABILITY_BOLT_ABILITY_DRAIN_INTELLIGENCE, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELLABILITY_BOLT_ABILITY_DRAIN_STRENGTH))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_BOLT_ABILITY_DRAIN_STRENGTH && nRange <= 20.0 && allowAttackAbilities && !GetIsImmune(oTarget, IMMUNITY_TYPE_ABILITY_DECREASE, OBJECT_SELF) && !GetIsDisabled1(EFFECT_TYPE_ABILITY_DECREASE, oTarget))
            {
                CastSpellAbilityOnObject(SPELLABILITY_BOLT_ABILITY_DRAIN_STRENGTH, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELLABILITY_BOLT_ABILITY_DRAIN_WISDOM))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_BOLT_ABILITY_DRAIN_WISDOM && nRange <= 20.0 && allowAttackAbilities && !GetIsImmune(oTarget, IMMUNITY_TYPE_ABILITY_DECREASE, OBJECT_SELF) && !GetIsDisabled1(EFFECT_TYPE_ABILITY_DECREASE, oTarget))
            {
                CastSpellAbilityOnObject(SPELLABILITY_BOLT_ABILITY_DRAIN_WISDOM, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELLABILITY_BOLT_ACID))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_BOLT_ACID && nRange <= 20.0 && allowAttackAbilities)
            {
                CastSpellAbilityOnObject(SPELLABILITY_BOLT_ACID, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELLABILITY_BOLT_CHARM))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_BOLT_CHARM && nRange <= 20.0 && allowAttackAbilities && !(GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) || GetIsImmune(oTarget, IMMUNITY_TYPE_CHARM, OBJECT_SELF)) && !GetIsDisabled1(EFFECT_TYPE_CHARMED, oTarget))
            {
                CastSpellAbilityOnObject(SPELLABILITY_BOLT_CHARM, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELLABILITY_BOLT_COLD))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_BOLT_COLD && nRange <= 20.0 && allowAttackAbilities)
            {
                CastSpellAbilityOnObject(SPELLABILITY_BOLT_COLD, oTarget); return TK_ATTACK;
            }
        }
        if (nAreaPosition < 250)
        {
            break;
        }
        if (GetHasSpell(SPELLABILITY_BOLT_CONFUSE))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_BOLT_CONFUSE && nRange <= 20.0 && allowAttackAbilities && !(GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) || GetIsImmune(oTarget, IMMUNITY_TYPE_CONFUSED, OBJECT_SELF)) && !GetIsDisabled(oTarget))
            {
                CastSpellAbilityOnObject(SPELLABILITY_BOLT_CONFUSE, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELLABILITY_BOLT_DISEASE))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_BOLT_DISEASE && nRange <= 20.0 && allowAttackAbilities && !GetIsImmune(oTarget, IMMUNITY_TYPE_DISEASE, OBJECT_SELF) && !GetIsDisabled1(EFFECT_TYPE_DISEASE, oTarget) && GetFortitudeSavingThrow(oTarget) <= GetCreatureDiseaseDC(DISEASE_CHECK_BOLT) + nMySpellCasterDCAdjust)
            {
                CastSpellAbilityOnObject(SPELLABILITY_BOLT_DISEASE, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELLABILITY_BOLT_FIRE))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_BOLT_FIRE && nRange <= 20.0 && allowAttackAbilities)
            {
                CastSpellAbilityOnObject(SPELLABILITY_BOLT_FIRE, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELLABILITY_BOLT_LIGHTNING))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_BOLT_LIGHTNING && nRange <= 20.0 && allowAttackAbilities)
            {
                CastSpellAbilityOnObject(SPELLABILITY_BOLT_LIGHTNING, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELLABILITY_BOLT_SHARDS))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_BOLT_SHARDS && nRange <= 20.0 && allowAttackAbilities)
            {
                CastSpellAbilityOnObject(SPELLABILITY_BOLT_SHARDS, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELLABILITY_BOLT_SLOW))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_BOLT_SLOW && nRange <= 20.0 && allowAttackAbilities && !GetIsImmune(oTarget, IMMUNITY_TYPE_SLOW, OBJECT_SELF) && !GetIsDisabled1(EFFECT_TYPE_SLOW, oTarget))
            {
                CastSpellAbilityOnObject(SPELLABILITY_BOLT_SLOW, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELLABILITY_BOLT_WEB))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_BOLT_WEB && nRange <= 20.0 && allowAttackAbilities && !GetIsImmune(oTarget, IMMUNITY_TYPE_ENTANGLE, OBJECT_SELF) && !GetIsDisabled1(EFFECT_TYPE_ENTANGLE, oTarget) && !GetHasFeat(FEAT_WOODLAND_STRIDE, oTarget) && !GetCreatureFlag(oTarget, CREATURE_VAR_IS_INCORPOREAL))
            {
                CastSpellAbilityOnObject(SPELLABILITY_BOLT_WEB, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELLABILITY_GAZE_DAZE))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_GAZE_DAZE && allowAttackAbilities && nRange <= 10.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 10.0, 8.0, 4, nMySpellAbilityLevel12, HENCH_CHECK_WILL_SAVE, HENCH_AREA_CHECK_DAZE_AND_MIND))
                {
                    nAreaPosition = 277;
                    nSpell = SPELLABILITY_GAZE_DAZE; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_GAZE_DOOM))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_GAZE_DOOM && allowAttackAbilities && nRange <= 10.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 10.0, 8.0, 4, nMySpellAbilityLevel12, HENCH_CHECK_WILL_SAVE, HENCH_AREA_CHECK_MIND))
                {
                    nAreaPosition = 278;
                    nSpell = SPELLABILITY_GAZE_DOOM; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_HOWL_DAZE))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_HOWL_DAZE && allowAttackAbilities && nRange <= RADIUS_SIZE_COLOSSAL)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, 0.0, 4, nMySpellAbilityLevel14, HENCH_CHECK_WILL_SAVE, HENCH_AREA_CHECK_DAZE_AND_MIND))
                {
                    nAreaPosition = 279;
                    nSpell = SPELLABILITY_HOWL_DAZE; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (nAreaPosition < 260)
        {
            break;
        }
        if (GetHasSpell(SPELLABILITY_HOWL_DOOM))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_HOWL_DOOM && allowAttackAbilities && nRange <= RADIUS_SIZE_COLOSSAL)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, 0.0, 4, nMySpellAbilityLevel14, HENCH_CHECK_WILL_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 280;
                    nSpell = SPELLABILITY_HOWL_DOOM; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_INTENSITY_2))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_INTENSITY_2)
            {
                if (allowBuffAbilities && !GetHasSpellEffect(SPELLABILITY_INTENSITY_2, OBJECT_SELF))
                {
                    CastSpellAbilityOnObject(SPELLABILITY_INTENSITY_2, OBJECT_SELF); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_PULSE_DROWN))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_PULSE_DROWN && allowAttackAbilities && nRange <= RADIUS_SIZE_LARGE)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_LARGE, 0.0, 4, 20 + nMySpellCasterDCAdjust, HENCH_CHECK_FORT_SAVE, HENCH_AREA_CHECK_DROWN))
                {
                    nAreaPosition = 282;
                    nSpell = SPELLABILITY_PULSE_DROWN; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_PULSE_SPORES))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_PULSE_SPORES && allowAttackAbilities && nRange <= RADIUS_SIZE_LARGE)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_LARGE, 0.0, 4, 25 + nMySpellCasterDCAdjust, HENCH_CHECK_FORT_SAVE, HENCH_AREA_CHECK_DISEASE))
                {
                    nAreaPosition = 283;
                    nSpell = SPELLABILITY_PULSE_SPORES; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_PULSE_WHIRLWIND))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_PULSE_WHIRLWIND && allowAttackAbilities && nRange <= RADIUS_SIZE_LARGE)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_LARGE, 0.0, 4, 14 + nMySpellCasterDCAdjust, HENCH_CHECK_REFLEX_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 284;
                    nSpell = SPELLABILITY_PULSE_WHIRLWIND; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFeat(FEAT_PRESTIGE_DARKNESS))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != FEAT_PRESTIGE_DARKNESS && allowAttackAbilities && nRange <= 40.0 + 6.7)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, 6.7, 40.0, 1, 20, HENCH_CHECK_NO_SAVE, HENCH_AREA_CHECK_DARKNESS))
                {
                    nAreaPosition = 285;
                    nSpell = FEAT_PRESTIGE_DARKNESS; nSpell2 = SPELLABILITY_AS_DARKNESS; nTargetType = TARGET_FEAT_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_DARKNESS))
        {
            if (nLastSpellCast != SPELL_DARKNESS && useAttackSpells && nRange <= 40.0 + 6.7)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, 6.7, 40.0, 2, -1000, HENCH_CHECK_NO_SAVE, HENCH_AREA_CHECK_DARKNESS))
                {
                    nAreaPosition = 286;
                    nSpell = SPELL_DARKNESS; nSpellLevel = 2; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_SHADOW_CONJURATION_DARKNESS))
        {
            if (nLastSpellCast != SPELL_SHADOW_CONJURATION_DARKNESS && useAttackSpells && nRange <= 40.0 + 6.7)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, 6.7, 40.0, 4, -1000, HENCH_CHECK_NO_SAVE, HENCH_AREA_CHECK_DARKNESS))
                {
                    nAreaPosition = 287;
                    nSpell = SPELL_SHADOW_CONJURATION_DARKNESS; nSpellLevel = 4; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFeat(FEAT_PRESTIGE_SPELL_GHOSTLY_VISAGE))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != FEAT_PRESTIGE_SPELL_GHOSTLY_VISAGE)
            {
                if (allowBuffAbilities && (!GetHasEffect(EFFECT_TYPE_DAMAGE_REDUCTION, OBJECT_SELF) || !GetHasEffect(EFFECT_TYPE_SPELLLEVELABSORPTION, OBJECT_SELF) || !GetHasEffect(EFFECT_TYPE_CONCEALMENT, OBJECT_SELF)))
                {
                    CastFeatOnObject(FEAT_PRESTIGE_SPELL_GHOSTLY_VISAGE, OBJECT_SELF); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_IMPROVED_INVISIBILITY))
        {
            if (nLastSpellCast != SPELL_IMPROVED_INVISIBILITY)
            {
                if (buffSelf && !GetHasEffect(EFFECT_TYPE_CONCEALMENT, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_IMPROVED_INVISIBILITY, OBJECT_SELF, 4); return TK_BUFFSELF;
                }
                if (!bFoundPotionOnly && buffOthers  && GetBestBuffTarget(-1, EFFECT_TYPE_CONCEALMENT, -1, -1))
                {
                    CastSetLastSpellOnObject(SPELL_IMPROVED_INVISIBILITY, oBestBuffTarget, 4); return TK_BUFFOTHER;
                }
            }
        }
        if (nAreaPosition < 270)
        {
            break;
        }
        if (GetHasFeat(FEAT_PRESTIGE_IMBUE_ARROW))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_AA_IMBUE_ARROW && allowAttackAbilities && nRange <= 40.0 + RADIUS_SIZE_HUGE && GetHasEquippedBow())
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_HUGE, 40.0, 1, -1000, HENCH_CHECK_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 290;
                    nSpell = FEAT_PRESTIGE_IMBUE_ARROW; nSpell2 = SPELLABILITY_AA_IMBUE_ARROW; nTargetType = TARGET_FEAT_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_SHADES_FIREBALL))
        {
            if (nLastSpellCast != SPELL_SHADES_FIREBALL && useAttackSpells && nRange <= 40.0 + RADIUS_SIZE_HUGE)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_HUGE, 40.0, 6, -1000, HENCH_CHECK_SR_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 291;
                    nSpell = SPELL_SHADES_FIREBALL; nSpellLevel = 6; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_FIREBALL))
        {
            if (nLastSpellCast != SPELL_FIREBALL && useAttackSpells && nRange <= 40.0 + RADIUS_SIZE_HUGE)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_HUGE, 40.0, 3, -1000, HENCH_CHECK_SR_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 292;
                    nSpell = SPELL_FIREBALL; nSpellLevel = 3; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_SCINTILLATING_SPHERE))
        {
            if (nLastSpellCast != SPELL_SCINTILLATING_SPHERE && useAttackSpells && nRange <= 20.0 + RADIUS_SIZE_HUGE)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_HUGE, 20.0, 3, -1000, HENCH_CHECK_SR_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 293;
                    nSpell = SPELL_SCINTILLATING_SPHERE; nSpellLevel = 3; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_MESTILS_ACID_BREATH))
        {
            if (nLastSpellCast != SPELL_MESTILS_ACID_BREATH && useAttackSpells && nRange <= 11.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 11.0, 8.0, 3, -1000, HENCH_CHECK_SR_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 294;
                    nSpell = SPELL_MESTILS_ACID_BREATH; nSpellLevel = 3; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_LIGHTNING_BOLT))
        {
            if (nLastSpellCast != SPELL_LIGHTNING_BOLT && useAttackSpells && nRange <= 30.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCYLINDER, 30.0, 20.0, 3, -1000, HENCH_CHECK_SR_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 295;
                    nSpell = SPELL_LIGHTNING_BOLT; nSpellLevel = 3; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_NEGATIVE_ENERGY_BURST))
        {
            if (nLastSpellCast != SPELL_NEGATIVE_ENERGY_BURST && useAttackSpells && nRange <= 20.0 + RADIUS_SIZE_HUGE)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_HUGE, 20.0, 3, -1000, HENCH_CHECK_SR_NO_SAVE, HENCH_AREA_CHECK_NEGLEVEL))
                {
                    nAreaPosition = 296;
                    nSpell = SPELL_NEGATIVE_ENERGY_BURST; nSpellLevel = 3; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_CHARMMONSTER))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_CHARMMONSTER && allowAttackAbilities && nRange <= 10.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 10.0, 8.0, 3, 17 + nMySpellCasterDCAdjust, HENCH_CHECK_WILL_SAVE, HENCH_AREA_CHECK_CONF_AND_MIND))
                {
                    nAreaPosition = 297;
                    nSpell = SPELLABILITY_CHARMMONSTER; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if ((GetLocalInt(OBJECT_SELF, "HENCH_USE_MIND_BLAST") || GetHasSpell(SPELLABILITY_MINDBLAST)))
        {
            bFoundSpellGlobal = TRUE;
            if (1 && allowAttackAbilities && nRange <= 15.0f)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 15.0f, 8.0, 5, nMySpellAbilityLevel12 + GetAbilityModifier(ABILITY_WISDOM,OBJECT_SELF), HENCH_CHECK_WILL_SAVE, HENCH_AREA_CHECK_MINDBLAST))
                {
                    nAreaPosition = 298;
                    nSpell = SPELLABILITY_MINDBLAST; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELL_HENCH_Mindflayer_Mindblast_10))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELL_HENCH_Mindflayer_Mindblast_10 && allowAttackAbilities && nRange <= 15.0f)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, 15.0f, 0.0, 8, nMySpellAbilityLevel12 + GetAbilityModifier(ABILITY_WISDOM,OBJECT_SELF), HENCH_CHECK_WILL_SAVE, HENCH_AREA_CHECK_STUN_AND_MIND))
                {
                    nAreaPosition = 299;
                    nSpell = SPELL_HENCH_Mindflayer_Mindblast_10; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (nAreaPosition < 280)
        {
            break;
        }
        if (GetHasFixedSpell(SPELL_ANIMATE_DEAD))
        {
            if (nLastSpellCast != SPELL_ANIMATE_DEAD && allowSummons)
            {
                CastSetLastSpellAtLocation(SPELL_ANIMATE_DEAD, GetSummonLocation(oTarget), 3); return TK_SUMMON;
            }
        }
        if (GetHasFixedSpell(SPELL_BESTOW_CURSE))
        {
            if (nLastSpellCast != SPELL_BESTOW_CURSE && nRange <= 4.0 && useAttackSpells && !GetIsImmune(oTarget, IMMUNITY_TYPE_CURSED, OBJECT_SELF) && !GetIsDisabled1(EFFECT_TYPE_CURSE, oTarget) && CheckSpellSaves(oTarget, 3, HENCH_CHECK_SR_WILL_SAVE))
            {
                CastSetLastSpellOnObject(SPELL_BESTOW_CURSE, oTarget, 3); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_CALL_LIGHTNING))
        {
            if (nLastSpellCast != SPELL_CALL_LIGHTNING && useAttackSpells && nRange <= 40.0 + RADIUS_SIZE_HUGE)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_HUGE, 40.0, 3, -1000, HENCH_CHECK_SR_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 302;
                    nSpell = SPELL_CALL_LIGHTNING; nSpellLevel = 3; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_VAMPIRIC_TOUCH))
        {
            if (nLastSpellCast != SPELL_VAMPIRIC_TOUCH && nRange <= 4.0 && useAttackSpells && CheckSpellSaves(oTarget, 3, HENCH_CHECK_SR_NO_SAVE) && !GetHasEffect(EFFECT_TYPE_TEMPORARY_HITPOINTS, OBJECT_SELF) && nRacialType != RACIAL_TYPE_UNDEAD && nRacialType != RACIAL_TYPE_CONSTRUCT)
            {
                CastSetLastSpellOnObject(SPELL_VAMPIRIC_TOUCH, oTarget, 3); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_POISON))
        {
            if (nLastSpellCast != SPELL_POISON && nRange <= 4.0 && useAttackSpells && !GetIsImmune(oTarget, IMMUNITY_TYPE_POISON, OBJECT_SELF) && !GetIsDisabled1(EFFECT_TYPE_POISON, oTarget) && GetFortitudeSavingThrow(oTarget) <= 18 + nMySpellCasterDCAdjust && CheckSpellSaves(oTarget, 3, HENCH_CHECK_SR_NO_SAVE))
            {
                CastSetLastSpellOnObject(SPELL_POISON, oTarget, 3); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_CHARM_MONSTER))
        {
            if (nLastSpellCast != SPELL_CHARM_MONSTER && nRange <= 8.0 && useAttackSpells && !(GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) || GetIsImmune(oTarget, IMMUNITY_TYPE_CHARM, OBJECT_SELF)) && !GetIsDisabled1(EFFECT_TYPE_CHARMED, oTarget) && CheckSpellSaves(oTarget, 3, HENCH_CHECK_SR_WILL_SAVE))
            {
                CastSetLastSpellOnObject(SPELL_CHARM_MONSTER, oTarget, 3); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_CONFUSION))
        {
            if (nLastSpellCast != SPELL_CONFUSION && useAttackSpells && nRange <= 20.0 + RADIUS_SIZE_LARGE)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_LARGE, 20.0, 3, -1000, HENCH_CHECK_SR_WILL_SAVE, HENCH_AREA_CHECK_CONF_AND_MIND))
                {
                    nAreaPosition = 306;
                    nSpell = SPELL_CONFUSION; nSpellLevel = 3; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_SPIKE_GROWTH))
        {
            if (nLastSpellCast != SPELL_SPIKE_GROWTH && useAttackSpells && nRange <= 40.0 + 5.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, 5.0, 40.0, 3, -1000, HENCH_CHECK_SR_NO_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 307;
                    nSpell = SPELL_SPIKE_GROWTH; nSpellLevel = 3; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFeat(FEAT_CONTAGION))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != FEAT_CONTAGION && nRange <= 4.0 && allowAttackAbilities && !GetIsImmune(oTarget, IMMUNITY_TYPE_DISEASE, OBJECT_SELF) && !GetIsDisabled1(EFFECT_TYPE_DISEASE, oTarget) && GetFortitudeSavingThrow(oTarget) <= 14 + nMySpellCasterDCAdjust)
            {
                CastFeatOnObject(FEAT_CONTAGION, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_CONTAGION))
        {
            if (nLastSpellCast != SPELL_CONTAGION && nRange <= 4.0 && useAttackSpells && !GetIsImmune(oTarget, IMMUNITY_TYPE_DISEASE, OBJECT_SELF) && !GetIsDisabled1(EFFECT_TYPE_DISEASE, oTarget) && GetFortitudeSavingThrow(oTarget) <= 14 + nMySpellCasterDCAdjust && CheckSpellSaves(oTarget, 3, HENCH_CHECK_SR_NO_SAVE))
            {
                CastSetLastSpellOnObject(SPELL_CONTAGION, oTarget, 3); return TK_ATTACK;
            }
        }
        if (nAreaPosition < 290)
        {
            break;
        }
        if (GetHasFixedSpell(SPELL_INFESTATION_OF_MAGGOTS))
        {
            if (nLastSpellCast != SPELL_INFESTATION_OF_MAGGOTS && nRange <= 4.0 && useAttackSpells && CheckSpellSaves(oTarget, 3, HENCH_CHECK_SR_FORT_SAVE))
            {
                CastSetLastSpellOnObject(SPELL_INFESTATION_OF_MAGGOTS, oTarget, 3); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_HEALING_STING))
        {
            if (nLastSpellCast != SPELL_HEALING_STING && nRange <= 4.0 && useAttackSpells && CheckSpellSaves(oTarget, 3, HENCH_CHECK_SR_FORT_SAVE) && nRacialType != RACIAL_TYPE_UNDEAD && nRacialType != RACIAL_TYPE_CONSTRUCT   )
            {
                CastSetLastSpellOnObject(SPELL_HEALING_STING, oTarget, 3); return TK_ATTACK;
            }
        }
        if (GetHasCureSpell(SPELL_CURE_SERIOUS_WOUNDS))
        {
            if (nLastSpellCast != SPELL_CURE_SERIOUS_WOUNDS && nRange <= 4.0 && useAttackSpells && CheckSpellSaves(oTarget, 3, HENCH_CHECK_SR_NO_SAVE) && nRacialType == RACIAL_TYPE_UNDEAD)
            {
                CastSetLastSpellOnObject(SPELL_CURE_SERIOUS_WOUNDS, oTarget, 3); return TK_ATTACK;
            }
        }
        if (GetHasFeat(FEAT_INFLICT_SERIOUS_WOUNDS))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != FEAT_INFLICT_SERIOUS_WOUNDS && nRange <= 4.0 && allowAttackAbilities && nRacialType != RACIAL_TYPE_UNDEAD)
            {
                CastFeatOnObject(FEAT_INFLICT_SERIOUS_WOUNDS, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasInflictSpell(SPELL_INFLICT_SERIOUS_WOUNDS))
        {
            if (nLastSpellCast != SPELL_INFLICT_SERIOUS_WOUNDS && nRange <= 4.0 && useAttackSpells && CheckSpellSaves(oTarget, 3, HENCH_CHECK_SR_NO_SAVE) && nRacialType != RACIAL_TYPE_UNDEAD)
            {
                CastSetLastSpellOnObject(SPELL_INFLICT_SERIOUS_WOUNDS, oTarget, 3); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_DOMINATE_ANIMAL))
        {
            if (nLastSpellCast != SPELL_DOMINATE_ANIMAL && allowDominate && nRange <= 20.0 && useAttackSpells && !(GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) || GetIsImmune(oTarget, IMMUNITY_TYPE_DOMINATE, OBJECT_SELF)) && CheckSpellSaves(oTarget, 3, HENCH_CHECK_SR_WILL_SAVE) && nRacialType == RACIAL_TYPE_ANIMAL)
            {
                SetLastDominate(); CastSetLastSpellOnObject(SPELL_DOMINATE_ANIMAL, oTarget, 3); return TK_DOMINATE;
            }
        }
        if (GetHasFixedSpell(SPELL_FEAR))
        {
            if (nLastSpellCast != SPELL_FEAR && useAttackSpells && nRange <= 20.0 + RADIUS_SIZE_LARGE)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_LARGE, 20.0, 3, -1000, HENCH_CHECK_SR_WILL_SAVE, HENCH_AREA_CHECK_MIND_AND_FEAR))
                {
                    nAreaPosition = 316;
                    nSpell = SPELL_FEAR; nSpellLevel = 3; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_FLAME_ARROW))
        {
            if (nLastSpellCast != SPELL_FLAME_ARROW && nRange <= 40.0 && useAttackSpells && CheckSpellSaves(oTarget, 3, HENCH_CHECK_SR_REFLEX_EVASION_SAVE))
            {
                CastSetLastSpellOnObject(SPELL_FLAME_ARROW, oTarget, 3); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_QUILLFIRE))
        {
            if (nLastSpellCast != SPELL_QUILLFIRE && nRange <= 8.0 && useAttackSpells && !GetIsImmune(oTarget, IMMUNITY_TYPE_POISON, OBJECT_SELF) && !GetIsDisabled1(EFFECT_TYPE_POISON, oTarget) && GetFortitudeSavingThrow(oTarget) <= 18 + nMySpellCasterDCAdjust)
            {
                CastSetLastSpellOnObject(SPELL_QUILLFIRE, oTarget, 3); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_SLOW))
        {
            if (nLastSpellCast != SPELL_SLOW && useAttackSpells && nRange <= 8.0 + RADIUS_SIZE_COLOSSAL)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, 8.0, 3, -1000, HENCH_CHECK_SR_WILL_SAVE, HENCH_AREA_CHECK_SLOW))
                {
                    nAreaPosition = 319;
                    nSpell = SPELL_SLOW; nSpellLevel = 3; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (nAreaPosition < 300)
        {
            break;
        }
        if (GetHasFixedSpell(SPELL_STINKING_CLOUD))
        {
            if (nLastSpellCast != SPELL_STINKING_CLOUD && useAttackSpells && nRange <= 20.0 + 6.7)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, 6.7, 20.0, 3, -1000, HENCH_CHECK_SR_FORT_SAVE, HENCH_AREA_CHECK_POISON_DAZE_AND_MIND))
                {
                    nAreaPosition = 320;
                    nSpell = SPELL_STINKING_CLOUD; nSpellLevel = 3; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_HENCH_Haste_Slow_X2))
        {
            if (nLastSpellCast != SPELL_HENCH_Haste_Slow_X2)
            {
                if (buffSelf && !GetHasEffect(EFFECT_TYPE_HASTE, OBJECT_SELF) && !GetCreatureHasItemProperty(ITEM_PROPERTY_HASTE, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_HENCH_Haste_Slow_X2, OBJECT_SELF, 3); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_MAGIC_CIRCLE_AGAINST_EVIL))
        {
            if (nLastSpellCast != SPELL_MAGIC_CIRCLE_AGAINST_EVIL)
            {
                if (groupBuff && iTargetGEAlign == ALIGNMENT_EVIL && !GetHasSpellEffect(SPELL_HOLY_AURA, OBJECT_SELF) && !GetHasSpellEffect(SPELL_PROTECTION_FROM_EVIL, OBJECT_SELF) && !GetHasSpellEffect(SPELL_MAGIC_CIRCLE_AGAINST_EVIL, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_MAGIC_CIRCLE_AGAINST_EVIL, OBJECT_SELF, 3); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_MAGIC_CIRCLE_AGAINST_GOOD))
        {
            if (nLastSpellCast != SPELL_MAGIC_CIRCLE_AGAINST_GOOD)
            {
                if (groupBuff && iTargetGEAlign == ALIGNMENT_GOOD && !GetHasSpellEffect(SPELL_UNHOLY_AURA, OBJECT_SELF) && !GetHasSpellEffect(SPELL_PROTECTION_FROM_GOOD, OBJECT_SELF)     && !GetHasSpellEffect(SPELL_MAGIC_CIRCLE_AGAINST_GOOD, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_MAGIC_CIRCLE_AGAINST_GOOD, OBJECT_SELF, 3); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_NEGATIVE_ENERGY_PROTECTION))
        {
            if (nLastSpellCast != SPELL_NEGATIVE_ENERGY_PROTECTION)
            {
                if (buffSelf && !GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_ABILITY_DECREASE, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_NEGATIVE_ENERGY_PROTECTION, OBJECT_SELF, 3); return TK_BUFFSELF;
                }
                if (!bFoundPotionOnly && buffOthers  && GetBestBuffTarget(IMMUNITY_TYPE_ABILITY_DECREASE, -1, -1, -1))
                {
                    CastSetLastSpellOnObject(SPELL_NEGATIVE_ENERGY_PROTECTION, oBestBuffTarget, 3); return TK_BUFFOTHER;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_GUST_OF_WIND))
        {
            if (nLastSpellCast != SPELL_GUST_OF_WIND && useAttackSpells && nRange <= 20.0 + RADIUS_SIZE_HUGE && (d100() <= 10))
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_HUGE, 20.0, 3, -1000, HENCH_CHECK_SR_FORT_SAVE, HENCH_AREA_CHECK_KNOCKDOWN))
                {
                    nAreaPosition = 325;
                    nSpell = SPELL_GUST_OF_WIND; nSpellLevel = 3; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_PRAYER))
        {
            if (nLastSpellCast != SPELL_PRAYER)
            {
                if (groupBuff && !GetHasEffect(EFFECT_TYPE_ATTACK_INCREASE, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_PRAYER, OBJECT_SELF, 3); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_PROTECTION_FROM_ELEMENTS))
        {
            if (nLastSpellCast != SPELL_PROTECTION_FROM_ELEMENTS)
            {
                if (buffSelf && !GetHasSpellEffect(SPELL_ENERGY_BUFFER, OBJECT_SELF) && !GetHasSpellEffect(SPELL_RESIST_ELEMENTS, OBJECT_SELF) && !GetHasSpellEffect(SPELL_ENDURE_ELEMENTS, OBJECT_SELF) && !GetHasSpellEffect(SPELL_ELEMENTAL_SHIELD, OBJECT_SELF) && !GetHasSpellEffect(SPELL_PROTECTION_FROM_ELEMENTS, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_PROTECTION_FROM_ELEMENTS, OBJECT_SELF, 3); return TK_BUFFSELF;
                }
                if (!bFoundPotionOnly && buffOthers  && GetBestElemProtTarget())
                {
                    CastSetLastSpellOnObject(SPELL_PROTECTION_FROM_ELEMENTS, oBestBuffTarget, 3); return TK_BUFFOTHER;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_SEARING_LIGHT))
        {
            if (nLastSpellCast != SPELL_SEARING_LIGHT && nRange <= 20.0 && useAttackSpells && CheckSpellSaves(oTarget, 3, HENCH_CHECK_SR_NO_SAVE) && (nRacialType == RACIAL_TYPE_UNDEAD || nRacialType == RACIAL_TYPE_CONSTRUCT))
            {
                CastSetLastSpellOnObject(SPELL_SEARING_LIGHT, oTarget, 3); return TK_ATTACK;
            }
        }
        if (GetHasFeat(FEAT_INFLICT_LIGHT_WOUNDS))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_BG_CREATEDEAD && allowSummons)
            {
                CastSetLastFeatSpellAtLocation(FEAT_INFLICT_LIGHT_WOUNDS, SPELLABILITY_BG_CREATEDEAD, GetSummonLocation(oTarget)); return TK_SUMMON;
            }
        }
        if (nAreaPosition < 310)
        {
            break;
        }
        if (GetHasFixedSpell(SPELL_SUMMON_CREATURE_III))
        {
            if (nLastSpellCast != SPELL_SUMMON_CREATURE_III && allowSummons)
            {
                CastSetLastSpellAtLocation(SPELL_SUMMON_CREATURE_III, GetSummonLocation(oTarget), 3); return TK_SUMMON;
            }
        }
        if (GetHasSpell(SPELLABILITY_BOLT_KNOCKDOWN))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_BOLT_KNOCKDOWN && nRange <= 20.0 && allowAttackAbilities && !GetIsImmune(oTarget, IMMUNITY_TYPE_KNOCKDOWN, OBJECT_SELF))
            {
                CastSpellAbilityOnObject(SPELLABILITY_BOLT_KNOCKDOWN, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELLABILITY_INTENSITY_1))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_INTENSITY_1)
            {
                if (allowBuffAbilities && !GetHasSpellEffect(SPELLABILITY_INTENSITY_1, OBJECT_SELF))
                {
                    CastSpellAbilityOnObject(SPELLABILITY_INTENSITY_1, OBJECT_SELF); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_MEPHIT_SALT_BREATH))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_MEPHIT_SALT_BREATH && nRange <= 20.0 && allowAttackAbilities && (!(GetHasFeat(FEAT_EVASION, oTarget) || GetHasFeat(FEAT_IMPROVED_EVASION, oTarget)) || (GetReflexSavingThrow(oTarget) <= nMySpellAbilityLevel12)))
            {
                CastSpellAbilityOnObject(SPELLABILITY_MEPHIT_SALT_BREATH, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELLABILITY_MEPHIT_STEAM_BREATH))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_MEPHIT_STEAM_BREATH && nRange <= 20.0 && allowAttackAbilities && (!(GetHasFeat(FEAT_EVASION, oTarget) || GetHasFeat(FEAT_IMPROVED_EVASION, oTarget)) || (GetReflexSavingThrow(oTarget) <= nMySpellAbilityLevel12)))
            {
                CastSpellAbilityOnObject(SPELLABILITY_MEPHIT_STEAM_BREATH, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELLABILITY_SMOKE_CLAW))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_SMOKE_CLAW && nRange <= 4.0 && allowAttackAbilities && GetFortitudeSavingThrow(oTarget) <= 14 + nMySpellCasterDCAdjust)
            {
                CastSpellAbilityOnObject(SPELLABILITY_SMOKE_CLAW, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_WOUNDING_WHISPERS))
        {
            if (nLastSpellCast != SPELL_WOUNDING_WHISPERS)
            {
                if (buffSelf && !GetHasSpellEffect(SPELL_WOUNDING_WHISPERS, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_WOUNDING_WHISPERS, OBJECT_SELF, 3); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_GREATER_MAGIC_FANG))
        {
            if (nLastSpellCast != SPELL_GREATER_MAGIC_FANG && buffAnimalCompanion && !GetHasSpellEffect(SPELL_GREATER_MAGIC_FANG, oAnimalCompanion) && !GetHasSpellEffect(SPELL_MAGIC_FANG, oAnimalCompanion))
            {
                CastSetLastSpellOnObject(SPELL_GREATER_MAGIC_FANG, OBJECT_SELF, 3); return TK_BUFFOTHER;
            }
        }
        if (GetHasFixedSpell(SPELL_DISPLACEMENT))
        {
            if (nLastSpellCast != SPELL_DISPLACEMENT)
            {
                if (buffSelf && !GetHasEffect(EFFECT_TYPE_CONCEALMENT, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_DISPLACEMENT, OBJECT_SELF, 3); return TK_BUFFSELF;
                }
                if (!bFoundPotionOnly && buffOthers  && GetBestBuffTarget(-1, EFFECT_TYPE_CONCEALMENT, -1, -1))
                {
                    CastSetLastSpellOnObject(SPELL_DISPLACEMENT, oBestBuffTarget, 3); return TK_BUFFOTHER;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_SILENCE))
        {
            if (nLastSpellCast != SPELL_SILENCE && allowWeakOffSpells && nRange <= 40.0 + 4.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, 4.0, 40.0, 2, -1000, HENCH_CHECK_SR_WILL_SAVE, HENCH_AREA_CHECK_SILENCE))
                {
                    nAreaPosition = 339;
                    nSpell = SPELL_SILENCE; nSpellLevel = 2; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (nAreaPosition < 320)
        {
            break;
        }
        if (GetHasFixedSpell(SPELL_GEDLEES_ELECTRIC_LOOP))
        {
            if (nLastSpellCast != SPELL_GEDLEES_ELECTRIC_LOOP && allowWeakOffSpells && nRange <= 8.0 + RADIUS_SIZE_SMALL)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_SMALL, 8.0, 2, -1000, HENCH_CHECK_SR_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 340;
                    nSpell = SPELL_GEDLEES_ELECTRIC_LOOP; nSpellLevel = 2; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_SOUND_BURST))
        {
            if (nLastSpellCast != SPELL_SOUND_BURST && allowWeakOffSpells && nRange <= 40.0 + RADIUS_SIZE_MEDIUM)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, 40.0, 2, -1000, HENCH_CHECK_SR_NO_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 341;
                    nSpell = SPELL_SOUND_BURST; nSpellLevel = 2; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFeat(FEAT_ANIMAL_COMPANION))
        {
            bFoundSpellGlobal = TRUE;
            if (TRUE  && iAmMonster && !GetLocalInt(OBJECT_SELF, sHenchSummonedAniComp) && !GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION)) && (GetMonsterOptions(HENCH_MONAI_COMP) & HENCH_MONAI_COMP))
            {
                HenchSummonAnimalCompanion(oTarget); return TK_SUMMON;
            }
        }
        if (GetHasFixedSpell(SPELL_BALAGARNSIRONHORN))
        {
            if (nLastSpellCast != SPELL_BALAGARNSIRONHORN && allowWeakOffSpells && nRange <= RADIUS_SIZE_COLOSSAL)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, 0.0, 2, -1000, HENCH_CHECK_SR_NO_SAVE, HENCH_AREA_CHECK_IRONHORN))
                {
                    nAreaPosition = 343;
                    nSpell = SPELL_BALAGARNSIRONHORN; nSpellLevel = 2; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_GREATER_SHADOW_CONJURATION_WEB))
        {
            if (nLastSpellCast != SPELL_GREATER_SHADOW_CONJURATION_WEB && allowWeakOffSpells && nRange <= 20.0 + 6.7)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, 6.7, 20.0, 5, -1000, HENCH_CHECK_SR_REFLEX_SAVE, HENCH_AREA_CHECK_ENTANGLE))
                {
                    nAreaPosition = 344;
                    nSpell = SPELL_GREATER_SHADOW_CONJURATION_WEB; nSpellLevel = 5; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_WEB))
        {
            if (nLastSpellCast != SPELL_WEB && allowWeakOffSpells && nRange <= 20.0 + 6.7)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, 6.7, 20.0, 2, -1000, HENCH_CHECK_SR_REFLEX_SAVE, HENCH_AREA_CHECK_ENTANGLE))
                {
                    nAreaPosition = 345;
                    nSpell = SPELL_WEB; nSpellLevel = 2; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_CLOUD_OF_BEWILDERMENT))
        {
            if (nLastSpellCast != SPELL_CLOUD_OF_BEWILDERMENT && allowWeakOffSpells && nRange <= 8.0 + 5.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, 5.0, 8.0, 2, -1000, HENCH_CHECK_SR_FORT_SAVE, HENCH_AREA_CHECK_POISON))
                {
                    nAreaPosition = 346;
                    nSpell = SPELL_CLOUD_OF_BEWILDERMENT; nSpellLevel = 2; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_KRENSHAR_SCARE))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_KRENSHAR_SCARE && allowAttackAbilities && nRange <= 10.0)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_CONE, 10.0, 8.0, 2, 12 + nMySpellCasterDCAdjust, HENCH_CHECK_WILL_SAVE, HENCH_AREA_CHECK_MIND_AND_FEAR))
                {
                    nAreaPosition = 347;
                    nSpell = SPELLABILITY_KRENSHAR_SCARE; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_BARKSKIN))
        {
            if (nLastSpellCast != SPELL_BARKSKIN)
            {
                if (buffSelf && !GetHasEffect(EFFECT_TYPE_AC_INCREASE, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_BARKSKIN, OBJECT_SELF, 2); return TK_BUFFSELF;
                }
                if (!bFoundPotionOnly && buffOthers  && GetBestBuffTarget(-1, EFFECT_TYPE_AC_INCREASE, -1, -1))
                {
                    CastSetLastSpellOnObject(SPELL_BARKSKIN, oBestBuffTarget, 2); return TK_BUFFOTHER;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_BLINDNESS_AND_DEAFNESS))
        {
            if (nLastSpellCast != SPELL_BLINDNESS_AND_DEAFNESS && nRange <= 20.0 && allowWeakOffSpells && !(GetIsImmune(oTarget, IMMUNITY_TYPE_BLINDNESS, OBJECT_SELF) || GetIsImmune(oTarget, IMMUNITY_TYPE_DEAFNESS, OBJECT_SELF)) && !GetIsDisabled2(EFFECT_TYPE_DEAF, EFFECT_TYPE_BLINDNESS, oTarget) && CheckSpellSaves(oTarget, 2, HENCH_CHECK_SR_FORT_SAVE))
            {
                CastSetLastSpellOnObject(SPELL_BLINDNESS_AND_DEAFNESS, oTarget, 2); return TK_ATTACK;
            }
        }
        if (nAreaPosition < 330)
        {
            break;
        }
        if (GetHasFixedSpell(SPELL_COMBUST))
        {
            if (nLastSpellCast != SPELL_COMBUST && nRange <= 4.0 && allowWeakOffSpells && CheckSpellSaves(oTarget, 2, HENCH_CHECK_SR_NO_SAVE))
            {
                CastSetLastSpellOnObject(SPELL_COMBUST, oTarget, 2); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_TASHAS_HIDEOUS_LAUGHTER))
        {
            if (nLastSpellCast != SPELL_TASHAS_HIDEOUS_LAUGHTER && nRange <= 8.0 && allowWeakOffSpells && !(GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) || GetIsImmune(oTarget, IMMUNITY_TYPE_KNOCKDOWN, OBJECT_SELF)) && CheckSpellSaves(oTarget, 2, HENCH_CHECK_SR_WILL_SAVE) && !spellsIsMindless(oTarget))
            {
                CastSetLastSpellOnObject(SPELL_TASHAS_HIDEOUS_LAUGHTER, oTarget, 2); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_FLAME_LASH))
        {
            if (nLastSpellCast != SPELL_FLAME_LASH && nRange <= 8.0 && allowWeakOffSpells && CheckSpellSaves(oTarget, 2, HENCH_CHECK_SR_REFLEX_EVASION_SAVE))
            {
                CastSetLastSpellOnObject(SPELL_FLAME_LASH, oTarget, 2); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_GHOUL_TOUCH))
        {
            if (nLastSpellCast != SPELL_GHOUL_TOUCH && nRange <= 4.0 && allowWeakOffSpells && !(GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) || GetIsImmune(oTarget, IMMUNITY_TYPE_PARALYSIS, OBJECT_SELF)) && !GetIsDisabled(oTarget) && CheckSpellSaves(oTarget, 2, HENCH_CHECK_SR_FORT_SAVE))
            {
                CastSetLastSpellOnObject(SPELL_GHOUL_TOUCH, oTarget, 2); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_HOLD_ANIMAL))
        {
            if (nLastSpellCast != SPELL_HOLD_ANIMAL && nRange <= 20.0 && allowWeakOffSpells && !(GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) || GetIsImmune(oTarget, IMMUNITY_TYPE_PARALYSIS, OBJECT_SELF)) && !GetIsDisabled(oTarget) && CheckSpellSaves(oTarget, 2, HENCH_CHECK_SR_WILL_SAVE) && nRacialType == RACIAL_TYPE_ANIMAL)
            {
                CastSetLastSpellOnObject(SPELL_HOLD_ANIMAL, oTarget, 2); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_HOLD_PERSON))
        {
            if (nLastSpellCast != SPELL_HOLD_PERSON && nRange <= 20.0 && allowWeakOffSpells && !(GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) || GetIsImmune(oTarget, IMMUNITY_TYPE_PARALYSIS, OBJECT_SELF)) && !GetIsDisabled(oTarget) && CheckSpellSaves(oTarget, 2, HENCH_CHECK_SR_WILL_SAVE) && GetIsHumanoid(nRacialType))
            {
                CastSetLastSpellOnObject(SPELL_HOLD_PERSON, oTarget, 2); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_MELFS_ACID_ARROW))
        {
            if (nLastSpellCast != SPELL_MELFS_ACID_ARROW && nRange <= 40.0 && allowWeakOffSpells && CheckSpellSaves(oTarget, 2, HENCH_CHECK_SR_NO_SAVE) &&!GetHasSpellEffect(SPELL_MELFS_ACID_ARROW, oTarget))
            {
                CastSetLastSpellOnObject(SPELL_MELFS_ACID_ARROW, oTarget, 2); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_GREATER_SHADOW_CONJURATION_ACID_ARROW))
        {
            if (nLastSpellCast != SPELL_GREATER_SHADOW_CONJURATION_ACID_ARROW && nRange <= 40.0 && allowWeakOffSpells && CheckSpellSaves(oTarget, 5, HENCH_CHECK_SR_NO_SAVE) &&!GetHasSpellEffect(SPELL_GREATER_SHADOW_CONJURATION_ACID_ARROW, oTarget))
            {
                CastSetLastSpellOnObject(SPELL_GREATER_SHADOW_CONJURATION_ACID_ARROW, oTarget, 5); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_CHARM_PERSON_OR_ANIMAL))
        {
            if (nLastSpellCast != SPELL_CHARM_PERSON_OR_ANIMAL && nRange <= 8.0 && allowWeakOffSpells && !(GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) || GetIsImmune(oTarget, IMMUNITY_TYPE_CHARM, OBJECT_SELF)) && !GetIsDisabled1(EFFECT_TYPE_CHARMED, oTarget) && CheckSpellSaves(oTarget, 2, HENCH_CHECK_SR_WILL_SAVE) && (GetIsHumanoid(nRacialType) || nRacialType == RACIAL_TYPE_ANIMAL))
            {
                CastSetLastSpellOnObject(SPELL_CHARM_PERSON_OR_ANIMAL, oTarget, 2); return TK_ATTACK;
            }
        }
        if (GetHasCureSpell(SPELL_CURE_MODERATE_WOUNDS))
        {
            if (nLastSpellCast != SPELL_CURE_MODERATE_WOUNDS && nRange <= 4.0 && allowWeakOffSpells && CheckSpellSaves(oTarget, 2, HENCH_CHECK_SR_NO_SAVE) && nRacialType == RACIAL_TYPE_UNDEAD)
            {
                CastSetLastSpellOnObject(SPELL_CURE_MODERATE_WOUNDS, oTarget, 2); return TK_ATTACK;
            }
        }
        if (nAreaPosition < 340)
        {
            break;
        }
        if (GetHasInflictSpell(SPELL_INFLICT_MODERATE_WOUNDS))
        {
            if (nLastSpellCast != SPELL_INFLICT_MODERATE_WOUNDS && nRange <= 4.0 && allowWeakOffSpells && CheckSpellSaves(oTarget, 2, HENCH_CHECK_SR_NO_SAVE) && nRacialType != RACIAL_TYPE_UNDEAD)
            {
                CastSetLastSpellOnObject(SPELL_INFLICT_MODERATE_WOUNDS, oTarget, 2); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_HENCH_AuraOfGlory_X2))
        {
            if (nLastSpellCast != SPELL_HENCH_AuraOfGlory_X2)
            {
                if (groupBuff && !GetHasSpellEffect(SPELL_HENCH_AuraOfGlory_X2, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_HENCH_AuraOfGlory_X2, OBJECT_SELF, 2); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_AURAOFGLORY))
        {
            if (nLastSpellCast != SPELL_AURAOFGLORY)
            {
                if (groupBuff && !GetHasSpellEffect(SPELL_AURAOFGLORY, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_AURAOFGLORY, OBJECT_SELF, 2); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_DEATH_ARMOR))
        {
            if (nLastSpellCast != SPELL_DEATH_ARMOR)
            {
                if (buffSelf && !GetHasSpellEffect(SPELL_DEATH_ARMOR, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_DEATH_ARMOR, OBJECT_SELF, 2); return TK_BUFFSELF;
                }
            }
        }
        {
            int attrResult = GetBestUndeadBuff(buffSelf, buffOthers, nLastSpellCast);
            if (attrResult)
            {
                return attrResult;
            }
        }
        if (GetHasFixedSpell(SPELL_AID))
        {
            if (nLastSpellCast != SPELL_AID)
            {
                if (buffSelf && (!GetHasEffect(EFFECT_TYPE_ATTACK_INCREASE, OBJECT_SELF) || !GetHasEffect(EFFECT_TYPE_TEMPORARY_HITPOINTS, OBJECT_SELF)))
                {
                    CastSetLastSpellOnObject(SPELL_AID, OBJECT_SELF, 2); return TK_BUFFSELF;
                }
                if (!bFoundPotionOnly && buffOthers  && GetBestBuffTarget(-1, EFFECT_TYPE_ATTACK_INCREASE, EFFECT_TYPE_TEMPORARY_HITPOINTS, -1))
                {
                    CastSetLastSpellOnObject(SPELL_AID, oBestBuffTarget, 2); return TK_BUFFOTHER;
                }
            }
        }
        {
            int attrResult = GetBestAttribBuff(buffSelf, buffOthers, nLastSpellCast);
            if (attrResult)
            {
                return attrResult;
            }
        }
        if (GetHasFeat(FEAT_PRESTIGE_INVISIBILITY_2))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != FEAT_PRESTIGE_INVISIBILITY_2)
            {
                if (allowBuffAbilities && !GetHasEffect(EFFECT_TYPE_DAMAGE_REDUCTION, OBJECT_SELF))
                {
                    CastFeatOnObject(FEAT_PRESTIGE_INVISIBILITY_2, OBJECT_SELF); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_GHOSTLY_VISAGE))
        {
            if (nLastSpellCast != SPELL_GHOSTLY_VISAGE && (d100() <= 50))
            {
                if (buffSelf && !GetHasEffect(EFFECT_TYPE_DAMAGE_REDUCTION, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_GHOSTLY_VISAGE, OBJECT_SELF, 2); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_GREATER_SHADOW_CONJURATION_MIRROR_IMAGE))
        {
            if (nLastSpellCast != SPELL_GREATER_SHADOW_CONJURATION_MIRROR_IMAGE && (d100() <= 50))
            {
                if (buffSelf && (!GetHasEffect(EFFECT_TYPE_DAMAGE_REDUCTION, OBJECT_SELF) || !GetHasEffect(EFFECT_TYPE_SPELLLEVELABSORPTION, OBJECT_SELF) || !GetHasEffect(EFFECT_TYPE_CONCEALMENT, OBJECT_SELF)))
                {
                    CastSetLastSpellOnObject(SPELL_GREATER_SHADOW_CONJURATION_MIRROR_IMAGE, OBJECT_SELF, 5); return TK_BUFFSELF;
                }
            }
        }
        if (nAreaPosition < 350)
        {
            break;
        }
        if (GetHasFixedSpell(SPELL_RESIST_ELEMENTS))
        {
            if (nLastSpellCast != SPELL_RESIST_ELEMENTS)
            {
                if (buffSelf && !GetHasSpellEffect(SPELL_ENERGY_BUFFER, OBJECT_SELF) && !GetHasSpellEffect(SPELL_PROTECTION_FROM_ELEMENTS, OBJECT_SELF) && !GetHasSpellEffect(SPELL_ENDURE_ELEMENTS, OBJECT_SELF) && !GetHasSpellEffect(SPELL_ELEMENTAL_SHIELD, OBJECT_SELF) && !GetHasSpellEffect(SPELL_RESIST_ELEMENTS, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_RESIST_ELEMENTS, OBJECT_SELF, 2); return TK_BUFFSELF;
                }
                if (!bFoundPotionOnly && buffOthers  && GetBestElemProtTarget())
                {
                    CastSetLastSpellOnObject(SPELL_RESIST_ELEMENTS, oBestBuffTarget, 2); return TK_BUFFOTHER;
                }
            }
        }
        if (GetHasFeat(FEAT_ANIMATE_DEAD))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_PM_ANIMATE_DEAD && allowSummons)
            {
                CastSetLastFeatSpellAtLocation(FEAT_ANIMATE_DEAD, SPELLABILITY_PM_ANIMATE_DEAD, GetSummonLocation(oTarget)); return TK_SUMMON;
            }
        }
        if (GetHasFixedSpell(SPELL_SUMMON_CREATURE_II))
        {
            if (nLastSpellCast != SPELL_SUMMON_CREATURE_II && allowSummons)
            {
                CastSetLastSpellAtLocation(SPELL_SUMMON_CREATURE_II, GetSummonLocation(oTarget), 2); return TK_SUMMON;
            }
        }
        if (GetHasFixedSpell(SPELL_ONE_WITH_THE_LAND))
        {
            if (nLastSpellCast != SPELL_ONE_WITH_THE_LAND)
            {
                if (buffSelf && !GetHasSpellEffect(SPELL_ONE_WITH_THE_LAND, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_ONE_WITH_THE_LAND, OBJECT_SELF, 2); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFeat(FEAT_SUMMON_FAMILIAR))
        {
            bFoundSpellGlobal = TRUE;
            if (TRUE  && iAmMonster && !GetLocalInt(OBJECT_SELF, sHenchSummonedFamiliar) && !GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_FAMILIAR)) && (GetMonsterOptions(HENCH_MONAI_COMP) & HENCH_MONAI_COMP))
            {
                HenchSummonFamiliar(oTarget); return TK_SUMMON;
            }
        }
        if (GetHasFixedSpell(SPELL_BLESS))
        {
            if (nLastSpellCast != SPELL_BLESS)
            {
                if (groupBuff && (!GetHasEffect(EFFECT_TYPE_ATTACK_INCREASE, OBJECT_SELF) || !GetHasEffect(EFFECT_TYPE_SAVING_THROW_INCREASE, OBJECT_SELF)))
                {
                    CastSetLastSpellOnObject(SPELL_BLESS, OBJECT_SELF, 1); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_VINE_MINE_ENTANGLE))
        {
            if (nLastSpellCast != SPELL_VINE_MINE_ENTANGLE && allowWeakOffSpells && nRange <= 20.0 + 5.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, 5.0, 20.0, 5, -1000, HENCH_CHECK_SR_REFLEX_SAVE, HENCH_AREA_CHECK_ENTANGLE))
                {
                    nAreaPosition = 376;
                    nSpell = SPELL_VINE_MINE_ENTANGLE; nSpellLevel = 5; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_VINE_MINE_HAMPER_MOVEMENT))
        {
            if (nLastSpellCast != SPELL_VINE_MINE_HAMPER_MOVEMENT && allowWeakOffSpells && nRange <= 20.0 + 5.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, 5.0, 20.0, 5, -1000, HENCH_CHECK_NO_SAVE, HENCH_AREA_CHECK_MOVE_SPEED_DEC))
                {
                    nAreaPosition = 377;
                    nSpell = SPELL_VINE_MINE_HAMPER_MOVEMENT; nSpellLevel = 5; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_BURNING_HANDS))
        {
            if (nLastSpellCast != SPELL_BURNING_HANDS && allowWeakOffSpells && nRange <= 10.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 10.0, 8.0, 1, -1000, HENCH_CHECK_SR_REFLEX_EVASION_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 379;
                    nSpell = SPELL_BURNING_HANDS; nSpellLevel = 1; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (nAreaPosition < 360)
        {
            break;
        }
        if (GetHasFixedSpell(SPELL_CHARM_PERSON))
        {
            if (nLastSpellCast != SPELL_CHARM_PERSON && nRange <= 8.0 && allowWeakOffSpells && !(GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) || GetIsImmune(oTarget, IMMUNITY_TYPE_CHARM, OBJECT_SELF)) && !GetIsDisabled1(EFFECT_TYPE_CHARMED, oTarget) && CheckSpellSaves(oTarget, 1, HENCH_CHECK_SR_WILL_SAVE) && GetIsHumanoid(nRacialType))
            {
                CastSetLastSpellOnObject(SPELL_CHARM_PERSON, oTarget, 1); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_COLOR_SPRAY))
        {
            if (nLastSpellCast != SPELL_COLOR_SPRAY && allowWeakOffSpells && nRange <= 10.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPELLCONE, 10.0, 8.0, 1, -1000, HENCH_CHECK_SR_WILL_SAVE, HENCH_AREA_CHECK_MIND))
                {
                    nAreaPosition = 381;
                    nSpell = SPELL_COLOR_SPRAY; nSpellLevel = 1; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_HORIZIKAULS_BOOM))
        {
            if (nLastSpellCast != SPELL_HORIZIKAULS_BOOM && nRange <= 8.0 && allowWeakOffSpells && CheckSpellSaves(oTarget, 1, HENCH_CHECK_SR_NO_SAVE))
            {
                CastSetLastSpellOnObject(SPELL_HORIZIKAULS_BOOM, oTarget, 1); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_MAGIC_MISSILE))
        {
            if (nLastSpellCast != SPELL_MAGIC_MISSILE && nRange <= 40.0 && allowWeakOffSpells && CheckSpellSaves(oTarget, 1, HENCH_CHECK_SR_NO_SAVE) && !GetHasSpellEffect(SPELL_SHIELD, oTarget))
            {
                CastSetLastSpellOnObject(SPELL_MAGIC_MISSILE, oTarget, 1); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELL_HENCH_EyeballRay0))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELL_HENCH_EyeballRay0 && nRange <= 20.0 && allowUnlimitedAttackAbilities)
            {
                CastSpellAbilityOnObject(SPELL_HENCH_EyeballRay0, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELL_HENCH_EyeballRay1))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELL_HENCH_EyeballRay1 && nRange <= 20.0 && allowUnlimitedAttackAbilities && nRacialType != RACIAL_TYPE_UNDEAD)
            {
                CastSpellAbilityOnObject(SPELL_HENCH_EyeballRay1, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasSpell(SPELL_HENCH_EyeballRay2))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELL_HENCH_EyeballRay2 && nRange <= 20.0 && allowUnlimitedAttackAbilities)
            {
                CastSpellAbilityOnObject(SPELL_HENCH_EyeballRay2, oTarget); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_HENCH_Shadow_Attack))
        {
            if (nLastSpellCast != SPELL_HENCH_Shadow_Attack && nRange <= 4.0 && allowWeakOffSpells && !GetIsImmune(oTarget, IMMUNITY_TYPE_ABILITY_DECREASE, OBJECT_SELF) && !GetIsDisabled1(EFFECT_TYPE_ABILITY_DECREASE, oTarget))
            {
                CastSetLastSpellOnObject(SPELL_HENCH_Shadow_Attack, oTarget, 1); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_ICE_DAGGER))
        {
            if (nLastSpellCast != SPELL_ICE_DAGGER && nRange <= 8.0 && allowWeakOffSpells && CheckSpellSaves(oTarget, 1, HENCH_CHECK_SR_REFLEX_EVASION_SAVE))
            {
                CastSetLastSpellOnObject(SPELL_ICE_DAGGER, oTarget, 1); return TK_ATTACK;
            }
        }
        if (GetHasCureSpell(SPELL_CURE_LIGHT_WOUNDS))
        {
            if (nLastSpellCast != SPELL_CURE_LIGHT_WOUNDS && nRange <= 4.0 && allowWeakOffSpells && CheckSpellSaves(oTarget, 1, HENCH_CHECK_SR_NO_SAVE) && nRacialType == RACIAL_TYPE_UNDEAD)
            {
                CastSetLastSpellOnObject(SPELL_CURE_LIGHT_WOUNDS, oTarget, 1); return TK_ATTACK;
            }
        }
        if (nAreaPosition < 370)
        {
            break;
        }
        if (GetHasInflictSpell(SPELL_INFLICT_LIGHT_WOUNDS))
        {
            if (nLastSpellCast != SPELL_INFLICT_LIGHT_WOUNDS && nRange <= 4.0 && allowWeakOffSpells && CheckSpellSaves(oTarget, 1, HENCH_CHECK_SR_NO_SAVE) && nRacialType != RACIAL_TYPE_UNDEAD)
            {
                CastSetLastSpellOnObject(SPELL_INFLICT_LIGHT_WOUNDS, oTarget, 1); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_DOOM))
        {
            if (nLastSpellCast != SPELL_DOOM && nRange <= 20.0 && allowWeakOffSpells && !GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) && CheckSpellSaves(oTarget, 1, HENCH_CHECK_SR_WILL_SAVE))
            {
                CastSetLastSpellOnObject(SPELL_DOOM, oTarget, 1); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_ENDURE_ELEMENTS))
        {
            if (nLastSpellCast != SPELL_ENDURE_ELEMENTS)
            {
                if (buffSelf && !GetHasSpellEffect(SPELL_ENERGY_BUFFER, OBJECT_SELF) && !GetHasSpellEffect(SPELL_PROTECTION_FROM_ELEMENTS, OBJECT_SELF) && !GetHasSpellEffect(SPELL_RESIST_ELEMENTS, OBJECT_SELF) && !GetHasSpellEffect(SPELL_ELEMENTAL_SHIELD, OBJECT_SELF) && !GetHasSpellEffect(SPELL_ENDURE_ELEMENTS, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_ENDURE_ELEMENTS, OBJECT_SELF, 1); return TK_BUFFSELF;
                }
                if (!bFoundPotionOnly && buffOthers  && GetBestElemProtTarget())
                {
                    CastSetLastSpellOnObject(SPELL_ENDURE_ELEMENTS, oBestBuffTarget, 1); return TK_BUFFOTHER;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_ENTANGLE))
        {
            if (nLastSpellCast != SPELL_ENTANGLE && allowWeakOffSpells && nRange <= 40.0 + 5.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, 5.0, 40.0, 1, -1000, HENCH_CHECK_SR_REFLEX_SAVE, HENCH_AREA_CHECK_ENTANGLE))
                {
                    nAreaPosition = 393;
                    nSpell = SPELL_ENTANGLE; nSpellLevel = 1; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_GREASE))
        {
            if (nLastSpellCast != SPELL_GREASE && allowWeakOffSpells && nRange <= 40.0 + 6.0)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, 6.0, 40.0, 1, -1000, HENCH_CHECK_SR_REFLEX_SAVE, HENCH_AREA_CHECK_GREASE))
                {
                    nAreaPosition = 394;
                    nSpell = SPELL_GREASE; nSpellLevel = 1; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_SHIELD))
        {
            if (nLastSpellCast != SPELL_SHIELD)
            {
                if (buffSelf && !GetHasEffect(EFFECT_TYPE_AC_INCREASE, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_SHIELD, OBJECT_SELF, 1); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_ENTROPIC_SHIELD))
        {
            if (nLastSpellCast != SPELL_ENTROPIC_SHIELD)
            {
                if (buffSelf && !GetHasEffect(EFFECT_TYPE_CONCEALMENT, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_ENTROPIC_SHIELD, OBJECT_SELF, 1); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_SHIELD_OF_FAITH))
        {
            if (nLastSpellCast != SPELL_SHIELD_OF_FAITH)
            {
                if (buffSelf && !GetHasEffect(EFFECT_TYPE_AC_INCREASE, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_SHIELD_OF_FAITH, OBJECT_SELF, 1); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_MAGE_ARMOR))
        {
            if (nLastSpellCast != SPELL_MAGE_ARMOR)
            {
                if (buffSelf && !GetHasSpellEffect(SPELL_MAGE_ARMOR, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_MAGE_ARMOR, OBJECT_SELF, 1); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_SHADOW_CONJURATION_MAGE_ARMOR))
        {
            if (nLastSpellCast != SPELL_SHADOW_CONJURATION_MAGE_ARMOR)
            {
                if (buffSelf && !GetHasSpellEffect(SPELL_SHADOW_CONJURATION_MAGE_ARMOR, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_SHADOW_CONJURATION_MAGE_ARMOR, OBJECT_SELF, 4); return TK_BUFFSELF;
                }
            }
        }
        if (nAreaPosition < 380)
        {
            break;
        }
        if (GetHasFixedSpell(SPELL_SHADOW_CONJURATION_MAGIC_MISSILE))
        {
            if (nLastSpellCast != SPELL_SHADOW_CONJURATION_MAGIC_MISSILE && nRange <= 40.0 && allowWeakOffSpells && CheckSpellSaves(oTarget, 4, HENCH_CHECK_SR_NO_SAVE) && !GetHasSpellEffect(SPELL_SHIELD, oTarget))
            {
                CastSetLastSpellOnObject(SPELL_SHADOW_CONJURATION_MAGIC_MISSILE, oTarget, 4); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_PROTECTION_FROM_EVIL))
        {
            if (nLastSpellCast != SPELL_PROTECTION_FROM_EVIL && iTargetGEAlign == ALIGNMENT_EVIL)
            {
                if (buffSelf && !GetHasSpellEffect(SPELL_HOLY_AURA, OBJECT_SELF) && !GetHasSpellEffect(SPELL_MAGIC_CIRCLE_AGAINST_EVIL, OBJECT_SELF) && !GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_PROTECTION_FROM_EVIL, OBJECT_SELF, 1); return TK_BUFFSELF;
                }
                if (!bFoundPotionOnly && buffOthers  && GetBestBuffTarget(IMMUNITY_TYPE_MIND_SPELLS, EFFECT_TYPE_AC_INCREASE, EFFECT_TYPE_SAVING_THROW_INCREASE, -1))
                {
                    CastSetLastSpellOnObject(SPELL_PROTECTION_FROM_EVIL, oBestBuffTarget, 1); return TK_BUFFOTHER;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_PROTECTION_FROM_GOOD))
        {
            if (nLastSpellCast != SPELL_PROTECTION_FROM_GOOD && iTargetGEAlign == ALIGNMENT_GOOD)
            {
                if (buffSelf && !GetHasSpellEffect(SPELL_UNHOLY_AURA, OBJECT_SELF) && !GetHasSpellEffect(SPELL_MAGIC_CIRCLE_AGAINST_GOOD, OBJECT_SELF) && !GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_PROTECTION_FROM_GOOD, OBJECT_SELF, 1); return TK_BUFFSELF;
                }
                if (!bFoundPotionOnly && buffOthers  && GetBestBuffTarget(IMMUNITY_TYPE_MIND_SPELLS, EFFECT_TYPE_AC_INCREASE, EFFECT_TYPE_SAVING_THROW_INCREASE, -1))
                {
                    CastSetLastSpellOnObject(SPELL_PROTECTION_FROM_GOOD, oBestBuffTarget, 1); return TK_BUFFOTHER;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_RAY_OF_ENFEEBLEMENT))
        {
            if (nLastSpellCast != SPELL_RAY_OF_ENFEEBLEMENT && nRange <= 8.0 && allowWeakOffSpells && !GetIsImmune(oTarget, IMMUNITY_TYPE_ABILITY_DECREASE, OBJECT_SELF) && !GetIsDisabled1(EFFECT_TYPE_ABILITY_DECREASE, oTarget) && CheckSpellSaves(oTarget, 1, HENCH_CHECK_SR_FORT_SAVE))
            {
                CastSetLastSpellOnObject(SPELL_RAY_OF_ENFEEBLEMENT, oTarget, 1); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_RESISTANCE))
        {
            if (nLastSpellCast != SPELL_RESISTANCE)
            {
                if (buffSelf && !GetHasEffect(EFFECT_TYPE_SAVING_THROW_INCREASE, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_RESISTANCE, OBJECT_SELF, 1); return TK_BUFFSELF;
                }
                if (!bFoundPotionOnly && buffOthers  && GetBestBuffTarget(-1, EFFECT_TYPE_SAVING_THROW_INCREASE, -1, -1))
                {
                    CastSetLastSpellOnObject(SPELL_RESISTANCE, oBestBuffTarget, 1); return TK_BUFFOTHER;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_MAGIC_FANG))
        {
            if (nLastSpellCast != SPELL_MAGIC_FANG && buffAnimalCompanion && !GetHasSpellEffect(SPELL_GREATER_MAGIC_FANG, oAnimalCompanion) && !GetHasSpellEffect(SPELL_GREATER_MAGIC_FANG, oAnimalCompanion) && !GetHasSpellEffect(SPELL_MAGIC_FANG, oAnimalCompanion))
            {
                CastSetLastSpellOnObject(SPELL_MAGIC_FANG, OBJECT_SELF, 1); return TK_BUFFOTHER;
            }
        }
        if (GetHasFixedSpell(SPELL_SCARE))
        {
            if (nLastSpellCast != SPELL_SCARE && nRange <= 8.0 && allowWeakOffSpells && !(GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) || GetIsImmune(oTarget, IMMUNITY_TYPE_FEAR, OBJECT_SELF)) && !GetIsDisabled(oTarget) && CheckSpellSaves(oTarget, 1, HENCH_CHECK_SR_WILL_SAVE) && GetHitDice(oTarget) < 6)
            {
                CastSetLastSpellOnObject(SPELL_SCARE, oTarget, 1); return TK_ATTACK;
            }
        }
        if (GetHasFeat(FEAT_HARPER_SLEEP))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != FEAT_HARPER_SLEEP && allowAttackAbilities && nRange <= 20.0 + RADIUS_SIZE_HUGE)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_HUGE, 20.0, 1, -1000, HENCH_CHECK_WILL_SAVE, HENCH_AREA_CHECK_SLEEP))
                {
                    nAreaPosition = 407;
                    nSpell = FEAT_HARPER_SLEEP; nSpell2 = SPELL_HENCH_HarperSleep; nTargetType = TARGET_FEAT_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_SLEEP))
        {
            if (nLastSpellCast != SPELL_SLEEP && allowWeakOffSpells && nRange <= 20.0 + RADIUS_SIZE_HUGE)
            {
                if (GetTotalEnemyCount(oTarget, 1,SHAPE_SPHERE, RADIUS_SIZE_HUGE, 20.0, 1, -1000, HENCH_CHECK_SR_WILL_SAVE, HENCH_AREA_CHECK_SLEEP))
                {
                    nAreaPosition = 408;
                    nSpell = SPELL_SLEEP; nSpellLevel = 1; nTargetType = TARGET_SPELL_AT_LOCATION;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_BANE))
        {
            if (nLastSpellCast != SPELL_BANE && allowWeakOffSpells && nRange <= 40.0 + RADIUS_SIZE_COLOSSAL)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, 40.0, 1, -1000, HENCH_CHECK_SR_WILL_SAVE, HENCH_AREA_CHECK_ATTDEC))
                {
                    nAreaPosition = 409;
                    nSpell = SPELL_BANE; nSpellLevel = 1; nTargetType = TARGET_SPELL_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (nAreaPosition < 390)
        {
            break;
        }
        if (GetHasSpell(SPELLABILITY_HELL_HOUND_FIREBREATH))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_HELL_HOUND_FIREBREATH && allowAttackAbilities && nRange <= 11.0)
            {
                if (GetTotalEnemyCount(oTarget, 0,SHAPE_SPELLCONE, 11.0, 8.0, 1, nMySpellAbilityLevel1, HENCH_CHECK_NO_SAVE, HENCH_AREA_NO_CHECK))
                {
                    nAreaPosition = 410;
                    nSpell = SPELLABILITY_HELL_HOUND_FIREBREATH; nTargetType = TARGET_SPELLABILITY_AREA_ON_OBJECT;
                }
                if (nAreaSpellExtraTargets > 0)
                {
                    break;
                }
            }
        }
        if (GetHasCureSpell(SPELL_CURE_MINOR_WOUNDS))
        {
            if (nLastSpellCast != SPELL_CURE_MINOR_WOUNDS && nRange <= 4.0 && allowWeakOffSpells && CheckSpellSaves(oTarget, 0, HENCH_CHECK_SR_NO_SAVE) && nRacialType == RACIAL_TYPE_UNDEAD)
            {
                CastSetLastSpellOnObject(SPELL_CURE_MINOR_WOUNDS, oTarget, 0); return TK_ATTACK;
            }
        }
        if (GetHasInflictSpell(SPELL_INFLICT_MINOR_WOUNDS))
        {
            if (nLastSpellCast != SPELL_INFLICT_MINOR_WOUNDS && nRange <= 4.0 && allowWeakOffSpells && CheckSpellSaves(oTarget, 0, HENCH_CHECK_SR_NO_SAVE) && nRacialType != RACIAL_TYPE_UNDEAD)
            {
                CastSetLastSpellOnObject(SPELL_INFLICT_MINOR_WOUNDS, oTarget, 0); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_IRONGUTS))
        {
            if (nLastSpellCast != SPELL_IRONGUTS)
            {
                if (buffSelf && !GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_POISON, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_IRONGUTS, OBJECT_SELF, 1); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_SHELGARNS_PERSISTENT_BLADE))
        {
            if (nLastSpellCast != SPELL_SHELGARNS_PERSISTENT_BLADE && allowSummons)
            {
                CastSetLastSpellAtLocation(SPELL_SHELGARNS_PERSISTENT_BLADE, GetSummonLocation(oTarget), 1); return TK_SUMMON;
            }
        }
        if (GetHasFixedSpell(SPELL_SUMMON_CREATURE_I))
        {
            if (nLastSpellCast != SPELL_SUMMON_CREATURE_I && allowSummons)
            {
                CastSetLastSpellAtLocation(SPELL_SUMMON_CREATURE_I, GetSummonLocation(oTarget), 1); return TK_SUMMON;
            }
        }
        if (GetHasFixedSpell(SPELL_NEGATIVE_ENERGY_RAY))
        {
            if (nLastSpellCast != SPELL_NEGATIVE_ENERGY_RAY && nRange <= 20.0 && allowWeakOffSpells && CheckSpellSaves(oTarget, 1, HENCH_CHECK_SR_NO_SAVE) && nRacialType != RACIAL_TYPE_UNDEAD)
            {
                CastSetLastSpellOnObject(SPELL_NEGATIVE_ENERGY_RAY, oTarget, 1); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_DAZE))
        {
            if (nLastSpellCast != SPELL_DAZE && nRange <= 40.0 && allowWeakOffSpells && !(GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF) || GetIsImmune(oTarget, IMMUNITY_TYPE_DAZED, OBJECT_SELF)) && !GetIsDisabled(oTarget) && CheckSpellSaves(oTarget, 0, HENCH_CHECK_SR_WILL_SAVE) && GetIsHumanoid(nRacialType) && GetHitDice(oTarget) <= 5)
            {
                CastSetLastSpellOnObject(SPELL_DAZE, oTarget, 0); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_ACID_SPLASH))
        {
            if (nLastSpellCast != SPELL_ACID_SPLASH && nRange <= 20.0 && allowWeakOffSpells && CheckSpellSaves(oTarget, 0, HENCH_CHECK_SR_NO_SAVE))
            {
                CastSetLastSpellOnObject(SPELL_ACID_SPLASH, oTarget, 0); return TK_ATTACK;
            }
        }
        if (nAreaPosition < 400)
        {
            break;
        }
        if (GetHasFixedSpell(SPELL_ELECTRIC_JOLT))
        {
            if (nLastSpellCast != SPELL_ELECTRIC_JOLT && nRange <= 20.0 && allowWeakOffSpells && CheckSpellSaves(oTarget, 0, HENCH_CHECK_SR_NO_SAVE))
            {
                CastSetLastSpellOnObject(SPELL_ELECTRIC_JOLT, oTarget, 0); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_FLARE))
        {
            if (nLastSpellCast != SPELL_FLARE && nRange <= 20.0 && allowWeakOffSpells && !GetIsImmune(oTarget, IMMUNITY_TYPE_ATTACK_DECREASE, OBJECT_SELF) && !GetIsDisabled1(EFFECT_TYPE_ATTACK_DECREASE, oTarget) && CheckSpellSaves(oTarget, 0, HENCH_CHECK_SR_FORT_SAVE))
            {
                CastSetLastSpellOnObject(SPELL_FLARE, oTarget, 0); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_RAY_OF_FROST))
        {
            if (nLastSpellCast != SPELL_RAY_OF_FROST && nRange <= 20.0 && allowWeakOffSpells && CheckSpellSaves(oTarget, 0, HENCH_CHECK_SR_NO_SAVE))
            {
                CastSetLastSpellOnObject(SPELL_RAY_OF_FROST, oTarget, 0); return TK_ATTACK;
            }
        }
        if (GetHasFixedSpell(SPELL_BLACKSTAFF))
        {
            if (nLastSpellCast != SPELL_BLACKSTAFF)
            {
                int attrResult = GetBestWeaponBuffTarget(buffSelf, FALSE, ITEM_PROPERTY_ON_HIT_PROPERTIES, 4, HENCH_WEAPON_STAFF_FLAG, SPELL_BLACKSTAFF, 8);
                if (attrResult)
                {
                    return attrResult;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_HOLY_SWORD))
        {
            if (nLastSpellCast != SPELL_HOLY_SWORD)
            {
                int attrResult = GetBestWeaponBuffTarget(buffSelf, buffOthers, ITEM_PROPERTY_HOLY_AVENGER, -1, HENCH_WEAPON_HOLY_SWORD, SPELL_HOLY_SWORD, 4);
                if (attrResult)
                {
                    return attrResult;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_GREATER_MAGIC_WEAPON))
        {
            if (nLastSpellCast != SPELL_GREATER_MAGIC_WEAPON)
            {
                int attrResult = GetBestWeaponBuffTarget(buffSelf, buffOthers, -1, bFoundItemSpell ? 2 : ((nMySpellCasterLevel >= 15) ? 5 : (nMySpellCasterLevel / 3)), 0, SPELL_GREATER_MAGIC_WEAPON, 3);
                if (attrResult)
                {
                    return attrResult;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_BLADE_THIRST))
        {
            if (nLastSpellCast != SPELL_BLADE_THIRST)
            {
                int attrResult = GetBestWeaponBuffTarget(buffSelf, buffOthers, -1, 3, HENCH_WEAPON_SLASH_FLAG, SPELL_BLADE_THIRST, 3);
                if (attrResult)
                {
                    return attrResult;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_KEEN_EDGE))
        {
            if (nLastSpellCast != SPELL_KEEN_EDGE)
            {
                int attrResult = GetBestWeaponBuffTarget(buffSelf, buffOthers, ITEM_PROPERTY_KEEN, -1, HENCH_WEAPON_SLASH_FLAG, SPELL_KEEN_EDGE, 3);
                if (attrResult)
                {
                    return attrResult;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_DARKFIRE))
        {
            if (nLastSpellCast != SPELL_DARKFIRE)
            {
                int attrResult = GetBestWeaponBuffTarget(buffSelf, buffOthers, ITEM_PROPERTY_ONHITCASTSPELL, -1, 0, SPELL_DARKFIRE, 3);
                if (attrResult)
                {
                    return attrResult;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_FLAME_WEAPON))
        {
            if (nLastSpellCast != SPELL_FLAME_WEAPON)
            {
                int attrResult = GetBestWeaponBuffTarget(buffSelf, buffOthers, ITEM_PROPERTY_ONHITCASTSPELL, -1, 0, SPELL_FLAME_WEAPON, 2);
                if (attrResult)
                {
                    return attrResult;
                }
            }
        }
        if (nAreaPosition < 410)
        {
            break;
        }
        if (GetHasFixedSpell(SPELL_BLESS_WEAPON))
        {
            if (nLastSpellCast != SPELL_BLESS_WEAPON)
            {
                int attrResult = GetBestWeaponBuffTarget(buffSelf, buffOthers, -1, 1, 0, SPELL_BLESS_WEAPON, 1);
                if (attrResult)
                {
                    return attrResult;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_MAGIC_WEAPON))
        {
            if (nLastSpellCast != SPELL_MAGIC_WEAPON)
            {
                int attrResult = GetBestWeaponBuffTarget(buffSelf, buffOthers, -1, 1, 0, SPELL_MAGIC_WEAPON, 1);
                if (attrResult)
                {
                    return attrResult;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_DEAFENING_CLANG))
        {
            if (nLastSpellCast != SPELL_DEAFENING_CLANG)
            {
                int attrResult = GetBestWeaponBuffTarget(buffSelf, buffOthers, ITEM_PROPERTY_ONHITCASTSPELL, -1, 0, SPELL_DEAFENING_CLANG, 1);
                if (attrResult)
                {
                    return attrResult;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_RAGE_5))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_RAGE_5)
            {
                if (allowBuffAbilities && bUseMeleeAttackSpells && !GetHasSpellEffect(SPELLABILITY_RAGE_5, OBJECT_SELF))
                {
                    CastSpellAbilityOnObject(SPELLABILITY_RAGE_5, OBJECT_SELF); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_FEROCITY_3))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_FEROCITY_3)
            {
                if (allowBuffAbilities && bUseMeleeAttackSpells && !GetHasSpellEffect(SPELLABILITY_FEROCITY_3, OBJECT_SELF))
                {
                    CastSpellAbilityOnObject(SPELLABILITY_FEROCITY_3, OBJECT_SELF); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_RAGE_4))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_RAGE_4)
            {
                if (allowBuffAbilities && bUseMeleeAttackSpells && !GetHasSpellEffect(SPELLABILITY_RAGE_4, OBJECT_SELF))
                {
                    CastSpellAbilityOnObject(SPELLABILITY_RAGE_4, OBJECT_SELF); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_FEROCITY_2))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_FEROCITY_2)
            {
                if (allowBuffAbilities && bUseMeleeAttackSpells && !GetHasSpellEffect(SPELLABILITY_FEROCITY_2, OBJECT_SELF))
                {
                    CastSpellAbilityOnObject(SPELLABILITY_FEROCITY_2, OBJECT_SELF); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_RAGE_3))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_RAGE_3)
            {
                if (allowBuffAbilities && bUseMeleeAttackSpells && !GetHasSpellEffect(SPELLABILITY_RAGE_3, OBJECT_SELF))
                {
                    CastSpellAbilityOnObject(SPELLABILITY_RAGE_3, OBJECT_SELF); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasSpell(SPELLABILITY_FEROCITY_1))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_FEROCITY_1)
            {
                if (allowBuffAbilities && bUseMeleeAttackSpells && !GetHasSpellEffect(SPELLABILITY_FEROCITY_1, OBJECT_SELF))
                {
                    CastSpellAbilityOnObject(SPELLABILITY_FEROCITY_1, OBJECT_SELF); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFeat(FEAT_STRENGTH_DOMAIN_POWER))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_DIVINE_STRENGTH)
            {
                if (allowBuffAbilities && bUseMeleeAttackSpells && !GetHasFeatEffect(FEAT_STRENGTH_DOMAIN_POWER, OBJECT_SELF))
                {
                    CastSetLastFeatSpellOnObject(FEAT_STRENGTH_DOMAIN_POWER, SPELLABILITY_DIVINE_STRENGTH, OBJECT_SELF); return TK_BUFFSELF;
                }
            }
        }
        if (nAreaPosition < 420)
        {
            break;
        }
        if (GetHasFeat(FEAT_DIVINE_WRATH))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_DC_DIVINE_WRATH)
            {
                if (allowBuffAbilities && bUseMeleeAttackSpells && (!GetHasEffect(EFFECT_TYPE_ATTACK_INCREASE, OBJECT_SELF) || !GetHasEffect(EFFECT_TYPE_DAMAGE_REDUCTION, OBJECT_SELF) || !GetHasEffect(EFFECT_TYPE_SAVING_THROW_INCREASE, OBJECT_SELF)))
                {
                    CastSetLastFeatSpellOnObject(FEAT_DIVINE_WRATH, SPELLABILITY_DC_DIVINE_WRATH, OBJECT_SELF); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFeat(FEAT_BARBARIAN_RAGE))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != FEAT_BARBARIAN_RAGE)
            {
                if (allowBuffAbilities && bUseMeleeAttackSpells && !GetHasFeatEffect(FEAT_BARBARIAN_RAGE, OBJECT_SELF))
                {
                    CastFeatOnObject(FEAT_BARBARIAN_RAGE, OBJECT_SELF); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_BLOOD_FRENZY))
        {
            if (nLastSpellCast != SPELL_BLOOD_FRENZY)
            {
                if (buffSelf && bUseMeleeAttackSpells && !GetHasSpellEffect(SPELL_BLOOD_FRENZY, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_BLOOD_FRENZY, OBJECT_SELF, 2); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_DIVINE_POWER))
        {
            if (nLastSpellCast != SPELL_DIVINE_POWER)
            {
                if (buffSelf && bUseMeleeAttackSpells && !GetHasSpellEffect(SPELL_DIVINE_POWER, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_DIVINE_POWER, OBJECT_SELF, 4); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFeat(FEAT_WAR_DOMAIN_POWER))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != SPELLABILITY_BATTLE_MASTERY)
            {
                if (allowBuffAbilities && bUseMeleeAttackSpells && (!GetHasEffect(EFFECT_TYPE_ATTACK_INCREASE, OBJECT_SELF) || !GetHasEffect(EFFECT_TYPE_DAMAGE_REDUCTION, OBJECT_SELF)))
                {
                    CastSetLastFeatSpellOnObject(FEAT_WAR_DOMAIN_POWER, SPELLABILITY_BATTLE_MASTERY, OBJECT_SELF); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_DIVINE_FAVOR))
        {
            if (nLastSpellCast != SPELL_DIVINE_FAVOR)
            {
                if (buffSelf && bUseMeleeAttackSpells && !GetHasEffect(EFFECT_TYPE_ATTACK_INCREASE, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_DIVINE_FAVOR, OBJECT_SELF, 1); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFeat(FEAT_DIVINE_MIGHT) && GetHasFeat(FEAT_TURN_UNDEAD))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != FEAT_DIVINE_MIGHT && (d100() <= 10))
            {
                if (allowBuffAbilities && bUseMeleeAttackSpells && GetAbilityModifier(ABILITY_CHARISMA) > 0 && !GetHasFeatEffect(FEAT_DIVINE_MIGHT, OBJECT_SELF))
                {
                    CastFeatOnObject(FEAT_DIVINE_MIGHT, OBJECT_SELF); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFeat(FEAT_DIVINE_SHIELD) && GetHasFeat(FEAT_TURN_UNDEAD))
        {
            bFoundSpellGlobal = TRUE;
            if (nLastSpellCast != FEAT_DIVINE_SHIELD)
            {
                if (allowBuffAbilities && bUseMeleeAttackSpells && GetPercentageHPLoss(OBJECT_SELF) < 50 && GetAbilityModifier(ABILITY_CHARISMA) > 0 && !GetHasFeatEffect(FEAT_DIVINE_SHIELD, OBJECT_SELF))
                {
                    CastFeatOnObject(FEAT_DIVINE_SHIELD, OBJECT_SELF); return TK_BUFFSELF;
                }
            }
        }
        if (GetHasFixedSpell(SPELL_TRUE_STRIKE))
        {
            if (nLastSpellCast != SPELL_TRUE_STRIKE)
            {
                if (buffSelf && bUseMeleeAttackSpells && !GetHasEffect(EFFECT_TYPE_ATTACK_INCREASE, OBJECT_SELF))
                {
                    CastSetLastSpellOnObject(SPELL_TRUE_STRIKE, OBJECT_SELF, 1); return TK_BUFFSELF;
                }
            }
        }
//$INSERTIONPOINTEND
        break;
    }
//    Jug_Debug(GetName(OBJECT_SELF) + " targetType " + IntToString(nTargetType) + " nSpell = " + IntToString(nSpell));

    if (!bFoundSpellGlobal && bNoSpellDisabledDueToEffectOrHench)
    {
        // update spell vars
        SetSpellUnknownFlag(HENCH_MAIN_SPELL_SERIES);
    }

    HenchSetLastGenericSpellCast(nSpell);
    if (nTargetType == TARGET_SPELL_AT_LOCATION)
    {
        CastFixedSpellAtLocation(nSpell, areaSpellTargetLoc, nSpellLevel);
        return TK_ATTACK;
    }
    else if (nTargetType == TARGET_SPELL_AREA_ON_OBJECT)
    {
        CastFixedSpellOnObject(nSpell, oAreaSpellTarget, nSpellLevel);
        return TK_ATTACK;
    }
    else if (nTargetType == TARGET_SPELLABILITY_AT_LOCATION)
    {
        CheckDefense(FALSE);
        ActionCastSpellAtLocation(nSpell, areaSpellTargetLoc);
        return TK_ATTACK;
    }
    else if (nTargetType == TARGET_SPELLABILITY_AREA_ON_OBJECT)
    {
        if (nSpell == SPELLABILITY_MINDBLAST)
        {
            ActionDoCommand(SetFacingPoint(GetPositionFromLocation(GetLocation(oAreaSpellTarget))));
            ActionWait(0.5f);
            ActionCastSpellAtObject(nSpell, oAreaSpellTarget, METAMAGIC_ANY,TRUE,0,PROJECTILE_PATH_TYPE_DEFAULT);
        }
        else
        {
                // special case for dragons breath
            if ((nSpell >= SPELLABILITY_DRAGON_BREATH_ACID && nSpell <= SPELLABILITY_DRAGON_BREATH_WEAKEN) ||
                nSpell == SPELLABILITY_DRAGON_BREATH_NEGATIVE || nSpell == SPELL_HENCH_DRAGON_BREATH_Prismatic)
            {
                SetLocalInt(OBJECT_SELF, henchLastDraBrStr, GetLocalInt(OBJECT_SELF, henchCombatRoundStr));
            }
            CheckDefense(FALSE);
            ActionCastSpellAtObject(nSpell, oAreaSpellTarget);
        }
        return TK_ATTACK;
    }
    else if (nTargetType == TARGET_FEAT_ON_OBJECT)
    {
        CheckDefense(FALSE);
        ActionUseFeat(nSpell, oAreaSpellTarget);
        return TK_ATTACK;
    }
    else if (nTargetType == TARGET_FEAT_SPELL_AREA_ON_OBJECT)
    {
        CastSetLastFeatSpellOnObject(nSpell, nSpell2, oAreaSpellTarget);
        return TK_ATTACK;
    }
    else if (nTargetType == TARGET_FEAT_SPELL_AT_LOCATION)
    {
        CastSetLastFeatSpellAtLocation(nSpell, nSpell2, areaSpellTargetLoc);
        return TK_ATTACK;
    }
    HenchSetLastGenericSpellCast(-1);
    return TK_NOSPELL;
}


int CastNoDelaySpellOnObject(int nSpellID, object oTarget)
{
    if(GetHasSpell(nSpellID))
    {
        if(!GetHasSpellEffect(nSpellID, oTarget))
        {
            ActionCastSpellAtObject(nSpellID, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
        }
        return TRUE;
    }
    return FALSE;
}


// ACTIVATE AURAS
int HenchTalentPersistentAbilities()
{
    talent tUse = GetCreatureTalentBest(TALENT_CATEGORY_PERSISTENT_AREA_OF_EFFECT, 20);

    int nSpellID;
    int bFoundMatch = FALSE;
    if(GetIsTalentValid(tUse))
    {
            // quick cast all standard auras, shouldn't have to wait for them to cast
        nSpellID = GetIdFromTalent(tUse);
        if (CastNoDelaySpellOnObject(SPELLABILITY_MUMMY_BOLSTER_UNDEAD, OBJECT_SELF) && nSpellID == SPELLABILITY_MUMMY_BOLSTER_UNDEAD)
        {
            bFoundMatch = TRUE;
        }
        if (CastNoDelaySpellOnObject(SPELLABILITY_DRAGON_FEAR, OBJECT_SELF) && nSpellID == SPELLABILITY_DRAGON_FEAR)
        {
            bFoundMatch = TRUE;
        }
        if (CastNoDelaySpellOnObject(SPELLABILITY_AURA_UNEARTHLY_VISAGE, OBJECT_SELF) && nSpellID == SPELLABILITY_AURA_UNEARTHLY_VISAGE)
        {
            bFoundMatch = TRUE;
        }
        if (CastNoDelaySpellOnObject(SPELLABILITY_AURA_OF_COURAGE, OBJECT_SELF) && nSpellID == SPELLABILITY_AURA_OF_COURAGE)
        {
            bFoundMatch = TRUE;
        }
        if (CastNoDelaySpellOnObject(SPELLABILITY_AURA_PROTECTION, OBJECT_SELF) && nSpellID == SPELLABILITY_AURA_PROTECTION)
        {
            bFoundMatch = TRUE;
        }
        if (CastNoDelaySpellOnObject(SPELLABILITY_AURA_FEAR, OBJECT_SELF) && nSpellID == SPELLABILITY_AURA_FEAR)
        {
            bFoundMatch = TRUE;
        }
        if (CastNoDelaySpellOnObject(SPELLABILITY_AURA_UNNATURAL, OBJECT_SELF) && nSpellID == SPELLABILITY_AURA_UNNATURAL)
        {
            bFoundMatch = TRUE;
        }
        if (CastNoDelaySpellOnObject(SPELLABILITY_AURA_BLINDING, OBJECT_SELF) && nSpellID == SPELLABILITY_AURA_BLINDING)
        {
            bFoundMatch = TRUE;
        }
        if (CastNoDelaySpellOnObject(SPELLABILITY_AURA_STUN, OBJECT_SELF) && nSpellID == SPELLABILITY_AURA_STUN)
        {
            bFoundMatch = TRUE;
        }
        if (CastNoDelaySpellOnObject(SPELLABILITY_AURA_FIRE, OBJECT_SELF) && nSpellID == SPELLABILITY_AURA_FIRE)
        {
            bFoundMatch = TRUE;
        }
        if (CastNoDelaySpellOnObject(SPELLABILITY_AURA_COLD, OBJECT_SELF) && nSpellID == SPELLABILITY_AURA_COLD)
        {
            bFoundMatch = TRUE;
        }
        if (CastNoDelaySpellOnObject(SPELLABILITY_AURA_ELECTRICITY, OBJECT_SELF) && nSpellID == SPELLABILITY_AURA_ELECTRICITY)
        {
            bFoundMatch = TRUE;
        }
        if (CastNoDelaySpellOnObject(SPELLABILITY_TYRANT_FOG_MIST, OBJECT_SELF) && nSpellID == SPELLABILITY_TYRANT_FOG_MIST)
        {
            bFoundMatch = TRUE;
        }
        if (CastNoDelaySpellOnObject(SPELL_HENCH_Aura_of_Hellfire, OBJECT_SELF) && nSpellID == SPELL_HENCH_Aura_of_Hellfire)
        {
            bFoundMatch = TRUE;
        }
        if (CastNoDelaySpellOnObject(SPELLABILITY_AURA_HORRIFICAPPEARANCE, OBJECT_SELF) && nSpellID == SPELLABILITY_AURA_HORRIFICAPPEARANCE)
        {
            bFoundMatch = TRUE;
        }
        if (CastNoDelaySpellOnObject(SPELLABILITY_TROGLODYTE_STENCH, OBJECT_SELF) && nSpellID == SPELLABILITY_TROGLODYTE_STENCH)
        {
            bFoundMatch = TRUE;
        }
        // Nightmare_Smoke
        if (CastNoDelaySpellOnObject(819, OBJECT_SELF) && nSpellID == 819)
        {
            bFoundMatch = TRUE;
        }
        if(!bFoundMatch && !GetHasSpellEffect(nSpellID))
        {
            ActionCastSpellAtObject(nSpellID, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            return TRUE;
        }
        else
        {
            return FALSE;
        }
    }
    return FALSE;
}


struct sPersistSpellInfo GetAOEProblem()
{
    int curLoopCount = 1;
    object oAOE = GetNearestObject(OBJECT_TYPE_AREA_OF_EFFECT, OBJECT_SELF, curLoopCount);
    while (GetIsObjectValid(oAOE) && curLoopCount < 6 && GetDistanceToObject(oAOE) <= 10.0)
    {
        object oAOECreator = GetAreaOfEffectCreator(oAOE);
        int nFriendsAOE;
        if (GetObjectType(oAOECreator) != OBJECT_TYPE_CREATURE)
        {
            oAOECreator = OBJECT_INVALID;
            nFriendsAOE = FALSE;
        }
        else
        {
            nFriendsAOE = GetIsFriend(oAOECreator);
        }

        object oTarget = GetFirstInPersistentObject(oAOE);
        while(GetIsObjectValid(oTarget))
        {
            if (oTarget == OBJECT_SELF)
            {
                break;
            }
            //Get next target in spell area
            oTarget = GetNextInPersistentObject(oAOE);
        }

        if (oTarget == OBJECT_SELF)
        {
            string sAOEName = GetTag(oAOE);

            if (sAOEName == "VFX_PER_FOGACID")
            {
                if (GetDamageDealtByType(DAMAGE_TYPE_ACID) > 0)
                {
                    struct sPersistSpellInfo result;
                    result.oPersistSpell = oAOE;
                    return result;
                }
            }
/* this code won't be run anyway if dazed
            else if (sAOEName == "VFX_PER_FOGSTINK")
            {
                if (!GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_POISON, oAOECreator) &&
                    !GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_DAZED, oAOECreator))
                {
                        // only get out if dazed
                    if (GetHasEffect(EFFECT_TYPE_DAZED))
                    {
                        struct sPersistSpellInfo result;
                        result.oPersistSpell = oAOE;
                        return result;
                    }
                }
            } */
            else if (sAOEName == "VFX_PER_FOGKILL")
            {
                if ((GetHitDice(OBJECT_SELF) < 7 && !GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_DEATH, oAOECreator)) ||
                    (GetDamageDealtByType(DAMAGE_TYPE_ACID) > 0))
                {
                    struct sPersistSpellInfo result;
                    result.oPersistSpell = oAOE;
                    return result;
                }
            }
            else if (sAOEName == "VFX_PER_FOGMIND")
            {
                if (!GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_MIND_SPELLS, oAOECreator))
                {
                    struct sPersistSpellInfo result;
                    result.oPersistSpell = oAOE;
                    result.bDisableMoveAway = TRUE;
                    return result;
                }
            }
            else if ((sAOEName == "VFX_PER_WALLFIRE") || (sAOEName == "AOE_PER_FOGFIRE"))
            {
                if (GetDamageDealtByType(DAMAGE_TYPE_FIRE) > 0)
                {
                    struct sPersistSpellInfo result;
                    result.oPersistSpell = oAOE;
                    return result;
                }
            }
            else if ((sAOEName == "VFX_PER_WEB") || (sAOEName == "VFX_PER_GREASE"))
            {
                if (GetHasAnyEffect2(EFFECT_TYPE_MOVEMENT_SPEED_DECREASE, EFFECT_TYPE_ENTANGLE))
                {
                    struct sPersistSpellInfo result;
                    result.oPersistSpell = oAOE;
                    result.bDisableMoveAway = TRUE;
                    return result;
                }
            }
            else if (sAOEName == "VFX_PER_ENTANGLE")
            {
                if (!nFriendsAOE)
                {
                    if (GetHasEffect(EFFECT_TYPE_ENTANGLE))
                    {
                        struct sPersistSpellInfo result;
                        result.oPersistSpell = oAOE;
                        result.bDisableMoveAway = TRUE;
                        return result;
                    }
                }
            }
            else if (sAOEName == "VFX_PER_DARKNESS")
            {
                if (!GetHasAnyEffect2(EFFECT_TYPE_ULTRAVISION, EFFECT_TYPE_TRUESEEING) &&
                    !GetHasFeat(FEAT_BLINDSIGHT_60_FEET)  && !GetHasFeat(FEAT_BLIND_FIGHT) &&
                    !GetCreatureHasItemProperty(ITEM_PROPERTY_TRUE_SEEING))
                {
                    struct sPersistSpellInfo result;
                    result.oPersistSpell = oAOE;
                    return result;
                }
            }
            else if (sAOEName == "VFX_PER_STORM")
            {
                if (GetIsEnemy(oAOECreator) && (GetDamageDealtByType(DAMAGE_TYPE_ACID | DAMAGE_TYPE_ELECTRICAL) > 0))
                {
                    struct sPersistSpellInfo result;
                    result.oPersistSpell = oAOE;
                    return result;
                }
            }
            else if (sAOEName == "VFX_PER_WALLBLADE")
            {
                struct sPersistSpellInfo result;
                result.oPersistSpell = oAOE;
                return result;
            }
            else if (sAOEName == "VFX_PER_CREEPING_DOOM")
            {
                struct sPersistSpellInfo result;
                result.oPersistSpell = oAOE;
                return result;
            }
            else if (sAOEName == "VFX_PER_EVARDS_BLACK_TENTACLES")
            {
                if (GetCreatureSize(OBJECT_SELF) >= CREATURE_SIZE_MEDIUM)
                {
                    struct sPersistSpellInfo result;
                    result.oPersistSpell = oAOE;
                    return result;
                }
            }
            else if (sAOEName == "VFX_MOB_SILENCE")
            {
                if (GetIsObjectValid(oAOECreator) && !nFriendsAOE && (GetLevelByClass(CLASS_TYPE_WIZARD) > 0 || GetLevelByClass(CLASS_TYPE_SORCERER) > 0))
                {
                    oAOE = oAOECreator;
                }
                struct sPersistSpellInfo result;
                result.oPersistSpell = oAOE;
                return result;
            }
            else if (sAOEName == "VFX_PER_FOGBEWILDERMENT")
            {
                // 2nd level
                if (!GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_POISON, oAOECreator) &&
                    !(GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_BLINDNESS, oAOECreator) &&
                    GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_STUN, oAOECreator)))
                {
                    struct sPersistSpellInfo result;
                    result.oPersistSpell = oAOE;
                    return result;
                }
            }
        }
        curLoopCount++;
        oAOE = GetNearestObject(OBJECT_TYPE_AREA_OF_EFFECT, OBJECT_SELF, curLoopCount);
    }

    struct sPersistSpellInfo result;
    result.oPersistSpell = OBJECT_INVALID;
    return result;
}


int CheckAOEForSelf()
{
    GetBestDispelSpells();

    struct sPersistSpellInfo sPersistInfo = GetAOEProblem();
    object oAOEProblem = sPersistInfo.oPersistSpell;

    if (!GetIsObjectValid(oAOEProblem))
    {
        return FALSE;
    }

    int bUseDispel = TRUE;
    int bInDarkness = FALSE;

    if (GetObjectType(oAOEProblem) == OBJECT_TYPE_CREATURE)
    {
        if (GetIsFriend(oAOEProblem))
        {
            bUseDispel = FALSE;
        }
    }
    else
    {
        if (GetIsFriend(GetAreaOfEffectCreator(oAOEProblem)))
        {
            bUseDispel = FALSE;
        }
        if (GetTag(oAOEProblem) == "VFX_PER_DARKNESS")
        {
            bInDarkness = TRUE;
        }
    }
    if (bUseDispel && GetHasFixedSpell(SPELL_GUST_OF_WIND))
    {
            // Gust of wind should only destroy "cloud/fog like" area of effect spells.
        string sAOETag = GetTag(oAOEProblem);
        if ( sAOETag == "VFX_PER_FOGACID" ||
             sAOETag == "VFX_PER_FOGKILL" ||
             sAOETag == "VFX_PER_FOGBEWILDERMENT" ||
             sAOETag == "VFX_PER_FOGSTINK" ||
             sAOETag == "VFX_PER_FOGFIRE" ||
             sAOETag == "VFX_PER_FOGMIND" ||
             sAOETag == "VFX_PER_CREEPING_DOOM")
        {
            if (GetObjectType(oAOEProblem) == OBJECT_TYPE_CREATURE)
            {
                CastFixedSpellOnObject(SPELL_GUST_OF_WIND, oAOEProblem, 3);
                return TRUE;
            }
            location targetLoc = FindBestDispelLocation(oAOEProblem);
            CastFixedSpellAtLocation(SPELL_GUST_OF_WIND, targetLoc, 3);
            return TRUE;
        }
    }
    if (bUseDispel && iBestDispel && !GetLocalInt(OBJECT_SELF, sHenchDontDispel))
    {
        if (GetObjectType(oAOEProblem) == OBJECT_TYPE_CREATURE)
        {
            CastFixedSpellOnObject(iBestDispel, oAOEProblem, iBestDispelSpellLevel);
            return TRUE;
        }
        location targetLoc = FindBestDispelLocation(oAOEProblem);
        CastFixedSpellAtLocation(iBestDispel, targetLoc, iBestDispelSpellLevel);
        return TRUE;
    }
    if (bInDarkness)
    {
        if (GetHasFixedSpell(SPELL_TRUE_SEEING))
        {
            CastFixedSpellOnObject(SPELL_TRUE_SEEING, OBJECT_SELF, 5);
            return TRUE;
        }
        if (GetHasFixedSpell(SPELL_DARKVISION))
        {
            CastFixedSpellOnObject(SPELL_DARKVISION, OBJECT_SELF, 2);
            return TRUE;
        }
    }
    if (!nGlobalMeleeAttackers && !sPersistInfo.bDisableMoveAway)
    {
            // run away if no melee attackers
        ActionMoveAwayFromLocation(GetLocation(oAOEProblem), TRUE, 10.0);
        return TRUE;
    }
    return FALSE;
}


int HenchTalentInvisible()
{
    if (GetHasFixedSpell(SPELL_INVISIBILITY_SPHERE))
    {
        CastFixedSpellOnObject(SPELL_INVISIBILITY_SPHERE, OBJECT_SELF, 3);
        return TRUE;
    }
    if (GetHasFeat(FEAT_PRESTIGE_INVISIBILITY_1))
    {
        CastFeatOnObject(FEAT_PRESTIGE_INVISIBILITY_1, OBJECT_SELF);
        return TRUE;
    }
    if (GetHasFeat(FEAT_HARPER_INVISIBILITY))
    {
        CastFeatOnObject(FEAT_HARPER_INVISIBILITY, OBJECT_SELF);
        return TRUE;
    }
    if (GetHasFixedSpell(SPELL_INVISIBILITY))
    {
        CastFixedSpellOnObject(SPELL_INVISIBILITY, OBJECT_SELF, 2);
        return TRUE;
    }
    if (GetHasFixedSpell(SPELL_SHADOW_CONJURATION_INIVSIBILITY))
    {
        CastFixedSpellOnObject(SPELL_SHADOW_CONJURATION_INIVSIBILITY, OBJECT_SELF, 4);
        return TRUE;
    }
    return FALSE;
}


int HenchTalentImprovedInvisible()
{
    if (GetHasFeat(FEAT_PRESTIGE_INVISIBILITY_2))
    {
        CastFeatOnObject(FEAT_PRESTIGE_INVISIBILITY_2, OBJECT_SELF);
        return TRUE;
    }
    if (GetHasFeat(FEAT_EMPTY_BODY))
    {
        CastFeatOnObject(FEAT_EMPTY_BODY, OBJECT_SELF);
        return TRUE;
    }
    if (GetHasFixedSpell(SPELL_IMPROVED_INVISIBILITY))
    {
        CastFixedSpellOnObject(SPELL_IMPROVED_INVISIBILITY, OBJECT_SELF, 4);
        return TRUE;
    }
    return FALSE;
}


int StealthCanBeDetected(object oTarget)
{
    if (!GetIsObjectValid(oTarget))
    {
        return FALSE;
    }
    if (GetIsObjectValid(GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_HAS_SPELL_EFFECT, SPELL_TRUE_SEEING)))
    {
        return TRUE;
    }
    if (GetHasFeat(FEAT_BLINDSIGHT_60_FEET, oTarget))
    {
        return TRUE;
    }
    // since GetCreatureHasItemProperty is an expensive call, only do for closest
    if (GetCreatureHasItemProperty(ITEM_PROPERTY_TRUE_SEEING, oTarget))
    {
        return TRUE;
    }
    return FALSE;
}


void HenchTalentStealth(int iMeleeAttackers, int bCheckStealthDetect = TRUE, object oClosestSeen = OBJECT_INVALID)
{
    if (GetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH) || !CheckStealth())
    {
        return;
    }
    if (!GetHasFeat(FEAT_HIDE_IN_PLAIN_SIGHT) && !GetSpawnInCondition(NW_FLAG_STEALTH) &&
        !(GetMonsterOptions(HENCH_MONAI_STEALTH) & HENCH_MONAI_STEALTH))
    {
        return;
    }
    if (bCheckStealthDetect)
    {
        oClosestSeen = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY,
            OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
        if (StealthCanBeDetected(oClosestSeen))
        {
            return;
        }
    }
    if (GetHasFeat(FEAT_HIDE_IN_PLAIN_SIGHT) ||
        (!GetIsObjectValid(oClosestSeen) &&
        !LineOfSightObject(GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY), OBJECT_SELF)))
    {
        // try to sneak up to target
        SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, TRUE);
    }
}


int HenchTalentHide(int iCurEffects, int iMeleeAttackers)
{
    object oClosestSeen = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY,
        OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
    if (iCurEffects & HENCH_HAS_ETHEREAL_EFFECT)
    {
        return FALSE;
    }
    if (GetHasFixedSpell(SPELL_ETHEREALNESS))
    {
        CastFixedSpellOnObject(SPELL_ETHEREALNESS, OBJECT_SELF, 7);
        return TRUE;
    }
    if (StealthCanBeDetected(oClosestSeen))
    {
        return FALSE;
    }
    HenchTalentStealth(iMeleeAttackers, FALSE, oClosestSeen);
    if (!GetIsObjectValid(GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_HAS_SPELL_EFFECT, SPELL_SEE_INVISIBILITY)))
    {
        if (iCurEffects & HENCH_HAS_CONCEALMENT_EFFECT)
        {
            if (!(iCurEffects & HENCH_HAS_INVISIBILITY_EFFECT))
            {
                return HenchTalentInvisible();
            }
            return FALSE;
        }
        if (iCurEffects & HENCH_HAS_INVISIBILITY_EFFECT)
        {
            return FALSE;
        }
        if (HenchTalentImprovedInvisible())
        {
            return TRUE;
        }
        if (HenchTalentInvisible())
        {
            return TRUE;
        }
    }

    if (iCurEffects & HENCH_HAS_SANTUARY_EFFECT)
    {
        return FALSE;
    }
    if (GetHasFeat(FEAT_PROTECTION_DOMAIN_POWER))
    {
        CastSetLastFeatSpellOnObject(FEAT_PROTECTION_DOMAIN_POWER, SPELLABILITY_DIVINE_PROTECTION, OBJECT_SELF);
        return TRUE;
    }
    if (GetHasFixedSpell(SPELL_SANCTUARY))
    {
        CastFixedSpellOnObject(SPELL_SANCTUARY, OBJECT_SELF, 1);
        return TRUE;
    }
    return FALSE;
}


int HenchUseGrenade(object oTarget)
{
    if (CheckFriendlyFireOnTarget(oTarget, RADIUS_SIZE_MEDIUM))
    {
        return FALSE;
    }
    float distance = GetDistanceToObject(oTarget);

    if (distance <= 40.0)
    {
        if (GetHasFixedSpell(SPELL_HENCH_Battle_Boulder_Toss))
        {
            ActionUseTalentOnObject(GetItemTalentSpell(SPELL_HENCH_Battle_Boulder_Toss), oTarget);
            return TRUE;
        }
        if (GetHasSpell(SPELL_HENCH_Giant_hurl_rock))
        {
            ActionCastSpellAtObject(SPELL_HENCH_Giant_hurl_rock, oTarget);
            return TRUE;
        }
    }
    if (distance <= 20.0)
    {
        if (GetHasFixedSpell(SPELL_HENCH_Grenade_FireBomb))
        {
            ActionUseTalentOnObject(GetItemTalentSpell(SPELL_HENCH_Grenade_FireBomb), oTarget);
            return TRUE;
        }
        if (GetHasFixedSpell(SPELL_HENCH_Grenade_AcidBomb))
        {
            ActionUseTalentOnObject(GetItemTalentSpell(SPELL_HENCH_Grenade_AcidBomb), oTarget);
            return TRUE;
        }
        if (GetHasFixedSpell(SPELL_GRENADE_HOLY) && GetRacialType(oTarget) == RACIAL_TYPE_UNDEAD)
        {
            ActionUseTalentOnObject(GetItemTalentSpell(SPELL_GRENADE_HOLY), oTarget);
            return TRUE;
        }
        if (GetHasFixedSpell(SPELL_GRENADE_ACID))
        {
            ActionUseTalentOnObject(GetItemTalentSpell(SPELL_GRENADE_ACID), oTarget);
            return TRUE;
        }
        if (GetHasFixedSpell(SPELL_GRENADE_FIRE))
        {
            ActionUseTalentOnObject(GetItemTalentSpell(SPELL_GRENADE_FIRE), oTarget);
            return TRUE;
        }
        if (GetHasFixedSpell(SPELL_GRENADE_THUNDERSTONE))
        {
            nAreaSpellExtraTargets = 0;

            if (GetTotalEnemyCount(oTarget, 1, SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, 20.0, 0, 15 + nMySpellCasterDCAdjust, HENCH_CHECK_FORT_SAVE, HENCH_AREA_NO_CHECK))
            {
                ActionUseTalentAtLocation(GetItemTalentSpell(SPELL_GRENADE_THUNDERSTONE), areaSpellTargetLoc);
                return TRUE;
            }
        }
        if (GetHasFixedSpell(SPELL_GRENADE_CHOKING))
        {
            nAreaSpellExtraTargets = 0;
            if (GetTotalEnemyCount(oTarget, 1, SHAPE_SPHERE, RADIUS_SIZE_HUGE, 20.0, 0, 15 + nMySpellCasterDCAdjust, HENCH_CHECK_FORT_SAVE, HENCH_AREA_CHECK_DAZE_AND_MIND))
            {
                ActionUseTalentAtLocation(GetItemTalentSpell(SPELL_GRENADE_CHOKING), areaSpellTargetLoc);
                return TRUE;
            }
        }
        if (GetHasFixedSpell(SPELL_GRENADE_TANGLE) && !GetHasEffect(EFFECT_TYPE_ENTANGLE, oTarget) && !GetCreatureFlag(oTarget, CREATURE_VAR_IS_INCORPOREAL))
        {
            ActionUseTalentOnObject(GetItemTalentSpell(SPELL_GRENADE_TANGLE), oTarget);
            return TRUE;
        }
    }
    if (distance <= 8.0)
    {
        if (GetHasFixedSpell(SPELL_GRENADE_CALTROPS))
        {
            nAreaSpellExtraTargets = 0;
            if (GetTotalEnemyCount(oTarget, 1, SHAPE_SPHERE, RADIUS_SIZE_LARGE, 20.0, 0, 15 + nMySpellCasterDCAdjust, HENCH_CHECK_NO_SAVE, HENCH_AREA_NO_CHECK))
            {
                ActionUseTalentAtLocation(GetItemTalentSpell(SPELL_GRENADE_CALTROPS), areaSpellTargetLoc);
                return TRUE;
            }
        }
    }

    return FALSE;
}


// druid and shifter polymorph
int HenchTalentAdvancedPolymorph(int bIsPolymorphed)
{
    // TODO finish this
    /*
 FEAT_GREATER_WILDSHAPE_1,F,S,1,0,,,0,0,,,,,,*,*,*,*,,,1,100,,
FEAT_GREATER_WILDSHAPE_2,F,S,1,0,,,0,0,,,,,,*,*,*,*,,,1,100,,
FEAT_GREATER_WILDSHAPE_3,F,S,1,0,,,0,0,,,,,,*,*,*,*,,,1,100,,
FEAT_GREATER_WILDSHAPE_4,F,S,1,0,,,0,0,,,,,,*,*,*,*,,,1,100,,
FEAT_HUMANOID_SHAPE,F,S,1,0,,,0,0,,,,,,*,*,*,*,,,1,100,,
FEAT_EPIC_WILD_SHAPE_UNDEAD,F,S,1,0,,,0,0,,,,,,*,*,*,*,,,1,100,,
FEAT_EPIC_WILD_SHAPE_DRAGON,F,S,1,0,,,0,0,,,,,,*,*,*,*,,,1,100,,
  */

    return FALSE;
}


int HenchTalentPolymorph()
{
    /*
    if (!GetLocalInt(GetModule(),"X3_NO_SHAPESHIFT_SPELL_CHECK"))
    { // check to see if abort due to being mounted
        if (HorseGetIsMounted(OBJECT_SELF))
        { // abort
            return FALSE;
        } // abort
    } // check to see if abort due to being mounted
    */
    // note: do not need to check for potions for polymorph
    if (GetHasSpell(SPELL_SHAPECHANGE) && GetHasFixedSpell(SPELL_SHAPECHANGE))
    {
//        GetBestAttribBuff(TRUE, FALSE, -1, TRUE);
        CheckDefense(TRUE);
        CheckCastingMode(9, SPELL_SHAPECHANGE);
        int nSpell;
        switch (d8())
        {
        case 1:
        case 2:
            nSpell = 392;
            break;
        case 3:
            nSpell = 393;
            break;
        case 4:
        case 5:
            nSpell = 394;
            break;
        case 6:
            nSpell = 395;
            break;
        default:
            nSpell = 396;
        }
        ActionCastSpellAtObject(nSpell, OBJECT_SELF, METAMAGIC_ANY, TRUE);
        DecrementRemainingSpellUses(OBJECT_SELF, SPELL_SHAPECHANGE);
        return TRUE;
    }
    if (GetHasFeat(FEAT_ELEMENTAL_SHAPE))
    {
//        GetBestAttribBuff(TRUE, FALSE, -1, TRUE);
        CheckDefense(FALSE);
        ActionCastSpellAtObject(396 + d4(), OBJECT_SELF, METAMAGIC_NONE, TRUE);
        DecrementRemainingFeatUses(OBJECT_SELF, FEAT_ELEMENTAL_SHAPE);
        return TRUE;
    }
/*
    this spell doesn't work for non PC now
    if (GetHasFixedSpell(SPELL_TENSERS_TRANSFORMATION))
    {
//        GetBestAttribBuff(TRUE, FALSE, -1, TRUE);
        CheckDefense(TRUE);
        CastFixedSpellOnObject(SPELL_TENSERS_TRANSFORMATION, OBJECT_SELF, 6);
        return TRUE;
    } */
    // the ones below are weaker, only do some of the time
    if (d20() == 1 && GetHasFeat(FEAT_WILD_SHAPE))
    {
        int nSpell;
        switch (d8())
        {
        case 1:
        case 2:
        case 3:
            nSpell = 401;
            break;
        case 4:
        case 5:
            nSpell = 402;
            break;
        case 6:
            nSpell = 403;
            break;
        case 7:
            nSpell = 404;
            break;
        default:
            nSpell = 405;
        }
//        GetBestAttribBuff(TRUE, FALSE, -1, TRUE);
        CheckDefense(FALSE);
        ActionCastSpellAtObject(nSpell, OBJECT_SELF, METAMAGIC_NONE, TRUE);
        DecrementRemainingFeatUses(OBJECT_SELF, FEAT_WILD_SHAPE);
        return TRUE;
    }
    if (d20() == 1 && GetHasSpell(SPELL_POLYMORPH_SELF) && GetHasFixedSpell(SPELL_POLYMORPH_SELF))
    {
//        GetBestAttribBuff(TRUE, FALSE, -1, TRUE);
        CheckDefense(TRUE);
        CheckCastingMode(4, SPELL_POLYMORPH_SELF);
        int nSpell;
        switch (d8())
        {
        case 1:
            nSpell = 387;
            break;
        case 2:
        case 3:
        case 4:
            nSpell = 388;
            break;
        case 5:
        case 6:
            nSpell = 389;
            break;
        case 7:
            nSpell = 390;
            break;
        default:
            nSpell = 391;
        }
        ActionCastSpellAtObject(nSpell, OBJECT_SELF, METAMAGIC_ANY, TRUE);
        DecrementRemainingSpellUses(OBJECT_SELF, SPELL_POLYMORPH_SELF);
        return TRUE;
    }
    return FALSE;
}

