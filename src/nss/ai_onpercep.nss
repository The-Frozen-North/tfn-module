#include "inc_ai_combat"
#include "inc_ai_event"

void gsPlayVoiceChat()
{
    if (Random(100) >= 75)
    {
        switch (Random(7))
        {
        case 0: PlayVoiceChat(VOICE_CHAT_ATTACK);     break;
        case 1: PlayVoiceChat(VOICE_CHAT_BATTLECRY1); break;
        case 2: PlayVoiceChat(VOICE_CHAT_BATTLECRY2); break;
        case 3: PlayVoiceChat(VOICE_CHAT_BATTLECRY3); break;
        case 4: PlayVoiceChat(VOICE_CHAT_ENEMIES);    break;
        case 5: PlayVoiceChat(VOICE_CHAT_TAUNT);      break;
        case 6: PlayVoiceChat(VOICE_CHAT_THREATEN);   break;
        }
    }
}


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


//----------------------------------------------------------------
void main()
{
    SignalEvent(OBJECT_SELF, EventUserDefined(GS_EV_ON_PERCEPTION));

    object oPerceived = GetLastPerceived();

    if (GetLastPerceptionVanished() ||
        GetLastPerceptionInaudible())
    {
// Added a check if the target is in stealth mode.
        if (GetIsEnemy(oPerceived) && GetActionMode(oPerceived, ACTION_MODE_STEALTH) &&
            ! gsCBGetHasAttackTarget())
        {
            SetActionMode(OBJECT_SELF, ACTION_MODE_DETECT, TRUE);
        }
        return;
    }

    if (GetIsEnemy(oPerceived))
    {
        if (gsCBGetHasAttackTarget())
        {
            object oTarget = gsCBGetLastAttackTarget();
            FastBuff();

            if (oPerceived != oTarget &&
                GetDistanceToObject(oPerceived) + 5.0 <=
                GetDistanceToObject(oTarget))
            {
                gsCBDetermineCombatRound(oPerceived);
                gsPlayVoiceChat();
            }
        }
        else
        {
            gsCBDetermineCombatRound(oPerceived);
            gsPlayVoiceChat();
        }
    }
}
