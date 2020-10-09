/* COMBAT3 Library by Gigaschatten */

#include "inc_ai_combat2"

//void main() {}

//return TRUE if nFeat can be used on oTarget
int gsC3VerifyFeat(int nFeat, object oTarget = OBJECT_SELF);
//return TRUE if nSpell can/should be used on oTarget
int gsC3VerifySpell(int nSpell, object oTarget = OBJECT_SELF);

int gsC3VerifyFeat(int nFeat, object oTarget = OBJECT_SELF)
{
    if (! GetHasFeat(nFeat))              return FALSE;
    if (GetHasFeatEffect(nFeat, oTarget)) return FALSE;

    object oObject = OBJECT_INVALID;

    switch (nFeat)
    {
    //summon allies
    case FEAT_ANIMATE_DEAD:
    case FEAT_EPIC_SPELL_MUMMY_DUST:
    case FEAT_SUMMON_GREATER_UNDEAD:
    case FEAT_SUMMON_SHADOW:
    case FEAT_SUMMON_UNDEAD:
        return ! GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_SUMMONED));

    case FEAT_ANIMAL_COMPANION:
        return ! GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION));

    case FEAT_SUMMON_FAMILIAR:
        return ! GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_FAMILIAR));

    //melee
    case FEAT_DISARM:
        oObject = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTarget);
        return GetIsObjectValid(oObject) && ! GetWeaponRanged(oObject);

    case FEAT_KNOCKDOWN:
        return GetCreatureSize(OBJECT_SELF) >= GetCreatureSize(oTarget);

    case FEAT_IMPROVED_KNOCKDOWN:
        return GetCreatureSize(OBJECT_SELF) + 1 >= GetCreatureSize(oTarget);

    case FEAT_SAP:
    case FEAT_STUNNING_FIST:
        switch (GetRacialType(oTarget))
        {
        case RACIAL_TYPE_CONSTRUCT:
        case RACIAL_TYPE_ELEMENTAL:
        case RACIAL_TYPE_UNDEAD:
        case RACIAL_TYPE_VERMIN:
            return FALSE;
        }
    }

    return TRUE;
}
//----------------------------------------------------------------
int gsC3VerifySpell(int nSpell, object oTarget = OBJECT_SELF)
{
    if (! GetHasSpell(nSpell))                      return FALSE;
    if (! gsC2GetIsSpellEffective(nSpell, oTarget)) return FALSE;
    if (GetHasSpellEffect(nSpell, oTarget))         return FALSE;

    switch (nSpell)
    {
    //summon allies
    case SPELL_ANIMATE_DEAD:
    case SPELL_BLACK_BLADE_OF_DISASTER:
    case SPELL_CREATE_GREATER_UNDEAD:
    case SPELL_CREATE_UNDEAD:
    case SPELL_ELEMENTAL_SWARM:
    case SPELL_GREATER_PLANAR_BINDING:
    case SPELL_GREATER_SHADOW_CONJURATION_SUMMON_SHADOW:
    case SPELL_MORDENKAINENS_SWORD:
    case SPELL_PLANAR_ALLY:
    case SPELL_PLANAR_BINDING:
    case SPELL_SHADES_SUMMON_SHADOW:
    case SPELL_SHADOW_CONJURATION_SUMMON_SHADOW:
    case SPELL_SHELGARNS_PERSISTENT_BLADE:
    case SPELL_SUMMON_CREATURE_I:
    case SPELL_SUMMON_CREATURE_II:
    case SPELL_SUMMON_CREATURE_III:
    case SPELL_SUMMON_CREATURE_IV:
    case SPELL_SUMMON_CREATURE_IX:
    case SPELL_SUMMON_CREATURE_V:
    case SPELL_SUMMON_CREATURE_VI:
    case SPELL_SUMMON_CREATURE_VII:
    case SPELL_SUMMON_CREATURE_VIII:
    case SPELL_SUMMON_SHADOW:
    case SPELLABILITY_BG_CREATEDEAD:
    case SPELLABILITY_BG_FIENDISH_SERVANT:
    case SPELLABILITY_PM_ANIMATE_DEAD:
    case SPELLABILITY_PM_SUMMON_GREATER_UNDEAD:
    case SPELLABILITY_PM_SUMMON_UNDEAD:
    case SPELLABILITY_SUMMON_CELESTIAL:
    case SPELLABILITY_SUMMON_MEPHIT:
    case SPELLABILITY_SUMMON_SLAAD:
    case SPELLABILITY_SUMMON_TANARRI:
        return ! GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_SUMMONED));

    case SPELLABILITY_SUMMON_ANIMAL_COMPANION:
        return ! GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION));

    case SPELLABILITY_SUMMON_FAMILIAR:
        return ! GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_FAMILIAR));

    case SPELL_GATE:
        return GetHasSpellEffect(SPELL_PROTECTION_FROM_EVIL);

    //spell breach
    case SPELL_LESSER_SPELL_BREACH:
    case SPELL_GREATER_SPELL_BREACH:
        return gsC2GetHasBreachableSpell(oTarget);

    //dispel magic
    case SPELL_DISPEL_MAGIC:
    case SPELL_GREATER_DISPELLING:
    case SPELL_LESSER_DISPEL:
    case SPELL_MORDENKAINENS_DISJUNCTION:
        return gsC2GetEffectBalance(oTarget) > Random(4);

    //person
    case SPELL_CHARM_PERSON:
    case SPELL_DOMINATE_PERSON:
    case SPELL_HOLD_PERSON:
        switch (GetRacialType(oTarget))
        {
        case RACIAL_TYPE_DWARF:
        case RACIAL_TYPE_ELF:
        case RACIAL_TYPE_GNOME:
        case RACIAL_TYPE_HALFELF:
        case RACIAL_TYPE_HALFLING:
        case RACIAL_TYPE_HALFORC:
        case RACIAL_TYPE_HUMAN:
        case RACIAL_TYPE_HUMANOID_GOBLINOID:
        case RACIAL_TYPE_HUMANOID_MONSTROUS:
        case RACIAL_TYPE_HUMANOID_ORC:
        case RACIAL_TYPE_HUMANOID_REPTILIAN:
            return TRUE;
        }

        return FALSE;

    //animal
    case SPELL_DOMINATE_ANIMAL:
    case SPELL_HOLD_ANIMAL:
        return GetRacialType(oTarget) == RACIAL_TYPE_ANIMAL;

    //person or animal
    case SPELL_CHARM_PERSON_OR_ANIMAL:
        switch (GetRacialType(oTarget))
        {
        case RACIAL_TYPE_ANIMAL:
        case RACIAL_TYPE_DWARF:
        case RACIAL_TYPE_ELF:
        case RACIAL_TYPE_GNOME:
        case RACIAL_TYPE_HALFELF:
        case RACIAL_TYPE_HALFLING:
        case RACIAL_TYPE_HALFORC:
        case RACIAL_TYPE_HUMAN:
        case RACIAL_TYPE_HUMANOID_GOBLINOID:
        case RACIAL_TYPE_HUMANOID_MONSTROUS:
        case RACIAL_TYPE_HUMANOID_ORC:
        case RACIAL_TYPE_HUMANOID_REPTILIAN:
            return TRUE;
        }

        return FALSE;

    //living
    case SPELL_DROWN:
    case SPELLABILITY_PULSE_DROWN:
        switch (GetRacialType(oTarget))
        {
        case RACIAL_TYPE_CONSTRUCT:
        case RACIAL_TYPE_ELEMENTAL:
        case RACIAL_TYPE_UNDEAD:
            return FALSE;
        }

        return TRUE;

    //undead
    case SPELL_CONTROL_UNDEAD:
    case SPELL_STONE_BONES:
    case SPELL_UNDEATH_TO_DEATH:
        return GetRacialType(oTarget) == RACIAL_TYPE_UNDEAD;

    //associate
    case SPELL_BANISHMENT:
        return GetAssociateType(oTarget) != ASSOCIATE_TYPE_NONE;

    //animal companion
    case SPELL_AWAKEN:
        return GetAssociateType(oTarget) == ASSOCIATE_TYPE_ANIMALCOMPANION;

    //negative energy
    case SPELL_CIRCLE_OF_DOOM:
    case SPELL_HARM:
    case SPELL_INFLICT_CRITICAL_WOUNDS:
    case SPELL_INFLICT_LIGHT_WOUNDS:
    case SPELL_INFLICT_MINOR_WOUNDS:
    case SPELL_INFLICT_MODERATE_WOUNDS:
    case SPELL_INFLICT_SERIOUS_WOUNDS:
    case SPELL_NEGATIVE_ENERGY_BURST:
    case SPELL_NEGATIVE_ENERGY_RAY:
    case SPELL_VAMPIRIC_TOUCH:
        switch (GetRacialType(oTarget))
        {
        case RACIAL_TYPE_UNDEAD:
            return FALSE;
        }

        return TRUE;

    //power word
    case SPELL_POWER_WORD_KILL:
        return GetCurrentHitPoints(oTarget) <= 100;

    case SPELL_POWER_WORD_STUN:
        return GetCurrentHitPoints(oTarget) <= 150;

    //mind affecting
    case SPELL_CHARM_MONSTER:
    case SPELL_CLOAK_OF_CHAOS:
    case SPELL_CLOUD_OF_BEWILDERMENT:
    case SPELL_CONFUSION:
    case SPELL_DAZE:
    case SPELL_DOMINATE_MONSTER:
    case SPELL_FEAR:
    case SPELL_HOLD_MONSTER:
    case SPELL_MASS_CHARM:
    case SPELL_MIND_FOG:
    case SPELL_SLEEP:
    case SPELL_SPHERE_OF_CHAOS:
    case SPELL_WEIRD:
    case SPELLABILITY_DRAGON_BREATH_FEAR:
    case SPELLABILITY_GAZE_FEAR:
    case SPELLABILITY_HOWL_FEAR:
        switch (GetRacialType(oTarget))
        {
        case RACIAL_TYPE_CONSTRUCT:
        case RACIAL_TYPE_UNDEAD:
            return FALSE;
        }

        if (nSpell == SPELL_DAZE && GetHitDice(oTarget) > 5) return FALSE;

        return TRUE;
    }

    return TRUE;
}

