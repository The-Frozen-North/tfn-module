/*/////////////////////// [Include - Set Effects] //////////////////////////////
    Filename: J_INC_SetEffects
///////////////////////// [Include - Set Effects] //////////////////////////////
    This can be executed on a PC or NPC, and sets what thier current effects
    are - the hostile ones.

    It is executed on a PC every 6 seconds in combat, delayed by a timer,
    by other NPCs who want to target them.

    It is meant to be more efficient then doing countless checks against other
    NPCs and PCs for what effects they already have on them.
///////////////////////// [History] ////////////////////////////////////////////
    1.3 - Added
    1.4 - Changed so fear and stun was seperate.
          Uncommandable still is now for any uncommandable effects.

        - TO DO
        - Make the ability decrease into "light" "major" and so on, about 4
          ratings, each set as more decreases are present.
///////////////////////// [Workings] ///////////////////////////////////////////
    ExecuteScript - might not work faster. If so, it is easy to add into the
    generic AI and have oTarget to set to.

    It searches the code and sets 3 custom integers, but only once (so not
    during the loop)
///////////////////////// [Arguments] //////////////////////////////////////////
    Arguments: N/A
///////////////////////// [Include - Set Effects] ////////////////////////////*/

#include "inc_hai_constant"

// List (use Global to not conflict with the nwscript.nss!)
const int GlobalEffectUncommandable               = 0x00000001;// Stun. Sleep. Fear. Turning. Paralsis. Petrify.
const int GlobalEffectSilenced                    = 0x00000002;// Eeek!
const int GlobalEffectSlowed                      = 0x00000004;// Stop with haste.
const int GlobalEffectUltravision                 = 0x00000008;
const int GlobalEffectSeeInvisible                = 0x00000010; // NOT Inc. Trueseeing
const int GlobalEffectTrueSeeing                  = 0x00000020;
const int GlobalEffectTimestop                    = 0x00000040;
const int GlobalEffectInvisible                   = 0x00000080;
const int GlobalEffectDeaf                        = 0x00000100;// Ack!
const int GlobalEffectHaste                       = 0x00000200;
const int GlobalEffectPolymorph                   = 0x00000400;// Only attack
const int GlobalEffectBlindness                   = 0x00000800;// Oh no! Cannot see others to cast spells.
const int GlobalEffectDisease                     = 0x00001000;
const int GlobalEffectPoison                      = 0x00002000;
const int GlobalEffectCurse                       = 0x00004000;
const int GlobalEffectNegativeLevel               = 0x00008000;
const int GlobalEffectEntangle                    = 0x00010000;
const int GlobalEffectMovementSpeedDecrease       = 0x00020000;
const int GlobalEffectDarkness                    = 0x00040000;// Noo! Need ultravision!
const int GlobalEffectDazed                       = 0x00080000;// Special: 1.30 patch, we can move!
const int GlobalEffectEthereal                    = 0x00100000;
const int GlobalEffectPetrify                     = 0x00200000;
const int GlobalEffectParalyze                    = 0x00400000;// Divided from Uncommandable for healing of
const int GlobalEffectSpellFailure                = 0x00800000;// Makes sure spells are not cast under high failure.
const int GlobalEffectDamageShield                = 0x01000000;// All damage shields
const int GlobalEffectFear                        = 0x02000000;// 1.4. Remove fear + G.Rest. Removes.
const int GlobalEffectStun                        = 0x04000000;// 1.4. G.Rest. Removes.
//int GlobalEffectAbilityDecrease = 0; // In combat include

