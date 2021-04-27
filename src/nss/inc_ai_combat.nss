//void main() {}

// Buff OBJECT_SELF if OBJECT_SELF isn't already buffed with the particular spell
void BuffIfNotBuffed(int bSpell, int bInstant)
{
    if(GetHasSpell(bSpell) && !GetHasSpellEffect(bSpell))
    {
      ActionCastSpellAtObject(bSpell, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
}

// FAST BUFF SELF
// * Dec 19 2002: Added the instant parameter so this could be used for 'legal' spellcasting as well
void FastBuff(int bInstant = TRUE)
{
    if (GetLocalInt(OBJECT_SELF, "fast_buffed") == 1) return;
    SetLocalInt(OBJECT_SELF, "fast_buffed", 1);
    ClearAllActions(TRUE);

    // General Protections and misc buffs
    BuffIfNotBuffed(SPELL_NEGATIVE_ENERGY_PROTECTION, bInstant);
    BuffIfNotBuffed(SPELL_DEATH_WARD, bInstant);
    BuffIfNotBuffed(SPELL_DARKVISION, bInstant);
    BuffIfNotBuffed(SPELL_DEATH_WARD, bInstant);
    BuffIfNotBuffed(SPELL_TRUE_SEEING, bInstant);
    BuffIfNotBuffed(SPELL_FREEDOM_OF_MOVEMENT, bInstant);
    BuffIfNotBuffed(SPELL_PROTECTION_FROM_SPELLS, bInstant);
    BuffIfNotBuffed(SPELL_SPELL_RESISTANCE, bInstant);
    BuffIfNotBuffed(SPELL_RESISTANCE, bInstant);
    BuffIfNotBuffed(SPELL_VIRTUE, bInstant);
    BuffIfNotBuffed(SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE, bInstant);

    // Cleric buffs
    BuffIfNotBuffed(SPELL_BLESS, bInstant);
    BuffIfNotBuffed(SPELL_PRAYER, bInstant);
    BuffIfNotBuffed(SPELL_AID, bInstant);
    BuffIfNotBuffed(SPELL_DIVINE_POWER, bInstant);
    BuffIfNotBuffed(SPELL_DIVINE_FAVOR, bInstant);

    // Ranger/Druid buffs
    BuffIfNotBuffed(SPELL_CAMOFLAGE, bInstant);
    BuffIfNotBuffed(SPELL_MASS_CAMOFLAGE, bInstant);
    BuffIfNotBuffed(SPELL_ONE_WITH_THE_LAND, bInstant);

    // Weapon Buffs
    BuffIfNotBuffed(SPELL_DARKFIRE, bInstant);
    BuffIfNotBuffed(SPELL_MAGIC_VESTMENT, bInstant);
    BuffIfNotBuffed(SPELL_MAGIC_WEAPON, bInstant);
    BuffIfNotBuffed(SPELL_GREATER_MAGIC_WEAPON, bInstant);
    BuffIfNotBuffed(SPELL_FLAME_WEAPON, bInstant);
    BuffIfNotBuffed(SPELL_KEEN_EDGE, bInstant);
    BuffIfNotBuffed(SPELL_BLADE_THIRST, bInstant);
    BuffIfNotBuffed(SPELL_BLACKSTAFF, bInstant);
    BuffIfNotBuffed(SPELL_BLESS_WEAPON, bInstant);
    BuffIfNotBuffed(SPELL_DEAFENING_CLANG, bInstant);
    BuffIfNotBuffed(SPELL_HOLY_SWORD, bInstant);

    // Armor buffs
    BuffIfNotBuffed(SPELL_MAGE_ARMOR, bInstant);
    BuffIfNotBuffed(SPELL_SHIELD, bInstant);
    BuffIfNotBuffed(SPELL_SHIELD_OF_FAITH, bInstant);
    BuffIfNotBuffed(SPELL_ENTROPIC_SHIELD, bInstant);
    BuffIfNotBuffed(SPELL_BARKSKIN, bInstant);

    // Stat buffs
    BuffIfNotBuffed(SPELL_AURA_OF_VITALITY, bInstant);
    BuffIfNotBuffed(SPELL_BULLS_STRENGTH, bInstant);
    BuffIfNotBuffed(SPELL_OWLS_WISDOM, bInstant);
    BuffIfNotBuffed(SPELL_OWLS_INSIGHT, bInstant);
    BuffIfNotBuffed(SPELL_FOXS_CUNNING, bInstant);
    BuffIfNotBuffed(SPELL_ENDURANCE, bInstant);
    BuffIfNotBuffed(SPELL_CATS_GRACE, bInstant);


    // Alignment Protections
    int nAlignment = GetAlignmentGoodEvil(OBJECT_SELF);
    if (nAlignment == ALIGNMENT_EVIL)
    {
        BuffIfNotBuffed(SPELL_PROTECTION_FROM_GOOD, bInstant);
        BuffIfNotBuffed(SPELL_MAGIC_CIRCLE_AGAINST_GOOD, bInstant);
        BuffIfNotBuffed(SPELL_UNHOLY_AURA, bInstant);
    }
    else if (nAlignment == ALIGNMENT_GOOD || nAlignment == ALIGNMENT_NEUTRAL)
    {
        BuffIfNotBuffed(SPELL_PROTECTION_FROM_EVIL, bInstant);
        BuffIfNotBuffed(SPELL_MAGIC_CIRCLE_AGAINST_EVIL, bInstant);
        BuffIfNotBuffed(SPELL_HOLY_AURA, bInstant);
    }


    if(GetRacialType(OBJECT_SELF) == RACIAL_TYPE_UNDEAD && GetHasSpell(SPELL_STONE_BONES) && !GetHasSpellEffect(SPELL_STONE_BONES))
    {
        ActionCastSpellAtObject(SPELL_STONE_BONES, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }

    //Evasion Protections
    if(GetHasSpell(SPELL_IMPROVED_INVISIBILITY) && !GetHasSpellEffect(SPELL_IMPROVED_INVISIBILITY))
    {
        ActionCastSpellAtObject(SPELL_IMPROVED_INVISIBILITY, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    else if(GetHasSpell(SPELL_DISPLACEMENT)&& !GetHasSpellEffect(SPELL_DISPLACEMENT))
    {
        ActionCastSpellAtObject(SPELL_DISPLACEMENT, OBJECT_SELF, METAMAGIC_ANY, 0, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }

    //Regeneration Protections
    if(GetHasSpell(SPELL_REGENERATE) && !GetHasSpellEffect(SPELL_REGENERATE))
    {
        ActionCastSpellAtObject(SPELL_REGENERATE, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    else if(GetHasSpell(SPELL_MONSTROUS_REGENERATION)&& !GetHasSpellEffect(SPELL_MONSTROUS_REGENERATION))
    {
        ActionCastSpellAtObject(SPELL_MONSTROUS_REGENERATION, OBJECT_SELF, METAMAGIC_ANY, 0, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }

    //Combat Protections
    if(GetHasSpell(SPELL_PREMONITION) && !GetHasSpellEffect(SPELL_PREMONITION))
    {
        ActionCastSpellAtObject(SPELL_PREMONITION, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    else if(GetHasSpell(SPELL_GREATER_STONESKIN)&& !GetHasSpellEffect(SPELL_GREATER_STONESKIN))
    {
        ActionCastSpellAtObject(SPELL_GREATER_STONESKIN, OBJECT_SELF, METAMAGIC_ANY, 0, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    else if(GetHasSpell(SPELL_STONESKIN)&& !GetHasSpellEffect(SPELL_STONESKIN))
    {
        ActionCastSpellAtObject(SPELL_STONESKIN, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    //Visage Protections
    if(GetHasSpell(SPELL_SHADOW_SHIELD)&& !GetHasSpellEffect(SPELL_SHADOW_SHIELD))
    {
        ActionCastSpellAtObject(SPELL_SHADOW_SHIELD, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    else if(GetHasSpell(SPELL_ETHEREAL_VISAGE)&& !GetHasSpellEffect(SPELL_ETHEREAL_VISAGE))
    {
        ActionCastSpellAtObject(SPELL_ETHEREAL_VISAGE, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    else if(GetHasSpell(SPELL_GHOSTLY_VISAGE)&& !GetHasSpellEffect(SPELL_GHOSTLY_VISAGE))
    {
        ActionCastSpellAtObject(SPELL_GHOSTLY_VISAGE, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    //Mantle Protections
    if(GetHasSpell(SPELL_GREATER_SPELL_MANTLE)&& !GetHasSpellEffect(SPELL_GREATER_SPELL_MANTLE))
    {
        ActionCastSpellAtObject(SPELL_GREATER_SPELL_MANTLE, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    else if(GetHasSpell(SPELL_SPELL_MANTLE)&& !GetHasSpellEffect(SPELL_SPELL_MANTLE))
    {
        ActionCastSpellAtObject(SPELL_SPELL_MANTLE, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    else if(GetHasSpell(SPELL_LESSER_SPELL_BREACH)&& !GetHasSpellEffect(SPELL_LESSER_SPELL_BREACH))
    {
        ActionCastSpellAtObject(SPELL_LESSER_SPELL_BREACH, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    // Globes
    if(GetHasSpell(SPELL_GLOBE_OF_INVULNERABILITY)&& !GetHasSpellEffect(SPELL_GLOBE_OF_INVULNERABILITY))
    {
        ActionCastSpellAtObject(SPELL_GLOBE_OF_INVULNERABILITY, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    else if(GetHasSpell(SPELL_MINOR_GLOBE_OF_INVULNERABILITY)&& !GetHasSpellEffect(SPELL_MINOR_GLOBE_OF_INVULNERABILITY))
    {
        ActionCastSpellAtObject(SPELL_MINOR_GLOBE_OF_INVULNERABILITY, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }

    //Misc Protections
    if(GetHasSpell(SPELL_ELEMENTAL_SHIELD)&& !GetHasSpellEffect(SPELL_ELEMENTAL_SHIELD))
    {
        ActionCastSpellAtObject(SPELL_ELEMENTAL_SHIELD, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    else if (GetHasSpell(SPELL_MESTILS_ACID_SHEATH)&& !GetHasSpellEffect(SPELL_MESTILS_ACID_SHEATH))
    {
        ActionCastSpellAtObject(SPELL_MESTILS_ACID_SHEATH, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    else if (GetHasSpell(SPELL_DEATH_ARMOR)&& !GetHasSpellEffect(SPELL_DEATH_ARMOR))
    {
        ActionCastSpellAtObject(SPELL_DEATH_ARMOR, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }

    //Elemental Protections
    if(GetHasSpell(SPELL_ENERGY_BUFFER)&& !GetHasSpellEffect(SPELL_ENERGY_BUFFER))
    {
        ActionCastSpellAtObject(SPELL_ENERGY_BUFFER, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    else if(GetHasSpell(SPELL_PROTECTION_FROM_ELEMENTS)&& !GetHasSpellEffect(SPELL_PROTECTION_FROM_ELEMENTS))
    {
        ActionCastSpellAtObject(SPELL_PROTECTION_FROM_ELEMENTS, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    else if(GetHasSpell(SPELL_RESIST_ELEMENTS)&& !GetHasSpellEffect(SPELL_RESIST_ELEMENTS))
    {
        ActionCastSpellAtObject(SPELL_RESIST_ELEMENTS, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    else if(GetHasSpell(SPELL_ENDURE_ELEMENTS)&& !GetHasSpellEffect(SPELL_ENDURE_ELEMENTS))
    {
        ActionCastSpellAtObject(SPELL_ENDURE_ELEMENTS, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }

    //Mental Protections
    if(GetHasSpell(SPELL_MIND_BLANK)&& !GetHasSpellEffect(SPELL_MIND_BLANK))
    {
        ActionCastSpellAtObject(SPELL_MIND_BLANK, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    else if(GetHasSpell(SPELL_LESSER_MIND_BLANK)&& !GetHasSpellEffect(SPELL_LESSER_MIND_BLANK))
    {
        ActionCastSpellAtObject(SPELL_LESSER_MIND_BLANK, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    else if(GetHasSpell(SPELL_CLARITY)&& !GetHasSpellEffect(SPELL_CLARITY))
    {
        ActionCastSpellAtObject(SPELL_CLARITY, OBJECT_SELF, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }

    //Summon Ally
    if(GetHasSpell(SPELL_BLACK_BLADE_OF_DISASTER))
    {
        ActionCastSpellAtLocation(SPELL_BLACK_BLADE_OF_DISASTER, GetLocation(OBJECT_SELF), METAMAGIC_ANY, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    else if(GetHasSpell(SPELL_SUMMON_CREATURE_IX))
    {
        ActionCastSpellAtLocation(SPELL_SUMMON_CREATURE_IX, GetLocation(OBJECT_SELF), METAMAGIC_ANY, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    else if(GetHasSpell(SPELLABILITY_PM_SUMMON_GREATER_UNDEAD))
    {
        ActionCastSpellAtLocation(SPELLABILITY_PM_SUMMON_GREATER_UNDEAD, GetLocation(OBJECT_SELF), METAMAGIC_ANY, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    else if(GetHasSpell(SPELL_SUMMON_CREATURE_VIII))
    {
        ActionCastSpellAtLocation(SPELL_SUMMON_CREATURE_VIII, GetLocation(OBJECT_SELF), METAMAGIC_ANY, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    else if(GetHasSpell(SPELL_SUMMON_CREATURE_VII))
    {
        ActionCastSpellAtLocation(SPELL_SUMMON_CREATURE_VII, GetLocation(OBJECT_SELF), METAMAGIC_ANY, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    else if(GetHasSpell(SPELL_SUMMON_CREATURE_VI))
    {
        ActionCastSpellAtLocation(SPELL_SUMMON_CREATURE_VI, GetLocation(OBJECT_SELF), METAMAGIC_ANY, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    else if(GetHasSpell(SPELL_CREATE_UNDEAD))
    {
        ActionCastSpellAtLocation(SPELL_CREATE_UNDEAD, GetLocation(OBJECT_SELF), METAMAGIC_ANY, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    else if(GetHasSpell(SPELL_PLANAR_ALLY))
    {
        ActionCastSpellAtLocation(SPELL_PLANAR_ALLY, GetLocation(OBJECT_SELF), METAMAGIC_ANY, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    else if(GetHasSpell(SPELL_SUMMON_CREATURE_V))
    {
        ActionCastSpellAtLocation(SPELL_SUMMON_CREATURE_V, GetLocation(OBJECT_SELF), METAMAGIC_ANY, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    else if(GetHasSpell(SPELL_SUMMON_CREATURE_IV))
    {
        ActionCastSpellAtLocation(SPELL_SUMMON_CREATURE_IV, GetLocation(OBJECT_SELF), METAMAGIC_ANY, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    else if(GetHasSpell(SPELL_ANIMATE_DEAD))
    {
        ActionCastSpellAtLocation(SPELL_ANIMATE_DEAD, GetLocation(OBJECT_SELF), METAMAGIC_ANY, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    else if(GetHasSpell(SPELL_SUMMON_CREATURE_III))
    {
        ActionCastSpellAtLocation(SPELL_SUMMON_CREATURE_III, GetLocation(OBJECT_SELF), METAMAGIC_ANY, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    else if(GetHasSpell(SPELL_SUMMON_CREATURE_II))
    {
        ActionCastSpellAtLocation(SPELL_SUMMON_CREATURE_II, GetLocation(OBJECT_SELF), METAMAGIC_ANY, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }
    else if(GetHasSpell(SPELL_SUMMON_CREATURE_I))
    {
        ActionCastSpellAtLocation(SPELL_SUMMON_CREATURE_I, GetLocation(OBJECT_SELF), METAMAGIC_ANY, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
    }


}

void DoCombatVoice()
{
    if (GetIsDead(OBJECT_SELF)) return;

    string sBattlecryScript = GetLocalString(OBJECT_SELF, "battlecry_script");
    if (sBattlecryScript != "")
    {
        ExecuteScript(sBattlecryScript, OBJECT_SELF);
    }
    else
    {
        int nRand = 40;
        if (GetLocalInt(OBJECT_SELF, "boss") == 1) nRand = nRand/2;

        switch (Random(nRand))
        {
            case 0: PlayVoiceChat(VOICE_CHAT_BATTLECRY1, OBJECT_SELF); break;
            case 1: PlayVoiceChat(VOICE_CHAT_BATTLECRY2, OBJECT_SELF); break;
            case 2: PlayVoiceChat(VOICE_CHAT_BATTLECRY3, OBJECT_SELF); break;
            case 3: PlayVoiceChat(VOICE_CHAT_ATTACK, OBJECT_SELF); break;
            case 4: PlayVoiceChat(VOICE_CHAT_TAUNT, OBJECT_SELF); break;
            case 5: PlayVoiceChat(VOICE_CHAT_LAUGH, OBJECT_SELF); break;
        }
    }
}

/* COMBAT Library by Gigaschatten */
/* COMBAT Library by Gigaschatten */

//#include "inc_boss"
//#include "inc_rename"
//#include "inc_zombie"
//#include "inc_flag"
#include "inc_ai_combat2"
#include "inc_ai_combat3"
//#include "gs_inc_flag"
//#include "inc_ai_time"
#include "x0_i0_position"

//void main() {}

const float MIN_RANGE_DISTANCE = 2.0;

const int GS_CB_BEHAVIOR_DEFENSIVE       = 1;
const int GS_CB_BEHAVIOR_ATTACK_SPELL    = 2;
const int GS_CB_BEHAVIOR_ATTACK_PHYSICAL = 3;

//return random class type by class relation of caller
int gsCBDetermineClass();
//return TRUE if oObject perceives oTarget
int gsCBGetIsPerceived(object oTarget, object oObject = OBJECT_SELF);
//return and set attack target of oObject, primary oTarget can be specified
object gsCBGetAttackTarget(object oObject = OBJECT_SELF, object oTarget = OBJECT_INVALID);
//return last attack target of oObject
object gsCBGetLastAttackTarget(object oObject = OBJECT_SELF);
//return TRUE if oObject has attack target
int gsCBGetHasAttackTarget(object oObject = OBJECT_SELF);
//set oTarget as attack target of oObject.  If oTarget is guarded, return the
//guarding creature.
object gsCBSetAttackTarget(object oTarget, object oObject = OBJECT_SELF);
//clear attack target of oObject
void gsCBClearAttackTarget(object oObject = OBJECT_SELF);
//return TRUE if caller is involved in combat
int gsCBGetIsInCombat();
//return TRUE if oObject is actually following a target across area borders
int gsCBGetIsFollowing(object oObject = OBJECT_SELF);
//return creature of nRace with distance between fMinimumDistance and fMaximumDistance to lLocation, specified by flag nFriendly, nNeutral, nHostile, nDamaged, nRequiredAid and nCounterMeasure
object gsCBGetCreatureAtLocation(location lLocation, int nFriendly = TRUE, int nNeutral = TRUE, int nHostile = TRUE, float fMinimumDistance = 0.0, float fMaximumDistance = 5.0, int nRace = RACIAL_TYPE_ALL, int nDamaged = FALSE, int nRequiredAid = FALSE, int nCounterMeasure = FALSE);
//return number of creatures of nRace with distance between fMinimumDistance and fMaximumDistance to lLocation, specified by flag nFriendly, nNeutral, nHostile, nDamaged, nRequiredAid and nCounterMeasure
int gsCBGetCreatureCountAtLocation(location lLocation, int nFriendly = TRUE, int nNeutral = TRUE, int nHostile = TRUE, float fMinimumDistance = 0.0, float fMaximumDistance = 5.0, int nRace = RACIAL_TYPE_ALL, int nDamaged = FALSE, int nRequiredAid = FALSE, int nCounterMeasure = FALSE);
//return force balance at location of caller
int gsCBGetForceBalance();

//caller decides to attack oVictim, the attacker of oVictim or to do no action
void gsCBDetermineAttackTarget(object oVictim);
//main combat ai function
void gsCBDetermineCombatRound(object oTarget = OBJECT_INVALID);

//return TRUE if tTalent is used on oTarget
int gsCBUseTalentOnObject(talent tTalent, object oTarget = OBJECT_SELF);
//return TRUE if nFeat is used on oTarget
int gsCBUseFeatOnObject(int nFeat, object oTarget = OBJECT_SELF);
//return TRUE if nSpell is cast at oTarget
int gsCBCastSpellAtObject(int nSpell, object oTarget = OBJECT_SELF);
//return TRUE if caller can use a talent from the specified categories on itself
int gsCBTalentSelf(int nTalentCategorySelf, int nTalentCategorySingle = FALSE, int nTalentCategoryPotion = FALSE,int nTalentCategoryArea = FALSE);
//return TRUE if caller can use a talent from the specified categories on allies
int gsCBTalentOthers(int nTalentCategoryArea, int nTalentCategorySingle = FALSE);
//return TRUE if caller can protect itself with spells, features or potions
int gsCBTalentProtectSelf();
//return TRUE if caller can protect allies with spells or features
int gsCBTalentProtectOthers();
//return TRUE if caller can enhance itself with spells, features or potions
int gsCBTalentEnhanceSelf();
//return TRUE if caller can enhance allies with spells or features
int gsCBTalentEnhanceOthers();
//return TRUE if caller can use persistent effect on itself
int gsCBTalentPersistentEffect();
//return TRUE if caller can heal itself with spells, features or potions
int gsCBTalentHealSelf();
//return TRUE if caller can heal allies with spells or features
int gsCBTalentHealOthers();
//return TRUE if caller can remove negative conditions from itself or allies
int gsCBTalentCureCondition();
//internally used
object _gsCBTalentCureCondition(location lLocation, int nRequiredAid);
//return TRUE if caller can take counter measure against enemy
int gsCBTalentCounterMeasure();
//internally used
object _gsCBTalentCounterMeasure(location lLocation, int nCounterMeasure);
//return TRUE if caller can obtain ally near oTarget
int gsCBTalentSummonAlly(object oTarget = OBJECT_SELF);
//return TRUE if caller can turn/destroy enemies
int gsCBTalentUseTurning();
//return TRUE if caller can use dragon breath on oTarget
int gsCBTalentDragonBreath(object oTarget);
//return TRUE if caller can use dragon wing on oTarget
int gsCBTalentDragonWing(object oTarget, int nFly = FALSE);
//internally used
void _gsCBTalentDragonWing(object oObject);
//internally used
void __gsCBTalentDragonWing(object oObject);
//internally used
int ___gsCBTalentDragonWing(location lLocation);
//internally used
void ____gsCBTalentDragonWing(location lLocation);
//return TRUE if caller can cast harmful spell on oTarget
int gsCBTalentSpellAttack(object oTarget);
//caller tries to physically attack oTarget
void gsCBTalentAttack(object oTarget);
//internally used
void _gsCBTalentAttack(object oTarget, int nDistance);
//return TRUE if caller follows attack target across area borders
int gsCBTalentFollow();
//return TRUE if caller can use protection spell on itself
int gsCBTalentProtectBySpell();
//internally used
int _gsCBTalentProtectBySpell(int nSpell, int nInstant = FALSE);
//return TRUE if caller can dispel benevolent magic on oTarget
int gsCBTalentDispelMagic(object oTarget);
//return TRUE if caller takes action to evade darkness effect
int gsCBTalentEvadeDarkness();
// If the NPC has Taunt they may use Taunt.
int gsCBTalentTaunt(object oTarget);
// If the NPC has Hide they may attempt a feint.
//int gsCBTalentFeint(object oTarget);
// If the NPC has Parry they may enter parry mode.
int gsCBTalentParry(object oTarget);
// added by Dunshine, Gonne NPC functions
//int gsCBTalentGonne(object oTarget);
// Delayed (telegraphed) attacks.
//int gsCBTelegraphAttack(object oTarget);

//caller issues requests reinforcement if required
void gsCBRequestReinforcement();
//set reinforcement requested by oObject from caller
void gsCBSetReinforcementRequestedBy(object oObject);
//return TRUE if caller follows reinforcement request
int gsCBReinforce();
//equips most damaging melee weapon, or if monk, unequips.
void gsCBEquipMeleeWeapon(object oTarget);

// Associate -guard functions, which are superceded by the -guard chat command.
// Implemented for the introduction of guardian summons (e.g. shadowdancer shadow).
//void SetAssociateGuardian(object oPC, object oGuardian, int bFeedback = TRUE);
//object GetAssociateGuardian(object oPC, int bReturnInactiveGuardian = FALSE);
//int GetIsAssociateGuardEnabled(object oPC);
//void SetIsAssociateGuardEnabled(object oPC, int bIsEnabled, int bFeedback = TRUE);
//void SendAssociateGuardFeedback(object oPC);

void gsCBEquipMeleeWeapon(object oTarget)
{
    if (gsCBDetermineClass() != CLASS_TYPE_MONK)
          ActionEquipMostDamagingMelee(oTarget);
    else
    {
        object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);
        if (GetIsObjectValid(oWeapon)) ActionUnequipItem(oWeapon);
    }
}

int gsCBDetermineClass()
{
    int nClass1      = GetClassByPosition(1);
    int nClass2      = GetClassByPosition(2);
    int nClass3      = GetClassByPosition(3);
    int nClassLevel1 = GetLevelByClass(nClass1);
    int nClassLevel2 = GetLevelByClass(nClass2);
    int nClassLevel3 = GetLevelByClass(nClass3);
    int nClassLevel  = nClassLevel1 + nClassLevel2 + nClassLevel3;
    int nRandom      = Random(nClassLevel);

    if (nRandom < nClassLevel1)                return nClass1;
    if (nRandom < nClassLevel1 + nClassLevel2) return nClass2;
    return nClass3;
}
//----------------------------------------------------------------
int gsCBGetIsPerceived(object oTarget, object oObject = OBJECT_SELF)
{
    if (gsC2GetHasEffect(EFFECT_TYPE_ETHEREAL, oTarget))     return FALSE;
    if (gsC2GetHasEffect(EFFECT_TYPE_TRUESEEING, oObject))   return TRUE;
    if (GetObjectSeen(oTarget, oObject))                     return TRUE;
    if (gsC2GetHasEffect(EFFECT_TYPE_SANCTUARY, oTarget))    return FALSE;
    if (GetObjectHeard(oTarget, oObject))                    return TRUE;
    if (GetActionMode(oTarget, ACTION_MODE_STEALTH) &&
        ! (GetIsSkillSuccessful(oObject, SKILL_SPOT, GetSkillRank(SKILL_HIDE, oTarget) + d20()) ||
           GetIsSkillSuccessful(oObject, SKILL_LISTEN, GetSkillRank(SKILL_MOVE_SILENTLY, oTarget) + d20())))
    {
        return FALSE;
    }
    if (gsC2GetHasEffect(EFFECT_TYPE_SEEINVISIBLE, oObject)) return TRUE;
    if (gsC2GetHasEffect(EFFECT_TYPE_INVISIBILITY, oTarget)) return FALSE;
    return TRUE;
}
//----------------------------------------------------------------
int gsCBGetIsEnemy(object oTarget, object oSource = OBJECT_SELF)
{
    // Removed code to prevent multiple hostile NPCs fighting.
    // Instead we have turned off "global effect" from all hostile factions.
    return (GetIsEnemy(oTarget, oSource));
}

//----------------------------------------------------------------
object gsCBGetAttackTarget(object oObject = OBJECT_SELF, object oTarget = OBJECT_INVALID)
{

    if (! GetIsObjectValid(oTarget) ||
        GetPlotFlag(oTarget) ||
        GetIsDead(oTarget) ||
        GetDistanceBetween(oObject, oTarget) > 60.0 ||
        ! gsCBGetIsEnemy(oTarget, oObject) || //<<--Modified by Space Pirate March 2011
//--    (! gsCBGetIsEnemy(oTarget, oObject) && GetFactionEqual(oObject, oTarget)) ||
        ! gsCBGetIsPerceived(oTarget, oObject)
        )
    {
        oTarget = gsCBGetLastAttackTarget(oObject);

        if (! GetIsObjectValid(oTarget) ||
            ! GetIsEnemy(oTarget) ||
            GetPlotFlag(oTarget) ||
            GetIsDead(oTarget) ||
            ! gsCBGetIsEnemy(oTarget, oObject) || //<<--Modified by Space Pirate March 2011
//--        (! gsCBGetIsEnemy(oTarget, oObject) && GetFactionEqual(oObject, oTarget)) ||
            ! gsCBGetIsPerceived(oTarget, oObject))
        {
            oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY,
                                         oObject, 1,
                                         CREATURE_TYPE_IS_ALIVE, TRUE,
                                         CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);

            if (! GetIsObjectValid(oTarget) ||
                ! gsCBGetIsEnemy(oTarget, oObject) ||
                GetPlotFlag(oTarget))
            {
                oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY,
                                             oObject, 1,
                                             CREATURE_TYPE_IS_ALIVE, TRUE,
                                             CREATURE_TYPE_PERCEPTION, PERCEPTION_HEARD);

                if (! GetIsObjectValid(oTarget) ||
                    ! gsCBGetIsEnemy(oTarget, oObject) ||
                    GetPlotFlag(oTarget))
                {
                    gsCBClearAttackTarget(oObject);
                    return OBJECT_INVALID;
                }
            }
        }
    }

    oTarget = gsCBSetAttackTarget(oTarget, oObject);
    return oTarget;
}
//----------------------------------------------------------------
object gsCBGetLastAttackTarget(object oObject = OBJECT_SELF)
{
    return GetLocalObject(oObject, "GS_CB_ATTACK_TARGET");
}
//----------------------------------------------------------------
int gsCBGetHasAttackTarget(object oObject = OBJECT_SELF)
{
    return GetIsObjectValid(gsCBGetLastAttackTarget(oObject));
}
//----------------------------------------------------------------
object gsCBSetAttackTarget(object oTarget, object oObject = OBJECT_SELF)
{
    /*
    int nTime = GetModuleTime();
    int bAssociateGuardingMe = FALSE;
    object oGuard = GetLocalObject(oTarget, "CURRENT_GUARD");
    object oMaster;
    string sName;
    int bGuarded = FALSE;
    int bWarded = FALSE;

    if(!GetIsObjectValid(oGuard) || GetDistanceBetween(oTarget, oGuard) == 0.0 || GetDistanceBetween(oTarget, oGuard) > 3.0)
    {
        // Fallback guard. Implemented for use with guardian summons (e.g. shadowdancer shadow). This implementation is a little
        // messy and should probably just reference a prioritized list, but this'll do for now.
        oGuard = GetAssociateGuardian(oTarget);
        bAssociateGuardingMe = TRUE;
    }

    if (GetIsObjectValid(oGuard) &&
        (bAssociateGuardingMe || GetLocalObject(oGuard, "CURRENT_WARD") == oTarget) &&
        GetDistanceBetween(oTarget, oGuard) != 0.0f &&
        GetDistanceBetween(oTarget, oGuard) <= 3.0f)
    {
      // Added timestamps to prevent -guard feedback spam. Now shows at most once
      // per round.
      if(nTime - GetLocalInt(oTarget, "GuardFeedbackTimestamp") >= 6)
      {
        //sName = GetIsPC(oGuard) ? svGetPCNameOverride(oGuard) : GetName(oGuard);
        sName = GetName(oGuard);
        FloatingTextStringOnCreature(sName + " shields you from an attacker.", oTarget, FALSE);
        SetLocalInt(oTarget, "GuardFeedbackTimestamp", nTime);
      }
      if(nTime - GetLocalInt(oGuard, "GuardFeedbackTimestamp") >= 6)
      {
        //sName = GetIsPC(oTarget) ? svGetPCNameOverride(oTarget) : GetName(oTarget);
        sName = GetName(oTarget);
        FloatingTextStringOnCreature("You shield " + sName + " from an attacker.", oGuard, FALSE);
        SetLocalInt(oGuard, "GuardFeedbackTimestamp", nTime);
      }
      oTarget = oGuard;
      bGuarded = TRUE;
    }

    // Separate guardian system for PDK wards
    object oPDK = GetLocalObject(oTarget, "PDKWarded");
    if (bGuarded == FALSE && GetIsObjectValid(oPDK) == TRUE && oTarget == GetLocalObject(oPDK, "PDKWard")) {
        if (GetDistanceBetween(oTarget, oPDK) != 0.0f && GetDistanceBetween(oTarget, oPDK) <= 6.0f)
        {
            if(nTime - GetLocalInt(oTarget, "WardFeedbackTimestamp") >= 6)
            {
                //sName = GetIsPC(oPDK) ? svGetPCNameOverride(oPDK) : GetName(oPDK);
                sName = GetName(oPDK);
                FloatingTextStringOnCreature(sName + " shields you from an attacker.", oTarget, FALSE);
                SetLocalInt(oTarget, "WardFeedbackTimestamp", nTime);
            }
            if(nTime - GetLocalInt(oPDK, "WardFeedbackTimestamp") >= 6)
            {
                //sName = GetIsPC(oTarget) ? svGetPCNameOverride(oTarget) : GetName(oTarget);
                sName = GetName(oTarget);
                FloatingTextStringOnCreature("You shield " + sName + " from an attacker.", oPDK, FALSE);
                SetLocalInt(oPDK, "WardFeedbackTimestamp", nTime);
            }
            oTarget = oPDK;
            bWarded = TRUE;
        }
    }
    // Oath of Wrath!  Focus on the object of our ire for one minute.
    object oWrath = GetLocalObject(oObject, "PDKWrath");
    int nWrathTime = GetLocalInt(oObject, "WrathTimeStamp");
    if (bGuarded == FALSE &&
        bWarded == FALSE &&
        GetIsObjectValid(oWrath) == TRUE &&
        nTime - nWrathTime < 60)
    {
        if (GetDistanceBetween(oTarget, oWrath) != 0.0f && GetDistanceBetween(oTarget, oWrath) <= 6.0f)
        {
            if(nTime - GetLocalInt(oTarget, "WrathFeedbackTimestamp") >= 6)
            {
                //sName = GetIsPC(oWrath) ? svGetPCNameOverride(oWrath) : GetName(oWrath);
                sName = GetName(oWrath);
                FloatingTextStringOnCreature(sName + " draws the attacker's ire.", oTarget, FALSE);
                SetLocalInt(oTarget, "WrathFeedbackTimestamp", nTime);
            }
            if(nTime - GetLocalInt(oWrath, "WrathFeedbackTimestamp") >= 6)
            {
                //sName = GetIsPC(oTarget) ? svGetPCNameOverride(oTarget) : GetName(oTarget);
                sName = GetName(oTarget);
                FloatingTextStringOnCreature("You distract an attacker away from " + sName + ".", oWrath, FALSE);
                SetLocalInt(oWrath, "WrathFeedbackTimestamp", nTime);
            }
            oTarget = oWrath;
        }
    }
    */
    object oMaster = GetMaster(oTarget);
    if(GetPlotFlag(oTarget) && (!GetPlotFlag(oMaster) && GetIsObjectValid(GetMaster(oTarget))))
    {
        // Catch to ensure enemies change targets when facing plot-flagged associates, such as
        // Black Blade of Diaster.
        oTarget = GetMaster(oTarget);
    }

    SetLocalObject(oObject, "GS_CB_ATTACK_TARGET", oTarget);
    return oTarget;
}
//----------------------------------------------------------------
void gsCBClearAttackTarget(object oObject = OBJECT_SELF)
{
    DeleteLocalObject(oObject, "GS_CB_ATTACK_TARGET");
}
//----------------------------------------------------------------
int gsCBGetIsInCombat()
{
    // Added a bunch of status effects to this check, because they
    // prevent a creature participating in combat normally.
    return GetIsInCombat() ||
           GetIsObjectValid(GetAttackTarget()) ||
           GetIsObjectValid(GetAttemptedAttackTarget()) ||
           GetIsObjectValid(GetAttemptedSpellTarget()) ||
           gsC2GetIsIncapacitated(OBJECT_SELF) ;
}
//----------------------------------------------------------------
int gsCBGetIsFollowing(object oObject = OBJECT_SELF)
{
    // If we're a boss, don't follow our target across areas.
    object oTarget = GetLocalObject(oObject, "GS_CB_FOLLOW_TARGET");
    if (GetIsObjectValid(oTarget) &&
    //    gsBOGetIsBossCreature(oObject) &&
        (GetLocalInt(oObject, "boss") == 1 || GetLocalInt(oObject, "semiboss") == 1) &&
        GetArea(oObject) != GetArea(oTarget))
    {
      DeleteLocalObject(oObject, "GS_CB_FOLLOW_TARGET");
      DeleteLocalInt(oObject, "GS_CB_FOLLOW_COUNTER");
      AssignCommand(oObject, ClearAllActions());
      return FALSE;
    }

    return GetIsObjectValid(oTarget);
}
//----------------------------------------------------------------
object gsCBGetCreatureAtLocation(location lLocation,
                                 int nFriendly          = TRUE,
                                 int nNeutral           = TRUE,
                                 int nHostile           = TRUE,
                                 float fMinimumDistance = 0.0,
                                 float fMaximumDistance = 5.0,
                                 int nRace              = RACIAL_TYPE_ALL,
                                 int nDamaged           = FALSE,
                                 int nRequiredAid       = FALSE,
                                 int nCounterMeasure    = FALSE)
{
    object oObject   = GetFirstObjectInShape(SHAPE_SPHERE, fMaximumDistance, lLocation, TRUE);
    vector vPosition = GetPositionFromLocation(lLocation);
    float fDistance  = 0.0;
    int nReputation  = 0;

    while (GetIsObjectValid(oObject))
    {
        nReputation = GetReputation(OBJECT_SELF, oObject);

        if (! GetIsDead(oObject) &&
            (nFriendly && nReputation >= 65)                    ||
            (nNeutral  && nReputation > 35 && nReputation < 65) ||
            (nHostile  && nReputation <= 35))
        {
            fDistance = VectorMagnitude(vPosition - GetPosition(oObject));

            if (fDistance >= fMinimumDistance                                                 &&
                                      nRace                          & GetRacialType(oObject) &&
                (! nDamaged        || gsC2GetIsDamaged(oObject))                              &&
                (! nRequiredAid    || gsC2GetRequiredAid(oObject)    & nRequiredAid)          &&
                (! nCounterMeasure || gsC2GetCounterMeasure(oObject) & nCounterMeasure))
            {
                return oObject;
            }
        }

        oObject     = GetNextObjectInShape(SHAPE_SPHERE, fMaximumDistance, lLocation, TRUE);
    }

    return OBJECT_INVALID;
}
//----------------------------------------------------------------
int gsCBGetCreatureCountAtLocation(location lLocation,
                                   int nFriendly          = TRUE,
                                   int nNeutral           = TRUE,
                                   int nHostile           = TRUE,
                                   float fMinimumDistance = 0.0,
                                   float fMaximumDistance = 5.0,
                                   int nRace              = RACIAL_TYPE_ALL,
                                   int nDamaged           = FALSE,
                                   int nRequiredAid       = FALSE,
                                   int nCounterMeasure    = FALSE)
{
    object oObject   = GetFirstObjectInShape(SHAPE_SPHERE, fMaximumDistance, lLocation, TRUE);
    vector vPosition = GetPositionFromLocation(lLocation);
    float fDistance  = 0.0;
    int nReputation  = 0;
    int nCount       = 0;

    while (GetIsObjectValid(oObject))
    {
        nReputation = GetReputation(OBJECT_SELF, oObject);

        if (! GetIsDead(oObject) &&
            (nFriendly && nReputation >= 65)                    ||
            (nNeutral  && nReputation > 35 && nReputation < 65) ||
            (nHostile  && nReputation <= 35))
        {
            fDistance = VectorMagnitude(vPosition - GetPosition(oObject));

            if (fDistance >= fMinimumDistance                                                 &&
                                      nRace                          & GetRacialType(oObject) &&
                (! nDamaged        || gsC2GetIsDamaged(oObject))                              &&
                (! nRequiredAid    || gsC2GetRequiredAid(oObject)    & nRequiredAid)          &&
                (! nCounterMeasure || gsC2GetCounterMeasure(oObject) & nCounterMeasure))
            {
                if (++nCount == 3) return nCount;
            }
        }

        oObject     = GetNextObjectInShape(SHAPE_SPHERE, fMaximumDistance, lLocation, TRUE);
    }

    return nCount;
}
//----------------------------------------------------------------
int gsCBGetForceBalance()
{
    location lLocation = GetLocation(OBJECT_SELF);
    object oObject     = GetFirstObjectInShape(SHAPE_SPHERE, 15.0, lLocation, TRUE);
    float fRating      = 0.0;
    float fBalance     = 0.0;
    int nReputation    = 0;

    while (GetIsObjectValid(oObject))
    {
        nReputation = GetReputation(OBJECT_SELF, oObject);

        if (! GetIsDead(oObject) &&
            (nReputation <= 35 || nReputation >= 65))
        {
            fRating   = (GetIsPC(oObject) ?
                         IntToFloat(GetHitDice(oObject)) :
                         GetChallengeRating(oObject))
                        * IntToFloat(GetCurrentHitPoints(oObject))
                        / IntToFloat(GetMaxHitPoints(oObject));
            fBalance += nReputation >= 65 ? fRating : -fRating;
        }

        oObject = GetNextObjectInShape(SHAPE_SPHERE, 15.0, lLocation, TRUE);
    }

    return FloatToInt(fBalance * 10.0);
}
//----------------------------------------------------------------
//COMBAT
//----------------------------------------------------------------
void gsCBDetermineAttackTarget(object oVictim)
{
    if (GetIsObjectValid(oVictim))
    {
        object oAttacker = GetIsPC(oVictim) ?
                           OBJECT_INVALID :
                           gsCBGetAttackTarget(oVictim);

        if (GetIsObjectValid(oAttacker))
        {
            int nReputationVictim   = GetReputation(OBJECT_SELF, oVictim);
            int nReputationAttacker = GetReputation(OBJECT_SELF, oAttacker);

            if (nReputationVictim >= 65 &&
                nReputationVictim > nReputationAttacker)
            {
                gsCBDetermineCombatRound(oAttacker);
            }
            else if (nReputationAttacker >= 65)
            {
                gsCBDetermineCombatRound(oVictim);
            }
        }
        else if (GetIsEnemy(oVictim))
        {
            gsCBDetermineCombatRound(oVictim);
        }
    }
}
//----------------------------------------------------------------
void gsCBDetermineCombatRound(object oTarget = OBJECT_INVALID)
{

    guALSetAILevel(AI_LEVEL_NORMAL);
    /*
    if (GetPlotFlag() ||
        gsFLGetFlag(GS_FL_DISABLE_COMBAT))
          GetLevelByClass(CLASS_TYPE_COMMONER) > 0)
    {
        return;
    }
    */
    //attack target
    oTarget = gsCBGetAttackTarget(OBJECT_SELF, oTarget);

    if (! GetIsObjectValid(oTarget))
    {
        ClearAllActions();

        // Check whether our last attacker is standing in darkness and not
        // concealed.
        object oLastAttacker = GetLastAttacker();
        if (gsC2GetHasEffect(EFFECT_TYPE_DARKNESS, oLastAttacker) ||
            gsC2GetHasEffect(EFFECT_TYPE_INVISIBILITY, oLastAttacker))
        {
          // Walk up and see what's going on.
          if (d6() == 6) PlayVoiceChat(VOICE_CHAT_ENEMIES);
          AssignCommand(OBJECT_SELF, ActionMoveToObject(oLastAttacker, TRUE));
        }

        //::  ActionReplay
        //::  [-------------------- Darkness SMRT AI FIX START
        object oPotentialThreat = GetLastHostileActor();
        if ( GetIsPC(oPotentialThreat) &&
            (gsC2GetHasEffect(EFFECT_TYPE_DARKNESS, oPotentialThreat) ||
             gsC2GetHasEffect(EFFECT_TYPE_INVISIBILITY, oPotentialThreat)) ) {

            if ( !(gsC2GetHasEffect(EFFECT_TYPE_TRUESEEING) || gsC2GetHasEffect(EFFECT_TYPE_ULTRAVISION)) ) {
                int nSpell = -1;
                if (GetHasSpell(SPELL_TRUE_SEEING))                    nSpell = SPELL_TRUE_SEEING;
                else if (GetHasSpell(SPELL_DARKVISION))                nSpell = SPELL_DARKVISION;

                if (nSpell != -1 && gsCBCastSpellAtObject(nSpell))     return;

                if (GetHasSpell(SPELL_LESSER_DISPEL))                  nSpell = SPELL_LESSER_DISPEL;
                else if (GetHasSpell(SPELL_DISPEL_MAGIC))              nSpell = SPELL_DISPEL_MAGIC;
                else if (GetHasSpell(SPELL_GREATER_DISPELLING))        nSpell = SPELL_GREATER_DISPELLING;
                else if (GetHasSpell(SPELL_MORDENKAINENS_DISJUNCTION)) nSpell = SPELL_MORDENKAINENS_DISJUNCTION;

                if (nSpell != -1)
                {
                    ActionCastSpellAtLocation(nSpell, GetLocation(oPotentialThreat));
                    return;
                }
                //::  Fallback for creatures not having appropriate spells
                else if ( !GetLocalInt(OBJECT_SELF, "AR_STOP_POLLING") ) {
                    //::  Just move into the darkness if below conditions are met
                    if ( d4() == 1 && (GetHitDice(OBJECT_SELF) >= 18 || GetAbilityModifier(ABILITY_WISDOM, OBJECT_SELF) >= 3)  ) {
                        ActionMoveToLocation( GetRandomLocation(GetArea(OBJECT_SELF), oPotentialThreat, RADIUS_SIZE_MEDIUM + d4()), TRUE );
                        SetLocalInt(OBJECT_SELF, "AR_STOP_POLLING", TRUE);
                        DelayCommand(7.0, DeleteLocalInt(OBJECT_SELF, "AR_STOP_POLLING"));
                    }
                    //::  Run away we're cowards
                    else
                        ActionMoveAwayFromLocation(GetLocation(OBJECT_SELF), TRUE, 10.0);
                }
            }
        }
        //:: [-------------------- Darkness SMRT AI FIX END

        return;
    }

    if (GetStandardFactionReputation(STANDARD_FACTION_COMMONER) > 25) SpeakString("GS_AI_INNOCENT_ATTACKED", TALKVOLUME_SILENT_TALK);

    if (! GetIsEnemy(oTarget)) SetIsTemporaryEnemy(oTarget, OBJECT_SELF, TRUE, 1800.00);

    //analyze
    gsC2Analyze();

    //if (fbZGetIsZombie(OBJECT_SELF))
    //{
    //  SetLocalInt(OBJECT_SELF, "GS_CB_BEHAVIOUR", GS_CB_BEHAVIOR_ATTACK_PHYSICAL);
    //  gsCBTalentAttack(oTarget);
    //  return;
    //}

    //follow target
    if (gsCBGetIsFollowing()) return;

    //call aid, if we're intelligent enough to do so.
    if (GetLocalInt(OBJECT_SELF, "HELP_REQUESTED") == 0) {
      //if (! gsFLGetFlag(GS_FL_DISABLE_CALL) && GetAbilityModifier(ABILITY_INTELLIGENCE, OBJECT_SELF) >= -2)
      if (GetAbilityModifier(ABILITY_INTELLIGENCE, OBJECT_SELF) >= -2)
      {
        SetLocalInt(OBJECT_SELF, "HELP_REQUESTED", 1);
        SpeakString("GS_AI_ATTACK_TARGET", TALKVOLUME_SILENT_TALK);
        gsCBRequestReinforcement();
        if (gsCBReinforce()) oTarget = gsCBGetLastAttackTarget();
      }
    }

    // added by Dunshine, check if the NPC is a Gonne user
    //if (gsCBTalentGonne(oTarget)) return;

    // added by Dunshine, check if the NPC has a percentage chance of getting a True Strike effect
    // use this variable to add some randomness and danger to monsters here and there

    // check if the effect is activated already
    /*
    if (GetLocalInt(OBJECT_SELF,"GVD_TRUESTRIKE_RUNNING") != 1) {

      // not in effect yet, see if the monster got lucky
      if (d100(1) <= GetLocalInt(OBJECT_SELF,"GVD_TRUESTRIKE")) {

        // keep track of activation
        SetLocalInt(OBJECT_SELF,"GVD_TRUESTRIKE_RUNNING",1);
        DelayCommand(10.0f, DeleteLocalInt(OBJECT_SELF,"GVD_TRUESTRIKE_RUNNING"));

        // flavor
        string sFlavor = GetLocalString(OBJECT_SELF,"GVD_TRUESTRIKE_FLAVOR");
        if (sFlavor == "") {
          // default flavor
          sFlavor = "*" + GetName(OBJECT_SELF) + " gets lucky...*";
        }
        // Speak the string as floating text on NPCs won't be visible to PCs
        SpeakString(sFlavor);

        // apply effect
        effect eTrueStrike = EffectAttackIncrease(20);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTrueStrike, OBJECT_SELF, 9.0f);
      }
    }
    */

    if (GetCurrentAction() != ACTION_CASTSPELL)
    {
      ClearAllActions();
    }

    //no magic area // added extra check by Dunshine to make it possible for NPCs to use magic or monsterabilities in no magic zones
    // set GVD_OVERRIDE_NO_MAGIC as a local int on the NPC with value 1 for these situations.
    //if (gsFLGetAreaFlag("OVERRIDE_MAGIC") && (GetLocalInt(OBJECT_SELF,"GVD_OVERRIDE_NO_MAGIC") != 1))
    //{
    //    SetLocalInt(OBJECT_SELF, "GS_CB_BEHAVIOR", GS_CB_BEHAVIOR_ATTACK_PHYSICAL);
    //    gsCBTalentAttack(oTarget);
    //    return;
    //}

    //initial protection
    if (! gsCBGetIsInCombat()) gsCBTalentProtectBySpell();

    DoCombatVoice();

    float fDistance = GetDistanceToObject(oTarget);

    if (GetLocalInt(OBJECT_SELF, "range") == 1 && fDistance >= MIN_RANGE_DISTANCE && fDistance <= 8.0)
    {
        ActionMoveAwayFromObject(oTarget, TRUE, 10.0);
    }

    int nBehavior   = GetLocalInt(OBJECT_SELF, "GS_CB_BEHAVIOR");
    int nAttack     = 80;
    int nSpell      = 20;

    //adjust class behavior
    switch (gsCBDetermineClass())
    {
    case CLASS_TYPE_ABERRATION:
        break;
    case CLASS_TYPE_ANIMAL:
        nAttack = 70;
        break;
    case CLASS_TYPE_ARCANE_ARCHER:
        break;
    case CLASS_TYPE_ASSASSIN:
        nAttack = 70;
        break;
    case CLASS_TYPE_BARBARIAN:
        nAttack = 90;
        nSpell  = 10;
        break;
    case CLASS_TYPE_BARD:
        nAttack = 70;
        nSpell  = 40;
        break;
    case CLASS_TYPE_BEAST:
        nAttack = 90;
        break;
    case CLASS_TYPE_BLACKGUARD:
        nAttack = 90;
        break;
    case CLASS_TYPE_CLERIC:
        nAttack = 70;
        nSpell  = 40;
        break;
    case CLASS_TYPE_COMMONER:
        nAttack = 20;
        break;
    case CLASS_TYPE_CONSTRUCT:
        nAttack = 90;
        nSpell  = 10;
        break;
    case CLASS_TYPE_DRAGON:
        nAttack = 70;
        nSpell  = 30;
        break;
    case CLASS_TYPE_DRAGONDISCIPLE:
        nAttack = 70;
        nSpell  = 40;
        break;
    case CLASS_TYPE_DRUID:
        nAttack = 70;
        nSpell  = 40;
        break;
    case CLASS_TYPE_DWARVENDEFENDER:
        nAttack = 90;
        nSpell  = 10;
        break;
    case CLASS_TYPE_ELEMENTAL:
        nAttack = 90;
        nSpell  = 10;
        break;
    case CLASS_TYPE_FEY:
        nAttack = 70;
        nSpell  = 60;
        break;
    case CLASS_TYPE_FIGHTER:
        nAttack = 90;
        nSpell  = 10;
        break;
    case CLASS_TYPE_GIANT:
        nAttack = 90;
        nSpell  = 10;
        break;
    case CLASS_TYPE_HARPER:
        nAttack = 70;
        nSpell  = 40;
        break;
    case CLASS_TYPE_HUMANOID:
        nAttack = 70;
        break;
    case CLASS_TYPE_MAGICAL_BEAST:
        nAttack = 90;
        nSpell  = 40;
        break;
    case CLASS_TYPE_MONK:
        nAttack = 90;
        nSpell  = 10;
        break;
    case CLASS_TYPE_MONSTROUS:
        nAttack = 90;
        nSpell  = 10;
        break;
    case CLASS_TYPE_OOZE:
        nAttack = 90;
        nSpell  = 10;
        break;
    case CLASS_TYPE_OUTSIDER:
        nSpell  = 30;
        break;
    case CLASS_TYPE_PALADIN:
        nAttack = 90;
        break;
    case CLASS_TYPE_PALEMASTER:
        nAttack = 70;
        nSpell  = 40;
        break;
    case CLASS_TYPE_RANGER:
        nAttack = 70;
        nSpell  = 40;
        break;
    case CLASS_TYPE_ROGUE:
        nAttack = 70;
        break;
    case CLASS_TYPE_SHADOWDANCER:
        nAttack = 70;
        break;
    case CLASS_TYPE_SHAPECHANGER:
        break;
    case CLASS_TYPE_SHIFTER:
        break;
    case CLASS_TYPE_SORCERER:
        nSpell  = 100;
        break;
    case CLASS_TYPE_UNDEAD:
        nAttack = 90;
        nSpell  = 10;
        break;
    case CLASS_TYPE_VERMIN:
        nAttack = 90;
        nSpell  = 10;
        break;
    case CLASS_TYPE_WEAPON_MASTER:
        nAttack = 90;
        nSpell  = 10;
        break;
    case CLASS_TYPE_WIZARD:
        nSpell  = 100;
        break;
    }

    // Override - for custom creature behaviour.
    int nOverrideSpell = GetLocalInt(OBJECT_SELF, "GS_OVERRIDE_SPELL");
    int nOverrideAttack = GetLocalInt(OBJECT_SELF, "GS_OVERRIDE_ATTACK");
    if (nOverrideSpell) nSpell = nOverrideSpell;
    if (nOverrideAttack) nAttack = nOverrideAttack;

    //additional behavior adjustment
    if (fDistance > 5.0)
    {
        nSpell  +=  10;
        nAttack -=  50;
    }

    nSpell -= GetArcaneSpellFailure(OBJECT_SELF);

    if (nBehavior == GS_CB_BEHAVIOR_DEFENSIVE)
    {
        nAttack  = 100;
        SetActionMode(OBJECT_SELF, ACTION_MODE_PARRY, FALSE);
    }

    //primary
    if (gsCBTalentEvadeDarkness())           return;
    if (gsCBTalentDragonWing(oTarget, TRUE)) return;
    //if (gsCBTelegraphAttack(oTarget))        return;

    //defensive
    if (Random(100) >= nAttack)
    {
        SetLocalInt(OBJECT_SELF, "GS_CB_BEHAVIOR", GS_CB_BEHAVIOR_DEFENSIVE);

        if (gsCBTalentHealSelf() || gsCBTalentHealOthers())        return;
        if (Random(100) >= 25 && gsCBTalentCureCondition())        return;
        if (Random(100) >= 25 && gsCBTalentPersistentEffect())     return;
        if (Random(100) >= 25 && gsCBTalentProtectSelf())          return;
        if (Random(100) >= 25 && gsCBTalentProtectOthers())        return;
        if (Random(100) >= 25 && gsCBTalentEnhanceSelf())          return;
        if (Random(100) >= 25 && gsCBTalentEnhanceOthers())        return;
        if (Random(100) >= 25 && gsCBTalentSummonAlly(oTarget))    return;
        if (Random(100) >= 25 && gsCBTalentParry(oTarget))         return;
    }

    //spell
    if (Random(100) < nSpell && LineOfSightObject(OBJECT_SELF, oTarget))
    {
        SetLocalInt(OBJECT_SELF, "GS_CB_BEHAVIOR", GS_CB_BEHAVIOR_ATTACK_SPELL);

        if (Random(100) >= 25 && gsCBTalentUseTurning())           return;
        if (Random(100) >= 25 && gsCBTalentCounterMeasure())       return;
        if (Random(100) >= 25 && gsCBTalentDispelMagic(oTarget))   return;
        if (Random(100) >= 50 && gsCBTalentDragonBreath(oTarget))  return;
        if (gsCBTalentSpellAttack(oTarget))                        return;
    }

    //offensive
    SetLocalInt(OBJECT_SELF, "GS_CB_BEHAVIOR", GS_CB_BEHAVIOR_ATTACK_PHYSICAL);

    // Taunt?
    if (Random(100) >= 80 && gsCBTalentTaunt(oTarget)) return;

    // Feint? NB - this will always return FALSE even if a feint is attempted.
    //if (Random(100) >= 80 && gsCBTalentFeint(oTarget)) return;

    // Note - wing buffet will actually fire every other time this is called.
    if (Random(100) >= 60 && gsCBTalentDragonWing(oTarget)) return;
    gsCBTalentAttack(oTarget);
}
//----------------------------------------------------------------
int gsCBUseTalentOnObject(talent tTalent, object oTarget = OBJECT_SELF)
{
    //SpeakString("Debug: Using talent type " + IntToString(GetTypeFromTalent(tTalent)) + ", number " + IntToString(GetIdFromTalent(tTalent)));
    if (GetIsTalentValid(tTalent))
    {
        int nID   = GetIdFromTalent(tTalent);
        int nType = GetTypeFromTalent(tTalent);

        // Catch talents which aren't useful in combat and suppress them.
        if (gsCBGetHasAttackTarget())
        {
          if (nType == TALENT_TYPE_FEAT && nID == 1089) // Ride menu
          {
            return FALSE;
          }

          if (nType == TALENT_TYPE_SKILL)
          {
            // When we call this method we've done ClearAllActions(), so we won't be attacking.
            // See gsCBTalentParry instead.
            if (nID == SKILL_PARRY) return FALSE;

            // Only try to taunt if (a) we have a valid target and (b) we're good at it...
            // Turns out taunt is never called in a useful context.  Created gsCBTalentTaunt for it instead.
            if (nID == SKILL_TAUNT && (!(GetSkillRank(SKILL_TAUNT, OBJECT_SELF, TRUE) > 0) || oTarget == OBJECT_SELF || !GetIsEnemy(oTarget, OBJECT_SELF))) return FALSE;
          }
        }

        switch (nType)
        {
        case TALENT_TYPE_FEAT:
            return gsCBUseFeatOnObject(nID, oTarget);

        case TALENT_TYPE_SKILL:
            if (GetHasSkill(nID))
            {
                if (nID == SKILL_HEAL)
                {
                  object oKit = GetFirstItemInInventory();

                  while(GetIsObjectValid(oKit))
                  {
                    // Get if healers kit
                    if(GetBaseItemType(oKit) == BASE_ITEM_HEALERSKIT)
                    {
                      break;
                    }

                    oKit = GetNextItemInInventory();
                  }

                  // Check oKit
                  if(GetIsObjectValid(oKit))
                  {
                    // Use our heal skill.
                    ActionUseSkill(SKILL_HEAL, OBJECT_SELF, 0, oKit);
                  }
                  else
                  {
                    // No healing kit - cannot heal.
                    return FALSE;
                  }
                }

                ActionUseSkill(nID, oTarget);
                return TRUE;
            }
            break;

        case TALENT_TYPE_SPELL:
            return gsCBCastSpellAtObject(GetIdFromTalent(tTalent), oTarget);
        }
    }

    return FALSE;
}
//----------------------------------------------------------------
int gsCBUseFeatOnObject(int nFeat, object oTarget = OBJECT_SELF)
{
    if (gsC3VerifyFeat(nFeat, oTarget))
    {
        ActionUseFeat(nFeat, oTarget);
        return TRUE;
    }

    return FALSE;
}
//----------------------------------------------------------------
int gsCBCastSpellAtObject(int nSpell, object oTarget = OBJECT_SELF)
{
    if (gsC3VerifySpell(nSpell, oTarget))
    {
        ActionCastSpellAtObject(nSpell, oTarget);
        return TRUE;
    }

    return FALSE;
}
//----------------------------------------------------------------
int gsCBTalentSelf(int nTalentCategorySelf,
                   int nTalentCategorySingle = FALSE,
                   int nTalentCategoryPotion = FALSE,
                   int nTalentCategoryArea   = FALSE)
{
    talent tTalent = GetCreatureTalentBest(nTalentCategorySelf, 100);

    if (! GetIsTalentValid(tTalent) && nTalentCategorySingle)
    {
        tTalent = GetCreatureTalentBest(nTalentCategorySingle, 100);

        if (! GetIsTalentValid(tTalent) && nTalentCategoryPotion)
        {
            tTalent = GetCreatureTalentBest(nTalentCategoryPotion, 100);

            if (! GetIsTalentValid(tTalent) && nTalentCategoryArea)
            {
                tTalent = GetCreatureTalentBest(nTalentCategoryArea, 100);
            }
        }
    }

    return gsCBUseTalentOnObject(tTalent);
}
//----------------------------------------------------------------
int gsCBTalentOthers(int nTalentCategoryArea,
                     int nTalentCategorySingle = FALSE)
{
    object oTarget = OBJECT_INVALID;
    talent tTalent = GetCreatureTalentBest(nTalentCategoryArea, 100);
    int nNth       = 0;
    int nCount     = 0;

    if (GetIsTalentValid(tTalent))
    {
        nNth    = 1;
        oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND,
                                     OBJECT_SELF, 1,
                                     CREATURE_TYPE_IS_ALIVE, TRUE,
                                     CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);

        while (GetIsObjectValid(oTarget) &&
               GetDistanceToObject(oTarget) <= 10.0)
        {
            nCount  = gsCBGetCreatureCountAtLocation(GetLocation(oTarget),
                                                     TRUE, FALSE, FALSE);

            if (d3() >= nCount && gsCBUseTalentOnObject(tTalent, oTarget)) return TRUE;
            if (++nNth > 3)                                                break;

            oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND,
                                         OBJECT_SELF, nNth,
                                         CREATURE_TYPE_IS_ALIVE, TRUE,
                                         CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
        }
    }

    if (nTalentCategorySingle)
    {
        tTalent = GetCreatureTalentBest(nTalentCategorySingle, 100);

        if (GetIsTalentValid(tTalent))
        {
            nNth    = 1;
            oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND,
                                         OBJECT_SELF, 1,
                                         CREATURE_TYPE_IS_ALIVE, TRUE,
                                         CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);

            while (GetIsObjectValid(oTarget) &&
                   GetDistanceToObject(oTarget) <= 10.0)
            {
                if (gsCBUseTalentOnObject(tTalent, oTarget)) return TRUE;
                if (++nNth > 3)                              break;

                oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND,
                                             OBJECT_SELF, nNth,
                                             CREATURE_TYPE_IS_ALIVE, TRUE,
                                             CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
            }
        }
    }

    return FALSE;
}
//----------------------------------------------------------------
int gsCBTalentProtectSelf()
{
    return gsCBTalentSelf(TALENT_CATEGORY_BENEFICIAL_PROTECTION_SELF,
                          TALENT_CATEGORY_BENEFICIAL_PROTECTION_SINGLE,
                          TALENT_CATEGORY_BENEFICIAL_PROTECTION_POTION,
                          TALENT_CATEGORY_BENEFICIAL_PROTECTION_AREAEFFECT);
}
//----------------------------------------------------------------
int gsCBTalentProtectOthers()
{
    return gsCBTalentOthers(TALENT_CATEGORY_BENEFICIAL_PROTECTION_AREAEFFECT,
                            TALENT_CATEGORY_BENEFICIAL_PROTECTION_SINGLE);
}
//----------------------------------------------------------------
int gsCBTalentEnhanceSelf()
{
    return gsCBTalentSelf(TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_SELF,
                          TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_SINGLE,
                          TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_POTION,
                          TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_AREAEFFECT);
}
//----------------------------------------------------------------
int gsCBTalentEnhanceOthers()
{
    return gsCBTalentOthers(TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_AREAEFFECT,
                            TALENT_CATEGORY_BENEFICIAL_ENHANCEMENT_SINGLE);
}
//----------------------------------------------------------------
int gsCBTalentPersistentEffect()
{
    return gsCBTalentSelf(TALENT_CATEGORY_PERSISTENT_AREA_OF_EFFECT);
}
//----------------------------------------------------------------
int gsCBTalentHealSelf()
{
    if (gsC2GetIsDamaged() &&
        GetRacialType(OBJECT_SELF) != RACIAL_TYPE_UNDEAD)
    {
        return gsCBTalentSelf(FALSE,
                              TALENT_CATEGORY_BENEFICIAL_HEALING_TOUCH,
                              TALENT_CATEGORY_BENEFICIAL_HEALING_POTION,
                              TALENT_CATEGORY_BENEFICIAL_HEALING_AREAEFFECT);
    }

    return FALSE;
}
//----------------------------------------------------------------
int gsCBTalentHealOthers()
{
    object oTarget = gsCBGetCreatureAtLocation(
        GetLocation(OBJECT_SELF),
        TRUE, FALSE, FALSE,
        0.0, 20.0,
        RACIAL_TYPE_ALL & ~RACIAL_TYPE_UNDEAD,
        TRUE);

    if (! GetIsObjectValid(oTarget)) return FALSE;

    talent tTalent;
    int nCount     = gsCBGetCreatureCountAtLocation(
        GetLocation(oTarget),
        TRUE, FALSE, FALSE,
        0.0, 5.0,
        RACIAL_TYPE_ALL & ~RACIAL_TYPE_UNDEAD,
        TRUE);

    if (nCount > 1)
    {
        tTalent = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_HEALING_AREAEFFECT, 100);
        if (! GetIsTalentValid(tTalent))
            tTalent = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_HEALING_TOUCH, 100);
    }
    else
    {
        tTalent = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_HEALING_TOUCH, 100);
        if (! GetIsTalentValid(tTalent))
            tTalent = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_HEALING_AREAEFFECT, 100);
    }

    return gsCBUseTalentOnObject(tTalent, oTarget);
}
//----------------------------------------------------------------
int gsCBTalentCureCondition()
{
    object oTarget     = OBJECT_INVALID;
    location lLocation = GetLocation(OBJECT_SELF);

    if (GetHasSpell(SPELL_GREATER_RESTORATION)) //7
    {
        oTarget = _gsCBTalentCureCondition(lLocation, GS_C2_GREATER_RESTORATION);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_GREATER_RESTORATION, oTarget))
        {
            return TRUE;
        }
    }

    if (GetHasSpell(SPELL_RESTORATION)) //4
    {
        oTarget = _gsCBTalentCureCondition(lLocation, GS_C2_RESTORATION);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_RESTORATION, oTarget))
        {
            return TRUE;
        }
    }

    if (GetHasSpell(SPELL_LESSER_RESTORATION)) //2
    {
        oTarget = _gsCBTalentCureCondition(lLocation, GS_C2_LESSER_RESTORATION);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_LESSER_RESTORATION, oTarget))
        {
            return TRUE;
        }
    }

    if (GetHasSpell(SPELL_STONE_TO_FLESH))
    {
        oTarget = _gsCBTalentCureCondition(lLocation, GS_C2_STONE_TO_FLESH);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_STONE_TO_FLESH, oTarget))
        {
            return TRUE;
        }
    }

    if (GetHasSpell(SPELL_FREEDOM_OF_MOVEMENT)) //4
    {
        oTarget = _gsCBTalentCureCondition(lLocation, GS_C2_FREEDOM_OF_MOVEMENT);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_FREEDOM_OF_MOVEMENT, oTarget))
        {
            return TRUE;
        }
    }

    if (GetHasSpell(SPELL_REMOVE_PARALYSIS)) //2
    {
        oTarget = _gsCBTalentCureCondition(lLocation, GS_C2_REMOVE_PARALYSIS);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_REMOVE_PARALYSIS, oTarget))
        {
            return TRUE;
        }
    }

    if (GetHasSpell(SPELL_MIND_BLANK)) //8
    {
        oTarget = _gsCBTalentCureCondition(lLocation, GS_C2_MIND_BLANK);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_MIND_BLANK, oTarget))
        {
            return TRUE;
        }
    }

    if (GetHasSpell(SPELL_LESSER_MIND_BLANK)) //5
    {
        oTarget = _gsCBTalentCureCondition(lLocation, GS_C2_LESSER_MIND_BLANK);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_LESSER_MIND_BLANK, oTarget))
        {
            return TRUE;
        }
    }

    if (GetHasSpell(SPELL_CLARITY)) //2
    {
        oTarget = _gsCBTalentCureCondition(lLocation, GS_C2_CLARITY);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_CLARITY, oTarget))
        {
            return TRUE;
        }
    }

    if (GetHasSpell(SPELL_REMOVE_BLINDNESS_AND_DEAFNESS)) //3
    {
        oTarget = _gsCBTalentCureCondition(lLocation, GS_C2_REMOVE_BLINDNESS_AND_DEAFNESS);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_REMOVE_BLINDNESS_AND_DEAFNESS, oTarget))
        {
            return TRUE;
        }
    }

    if (GetHasSpell(SPELL_REMOVE_FEAR)) //1
    {
        oTarget = _gsCBTalentCureCondition(lLocation, GS_C2_REMOVE_FEAR);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_REMOVE_FEAR, oTarget))
        {
            return TRUE;
        }
    }

    if (GetHasSpell(SPELL_NEUTRALIZE_POISON)) //3
    {
        oTarget = _gsCBTalentCureCondition(lLocation, GS_C2_NEUTRALIZE_POISON);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_NEUTRALIZE_POISON, oTarget))
        {
            return TRUE;
        }
    }

    if (GetHasSpell(SPELL_REMOVE_DISEASE)) //3
    {
        oTarget = _gsCBTalentCureCondition(lLocation, GS_C2_REMOVE_DISEASE);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_REMOVE_DISEASE, oTarget))
        {
            return TRUE;
        }
    }

    if (GetHasSpell(SPELL_REMOVE_CURSE)) //3
    {
        oTarget = _gsCBTalentCureCondition(lLocation, GS_C2_REMOVE_CURSE);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_REMOVE_CURSE, oTarget))
        {
            return TRUE;
        }
    }

    return FALSE;
}
//----------------------------------------------------------------
object _gsCBTalentCureCondition(location lLocation, int nRequiredAid)
{
    return gsCBGetCreatureAtLocation(
        lLocation,
        TRUE, FALSE, FALSE,
        0.0, 20.0,
        RACIAL_TYPE_ALL,
        FALSE, nRequiredAid);
}
//----------------------------------------------------------------
int gsCBTalentCounterMeasure()
{
    object oTarget     = OBJECT_INVALID;
    location lLocation = GetLocation(OBJECT_SELF);

    if (! (gsC2GetHasEffect(EFFECT_TYPE_TRUESEEING) ||
           gsC2GetHasEffect(EFFECT_TYPE_SEEINVISIBLE)))
    {
        if (GetHasSpell(SPELL_TRUE_SEEING)) //5
        {
            oTarget = _gsCBTalentCounterMeasure(lLocation, GS_C2_TRUE_SEEING);
            if (GetIsObjectValid(oTarget) &&
                gsCBCastSpellAtObject(SPELL_TRUE_SEEING, OBJECT_SELF))
            {
                return TRUE;
            }
        }

        if (GetHasSpell(SPELL_SEE_INVISIBILITY)) //2
        {
            oTarget = _gsCBTalentCounterMeasure(lLocation, GS_C2_SEE_INVISIBILITY);
            if (GetIsObjectValid(oTarget) &&
                gsCBCastSpellAtObject(SPELL_SEE_INVISIBILITY, OBJECT_SELF))
            {
                return TRUE;
            }
        }
    }

    if (GetHasSpell(SPELL_INVISIBILITY_PURGE)) //3
    {
        oTarget = _gsCBTalentCounterMeasure(lLocation, GS_C2_INVISIBILITY_PURGE);
        if (GetIsObjectValid(oTarget) &&
            gsCBCastSpellAtObject(SPELL_SEE_INVISIBILITY, oTarget))
        {
            return TRUE;
        }
    }

    return FALSE;
}
//----------------------------------------------------------------
object _gsCBTalentCounterMeasure(location lLocation, int nCounterMeasure)
{
    return gsCBGetCreatureAtLocation(
        lLocation,
        FALSE, FALSE, TRUE,
        0.0, 10.0,
        RACIAL_TYPE_ALL,
        FALSE, FALSE, nCounterMeasure);
}
//----------------------------------------------------------------
int gsCBTalentSummonAlly(object oTarget = OBJECT_SELF)
{
    return gsCBUseTalentOnObject(
        GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_OBTAIN_ALLIES, 100),
        oTarget);
}
//----------------------------------------------------------------
int gsCBTalentUseTurning()
{
    if (GetHasFeat(FEAT_TURN_UNDEAD))
    {
        location lLocation = GetLocation(OBJECT_SELF);
        int nRace          = RACIAL_TYPE_UNDEAD;

        if (GetHasFeat(FEAT_DESTRUCTION_DOMAIN_POWER))
        {
            nRace |= RACIAL_TYPE_CONSTRUCT;
        }
        if (GetHasFeat(FEAT_AIR_DOMAIN_POWER) ||
            GetHasFeat(FEAT_EARTH_DOMAIN_POWER) ||
            GetHasFeat(FEAT_FIRE_DOMAIN_POWER) ||
            GetHasFeat(FEAT_FIRE_DOMAIN_POWER))
        {
            nRace |= RACIAL_TYPE_ELEMENTAL;
        }
        if (GetHasFeat(FEAT_GOOD_DOMAIN_POWER) ||
            GetHasFeat(FEAT_EVIL_DOMAIN_POWER))
        {
            nRace |= RACIAL_TYPE_OUTSIDER;
        }
        if (GetHasFeat(FEAT_PLANT_DOMAIN_POWER) ||
            GetHasFeat(FEAT_ANIMAL_COMPANION))
        {
            nRace |= RACIAL_TYPE_VERMIN;
        }

        return gsCBGetCreatureCountAtLocation(lLocation, FALSE, FALSE, TRUE, 0.0, 10.0, nRace) &&
               gsCBUseFeatOnObject(FEAT_TURN_UNDEAD);
    }

    return FALSE;
}
//----------------------------------------------------------------
int gsCBTalentDragonBreath(object oTarget)
{
    talent tTalent    = GetCreatureTalentBest(TALENT_CATEGORY_DRAGONS_BREATH, 100);
    int nTalentID     = 0;
    int nLastTalentID = GetLocalInt(OBJECT_SELF, "GS_CB_TALENT_BREATH");

    if (GetIsTalentValid(tTalent))
    {
        nTalentID = GetIdFromTalent(tTalent);

        if (nTalentID == nLastTalentID)
        {
            tTalent   = GetCreatureTalentRandom(TALENT_CATEGORY_DRAGONS_BREATH);
            nTalentID = GetIdFromTalent(tTalent);
        }

        if (gsCBUseTalentOnObject(tTalent, oTarget))
        {
            SetLocalInt(OBJECT_SELF, "GS_CB_TALENT_BREATH", nTalentID);
            return TRUE;
        }
    }

    DeleteLocalInt(OBJECT_SELF, "GS_CB_TALENT_BREATH");
    return FALSE;
}
//----------------------------------------------------------------
int gsCBTalentTaunt(object oTarget)
{
  int nDistance = GetDistanceToObject(oTarget) > 2.5;

  if (nDistance ||
      !(GetSkillRank(SKILL_TAUNT, OBJECT_SELF, TRUE) > 0) ||
      oTarget == OBJECT_SELF ||
      !GetIsEnemy(oTarget, OBJECT_SELF))
  {
    return FALSE;
  }

  FloatingTextStringOnCreature(GetName(OBJECT_SELF) + " taunts you!", oTarget);
  ActionUseSkill(SKILL_TAUNT, oTarget);
  return TRUE;
}
//----------------------------------------------------------------
/*
int gsCBTalentFeint(object oTarget)
{
  if (!(GetSkillRank(SKILL_TAUNT, OBJECT_SELF, TRUE) > 0)) return FALSE;
  if (GetArea(oTarget) != GetArea(OBJECT_SELF)) return FALSE;

  if (GetDistanceToObject(oTarget) > 2.5 || GetDistanceToObject(oTarget) == 0.0f) return FALSE;

  //--------------------------------------------------------------
  // Mimic the effect of Taunt, but for attack bonus.  5 rounds.
  // Hide vs Discipline, penalty of the amount the feinter wins by,
  // up to 5.  Tag the effect so multiples don't stack.
  // NB: we want to use INT not DEX here, so adjust accordingly.
  //--------------------------------------------------------------
  int nCheck = (d20() + GetSkillRank(SKILL_HIDE, OBJECT_SELF)) +
               (GetAbilityModifier(ABILITY_INTELLIGENCE) - GetAbilityModifier(ABILITY_DEXTERITY, oTarget)) -
               (d20() + GetSkillRank(SKILL_DISCIPLINE, oTarget));

  FloatingTextStringOnCreature(GetName(OBJECT_SELF) + " feints!", oTarget);

  if (nCheck <= 0)
  {
    // Nothing happens.
  }
  else
  {
    if (nCheck > 6) nCheck = 6;
    effect eFeint = TagEffect(ExtraordinaryEffect(EffectAttackDecrease(nCheck)), "FEINT");

    effect eEffect = GetFirstEffect(oTarget);
    while (GetIsEffectValid(eEffect))
    {
      if (GetEffectTag(eEffect) == "FEINT")
      {
        RemoveEffect(oTarget, eEffect);
        break;
      }

      eEffect = GetNextEffect(oTarget);
    }

    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eFeint, oTarget, 30.0f);
  }

  // Feint is a free action.  Carry on with other parts of the action queue.
  return FALSE;
}
*/
//----------------------------------------------------------------
int gsCBTalentParry(object oTarget)
{
    int nDistance = GetDistanceToObject(oTarget) > 2.5;

    if (!nDistance && GetSkillRank(SKILL_PARRY, OBJECT_SELF, TRUE) > 0)
    {
        FloatingTextStringOnCreature(GetName(OBJECT_SELF) + " parries!", oTarget);
        SetActionMode(OBJECT_SELF, ACTION_MODE_PARRY, TRUE);
        gsCBEquipMeleeWeapon(oTarget);
        ActionAttack(oTarget);
        return TRUE;
    }

    return FALSE;
}
//----------------------------------------------------------------
int gsCBTalentDragonWing(object oTarget, int nFly = FALSE)
{
    int canFly = GetLocalInt(OBJECT_SELF, "AR_CAN_FLY") == TRUE;

    if (!canFly && GetRacialType(OBJECT_SELF) != RACIAL_TYPE_DRAGON) return FALSE;

    if (nFly)
    {
        if (GetDistanceToObject(oTarget) > RADIUS_SIZE_COLOSSAL)
        {
            ActionDoCommand(_gsCBTalentDragonWing(oTarget));
            return TRUE;
        }
    }
    else if (___gsCBTalentDragonWing(GetLocation(OBJECT_SELF)))
    {
        ActionDoCommand(__gsCBTalentDragonWing(oTarget));
        return TRUE;
    }

    return FALSE;
}
//----------------------------------------------------------------
void _gsCBTalentDragonWing(object oObject)
{
    location lSelf     = GetLocation(OBJECT_SELF);
    location lLocation = GetLocation(oObject);
    effect eEffect     = EffectVisualEffect(VFX_IMP_PULSE_WIND);
    float fDistance    = GetDistanceToObject(oObject);
    float fDelay       = fDistance / 10.0 + 3.0;

    ClearAllActions();

    SetFacingPoint(GetPosition(oObject));
    ApplyEffectToObject(
        DURATION_TYPE_TEMPORARY,
        EffectDisappearAppear(lLocation),
        OBJECT_SELF,
        fDelay);

    if (___gsCBTalentDragonWing(lSelf))
    {
        ____gsCBTalentDragonWing(lSelf);
    }
    else
    {
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eEffect, lSelf);
    }

    if (___gsCBTalentDragonWing(lLocation))
    {
        DelayCommand(
            fDelay + 1.0,
            ____gsCBTalentDragonWing(lLocation));
    }
    else
    {
        DelayCommand(
            fDelay + 1.0,
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eEffect, lLocation));
    }

    DelayCommand(fDelay + 1.5, SetCommandable(TRUE));
    DelayCommand(fDelay + 2.0, ActionAttack(oObject));

    SetCommandable(FALSE);
}
//----------------------------------------------------------------
void __gsCBTalentDragonWing(object oObject)
{
    ClearAllActions();

    ApplyEffectToObject(
        DURATION_TYPE_INSTANT,
        EffectAppear(),
        OBJECT_SELF);

    ____gsCBTalentDragonWing(GetLocation(OBJECT_SELF));

    DelayCommand(1.5, SetCommandable(TRUE));
    DelayCommand(2.0, ActionAttack(oObject));

    SetCommandable(FALSE);
}
//----------------------------------------------------------------
int ___gsCBTalentDragonWing(location lLocation)
{
    if (GetCreatureSize(OBJECT_SELF) != CREATURE_SIZE_HUGE) return FALSE;

    // Avoid doing it two rounds in a row.
    if (GetLocalInt(OBJECT_SELF, "WINGED"))
    {
      DeleteLocalInt(OBJECT_SELF, "WINGED");
      return FALSE;
    }
    else
    {
      SetLocalInt(OBJECT_SELF, "WINGED", TRUE);
    }

    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, lLocation);
    int nFlag      = FALSE;

    while (GetIsObjectValid(oTarget))
    {
        if (oTarget != OBJECT_SELF &&
            GetCreatureSize(oTarget) != CREATURE_SIZE_HUGE)
        {
            if (GetIsEnemy(oTarget)) nFlag = TRUE;
            else                     return FALSE;
        }

        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, lLocation);
    }

    return nFlag;
}
//----------------------------------------------------------------
void ____gsCBTalentDragonWing(location lLocation)
{
    object oCreature = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, lLocation);
    effect eEffect   = EffectKnockdown();
    float fDistance  = 0.0;
    float fDelay     = 0.0;
    float fDuration  = RoundsToSeconds(2);
    int nHitDice     = GetHitDice(OBJECT_SELF);

    ApplyEffectAtLocation(
        DURATION_TYPE_INSTANT,
        EffectVisualEffect(VFX_IMP_PULSE_WIND),
        lLocation);

    while (GetIsObjectValid(oCreature))
    {
        if (oCreature != OBJECT_SELF &&
            GetCreatureSize(oCreature) != CREATURE_SIZE_HUGE &&
            ! FortitudeSave(oCreature, nHitDice))
        {
            fDistance = GetDistanceToObject(oCreature);
            fDelay    = fDistance / 20.0;

            if (fDistance <= RADIUS_SIZE_GARGANTUAN)
            {
                DelayCommand(fDelay,
                    ApplyEffectToObject(
                        DURATION_TYPE_INSTANT,
                        EffectDamage(Random(nHitDice) + 11, DAMAGE_TYPE_BLUDGEONING),
                        oCreature));
            }

            DelayCommand(fDelay,
                ApplyEffectToObject(
                    DURATION_TYPE_TEMPORARY,
                    eEffect,
                    oCreature,
                    fDuration));
        }

        oCreature = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, lLocation);
    }
}
//----------------------------------------------------------------
int gsCBTalentSpellAttack(object oTarget)
{
    talent tTalent;
    location lTarget        = GetLocation(oTarget);
    float fDistance         = GetDistanceToObject(oTarget);
    int nEnemy              = gsCBGetCreatureCountAtLocation(
                                  lTarget,
                                  FALSE, FALSE, TRUE,
                                  0.0, 10.0);
    int nFriend             = gsCBGetCreatureCountAtLocation(
                                  lTarget,
                                  TRUE, TRUE, FALSE,
                                  0.0, 10.0);
    int nAreaDiscriminant   = -1;
    int nAreaIndiscriminant = -1;
    int nSingleRanged       = -1;
    int nSingleTouch        = -1;
    int nSpell              = -1;
    int nNth                =  0;

    tTalent = GetCreatureTalentBest(TALENT_CATEGORY_HARMFUL_AREAEFFECT_DISCRIMINANT, 100);
    if (GetIsTalentValid(tTalent))
    {
        nAreaDiscriminant   = GetIdFromTalent(tTalent);
        if (! gsC3VerifySpell(nAreaDiscriminant, oTarget))
        {
            for (nNth = 0; nNth < 2; nNth++)
            {
                tTalent             = GetCreatureTalentRandom(TALENT_CATEGORY_HARMFUL_AREAEFFECT_DISCRIMINANT);
                nAreaDiscriminant   = GetIdFromTalent(tTalent);
                if (gsC3VerifySpell(nAreaDiscriminant, oTarget)) break;
                nAreaDiscriminant   = -1;
            }
        }
    }

    if (! nFriend)
    {
        tTalent = GetCreatureTalentBest(TALENT_CATEGORY_HARMFUL_AREAEFFECT_INDISCRIMINANT, 100);
        if (GetIsTalentValid(tTalent))
        {
            nAreaIndiscriminant = GetIdFromTalent(tTalent);
            if (! gsC3VerifySpell(nAreaIndiscriminant, oTarget))
            {
                for (nNth = 0; nNth < 2; nNth++)
                {
                    tTalent             = GetCreatureTalentRandom(TALENT_CATEGORY_HARMFUL_AREAEFFECT_INDISCRIMINANT);
                    nAreaIndiscriminant = GetIdFromTalent(tTalent);
                    if (gsC3VerifySpell(nAreaIndiscriminant, oTarget)) break;
                    nAreaIndiscriminant = -1;
                }
            }
        }
    }

    tTalent = GetCreatureTalentBest(TALENT_CATEGORY_HARMFUL_RANGED, 100);
    if (GetIsTalentValid(tTalent))
    {
        nSingleRanged       = GetIdFromTalent(tTalent);
        if (! gsC3VerifySpell(nSingleRanged, oTarget))
        {
            for (nNth = 0; nNth < 2; nNth++)
            {
                tTalent             = GetCreatureTalentRandom(TALENT_CATEGORY_HARMFUL_RANGED);
                nSingleRanged       = GetIdFromTalent(tTalent);
                if (gsC3VerifySpell(nSingleRanged, oTarget)) break;
                nSingleRanged       = -1;
            }
        }
    }

    tTalent = GetCreatureTalentBest(TALENT_CATEGORY_HARMFUL_TOUCH, 100);
    if (GetIsTalentValid(tTalent))
    {
        nSingleTouch        = GetIdFromTalent(tTalent);
        if (! gsC3VerifySpell(nSingleTouch, oTarget))
        {
            for (nNth = 0; nNth < 2; nNth++)
            {
                tTalent             = GetCreatureTalentRandom(TALENT_CATEGORY_HARMFUL_TOUCH);
                nSingleTouch        = GetIdFromTalent(tTalent);
                if (gsC3VerifySpell(nSingleTouch, oTarget)) break;
                nSingleTouch        = -1;
            }
        }
    }

    if (fDistance > 10.0)
    {
        if (nEnemy == 1) nSpell = nSingleRanged;
        if (nSpell == -1)
        {
            nSpell = nAreaIndiscriminant;
            if (nSpell == -1)
            {
                nSpell = nAreaDiscriminant;
                if (nSpell == -1)
                {
                    nSpell = nSingleRanged;
                    if (nSpell == -1) nSpell = nSingleTouch;
                }
            }
        }

        return nSpell != -1 && gsCBCastSpellAtObject(nSpell, oTarget);
    }

    if (nEnemy == 1)
    {
        if (fDistance <= 2.5) nSpell = nSingleTouch;
        if (nSpell == -1)     nSpell = nSingleRanged;
    }
    if (nSpell == -1)
    {
        nSpell = nAreaDiscriminant;
        if (nSpell == -1)
        {
            if (fDistance <= 2.5) nSpell = nSingleTouch;
            if (nSpell == -1)
            {
                nSpell = nSingleRanged;
                if (nSpell == -1) nSpell = nSingleTouch;
            }
        }
    }

    return nSpell != -1 && gsCBCastSpellAtObject(nSpell, oTarget);
}
//----------------------------------------------------------------
void gsCBTalentAttack(object oTarget)
{
    float fMeleeDistance = 5.0;

    if (GetLocalInt(OBJECT_SELF, "range") == 1)
    fMeleeDistance = MIN_RANGE_DISTANCE;

    int nDistance = GetDistanceToObject(oTarget) > fMeleeDistance;

    // Dunshine: extra check here, to see if the creature is not in a Cordor Arena fight, if so, only allow the ability during the fight, not before/after it
    //int iArena = GetLocalInt(OBJECT_SELF,"iArena");

    if ((nDistance)) //&& ((iArena == 0) || (iArena == 2)))
    {
      //string sYoinkText = GetLocalString(OBJECT_SELF, "MI_TALENT_YOINK");
      //string sJumpText  = GetLocalString(OBJECT_SELF, "MI_TALENT_JUMP");
      /*
      if ((sYoinkText != "") &&
          LineOfSightObject(OBJECT_SELF, oTarget) &&
          GetDistanceToObject(oTarget) < 25.0)
      {
        object oAttacker = OBJECT_SELF;

        // Some creatures can yoink PCs to them.
        SpeakString("*" + sYoinkText + " " + svGetPCNameOverride(oTarget) + "*");
        AssignCommand(oTarget, ClearAllActions());
        AssignCommand(oTarget, ActionJumpToObject(oAttacker, FALSE));
      }
      else
      if ((sJumpText != "") &&
          //LineOfSightObject(OBJECT_SELF, oTarget) &&  -- removed to see if it fixes TMI issues.
          GetDistanceToObject(oTarget) < 25.0)
      {
        // Some creatures can jump to their enemies.
        SpeakString("*" + sJumpText + " " + svGetPCNameOverride(oTarget) + "*");
        ActionJumpToObject(oTarget, FALSE);
      }
      else
      {*/
        ActionEquipMostDamagingRanged(oTarget);
      //}
    }
    else
    {
        gsCBEquipMeleeWeapon(oTarget);
    }

    ActionDoCommand(_gsCBTalentAttack(oTarget, nDistance));
}
//----------------------------------------------------------------
void _gsCBTalentAttack(object oTarget, int nDistance)
{
    if (Random(2))
    {
        talent tTalent = GetCreatureTalentRandom(
                             nDistance ?
                             TALENT_CATEGORY_HARMFUL_RANGED :
                             TALENT_CATEGORY_HARMFUL_MELEE);

        gsCBUseTalentOnObject(tTalent, oTarget);
    }

    ActionAttack(oTarget);
}
//----------------------------------------------------------------
int gsCBTalentFollow()
{
    if (GetLevelByClass(CLASS_TYPE_COMMONER)) return FALSE;

    object oTarget1 = OBJECT_INVALID;
    int nFlag       = FALSE;

    if (GetCurrentHitPoints() > GetMaxHitPoints() * 25 / 100)
    {
        oTarget1 = gsCBGetLastAttackTarget();

        if (GetIsObjectValid(oTarget1))
        {
            if (GetArea(oTarget1) == GetArea(OBJECT_SELF))
            {
                nFlag = TRUE;
            }
            else
            {
                object oTarget2 = GetLocalObject(OBJECT_SELF, "GS_CB_FOLLOW_TARGET");
                int nCounter    = 0;

                if (oTarget1 == oTarget2)
                    nCounter = GetLocalInt(OBJECT_SELF, "GS_CB_FOLLOW_COUNTER");

                if (nCounter < 10)
                {
                    if (! nCounter) ClearAllActions(TRUE);
                    ActionMoveToLocation(GetLocation(oTarget1), TRUE);
                    SetLocalObject(OBJECT_SELF, "GS_CB_FOLLOW_TARGET", oTarget1);
                    SetLocalInt(OBJECT_SELF, "GS_CB_FOLLOW_COUNTER", nCounter + 1);
                    return TRUE;
                }
            }
        }
    }

    DeleteLocalObject(OBJECT_SELF, "GS_CB_FOLLOW_TARGET");
    DeleteLocalInt(OBJECT_SELF, "GS_CB_FOLLOW_COUNTER");
    if (nFlag) gsCBDetermineCombatRound(oTarget1);
    return FALSE;
}
//----------------------------------------------------------------
int gsCBTalentProtectBySpell()
{
    object oPC    = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC);
    int nInstant  = GetDistanceToObject(oPC) > 10.0;
    int nValue    = FALSE;

    //invisibility
    nValue       |= _gsCBTalentProtectBySpell(SPELL_ETHEREALNESS, nInstant) || //7
                    _gsCBTalentProtectBySpell(SPELL_IMPROVED_INVISIBILITY, nInstant) || //4
                    _gsCBTalentProtectBySpell(SPELL_INVISIBILITY_SPHERE, nInstant) || //3
                    _gsCBTalentProtectBySpell(SPELL_INVISIBILITY, nInstant) || //2
                    _gsCBTalentProtectBySpell(SPELL_SANCTUARY, nInstant); //1

    //combat protection
    nValue       |= _gsCBTalentProtectBySpell(SPELL_PREMONITION, nInstant) || //8
                    _gsCBTalentProtectBySpell(SPELL_GREATER_STONESKIN, nInstant) || //6
                    _gsCBTalentProtectBySpell(SPELL_STONESKIN, nInstant) || //4
                    _gsCBTalentProtectBySpell(SPELL_SHADES_STONESKIN, nInstant) || //4
                    _gsCBTalentProtectBySpell(SPELL_BARKSKIN, nInstant); //2

    //visage protection
    nValue       |= _gsCBTalentProtectBySpell(SPELL_SHADOW_SHIELD, nInstant) || //7
                    _gsCBTalentProtectBySpell(SPELL_ETHEREAL_VISAGE, nInstant) || //5
                    _gsCBTalentProtectBySpell(SPELL_GHOSTLY_VISAGE, nInstant) || //2
                    _gsCBTalentProtectBySpell(SPELL_GREATER_SHADOW_CONJURATION_MIRROR_IMAGE, nInstant); //2

    //mantle protection
    nValue       |= _gsCBTalentProtectBySpell(SPELL_GREATER_SPELL_MANTLE, nInstant) || //9
                    _gsCBTalentProtectBySpell(SPELL_SPELL_MANTLE, nInstant) || //7
                    _gsCBTalentProtectBySpell(SPELL_LESSER_SPELL_MANTLE, nInstant); //5

    //globe protection
    nValue       |= _gsCBTalentProtectBySpell(SPELL_GLOBE_OF_INVULNERABILITY, nInstant) || //6
                    _gsCBTalentProtectBySpell(SPELL_MINOR_GLOBE_OF_INVULNERABILITY, nInstant) || //4
                    _gsCBTalentProtectBySpell(SPELL_GREATER_SHADOW_CONJURATION_MINOR_GLOBE, nInstant); //4

    //damage shield
    nValue       |= _gsCBTalentProtectBySpell(SPELL_MESTILS_ACID_SHEATH, nInstant) || //5
                    _gsCBTalentProtectBySpell(SPELL_ELEMENTAL_SHIELD, nInstant) || //4
                    _gsCBTalentProtectBySpell(SPELL_WOUNDING_WHISPERS, nInstant) || //3
                    _gsCBTalentProtectBySpell(SPELL_DEATH_ARMOR, nInstant); //2

    //elemental protection
    nValue       |= _gsCBTalentProtectBySpell(SPELL_ENERGY_BUFFER, nInstant) || //5
                    _gsCBTalentProtectBySpell(SPELL_PROTECTION_FROM_ELEMENTS, nInstant) || //3
                    _gsCBTalentProtectBySpell(SPELL_RESIST_ELEMENTS, nInstant) || //2
                    _gsCBTalentProtectBySpell(SPELL_ENDURE_ELEMENTS, nInstant); //1

    //mind protection
    nValue       |= _gsCBTalentProtectBySpell(SPELL_MIND_BLANK, nInstant) || //8
                    _gsCBTalentProtectBySpell(SPELL_LESSER_MIND_BLANK, nInstant) || //5
                    _gsCBTalentProtectBySpell(SPELL_CLARITY, nInstant); //2

    //vision
    nValue       |= _gsCBTalentProtectBySpell(SPELL_TRUE_SEEING, nInstant) || //6
                    _gsCBTalentProtectBySpell(SPELL_INVISIBILITY_PURGE, nInstant) || //3
                    _gsCBTalentProtectBySpell(SPELL_SEE_INVISIBILITY, nInstant); //2

    return nValue;
}
//----------------------------------------------------------------
int _gsCBTalentProtectBySpell(int nSpell, int nInstant = FALSE)
{
    if (gsC3VerifySpell(nSpell))
    {
        ActionCastSpellAtObject(
            nSpell,
            OBJECT_SELF,
            METAMAGIC_ANY,
            FALSE,
            0,
            PROJECTILE_PATH_TYPE_DEFAULT,
            nInstant);

        return TRUE;
    }

    return FALSE;
}
//----------------------------------------------------------------
int gsCBTalentDispelMagic(object oTarget)
{
    int nSpell = -1;

    if (gsC2GetHasBreachableSpell(oTarget))
    {
        if (GetHasSpell(SPELL_GREATER_SPELL_BREACH))      nSpell = SPELL_GREATER_SPELL_BREACH;
        else if (GetHasSpell(SPELL_LESSER_SPELL_BREACH))  nSpell = SPELL_LESSER_SPELL_BREACH;
    }

    if (nSpell == -1 && gsC2GetEffectBalance(oTarget) > Random(4))
    {
        if (GetHasSpell(SPELL_MORDENKAINENS_DISJUNCTION)) nSpell = SPELL_MORDENKAINENS_DISJUNCTION;
        else if (GetHasSpell(SPELL_GREATER_DISPELLING))   nSpell = SPELL_GREATER_DISPELLING;
        else if (GetHasSpell(SPELL_DISPEL_MAGIC))         nSpell = SPELL_DISPEL_MAGIC;
        else if (GetHasSpell(SPELL_LESSER_DISPEL))        nSpell = SPELL_LESSER_DISPEL;
    }

    return nSpell != -1 && gsCBCastSpellAtObject(nSpell, oTarget);
}
//----------------------------------------------------------------
int gsCBTalentEvadeDarkness()
{
    int nSpell = -1;

    if (gsC2GetHasEffect(EFFECT_TYPE_DARKNESS) &&
        ! (gsC2GetHasEffect(EFFECT_TYPE_TRUESEEING) ||
           gsC2GetHasEffect(EFFECT_TYPE_ULTRAVISION)))
    {
        if (GetHasSpell(SPELL_TRUE_SEEING))                    nSpell = SPELL_TRUE_SEEING;
        else if (GetHasSpell(SPELL_DARKVISION))                nSpell = SPELL_DARKVISION;

        if (nSpell != -1 && gsCBCastSpellAtObject(nSpell))     return TRUE;

        if (GetHasSpell(SPELL_LESSER_DISPEL))                  nSpell = SPELL_LESSER_DISPEL;
        else if (GetHasSpell(SPELL_DISPEL_MAGIC))              nSpell = SPELL_DISPEL_MAGIC;
        else if (GetHasSpell(SPELL_GREATER_DISPELLING))        nSpell = SPELL_GREATER_DISPELLING;
        else if (GetHasSpell(SPELL_MORDENKAINENS_DISJUNCTION)) nSpell = SPELL_MORDENKAINENS_DISJUNCTION;

        if (nSpell != -1)
        {
            ActionCastSpellAtLocation(nSpell, GetLocation(OBJECT_SELF));
            return TRUE;
        }

        if (d2() == 2)
        {
          ActionMoveAwayFromLocation(GetLocation(OBJECT_SELF), TRUE, 10.0);
          return TRUE;
        }
    }

    return FALSE;
}
//----------------------------------------------------------------
/*
int gsCBTelegraphAttack(object oTarget)
{
  // This method uses two new custom AOEs to telegraph the area that will be affected by an attack in 6s time.
  // Anyone who doesn't get out of the way will be hit for 1d6 damage per caster hit dice with no save or attack roll.
  // Don't telegraph an attack two rounds running.
  if (GetLocalInt(OBJECT_SELF, "TELEGRAPHED"))
  {
    DeleteLocalInt(OBJECT_SELF, "TELEGRAPHED");
    return FALSE;
  }

  if (GetDistanceBetween(oTarget, OBJECT_SELF) > 3.0f) return FALSE;

  if (d3() == 1) return FALSE;

  // Location calculations
  location lLocation = GetLocation(OBJECT_SELF);
  float fDir = GetFacing(OBJECT_SELF);
  location lAheadLocation = GenerateNewLocation(OBJECT_SELF, 3.0f, fDir, fDir);

  if (GetKnowsFeat(FEAT_SPELL_FOCUS_NECROMANCY, OBJECT_SELF))
  {
    SpeakString(GetName(OBJECT_SELF) + " readies Negative Burst!");
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectMovementSpeedDecrease(99), OBJECT_SELF, 6.0f);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_PULSE_NEGATIVE), OBJECT_SELF);
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectAreaOfEffect(55, "", "evt_custatk_hb", ""), lLocation, 7.0f);
    SetLocalInt(OBJECT_SELF, "TELEGRAPHED", TRUE);
    ActionAttack(oTarget);
    return TRUE;
  }
  else if (GetKnowsFeat(FEAT_SPELL_FOCUS_EVOCATION, OBJECT_SELF))
  {
    SpeakString(GetName(OBJECT_SELF) + " readies Cold Strike!");
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectMovementSpeedDecrease(99), OBJECT_SELF, 6.0f);
    SetLocalInt(OBJECT_SELF, "DAMAGE_TYPE", DAMAGE_TYPE_COLD);
    SetLocalInt(OBJECT_SELF, "VFX_IMP", VFX_IMP_FROST_L);
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectAreaOfEffect(54, "", "evt_custatk_hb", ""), lAheadLocation, 7.0f);
    SetLocalInt(OBJECT_SELF, "TELEGRAPHED", TRUE);
    ActionAttack(oTarget);
    return TRUE;
  }
  else if (GetKnowsFeat(FEAT_IMPROVED_WHIRLWIND, OBJECT_SELF))
  {
    SpeakString(GetName(OBJECT_SELF) + " readies Greater Whirlwind Attack!");
    SetLocalInt(OBJECT_SELF, "DAMAGE_TYPE", DAMAGE_TYPE_SLASHING);
    SetLocalInt(OBJECT_SELF, "VFX_IMP", VFX_IMP_WALLSPIKE);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectMovementSpeedDecrease(99), OBJECT_SELF, 6.0f);
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectAreaOfEffect(55, "", "evt_custatk_hb", ""), lLocation, 7.0f);
    SetLocalInt(OBJECT_SELF, "TELEGRAPHED", TRUE);
    ActionAttack(oTarget);
    return TRUE;
  }

  return FALSE;
}
*/
//----------------------------------------------------------------
void gsCBRequestReinforcement()
{
    DeleteLocalInt(OBJECT_SELF, "GS_CB_REINFORCEMENT");

    int nValue = -gsCBGetForceBalance();

    if (nValue > 0)
    {
        if (Random(100) > 75)
        {
            switch (Random(3))
            {
            case 0: PlayVoiceChat(VOICE_CHAT_GROUP);   break;
            case 1: PlayVoiceChat(VOICE_CHAT_GUARDME); break;
            case 2: PlayVoiceChat(VOICE_CHAT_HELP);
            }
        }

        SetLocalInt(OBJECT_SELF, "GS_CB_REINFORCEMENT", nValue);
        SpeakString("GS_AI_REQUEST_REINFORCEMENT", TALKVOLUME_SILENT_TALK);
    }
}
//----------------------------------------------------------------
void gsCBSetReinforcementRequestedBy(object oObject)
{
    int nValue = GetLocalInt(oObject, "GS_CB_REINFORCEMENT");

    if (nValue > GetLocalInt(OBJECT_SELF, "GS_CB_REINFORCEMENT") &&
        nValue > GetLocalInt(OBJECT_SELF, "GS_CB_REINFORCEMENT_REQUESTED"))
    {
        SetLocalObject(OBJECT_SELF, "GS_CB_REINFORCEMENT_REQUESTER", oObject);
        SetLocalInt(OBJECT_SELF, "GS_CB_REINFORCEMENT_REQUESTED", nValue);
    }
}
//----------------------------------------------------------------
int gsCBReinforce()
{
    object oObject = GetLocalObject(OBJECT_SELF, "GS_CB_REINFORCEMENT_REQUESTER");
    int nValue     =GetLocalInt(OBJECT_SELF, "GS_CB_REINFORCEMENT_REQUESTED");

    DeleteLocalObject(OBJECT_SELF, "GS_CB_REINFORCEMENT_REQUESTER");
    DeleteLocalInt(OBJECT_SELF, "GS_CB_REINFORCEMENT_REQUESTED");

    if (GetIsObjectValid(oObject) &&
        nValue > 0 &&
        GetDistanceToObject(oObject) > 10.0)
    {
        object oTarget = gsCBGetLastAttackTarget(oObject);

        if (GetIsObjectValid(oTarget))
        {
            oTarget = gsCBSetAttackTarget(oTarget);
            nValue -= FloatToInt(GetChallengeRating(OBJECT_SELF) * 10.0);
            if (nValue > 0) SetLocalInt(oObject, "GS_CB_REINFORCEMENT", nValue);
            else            DeleteLocalInt(oObject, "GS_CB_REINFORCEMENT");
            return TRUE;
        }
    }

    return FALSE;
}


// added by Dunshine function for NPC Gonne users:
// set variable GVD_OVERRIDE_GONNE on an NPC to have them use their Gonne instead of normal attacks
// set variable GVD_SLUGS to determine the amount of shots they can do

//----------------------------------------------------------------
/*
int gsCBTalentGonne(object oTarget)
{

    // Gonne wielder?
    if (GetLocalInt(OBJECT_SELF, "GVD_OVERRIDE_GONNE") == 1) {

      // check if not still reloading
      if (GetLocalInt(OBJECT_SELF,"GVD_GONNE_RELOAD") != 1) {

        // how many slugs left?
        int iSlugs = GetLocalInt(OBJECT_SELF, "GVD_SLUGS");
        if (iSlugs >= 1) {

          // check if line of sight to target
          if (LineOfSightObject(OBJECT_SELF, oTarget) == 1) {

            // use the Gonne and lower the amount of slugs
            SetLocalInt(OBJECT_SELF,"GVD_SLUGS", (iSlugs - 1));

            ClearAllActions();

            object oGonne = GetItemPossessedBy(OBJECT_SELF,"Gonne");
            ActionEquipItem(oGonne, INVENTORY_SLOT_RIGHTHAND);

            SetFacingPoint(GetPosition(oTarget));

            // 5% chance of ammunition exploding.
            if (d20() == 1) {
              SpeakString("*** Misfire! ***", TALKVOLUME_TALK);
              ActionCastSpellAtObject(SPELL_COMBUST,
                            OBJECT_SELF,
                            METAMAGIC_ANY,
                            TRUE,
                            0,
                            PROJECTILE_PATH_TYPE_DEFAULT,
                            TRUE);
            } else {

              SpeakString("*** Bang! ***", TALKVOLUME_TALK);

              // Roll to hit.  Touch attack; Gonnes really don't care about armour.
              int nHit = TouchAttackRanged(oTarget);

              ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_DUR_ARROW_IN_STERNUM), oTarget, 1.0);
              ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_FNF_SMOKE_PUFF), OBJECT_SELF, 1.0);

              if (nHit) {

                // Damage
                int nDamage = (nHit == 1) ? d6(30) : d6(60);

                // delay damage slightly, so PC knows he's being shot
                effect eDamage = EffectDamage(nDamage, DAMAGE_TYPE_PIERCING, DAMAGE_POWER_NORMAL);
                DelayCommand(1.0f, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oTarget));

              }

            }

            // force reload time
            effect eReload = EffectCutsceneImmobilize();
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eReload, OBJECT_SELF, 12.0f);
            SetLocalInt(OBJECT_SELF,"GVD_GONNE_RELOAD",1);
            DelayCommand(12.0f, DeleteLocalInt(OBJECT_SELF,"GVD_GONNE_RELOAD"));
            return TRUE;

          } else {
            // no longer line of sight to target, do something else
            return FALSE;
          }

        } else {
          // out of ammo, normal attack
          return FALSE;
        }

      } else {
        // still reloading
        return FALSE;

      }

    } else {
      return FALSE;
    }
}
*/
// TO DO:
// * Use constant string values for feedback and tie into -guard command.
// * Turn guard into a prioritized list, so that separate PC and associate
//   guard variables are no longer necessary. This will suffice for our current
//   purposes, however.
//----------------------------------------------------------------
/*
void SetAssociateGuardian(object oPC, object oGuardian, int bFeedback = TRUE)
{
    SetLocalObject(oPC, "AssociateGuardian", oGuardian);
    if(bFeedback && GetIsAssociateGuardEnabled(oPC))
    {
        SendAssociateGuardFeedback(oPC);
    }
}
//----------------------------------------------------------------
object GetAssociateGuardian(object oPC, int bReturnInactiveGuardian = FALSE)
{
    if(!bReturnInactiveGuardian && !GetIsAssociateGuardEnabled(oPC)) return OBJECT_INVALID;
    return GetLocalObject(oPC, "AssociateGuardian");
}
//----------------------------------------------------------------
int GetIsAssociateGuardEnabled(object oPC)
{
    // Returns !GetLocalInt so that value zero defaults to guard enabled.
    //return !GetLocalInt(gsPCGetCreatureHide(oPC), "AssociateGuardEnabled");
    return !GetLocalInt(oPC, "AssociateGuardEnabled");
}
//----------------------------------------------------------------
void SetIsAssociateGuardEnabled(object oPC, int bIsEnabled, int bFeedback = TRUE)
{
    //SetLocalInt(gsPCGetCreatureHide(oPC), "AssociateGuardEnabled", !bIsEnabled);
    SetLocalInt(oPC, "AssociateGuardEnabled", !bIsEnabled);
    if(bFeedback) SendAssociateGuardFeedback(oPC);
}
//----------------------------------------------------------------
void SendAssociateGuardFeedback(object oPC)
{
    string sName = GetName(GetAssociateGuardian(oPC, TRUE));

    if(GetIsAssociateGuardEnabled(oPC))
    {
        FloatingTextStringOnCreature(sName + " is now guarding you!", oPC, FALSE);
    }
    else
    {
        FloatingTextStringOnCreature(sName + " is no longer guarding you!", oPC, FALSE);
    }
}
*/

