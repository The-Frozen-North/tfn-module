/* COMBAT2 Library by Gigaschatten */

//void main() {}

//#include "gs_inc_flag"

//required aid constants
const int GS_C2_GREATER_RESTORATION           = 0x00000001;
const int GS_C2_RESTORATION                   = 0x00000002;
const int GS_C2_LESSER_RESTORATION            = 0x00000004;
const int GS_C2_STONE_TO_FLESH                = 0x00000008;
const int GS_C2_FREEDOM_OF_MOVEMENT           = 0x00000010;
const int GS_C2_REMOVE_PARALYSIS              = 0x00000020;
const int GS_C2_MIND_BLANK                    = 0x00000040;
const int GS_C2_LESSER_MIND_BLANK             = 0x00000080;
const int GS_C2_CLARITY                       = 0x00000100;
const int GS_C2_REMOVE_BLINDNESS_AND_DEAFNESS = 0x00000200;
const int GS_C2_REMOVE_FEAR                   = 0x00000400;
const int GS_C2_NEUTRALIZE_POISON             = 0x00000800;
const int GS_C2_REMOVE_DISEASE                = 0x00001000;
const int GS_C2_REMOVE_CURSE                  = 0x00002000;

//counter measure constants
const int GS_C2_TRUE_SEEING                   = 0x00000001;
const int GS_C2_SEE_INVISIBILITY              = 0x00000002;
const int GS_C2_INVISIBILITY_PURGE            = 0x00000004;

const string GS_C2_ANALYZE                    = "GS_C2_1";
const string GS_C2_DAMAGED                    = "GS_C2_2";
const string GS_C2_BREACHABLE_SPELL           = "GS_C2_3";
const string GS_C2_EFFECT_BALANCE             = "GS_C2_4";
const string GS_C2_EFFECT_REQUIRED_AID        = "GS_C2_5";
const string GS_C2_EFFECT_COUNTER_MEASURE     = "GS_C2_6";
const string GS_C2_EFFECT_LIST                = "GS_C2_7";
const string GS_C2_HIGHEST_DAMAGER            = "GS_C2_8";
const string GS_C2_HIGHEST_DAMAGE             = "GS_C2_9";
const string GS_C2_HIGHEST_DAMAGE_TYPE        = "GS_C2_10";
const string GS_C2_HIGHEST_DAMAGE_BY_TYPE     = "GS_C2_11";
const string GS_C2_LAST_DAMAGER               = "GS_C2_12";
const string GS_C2_LAST_DAMAGE                = "GS_C2_13";
const string GS_C2_LAST_DAMAGE_TYPE           = "GS_C2_14";

const string GS_C2_SPELL_EFFECTIVENESS        = "GS_C2_SE_";

int gsC2BreachableSpellNth                    = 0;
int gsC2DamageTypeNth                         = 0;

struct gsC2Effect
{
    int nBalance;
    int nRequiredAid;
    int nCounterMeasure;
    string sList;
};

//analyze oCreature
void gsC2Analyze(object oCreature = OBJECT_SELF);
//return TRUE if oCreature is damaged
int gsC2GetIsDamaged(object oCreature = OBJECT_SELF);
//return required aid of oCreature
int gsC2GetRequiredAid(object oCreature = OBJECT_SELF);
//return counter measure for oCreature
int gsC2GetCounterMeasure(object oCreature = OBJECT_SELF);
//return TRUE if oCreature is affected by nEffect
int gsC2GetHasEffect(int nEffect, object oCreature = OBJECT_SELF);
//return value reflecting effect balance of oCreature
int gsC2GetEffectBalance(object oCreature = OBJECT_SELF);
//return highest Damager of oCreature
object gsC2GetHighestDamager(object oCreature = OBJECT_SELF);
//return highest damage type dealt to oCreature
int gsC2GetHighestDamageType(object oCreature = OBJECT_SELF);
//return last damager of oCreature
object gsC2GetLastDamager(object oCreature = OBJECT_SELF);
//return effect information on oCreature
struct gsC2Effect gsC2GetEffect(object oCreature = OBJECT_SELF);
//return TRUE if oCreature is affected by spells that can be removed by spell breach
int gsC2GetHasBreachableSpell(object oCreature = OBJECT_SELF);
//return TRUE if oCreature is affected by spells that can be removed by spell breach
int gsC2GetBreachableSpell(object oCreature = OBJECT_SELF);
//return first spell that can be removed by spell breach
int gsC2GetFirstBreachableSpell();
//return next spell that can be removed by spell breach
int gsC2GetNextBreachableSpell();
//set damage values for caller
void gsC2SetDamage();
//clear damage values for caller
void gsC2ClearDamage();
//return first damage type
int gsC2GetFirstDamageType();
//return next damage type
int gsC2GetNextDamageType();
//return TRUE if nSpell is rated effective on oCreature
int gsC2GetIsSpellEffective(int nSpell, object oCreature);
//adjust if nSpell is nEffective on oCreature
void gsC2AdjustSpellEffectiveness(int nSpell, object oCreature, int nEffective = TRUE);