// These are Globals for spell effects, to not csat them on us again, and to
// speed things up...
// These are *good* spells. This effect is only set up on us.
const int GlobalHasStoneSkinProtections           = 0x00000001;
const int GlobalHasElementalProtections           = 0x00000002;
const int GlobalHasVisageProtections              = 0x00000004;
const int GlobalHasMantalProtections              = 0x00000008;
const int GlobalHasGlobeProtections               = 0x00000010;
const int GlobalHasMindResistanceProtections      = 0x00000020;
const int GlobalHasAidingSpell                    = 0x00000040;
const int GlobalHasRangedConsealment              = 0x00000080;
const int GlobalHasRageSpells                     = 0x00000100;
const int GlobalHasBullsStrengthSpell             = 0x00000200;
const int GlobalHasCatsGraceSpell                 = 0x00000400;
const int GlobalHasClairaudienceSpell             = 0x00000800;
const int GlobalHasDeathWardSpell                 = 0x00001000;
const int GlobalHasDivinePowerSpell               = 0x00002000;
const int GlobalHasEaglesSpledorSpell             = 0x00004000;
const int GlobalHasEnduranceSpell                 = 0x00008000;
const int GlobalHasFoxesCunningSpell              = 0x00010000;
const int GlobalHasProtectionEvilSpell            = 0x00020000;
const int GlobalHasProtectionGoodSpell            = 0x00040000;
const int GlobalHasLightSpell                     = 0x00080000;
const int GlobalHasConsealmentSpells              = 0x00100000;// Displacement
const int GlobalHasProtectionSpellsSpell          = 0x00200000;
const int GlobalHasRegenerateSpell                = 0x00400000;
const int GlobalHasOwlsWisdomSpell                = 0x00800000;
const int GlobalHasSpellResistanceSpell           = 0x01000000;
const int GlobalHasSpellWarCrySpell               = 0x02000000;
//const int GlobalHasElementalShieldSpell           = 0x04000000;// Is general effect
const int GlobalHasDomainSpells                   = 0x08000000;
const int GlobalHasDeflectionACSpell              = 0x10000000;
const int GlobalHasNaturalACSpell                 = 0x20000000;
const int GlobalHasOtherACSpell                   = 0x40000000;
const int GlobalHasWeaponHelpSpell                = 0x80000000;

// Other, AOE ones
//const int GlobalHasAreaEffectDamaging             = 0x04000000;
//const int GlobalHasAreaEffectImpeding             = 0x08000000;

int TempEffectHex, TempSpellHex;

// Sets up an effects thing to that
void AI_SetTargetHasEffect(int nEffectHex);
// Sets we have spell iSpellHex's effects.
void AI_SetWeHaveSpellsEffect(int nSpellHex);
// Sets up effects on oTarget
void AI_SetEffectsOnTarget(object oTarget = OBJECT_SELF);


// Simple return TRUE if it matches hex.
// - Effects tested on oTarget
int AI_GetAIHaveEffect(int nEffectHex, object oTarget = OBJECT_SELF);
// Simple return TRUE if it matches hex.
// * Can only be used on ourself.
int AI_GetAIHaveSpellsEffect(int nSpellHex);

// Sets up an effects thing to that
void AI_SetTargetHasEffect(int nEffectHex)
{
    TempEffectHex = TempEffectHex | nEffectHex;
}
// Sets we have spell iSpellHex's effects.
void AI_SetWeHaveSpellsEffect(int nSpellHex)
{
    TempSpellHex = TempSpellHex | nSpellHex;
}

// Simple return TRUE if it matches hex.
// - Effects tested on oTarget
int AI_GetAIHaveEffect(int nEffectHex, object oTarget = OBJECT_SELF)
{
    return (GetLocalInt(oTarget, AI_EFFECT_HEX) & nEffectHex);

}
// Simple return TRUE if it matches hex.
// * Can only be used on ourself.
int AI_GetAIHaveSpellsEffect(int nSpellHex)
{
    return (GetLocalInt(OBJECT_SELF, AI_SPELL_HEX) & nSpellHex);
}