void gsC2Analyze(object oCreature = OBJECT_SELF)
{
    if (GetLocalInt(oCreature, GS_C2_ANALYZE)) return;

    struct gsC2Effect stEffect = gsC2GetEffect(oCreature);

    SetLocalInt(
        oCreature,
        GS_C2_DAMAGED,
        GetCurrentHitPoints(oCreature) < GetMaxHitPoints(oCreature) * 2 / 3);

    SetLocalInt(
        oCreature,
        GS_C2_BREACHABLE_SPELL,
        gsC2GetBreachableSpell(oCreature));

    SetLocalInt(
        oCreature,
        GS_C2_EFFECT_BALANCE,
        stEffect.nBalance);
    SetLocalInt(
        oCreature,
        GS_C2_EFFECT_REQUIRED_AID,
        stEffect.nRequiredAid);
    SetLocalInt(
        oCreature,
        GS_C2_EFFECT_COUNTER_MEASURE,
        stEffect.nCounterMeasure);
    SetLocalString(
        oCreature,
        GS_C2_EFFECT_LIST,
        stEffect.sList);

    SetLocalInt(oCreature, GS_C2_ANALYZE, TRUE);
    AssignCommand(oCreature, DelayCommand(6.0, DeleteLocalInt(oCreature, GS_C2_ANALYZE)));
}
//----------------------------------------------------------------
int gsC2GetIsDamaged(object oCreature = OBJECT_SELF)
{
    gsC2Analyze(oCreature);
    return GetLocalInt(oCreature, GS_C2_DAMAGED);
}
//----------------------------------------------------------------
int gsC2GetRequiredAid(object oCreature = OBJECT_SELF)
{
    gsC2Analyze(oCreature);
    return GetLocalInt(oCreature, GS_C2_EFFECT_REQUIRED_AID);
}
//----------------------------------------------------------------
int gsC2GetCounterMeasure(object oCreature = OBJECT_SELF)
{
    gsC2Analyze(oCreature);
    return GetLocalInt(oCreature, GS_C2_EFFECT_COUNTER_MEASURE);
}
//----------------------------------------------------------------
int gsC2GetHasEffect(int nEffect, object oCreature = OBJECT_SELF)
{
    gsC2Analyze(oCreature);
    string sList = GetLocalString(oCreature, GS_C2_EFFECT_LIST);
    return GetSubString(sList, nEffect, 1) == "1";
}
//----------------------------------------------------------------
int gsC2GetEffectBalance(object oCreature = OBJECT_SELF)
{
    gsC2Analyze(oCreature);
    return GetLocalInt(oCreature, GS_C2_EFFECT_BALANCE);
}
//----------------------------------------------------------------
object gsC2GetHighestDamager(object oCreature = OBJECT_SELF)
{
    return GetLocalObject(oCreature, GS_C2_HIGHEST_DAMAGER);
}
//----------------------------------------------------------------
int gsC2GetHighestDamageType(object oCreature = OBJECT_SELF)
{
    return GetLocalInt(oCreature, GS_C2_HIGHEST_DAMAGE_TYPE);
}
//----------------------------------------------------------------
object gsC2GetLastDamager(object oCreature = OBJECT_SELF)
{
    return GetLocalObject(oCreature, GS_C2_LAST_DAMAGER);
}
//----------------------------------------------------------------
struct gsC2Effect gsC2GetEffect(object oCreature = OBJECT_SELF)
{
    struct gsC2Effect stEffect;
    stEffect.sList    = "00000000000000000000000000000000000000000000000000" +
                        "00000000000000000000000000000000000000000000000000";
    effect eEffect    = GetFirstEffect(oCreature);
    int nType         = 0;

    while (GetIsEffectValid(eEffect))
    {
        if (GetEffectSubType(eEffect) != SUBTYPE_EXTRAORDINARY)
        {
            nType          = GetEffectType(eEffect);
            stEffect.sList = GetStringLeft(stEffect.sList, nType) +
                             "1" +
                             GetStringRight(stEffect.sList, 99 - nType);

            switch (nType)
            {
            case EFFECT_TYPE_ABILITY_DECREASE:
                stEffect.nBalance--;
                stEffect.nRequiredAid    |= GS_C2_GREATER_RESTORATION |
                                            GS_C2_RESTORATION |
                                            GS_C2_LESSER_RESTORATION;
                break;

            case EFFECT_TYPE_ABILITY_INCREASE:
                stEffect.nBalance++;
                break;

            case EFFECT_TYPE_AC_DECREASE:
                stEffect.nBalance--;
                stEffect.nRequiredAid    |= GS_C2_GREATER_RESTORATION |
                                            GS_C2_RESTORATION |
                                            GS_C2_LESSER_RESTORATION;
                break;

            case EFFECT_TYPE_AC_INCREASE:
                stEffect.nBalance++;
                break;

            case EFFECT_TYPE_ARCANE_SPELL_FAILURE:
                stEffect.nBalance--;
                break;

            case EFFECT_TYPE_AREA_OF_EFFECT:
                break;

            case EFFECT_TYPE_ATTACK_DECREASE:
                stEffect.nBalance--;
                stEffect.nRequiredAid    |= GS_C2_GREATER_RESTORATION |
                                            GS_C2_RESTORATION |
                                            GS_C2_LESSER_RESTORATION;
                break;

            case EFFECT_TYPE_ATTACK_INCREASE:
                stEffect.nBalance++;
                break;

            case EFFECT_TYPE_BEAM:
                break;

            case EFFECT_TYPE_BLINDNESS:
                stEffect.nBalance--;
                stEffect.nRequiredAid    |= GS_C2_GREATER_RESTORATION |
                                            GS_C2_RESTORATION |
                                            GS_C2_REMOVE_BLINDNESS_AND_DEAFNESS;
                break;

            case EFFECT_TYPE_CHARMED:
                stEffect.nBalance--;
                stEffect.nRequiredAid    |= GS_C2_GREATER_RESTORATION |
                                            GS_C2_MIND_BLANK |
                                            GS_C2_LESSER_MIND_BLANK |
                                            GS_C2_CLARITY;
                break;

            case EFFECT_TYPE_CONCEALMENT:
                stEffect.nBalance++;
                break;

            case EFFECT_TYPE_CONFUSED:
                stEffect.nBalance--;
                stEffect.nRequiredAid    |= GS_C2_GREATER_RESTORATION |
                                            GS_C2_MIND_BLANK |
                                            GS_C2_LESSER_MIND_BLANK |
                                            GS_C2_CLARITY;
                break;

            case EFFECT_TYPE_CURSE:
                stEffect.nBalance--;
                stEffect.nRequiredAid    |= GS_C2_GREATER_RESTORATION |
                                            GS_C2_REMOVE_CURSE;
                break;

            case EFFECT_TYPE_CUTSCENE_PARALYZE:
                break;

            case EFFECT_TYPE_CUTSCENEGHOST:
                break;

            case EFFECT_TYPE_CUTSCENEIMMOBILIZE:
                break;

            case EFFECT_TYPE_DAMAGE_DECREASE:
                stEffect.nBalance--;
                stEffect.nRequiredAid    |= GS_C2_GREATER_RESTORATION |
                                            GS_C2_RESTORATION |
                                            GS_C2_LESSER_RESTORATION;
                break;

            case EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE:
                stEffect.nBalance--;
                stEffect.nRequiredAid    |= GS_C2_GREATER_RESTORATION |
                                            GS_C2_RESTORATION |
                                            GS_C2_LESSER_RESTORATION;
                break;

            case EFFECT_TYPE_DAMAGE_IMMUNITY_INCREASE:
                stEffect.nBalance++;
                break;

            case EFFECT_TYPE_DAMAGE_INCREASE:
                stEffect.nBalance++;
                break;

            case EFFECT_TYPE_DAMAGE_REDUCTION:
                stEffect.nBalance++;
                break;

            case EFFECT_TYPE_DAMAGE_RESISTANCE:
                stEffect.nBalance++;
                break;

            case EFFECT_TYPE_DARKNESS:
                stEffect.nBalance--;
                break;

            case EFFECT_TYPE_DAZED:
                stEffect.nBalance--;
                stEffect.nRequiredAid    |= GS_C2_GREATER_RESTORATION |
                                            GS_C2_MIND_BLANK |
                                            GS_C2_LESSER_MIND_BLANK |
                                            GS_C2_CLARITY;
                break;

            case EFFECT_TYPE_DEAF:
                stEffect.nBalance--;
                stEffect.nRequiredAid    |= GS_C2_GREATER_RESTORATION |
                                            GS_C2_RESTORATION |
                                            GS_C2_REMOVE_BLINDNESS_AND_DEAFNESS;
                break;

            case EFFECT_TYPE_DISAPPEARAPPEAR:
                break;

            case EFFECT_TYPE_DISEASE:
                stEffect.nBalance--;
                stEffect.nRequiredAid    |= GS_C2_GREATER_RESTORATION |
                                            GS_C2_REMOVE_DISEASE;
                break;

            case EFFECT_TYPE_DISPELMAGICALL:
                break;

            case EFFECT_TYPE_DISPELMAGICBEST:
                break;

            case EFFECT_TYPE_DOMINATED:
                stEffect.nBalance--;
                stEffect.nRequiredAid    |= GS_C2_GREATER_RESTORATION |
                                            GS_C2_MIND_BLANK |
                                            GS_C2_LESSER_MIND_BLANK;
                break;

            case EFFECT_TYPE_ELEMENTALSHIELD:
                stEffect.nBalance++;
                break;

            case EFFECT_TYPE_ENEMY_ATTACK_BONUS:
                break;

            case EFFECT_TYPE_ENTANGLE:
                stEffect.nBalance--;
                stEffect.nRequiredAid    |= GS_C2_FREEDOM_OF_MOVEMENT;
                break;

            case EFFECT_TYPE_ETHEREAL:
                stEffect.nBalance++;
                stEffect.nCounterMeasure |= GS_C2_TRUE_SEEING;
                break;

            case EFFECT_TYPE_FRIGHTENED:
                stEffect.nBalance--;
                stEffect.nRequiredAid    |= GS_C2_GREATER_RESTORATION |
                                            GS_C2_REMOVE_FEAR;
                break;

            case EFFECT_TYPE_HASTE:
                stEffect.nBalance++;
                break;

            case EFFECT_TYPE_IMMUNITY:
                stEffect.nBalance++;
                break;

            case EFFECT_TYPE_IMPROVEDINVISIBILITY:
                stEffect.nBalance++;
                stEffect.nCounterMeasure |= GS_C2_TRUE_SEEING |
                                            GS_C2_SEE_INVISIBILITY |
                                            GS_C2_INVISIBILITY_PURGE;
                break;

            case EFFECT_TYPE_INVISIBILITY:
                stEffect.nBalance++;
                stEffect.nCounterMeasure |= GS_C2_TRUE_SEEING |
                                            GS_C2_SEE_INVISIBILITY |
                                            GS_C2_INVISIBILITY_PURGE;
                break;

            case EFFECT_TYPE_INVULNERABLE:
                stEffect.nBalance++;
                break;

            case EFFECT_TYPE_MISS_CHANCE:
                stEffect.nBalance--;
                break;

            case EFFECT_TYPE_MOVEMENT_SPEED_DECREASE:
                stEffect.nBalance--;
                stEffect.nRequiredAid    |= GS_C2_FREEDOM_OF_MOVEMENT;
                break;

            case EFFECT_TYPE_MOVEMENT_SPEED_INCREASE:
                stEffect.nBalance++;
                break;

            case EFFECT_TYPE_NEGATIVELEVEL:
                stEffect.nBalance--;
                stEffect.nRequiredAid    |= GS_C2_GREATER_RESTORATION |
                                            GS_C2_RESTORATION;
                break;

            case EFFECT_TYPE_PARALYZE:
                stEffect.nBalance--;
                stEffect.nRequiredAid    |= GS_C2_GREATER_RESTORATION |
                                            GS_C2_RESTORATION |
                                            GS_C2_FREEDOM_OF_MOVEMENT |
                                            GS_C2_REMOVE_PARALYSIS;
                break;

            case EFFECT_TYPE_PETRIFY:
                stEffect.nBalance--;
                stEffect.nRequiredAid    |= GS_C2_STONE_TO_FLESH;
                break;

            case EFFECT_TYPE_POISON:
                stEffect.nBalance--;
                stEffect.nRequiredAid    |= GS_C2_GREATER_RESTORATION |
                                            GS_C2_NEUTRALIZE_POISON;
                break;

            case EFFECT_TYPE_POLYMORPH:
                stEffect.nBalance++;
                break;

            case EFFECT_TYPE_REGENERATE:
                stEffect.nBalance++;
                break;

            case EFFECT_TYPE_RESURRECTION:
                break;

            case EFFECT_TYPE_SANCTUARY:
                stEffect.nBalance++;
                stEffect.nCounterMeasure |= GS_C2_TRUE_SEEING;
                break;

            case EFFECT_TYPE_SAVING_THROW_DECREASE:
                stEffect.nBalance--;
                stEffect.nRequiredAid    |= GS_C2_GREATER_RESTORATION |
                                            GS_C2_RESTORATION |
                                            GS_C2_LESSER_RESTORATION;
                break;

            case EFFECT_TYPE_SAVING_THROW_INCREASE:
                stEffect.nBalance++;
                break;

            case EFFECT_TYPE_SEEINVISIBLE:
                stEffect.nBalance++;
                break;

            case EFFECT_TYPE_SILENCE:
                stEffect.nBalance--;
                break;

            case EFFECT_TYPE_SKILL_DECREASE:
                stEffect.nBalance--;
                stEffect.nRequiredAid    |= GS_C2_GREATER_RESTORATION |
                                            GS_C2_RESTORATION |
                                            GS_C2_LESSER_RESTORATION;
                break;

            case EFFECT_TYPE_SKILL_INCREASE:
                stEffect.nBalance++;
                break;

            case EFFECT_TYPE_SLEEP:
                stEffect.nBalance--;
                stEffect.nRequiredAid    |= GS_C2_MIND_BLANK |
                                            GS_C2_LESSER_MIND_BLANK |
                                            GS_C2_CLARITY;
                break;

            case EFFECT_TYPE_SLOW:
                stEffect.nBalance--;
                stEffect.nRequiredAid    |= GS_C2_GREATER_RESTORATION |
                                            GS_C2_FREEDOM_OF_MOVEMENT;
                break;

            case EFFECT_TYPE_SPELL_FAILURE:
                stEffect.nBalance--;
                break;

            case EFFECT_TYPE_SPELL_IMMUNITY:
                stEffect.nBalance++;
                break;

            case EFFECT_TYPE_SPELL_RESISTANCE_DECREASE:
                stEffect.nBalance--;
                stEffect.nRequiredAid    |= GS_C2_GREATER_RESTORATION |
                                            GS_C2_RESTORATION |
                                            GS_C2_LESSER_RESTORATION;
                break;

            case EFFECT_TYPE_SPELL_RESISTANCE_INCREASE:
                stEffect.nBalance++;
                break;

            case EFFECT_TYPE_SPELLLEVELABSORPTION:
                stEffect.nBalance++;
                break;

            case EFFECT_TYPE_STUNNED:
                stEffect.nBalance--;
                stEffect.nRequiredAid    |= GS_C2_GREATER_RESTORATION |
                                            GS_C2_MIND_BLANK |
                                            GS_C2_LESSER_MIND_BLANK |
                                            GS_C2_CLARITY;
                break;

            case EFFECT_TYPE_SWARM:
                break;

            case EFFECT_TYPE_TEMPORARY_HITPOINTS:
                stEffect.nBalance++;
                break;

            case EFFECT_TYPE_TRUESEEING:
                stEffect.nBalance++;
                break;

            case EFFECT_TYPE_TURN_RESISTANCE_DECREASE:
                stEffect.nBalance--;
                break;

            case EFFECT_TYPE_TURN_RESISTANCE_INCREASE:
                stEffect.nBalance++;
                break;

            case EFFECT_TYPE_TURNED:
                stEffect.nBalance--;
                break;

            case EFFECT_TYPE_ULTRAVISION:
                stEffect.nBalance++;
                break;

            case EFFECT_TYPE_VISUALEFFECT:
                break;
            }
        }

        eEffect = GetNextEffect(oCreature);
    }