// Sets up effects on oTarget
void AI_SetEffectsOnTarget(object oTarget = OBJECT_SELF)
{
    TempEffectHex = FALSE;
    TempSpellHex = FALSE;
    // Checks our effects once.
    effect eCheck = GetFirstEffect(oTarget);
    int nEffect, nEffectAbilityDecrease, nSpellID;
    // EFFECTS:
    // For ALL targets (that we will use), we set up effects on a system of Hexes.
    // like spawn in things. Replaces GetHasSpellEffect, except genralising -
    // IE we will NOT cast more than one of the stoneskin type things at once.
    while(GetIsEffectValid(eCheck))
    {
        nEffect = GetEffectType(eCheck);
        switch(nEffect)
        {
            case EFFECT_TYPE_INVALIDEFFECT:
            case EFFECT_TYPE_VISUALEFFECT:
                // Don't check these for spell values.
            break;
            case EFFECT_TYPE_PARALYZE: // Also makes you uncommandable
            {
                AI_SetTargetHasEffect(GlobalEffectParalyze);
                AI_SetTargetHasEffect(GlobalEffectUncommandable);
            }
            break;
            case EFFECT_TYPE_STUNNED: // Also makes you uncommandable
            {
                AI_SetTargetHasEffect(GlobalEffectStun);
                AI_SetTargetHasEffect(GlobalEffectUncommandable);
            }
            break;
            case EFFECT_TYPE_FRIGHTENED: // Also makes you uncommandable
            {
                AI_SetTargetHasEffect(GlobalEffectFear);
                AI_SetTargetHasEffect(GlobalEffectUncommandable);
            }
            break;
            // * Cannot remove these, but make you unable to move.
            case EFFECT_TYPE_SLEEP:
            case EFFECT_TYPE_TURNED:
            case EFFECT_TYPE_DISAPPEARAPPEAR:// Added for dragon flying
            case EFFECT_TYPE_CONFUSED:// 1.4 added. wasn't in before
                AI_SetTargetHasEffect(GlobalEffectUncommandable);
            break;
            case EFFECT_TYPE_DAZED:
                AI_SetTargetHasEffect(GlobalEffectDazed);
            break;
            case EFFECT_TYPE_SILENCE:
                AI_SetTargetHasEffect(GlobalEffectSilenced);
            break;
            case EFFECT_TYPE_SLOW:
                AI_SetTargetHasEffect(GlobalEffectSlowed);
            break;
            case EFFECT_TYPE_ULTRAVISION:
                AI_SetTargetHasEffect(GlobalEffectUltravision);
            break;
            case EFFECT_TYPE_SEEINVISIBLE:
                AI_SetTargetHasEffect(GlobalEffectSeeInvisible);
            break;
            // Caused by Beholder things mainly, but this stops any spell being
            // cast, not just, for example, arcane spells cast in armor.
            case EFFECT_TYPE_SPELL_FAILURE:
                AI_SetTargetHasEffect(GlobalEffectSpellFailure);
            break;
            // Penetrates darkness.
            case EFFECT_TYPE_TRUESEEING:
                AI_SetTargetHasEffect(GlobalEffectTrueSeeing);
            break;
            // Timestop - IE don't cast same spell twice.
            case EFFECT_TYPE_TIMESTOP:
                AI_SetTargetHasEffect(GlobalEffectTimestop);
            break;
            // Invisibility/Improved (although improved only uses normal in the spell)
            // Sneak attack/whatever :-)
            // - include the spell EFFECT_TYPE_ETHEREAL.
            case EFFECT_TYPE_INVISIBILITY:
            case EFFECT_TYPE_IMPROVEDINVISIBILITY:
                AI_SetTargetHasEffect(GlobalEffectInvisible);
            break;
            // Deaf - spell failing of 20%, but still cast.
            case EFFECT_TYPE_DEAF:
                AI_SetTargetHasEffect(GlobalEffectDeaf);
            break;
            // Special invis.
            case EFFECT_TYPE_ETHEREAL:
                 AI_SetTargetHasEffect(GlobalEffectEthereal);
            break;
            // Haste - so don't cast haste again and whatever.
            case EFFECT_TYPE_HASTE:
                AI_SetTargetHasEffect(GlobalEffectHaste);
            break;
            // Haste - so don't cast haste again and whatever.
            case EFFECT_TYPE_POLYMORPH:
                AI_SetTargetHasEffect(GlobalEffectPolymorph);
            break;
            // Blindness - oh no, can't see, only hear!
            case EFFECT_TYPE_BLINDNESS:
                AI_SetTargetHasEffect(GlobalEffectBlindness);
            break;
            // Damage shield = Elemental shield, wounding whispers, Death armor, mestals
            // sheth and so on.
            case EFFECT_TYPE_ELEMENTALSHIELD:
                AI_SetTargetHasEffect(GlobalEffectDamageShield);
            break;
            // Things we may want to remove VIA cirtain spells, we set here - may as well.
            // Same setting as any other.
            // IF we can remove it (not confusion ETC of course) then we set it.
            case EFFECT_TYPE_DISEASE:
                AI_SetTargetHasEffect(GlobalEffectDisease);
            break;
            case EFFECT_TYPE_POISON:
                AI_SetTargetHasEffect(GlobalEffectPoison);
            break;
            // SoU Petrify
            // Note: Also makes them uncommandable
            case EFFECT_TYPE_PETRIFY:
            {
                AI_SetTargetHasEffect(GlobalEffectPetrify);
                AI_SetTargetHasEffect(GlobalEffectUncommandable);
            }
            break;
            case EFFECT_TYPE_CURSE:
                AI_SetTargetHasEffect(GlobalEffectCurse);
            break;
            case EFFECT_TYPE_NEGATIVELEVEL:
                AI_SetTargetHasEffect(GlobalEffectNegativeLevel);
            break;
            case EFFECT_TYPE_ABILITY_DECREASE:
            case EFFECT_TYPE_AC_DECREASE:
            case EFFECT_TYPE_ATTACK_DECREASE:
            case EFFECT_TYPE_DAMAGE_DECREASE:
            case EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE:
            case EFFECT_TYPE_SAVING_THROW_DECREASE:
            case EFFECT_TYPE_SPELL_RESISTANCE_DECREASE:
            case EFFECT_TYPE_SKILL_DECREASE:
                // Special - we add one to this, to determine when to use restoration
                nEffectAbilityDecrease++;
            break;
            case EFFECT_TYPE_ENTANGLE:
                AI_SetTargetHasEffect(GlobalEffectEntangle);
            break;
            case EFFECT_TYPE_MOVEMENT_SPEED_DECREASE:
                AI_SetTargetHasEffect(GlobalEffectMovementSpeedDecrease);
            break;
            case EFFECT_TYPE_DARKNESS:
                AI_SetTargetHasEffect(GlobalEffectDarkness);
            break;
            default:
            {
                // Check spells *we* (1.4 change: now checks OBJECT_SELF)
                // have on...so we don't cast over them!
                nSpellID = GetEffectSpellId(eCheck);
                if(nSpellID != -1 && oTarget == OBJECT_SELF)
                {
                    switch(nSpellID)
                    {
                        // All weapon things are on one variable. We cast the best.
                        case SPELL_MAGIC_WEAPON:
                        case SPELL_BLESS_WEAPON:
                        case SPELL_FLAME_WEAPON:
                        case SPELL_GREATER_MAGIC_WEAPON:
                        case SPELL_BLACKSTAFF:
                        case SPELL_BLADE_THIRST:
                            AI_SetWeHaveSpellsEffect(GlobalHasWeaponHelpSpell);
                        break;
                        case SPELL_ENDURE_ELEMENTS:
                        case SPELL_ENERGY_BUFFER:
                        case SPELL_RESIST_ELEMENTS:
                        case SPELL_PROTECTION_FROM_ELEMENTS:
                            AI_SetWeHaveSpellsEffect(GlobalHasElementalProtections);
                        break;
                        case SPELL_BARKSKIN:
                        case SPELL_STONE_BONES: // +3 to undead
                            AI_SetWeHaveSpellsEffect(GlobalHasNaturalACSpell);
                        break;
                        case SPELL_SHIELD:
                        case SPELL_DIVINE_SHIELD:
                            AI_SetWeHaveSpellsEffect(GlobalHasDeflectionACSpell);
                        break;
                        case SPELL_EPIC_MAGE_ARMOR:// Epic spell +20 to AC.
                        case SPELL_MAGE_ARMOR:
                            AI_SetWeHaveSpellsEffect(GlobalHasOtherACSpell);
                        break;
                        case SPELL_ENTROPIC_SHIELD:
                            AI_SetWeHaveSpellsEffect(GlobalHasRangedConsealment);
                        break;
                        case AI_SPELL_EPIC_WARDING:
                        case SPELL_STONESKIN:
                        case SPELL_GREATER_STONESKIN:
                        case SPELL_PREMONITION:
                        case SPELL_SHADES_STONESKIN: // Stoneskin one: 342
                            AI_SetWeHaveSpellsEffect(GlobalHasStoneSkinProtections);
                        break;
                        case SPELL_GHOSTLY_VISAGE:
                        case SPELL_SHADOW_SHIELD:
                        case SPELL_ETHEREAL_VISAGE:
                        case SPELL_GREATER_SHADOW_CONJURATION_MIRROR_IMAGE: //  one: 351 is gostly visage. Speeds up not using number
                        case SPELL_SHADOW_EVADE: // Shadow dancer
                        case SPELLABILITY_AS_GHOSTLY_VISAGE: // Assassin
                            AI_SetWeHaveSpellsEffect(GlobalHasVisageProtections);
                        break;
                        case SPELL_GREATER_SPELL_MANTLE:
                        case SPELL_SPELL_MANTLE:
                        case SPELL_LESSER_SPELL_MANTLE:
                            AI_SetWeHaveSpellsEffect(GlobalHasMantalProtections);
                        break;
                        case SPELL_MINOR_GLOBE_OF_INVULNERABILITY:
                        case SPELL_GLOBE_OF_INVULNERABILITY:
                        case SPELL_GREATER_SHADOW_CONJURATION_MINOR_GLOBE:
                            AI_SetWeHaveSpellsEffect(GlobalHasGlobeProtections);
                        break;
                        case SPELL_AID:
                        case SPELL_PRAYER:
                        case SPELL_BLESS:
                            AI_SetWeHaveSpellsEffect(GlobalHasAidingSpell);
                        break;
                        case SPELL_BULLS_STRENGTH:
                        case SPELL_GREATER_BULLS_STRENGTH:
                        case SPELLABILITY_BG_BULLS_STRENGTH:  // Blackguard
                            AI_SetWeHaveSpellsEffect(GlobalHasBullsStrengthSpell);
                        break;
                        case SPELL_CATS_GRACE:
                        case SPELL_GREATER_CATS_GRACE:
                        case AI_SPELLABILITY_HARPER_CATS_GRACE:  // Harper
                            AI_SetWeHaveSpellsEffect(GlobalHasCatsGraceSpell);
                        break;
                        case SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE:
                            AI_SetWeHaveSpellsEffect(GlobalHasClairaudienceSpell);
                        break;
                        case SPELL_CLARITY:
                        case SPELL_LESSER_MIND_BLANK:
                        case SPELL_MIND_BLANK:
                            AI_SetWeHaveSpellsEffect(GlobalHasMindResistanceProtections);
                        break;
                        case SPELL_DEATH_WARD:
                        case SPELL_UNDEATHS_ETERNAL_FOE:// Similar to death ward. Got more things.
                            AI_SetWeHaveSpellsEffect(GlobalHasDeathWardSpell);
                        break;
                        case SPELL_DISPLACEMENT:// 50% consealment
                            AI_SetWeHaveSpellsEffect(GlobalHasConsealmentSpells);
                        break;
                        case SPELL_DIVINE_POWER:
                            AI_SetWeHaveSpellsEffect(GlobalHasDivinePowerSpell);
                        break;
                        case SPELL_EAGLE_SPLEDOR:
                        case SPELL_GREATER_EAGLE_SPLENDOR:
                        case AI_SPELLABILITY_HARPER_EAGLE_SPLEDOR: // Harper
                            AI_SetWeHaveSpellsEffect(GlobalHasEaglesSpledorSpell);
                        break;
                        case SPELL_ENDURANCE:
                        case SPELL_GREATER_ENDURANCE:
                            AI_SetWeHaveSpellsEffect(GlobalHasEnduranceSpell);
                        break;
                        case SPELL_FOXS_CUNNING:
                        case SPELL_GREATER_FOXS_CUNNING:
                            AI_SetWeHaveSpellsEffect(GlobalHasFoxesCunningSpell);
                        break;
                        case SPELL_HOLY_AURA:
                        case SPELL_MAGIC_CIRCLE_AGAINST_EVIL:
                        case SPELL_PROTECTION_FROM_EVIL:
                            AI_SetWeHaveSpellsEffect(GlobalHasProtectionEvilSpell);
                        break;
                        case SPELL_UNHOLY_AURA:
                        case SPELL_MAGIC_CIRCLE_AGAINST_GOOD:
                        case SPELL_PROTECTION_FROM_GOOD:
                            AI_SetWeHaveSpellsEffect(GlobalHasProtectionGoodSpell);
                        break;
                        case SPELL_LIGHT:
                        case SPELL_CONTINUAL_FLAME:
                            AI_SetWeHaveSpellsEffect(GlobalHasLightSpell);
                        break;
                        case SPELL_OWLS_WISDOM:
                        case SPELL_GREATER_OWLS_WISDOM:
                        case AI_SPELL_OWLS_INSIGHT:// Missed spell
                            AI_SetWeHaveSpellsEffect(GlobalHasOwlsWisdomSpell);
                        break;
                        case SPELL_PROTECTION_FROM_SPELLS:
                            AI_SetWeHaveSpellsEffect(GlobalHasProtectionSpellsSpell);
                        break;
                        case SPELL_REGENERATE:
                            AI_SetWeHaveSpellsEffect(GlobalHasRegenerateSpell);
                        break;
                        case SPELL_SPELL_RESISTANCE:
                            AI_SetWeHaveSpellsEffect(GlobalHasSpellResistanceSpell);
                        break;
                        case SPELL_WAR_CRY:
                            AI_SetWeHaveSpellsEffect(GlobalHasSpellWarCrySpell);
                        break;
                        case SPELLABILITY_DIVINE_PROTECTION:
                        case SPELLABILITY_DIVINE_STRENGTH:
                        case SPELLABILITY_DIVINE_TRICKERY:
                        case SPELLABILITY_BATTLE_MASTERY:
                            AI_SetWeHaveSpellsEffect(GlobalHasDomainSpells);
                        break;
                        case SPELLABILITY_RAGE_3:
                        case SPELLABILITY_RAGE_4:
                        case SPELLABILITY_RAGE_5:
                        case SPELLABILITY_BARBARIAN_RAGE:
                        case SPELLABILITY_INTENSITY_1:
                        case SPELLABILITY_INTENSITY_2:
                        case SPELLABILITY_INTENSITY_3:
                        case SPELLABILITY_FEROCITY_1:
                        case SPELLABILITY_FEROCITY_2:
                        case SPELLABILITY_FEROCITY_3:
                        case SPELL_BLOOD_FRENZY:
                            AI_SetWeHaveSpellsEffect(GlobalHasRageSpells);
                        break;
                    }
                }
            }
            break;
        }
        eCheck = GetNextEffect(oTarget);
    }
    // If undead, set some immunities by default
    if(GetRacialType(oTarget) == RACIAL_TYPE_UNDEAD)
    {
        AI_SetWeHaveSpellsEffect(GlobalHasDeathWardSpell);
    }
    DeleteLocalInt(oTarget, AI_ABILITY_DECREASE);
    DeleteLocalInt(oTarget, AI_EFFECT_HEX);
    // Special - only we set spell hexs on ourselves.
    if(oTarget == OBJECT_SELF)
    {
        DeleteLocalInt(oTarget, AI_SPELL_HEX);
        SetLocalInt(oTarget, AI_SPELL_HEX, TempSpellHex);
    }
    // Set final ones from temp integers
    SetLocalInt(oTarget, AI_ABILITY_DECREASE, nEffectAbilityDecrease);
    SetLocalInt(oTarget, AI_EFFECT_HEX, TempEffectHex);
}