    return stEffect;
}
//----------------------------------------------------------------
int gsC2GetHasBreachableSpell(object oCreature = OBJECT_SELF)
{
    gsC2Analyze(oCreature);
    return GetLocalInt(oCreature, GS_C2_BREACHABLE_SPELL);
}
//----------------------------------------------------------------
int gsC2GetBreachableSpell(object oCreature = OBJECT_SELF)
{
    int nSpell = gsC2GetFirstBreachableSpell();

    while (nSpell != -1)
    {
        if (GetHasSpellEffect(nSpell, oCreature)) return TRUE;
        nSpell = gsC2GetNextBreachableSpell();
    }

    return FALSE;
}
//----------------------------------------------------------------
int gsC2GetFirstBreachableSpell()
{
    gsC2BreachableSpellNth = 0;
    return gsC2GetNextBreachableSpell();
}
//----------------------------------------------------------------
int gsC2GetNextBreachableSpell()
{
    switch (++gsC2BreachableSpellNth)
    {
    case  1: return SPELL_GREATER_SPELL_MANTLE;
    case  2: return SPELL_PREMONITION;
    case  3: return SPELL_SPELL_MANTLE;
    case  4: return SPELL_SHADOW_SHIELD;
    case  5: return SPELL_GREATER_STONESKIN;
    case  6: return SPELL_ETHEREAL_VISAGE;
    case  7: return SPELL_GLOBE_OF_INVULNERABILITY;
    case  8: return SPELL_ENERGY_BUFFER;
    case  9: return SPELL_ETHEREALNESS;
    case 10: return SPELL_MINOR_GLOBE_OF_INVULNERABILITY;
    case 11: return SPELL_SPELL_RESISTANCE;
    case 12: return SPELL_STONESKIN;
    case 13: return SPELL_LESSER_SPELL_MANTLE;
    case 14: return SPELL_MESTILS_ACID_SHEATH;
    case 15: return SPELL_MIND_BLANK;
    case 16: return SPELL_ELEMENTAL_SHIELD;
    case 17: return SPELL_PROTECTION_FROM_SPELLS;
    case 18: return SPELL_PROTECTION_FROM_ELEMENTS;
    case 19: return SPELL_RESIST_ELEMENTS;
    case 20: return SPELL_DEATH_ARMOR;
    case 21: return SPELL_GHOSTLY_VISAGE;
    case 22: return SPELL_ENDURE_ELEMENTS;
    case 23: return SPELL_SHADOW_SHIELD;
    case 24: return SPELL_SHADOW_CONJURATION_MAGE_ARMOR;
    case 25: return SPELL_NEGATIVE_ENERGY_PROTECTION;
    case 26: return SPELL_SANCTUARY;
    case 27: return SPELL_MAGE_ARMOR;
    case 28: return SPELL_STONE_BONES;
    case 29: return SPELL_SHIELD;
    case 30: return SPELL_SHIELD_OF_FAITH;
    case 31: return SPELL_LESSER_MIND_BLANK;
    case 32: return SPELL_IRONGUTS;
    case 33: return SPELL_RESISTANCE;
    }

    return -1;
}
//----------------------------------------------------------------
void gsC2SetDamage()
{
    object oHighestDamager   = GetLocalObject(OBJECT_SELF, GS_C2_HIGHEST_DAMAGER);
    int nHighestDamage       = 0;
    int nHighestDamageType   = 0;
    int nHighestDamageByType = 0;

    if (GetIsObjectValid(oHighestDamager) &&
        GetArea(oHighestDamager) == GetArea(OBJECT_SELF) &&
        GetDistanceToObject(oHighestDamager) <= 60.0)
    {
        nHighestDamage       = GetLocalInt(OBJECT_SELF, GS_C2_HIGHEST_DAMAGE);
        nHighestDamageType   = GetLocalInt(OBJECT_SELF, GS_C2_HIGHEST_DAMAGE_TYPE);
        nHighestDamageByType = GetLocalInt(OBJECT_SELF, GS_C2_HIGHEST_DAMAGE_BY_TYPE);
    }

    object oLastDamager      = GetLastDamager();
    int nLastDamage          = GetTotalDamageDealt();
    int nLastDamageType      = 0;

    int nDamageType          = gsC2GetFirstDamageType();
    int nDamageByType        = 0;

    if (nLastDamage > nHighestDamage)
    {
        oHighestDamager = oLastDamager;
        nHighestDamage  = nLastDamage;
    }

    while (nDamageType != -1)
    {
        nDamageByType = GetDamageDealtByType(nDamageType);

        if (nDamageByType > 0)
        {
            nLastDamageType |= nDamageType;

            if (nDamageByType > nHighestDamageByType)
            {
                nHighestDamageType   = nDamageType;
                nHighestDamageByType = nDamageByType;
            }
        }

        nDamageType = gsC2GetNextDamageType();
    }

    SetLocalObject(OBJECT_SELF, GS_C2_HIGHEST_DAMAGER, oHighestDamager);
    SetLocalInt(OBJECT_SELF, GS_C2_HIGHEST_DAMAGE, nHighestDamage);
    SetLocalInt(OBJECT_SELF, GS_C2_HIGHEST_DAMAGE_TYPE, nHighestDamageType);
    SetLocalInt(OBJECT_SELF, GS_C2_HIGHEST_DAMAGE_BY_TYPE, nHighestDamageByType);

    SetLocalObject(OBJECT_SELF, GS_C2_LAST_DAMAGER, oLastDamager);
    SetLocalInt(OBJECT_SELF, GS_C2_LAST_DAMAGE, nLastDamage);
    SetLocalInt(OBJECT_SELF, GS_C2_LAST_DAMAGE_TYPE, nLastDamageType);
}
//----------------------------------------------------------------
void gsC2ClearDamage()
{
    DeleteLocalObject(OBJECT_SELF, GS_C2_HIGHEST_DAMAGER);
    DeleteLocalInt(OBJECT_SELF, GS_C2_HIGHEST_DAMAGE);
    DeleteLocalInt(OBJECT_SELF, GS_C2_HIGHEST_DAMAGE_TYPE);
    DeleteLocalInt(OBJECT_SELF, GS_C2_HIGHEST_DAMAGE_BY_TYPE);

    DeleteLocalObject(OBJECT_SELF, GS_C2_LAST_DAMAGER);
    DeleteLocalInt(OBJECT_SELF, GS_C2_LAST_DAMAGE);
    DeleteLocalInt(OBJECT_SELF, GS_C2_LAST_DAMAGE_TYPE);
}
//----------------------------------------------------------------
int gsC2GetFirstDamageType()
{
    gsC2DamageTypeNth = 0;
    return gsC2GetNextDamageType();
}
//----------------------------------------------------------------
int gsC2GetNextDamageType()
{
    switch (++gsC2DamageTypeNth)
    {
    case  1: return DAMAGE_TYPE_ACID;
    case  2: return DAMAGE_TYPE_BLUDGEONING;
    case  3: return DAMAGE_TYPE_COLD;
    case  4: return DAMAGE_TYPE_DIVINE;
    case  5: return DAMAGE_TYPE_ELECTRICAL;
    case  6: return DAMAGE_TYPE_FIRE;
    case  7: return DAMAGE_TYPE_MAGICAL;
    case  8: return DAMAGE_TYPE_NEGATIVE;
    case  9: return DAMAGE_TYPE_PIERCING;
    case 10: return DAMAGE_TYPE_POSITIVE;
    case 11: return DAMAGE_TYPE_SLASHING;
    case 12: return DAMAGE_TYPE_SONIC;
    }

    return -1;
}
//----------------------------------------------------------------
int gsC2GetIsSpellEffective(int nSpell, object oCreature)
{
    string sString = GS_C2_SPELL_EFFECTIVENESS + IntToString(nSpell);
    return Random(11) > GetLocalInt(oCreature, sString);
}
//----------------------------------------------------------------
void gsC2AdjustSpellEffectiveness(int nSpell, object oCreature, int nEffective = TRUE)
{
    string sString      = GS_C2_SPELL_EFFECTIVENESS + IntToString(nSpell);
    int nEffectiveness  = GetLocalInt(oCreature, sString);

    nEffectiveness     += nEffective ? -3 : 1;
    if (nEffectiveness > 9)      nEffectiveness = 9;
    else if (nEffectiveness < 0) nEffectiveness = 0;

    SetLocalInt(oCreature, sString, nEffectiveness);

    //debug
    //AssignCommand(oCreature, SpeakString(nEffective ? "spell effective" : "spell ineffective"));
}

