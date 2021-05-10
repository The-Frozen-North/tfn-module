/*/////////////////////// [On Spell Cast At] ///////////////////////////////////
    Filename: j_ai_onspellcast or nw_c2_defaultb
///////////////////////// [On Spell Cast At] ///////////////////////////////////
    What does this do? Well...
    - Any AOE spell effects are set in a timer, so we can react to them right
    - Reacts to hostile casters, or allies in combat

    And the normal attack :-)
///////////////////////// [History] ////////////////////////////////////////////
    1.3 - Added special AOE checks.
        - Hide checks.
    1.4 - Added more silent shouts. Edited the formatting. Moved a few things around.
///////////////////////// [Workings] ///////////////////////////////////////////
    This is fired when EventSpellCastAt(object oCaster, int nSpell, int bHarmful=TRUE)
    is signaled on the creature.

    GetLastSpellCaster() = oCaster (Door, Placeable, Creature who cast it)
    GetLastSpell()       = nSpell (The spell cast at us)
    GetLastSpellHarmful()= bHarmful (If it is harmful!)
///////////////////////// [Arguments] //////////////////////////////////////////
    Arguments: GetLastSpellCaster, GetLastSpellHarmful GetLastSpell()
///////////////////////// [On Spell Cast At] /////////////////////////////////*/

#include "inc_hai_other"

// Sets a local timer if the spell is an AOE one
void SetAOESpell(int nSpellCast, object oCaster);
// Gets the nearest AOE cast by oCaster, of sTag.
object GetNearestAOECastBy(string sTag, object oCaster);
// Gets the amount of protections we have - IE globes
int GetOurSpellLevelImmunity();

void main()
{
    // Pre-spell cast at-event. Returns TRUE if we interrupt this script call.
    if(FirePreUserEvent(AI_FLAG_UDE_SPELL_CAST_AT_PRE_EVENT, EVENT_SPELL_CAST_AT_PRE_EVENT)) return;

    // AI status check. Is the AI on?
    if(GetAIOff()) return;

    object oCaster = GetLastSpellCaster();
    int bHarmful = GetLastSpellHarmful();
    int nSpellCast = GetLastSpell();
    object oAttackerOfCaster;

    // If harmful, we set the spell to a timer, if an AOE one.
    if(bHarmful && GetIsObjectValid(oCaster))
    {
        object oMyMaster = GetMaster(OBJECT_SELF);
        if ((oMyMaster != OBJECT_INVALID) && (oMyMaster == oCaster || (oMyMaster  == GetMaster(oCaster))) )
        {
            ClearPersonalReputation(oCaster, OBJECT_SELF);
            return;
        }

        // Might set AOE spell to cast.
        SetAOESpell(nSpellCast, oCaster);
    }
    // If not a creature, probably an AOE or trap.
    if(GetObjectType(oCaster) != OBJECT_TYPE_CREATURE)
    {
        // 67: "[Spell] Caster isn't a creature! May look for target [Caster] " + GetName(oCaster)
        DebugActionSpeakByInt(67, oCaster);

        // Shout to allies to attack, or be prepared.
        AISpeakString(AI_SHOUT_CALL_TO_ARMS);

        // Attack anyone else around
        if(!CannotPerformCombatRound())
        {
            // Determine Combat Round
            DetermineCombatRound();
        }
    }
    // If a friend, or dead, or a DM, or invalid, or self, we ignore them.
    else if(!GetIgnoreNoFriend(oCaster) && oCaster != OBJECT_SELF)
    {
        // 1.3 changes here:
        // - We do NOT need to know if it is hostile or not, except if it is hostile
        //   and they are not our faction! We do, however, use bHarmful for speakstrings.

        // If harmful, we attack anyone! (and if is enemy)
        // 1.4: Faction equal check in GetIgnoreNoFriend()
        if(bHarmful || GetIsEnemy(oCaster))
        {
            // Spawn in condition hostile thingy
            if(GetSpawnInCondition(AI_FLAG_OTHER_CHANGE_FACTIONS_TO_HOSTILE_ON_ATTACK, AI_OTHER_MASTER))
            {
                if(!GetIsEnemy(oCaster))
                {
                    AdjustReputation(oCaster, OBJECT_SELF, -100);
                }
            }

            if(bHarmful)
            {
                // * Don't speak when dead. 1.4 change (an obvious one to make)
                if(CanSpeak())
                {
                    // Hostile spell speaksting, if set.
                    SpeakArrayString(AI_TALK_ON_HOSTILE_SPELL_CAST_AT);
                }
            }

            // Turn of hiding check
            TurnOffHiding(oCaster);

            // We attack
            if(!CannotPerformCombatRound())
            {
                // 68: "[Spell:Enemy/Hostile] Not in combat. Attacking: [Caster] " + GetName(oCaster)
                DebugActionSpeakByInt(68, oCaster);
                DetermineCombatRound(oCaster);
            }

            // Shout to allies to attack the enemy who attacked me, got via. Last Hostile Actor.
            AISpeakString(AI_SHOUT_I_WAS_ATTACKED);
        }
        // Else, was neutral perhaps. Don't attack them anyway.
        else
        {
            // 69: "[Spell] (ally). Not in combat. May Attack/Move [Caster] " + GetName(oCaster)
            DebugActionSpeakByInt(69, oCaster);

            // Set special action to investigate - as if this event was triggered
            // by I_WAS_ATTACKED.

            // If we are already attacking, we do not move
            if(CannotPerformCombatRound())
            {
                // Shout to allies to attack, or be prepared.
                AISpeakString(AI_SHOUT_CALL_TO_ARMS);
            }
            else
            {
                // We react as if the caster, a neutral, called for help ala
                // I_WAS_ATTACKED (they might not have, might just be
                // preperation for something), but normally, this is a neutral
                // casting a spell. Do not respond to PC's.
                if(!GetIsPC(oCaster))
                {
                    IWasAttackedResponse(oCaster);
                }
            }
        }
    }
    // If they are not a faction equal, and valid, we help them.
    else if(GetIsObjectValid(oCaster) && GetFactionEqual(oCaster))
    {
        IWasAttackedResponse(oCaster);
    }
    // Fire End-spell cast at-UDE
    FireUserEvent(AI_FLAG_UDE_SPELL_CAST_AT_EVENT, EVENT_SPELL_CAST_AT_EVENT);
}

// Sets a local timer if the spell is an AOE one
void SetAOESpell(int nSpellCast, object oCaster)
{
    // Check it is one we can check
    int bStop = TRUE;
    switch(nSpellCast)
    {
        case SPELL_ACID_FOG:
        case SPELL_MIND_FOG:
        case SPELL_STORM_OF_VENGEANCE:
        case SPELL_GREASE:
        case SPELL_CREEPING_DOOM:
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
        case SPELL_VINE_MINE_HAMPER_MOVEMENT:
        case SPELL_VINE_MINE_ENTANGLE:
        {
            bStop = FALSE;
        }
        break;
    }
    // Check immune level
    int nImmuneLevel = GetOurSpellLevelImmunity();
    if(nImmuneLevel >= 9)
    {
        bStop = TRUE;
    }
    // Check
    if(bStop == TRUE)
    {
        return;
    }
    // We do use intelligence here...
    int nAIInt = GetBoundriedAIInteger(AI_INTELLIGENCE);
    int bIgnoreSaves;
    int bIgnoreImmunities;
    object oAOE;

    // If it is low, we ignore all things that we could ignore with it...
    if(nAIInt <= 3)
    {
        bIgnoreSaves = TRUE;
        bIgnoreImmunities = TRUE;
    }
    // Average ignores saves
    else if(nAIInt <= 7)
    {
        bIgnoreSaves = TRUE;
        bIgnoreImmunities = FALSE;
    }
    // Else, we do both.
    else
    {
        bIgnoreSaves = FALSE;
        bIgnoreImmunities = FALSE;
    }

    int bSetAOE = FALSE;// TRUE means set to timer
    int nSaveDC = 11;

    // Get the caster DC, the most out of WIS, INT or CHA...
    int nInt = GetAbilityModifier(ABILITY_INTELLIGENCE, oCaster);
    int nWis = GetAbilityModifier(ABILITY_WISDOM, oCaster);
    int nCha = GetAbilityModifier(ABILITY_CHARISMA, oCaster);

    if(nInt > nWis && nInt > nCha)
    {
        nSaveDC += nInt;
    }
    else if(nWis > nCha)
    {
        nSaveDC += nWis;
    }
    else
    {
        nSaveDC += nCha;
    }
    // Note:
    // - No reaction type/friendly checks. Signal Event is only fired if the
    //   spell WILL pierce any PvP/Friendly/Area settings

    // We check immunities here, please note...
    switch(nSpellCast)
    {
        // First: IS GetIsReactionTypeHostile ones.
        case SPELL_EVARDS_BLACK_TENTACLES:
        // Fortitude save, but if we are immune to the hits, its impossible to hurt us
        {
            // If save immune OR AC immune, we ignore this.
            if(25 >= GetAC(OBJECT_SELF) && nImmuneLevel < 4 &&
             ((GetFortitudeSavingThrow(OBJECT_SELF) < nSaveDC + 2) || bIgnoreSaves))
            {
                bSetAOE = TRUE;
                // Nearest string of tag
                oAOE = GetNearestAOECastBy(AI_AOE_PER_EVARDS_BLACK_TENTACLES, oCaster);
            }
        }
        case SPELL_SPIKE_GROWTH:
        case SPELL_VINE_MINE_HAMPER_MOVEMENT:
        // d4 damage. LOTS of speed loss.
        // Reflex save, or immunity, would stop the speed
        {
            if(nImmuneLevel < 3 &&
              (!GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_MOVEMENT_SPEED_DECREASE) || bIgnoreImmunities) &&
              ((GetReflexSavingThrow(OBJECT_SELF) < nSaveDC + 5) || bIgnoreSaves))
            {
                bSetAOE = TRUE;
                // Both use ENTANGLE AOE's
                oAOE = GetNearestAOECastBy(AI_AOE_PER_ENTANGLE, oCaster);
            }
        }
        break;
        case SPELL_ENTANGLE:
        case SPELL_VINE_MINE_ENTANGLE:
        {
            if(nImmuneLevel < 1 &&
             (!GetHasFeat(FEAT_WOODLAND_STRIDE) || bIgnoreImmunities) &&
             (!GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_ENTANGLE) || bIgnoreImmunities) &&
             ((GetReflexSavingThrow(OBJECT_SELF) < nSaveDC + 4) || bIgnoreSaves))
            {
                bSetAOE = TRUE;
                // Both use ENTANGLE AOE's
                oAOE = GetNearestAOECastBy(AI_AOE_PER_ENTANGLE, oCaster);
            }
        }
        break;
        case SPELL_WEB:
        {
            if(nImmuneLevel < 1 &&
              (!GetHasFeat(FEAT_WOODLAND_STRIDE) || bIgnoreImmunities) &&
              (!GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_ENTANGLE) || bIgnoreImmunities) &&
              ((GetReflexSavingThrow(OBJECT_SELF) < nSaveDC + 4) || bIgnoreSaves))
            {
                bSetAOE = TRUE;
                // Web AOE
                oAOE = GetNearestAOECastBy(AI_AOE_PER_WEB, oCaster);
            }
        }
        break;
        // Fort save
        case SPELL_STINKING_CLOUD:
        {
            if(nImmuneLevel < 3 &&
              (!GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_POISON) || bIgnoreImmunities) &&
              (!GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_DAZED) || bIgnoreImmunities) &&
              ((GetFortitudeSavingThrow(OBJECT_SELF) < nSaveDC + 6) || bIgnoreSaves))
            {
                bSetAOE = TRUE;
                // Stinking cloud persistant AOE.
                oAOE = GetNearestAOECastBy(AI_AOE_PER_FOGSTINK, oCaster);
            }
        }
        break;
        // Fort save
        case SPELL_CLOUD_OF_BEWILDERMENT:
        {
            if(nImmuneLevel < 2 &&
              ((GetFortitudeSavingThrow(OBJECT_SELF) < nSaveDC + 7) || bIgnoreSaves))
            {
                bSetAOE = TRUE;
                // Bewilderment cloud persistant AOE.
                oAOE = GetNearestAOECastBy(AI_AOE_PER_FOGBEWILDERMENT, oCaster);
            }
        }
        break;
        // Special: Mind save is the effect.
        case SPELL_STONEHOLD:
        {
            if(nImmuneLevel < 6 &&
              (!GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_MIND_SPELLS) || bIgnoreImmunities) &&
              ((GetWillSavingThrow(OBJECT_SELF) < nSaveDC + 7) || bIgnoreSaves))
            {
                bSetAOE = TRUE;
                // Stonehold persistant AOE.
                oAOE = GetNearestAOECastBy(AI_AOE_PER_STONEHOLD, oCaster);
            }
        }
        break;
        // Special: EFFECT_TYPE_SAVING_THROW_DECREASE is the effect.
        case SPELL_MIND_FOG:
        {
            if(nImmuneLevel < 5 &&
              (!GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_SAVING_THROW_DECREASE) || bIgnoreImmunities) &&
              ((GetWillSavingThrow(OBJECT_SELF) < nSaveDC + 6) || bIgnoreSaves))
            {
                bSetAOE = TRUE;
                // Mind fog
                oAOE = GetNearestAOECastBy(AI_AOE_PER_FOGMIND, oCaster);
            }
        }
        break;
        // Special: Feats, knockdown
        case SPELL_GREASE:
        {
            if(nImmuneLevel < 1 &&
              (!GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_KNOCKDOWN) || bIgnoreImmunities) &&
              (!GetHasFeat(FEAT_WOODLAND_STRIDE, OBJECT_SELF) || bIgnoreImmunities) &&
              ((GetReflexSavingThrow(OBJECT_SELF) < nSaveDC + 2) || bIgnoreSaves))
            {
                bSetAOE = TRUE;
                // Grease
                oAOE = GetNearestAOECastBy(AI_AOE_PER_GREASE, oCaster);
            }
        }
        break;
        // All other ReactionType ones. Some have different saves though!
        case SPELL_BLADE_BARRIER: // Reflex
        case SPELL_INCENDIARY_CLOUD:// reflex
        case SPELL_WALL_OF_FIRE:// Reflex
        {
            if(nImmuneLevel < 6 &&
               (((GetReflexSavingThrow(OBJECT_SELF) < nSaveDC + 6) &&
                  !GetHasFeat(FEAT_IMPROVED_EVASION) &&
                  !GetHasFeat(FEAT_EVASION)) || bIgnoreSaves))
            {
                bSetAOE = TRUE;
                if(nSpellCast == SPELL_BLADE_BARRIER)
                {
                    // BB
                    oAOE = GetNearestAOECastBy(AI_AOE_PER_WALLBLADE, oCaster);
                }
                else if(nSpellCast == SPELL_INCENDIARY_CLOUD)
                {
                    // Fog of fire
                    oAOE = GetNearestAOECastBy(AI_AOE_PER_FOGFIRE, oCaster);
                }
                else if(nSpellCast == SPELL_WALL_OF_FIRE)
                {
                    // Wall of fire
                    oAOE = GetNearestAOECastBy(AI_AOE_PER_WALLFIRE, oCaster);
                }
            }
        }
        break;
        case SPELL_ACID_FOG: // Fort: Half. No check, always damages.
        case SPELL_CLOUDKILL:// No save!
        case SPELL_CREEPING_DOOM: // No save!
        {
            if(nImmuneLevel < 6)
            {
                bSetAOE = TRUE;
                if(nSpellCast == SPELL_ACID_FOG)
                {
                    // Acid fog
                    oAOE = GetNearestAOECastBy(AI_AOE_PER_FOGACID, oCaster);
                }
                else if(nSpellCast == SPELL_CLOUDKILL)
                {
                    // Cloud Kill
                    oAOE = GetNearestAOECastBy(AI_AOE_PER_FOGKILL, oCaster);
                }
                else if(nSpellCast == SPELL_CREEPING_DOOM)
                {
                    // Creeping doom
                    oAOE = GetNearestAOECastBy(AI_AOE_PER_CREEPING_DOOM, oCaster);
                }
            }
        }
        // Storm - because the AI likes it, we stay in it if it is ours :-)
        case SPELL_STORM_OF_VENGEANCE: // Reflex partial. No check, always damages.
        {
            if(oCaster != OBJECT_SELF && nImmuneLevel < 9)
            {
                bSetAOE = TRUE;
                // Storm of vengance
                oAOE = GetNearestAOECastBy(AI_AOE_PER_STORM, oCaster);
            }
        }
    }
    if(bSetAOE)
    {
        if(!GetLocalTimer(AI_TIMER_AOE_SPELL_EVENT + IntToString(nSpellCast)))
        {
            SetLocalTimer(AI_TIMER_AOE_SPELL_EVENT + IntToString(nSpellCast), 18.0);
            // Set nearest AOE
            if(GetIsObjectValid(oAOE))
            {
                // Set nearest AOE of this spell to the local
                object oNearest = GetAIObject(AI_TIMER_AOE_SPELL_EVENT + IntToString(nSpellCast));
                if(GetDistanceToObject(oAOE) < GetDistanceToObject(oNearest) ||
                  !GetIsObjectValid(oNearest))
                {
                    SetAIObject(AI_TIMER_AOE_SPELL_EVENT + IntToString(nSpellCast), oAOE);
                }
            }
        }
    }
}
// Gets the nearest AOE cast by oCaster, of sTag.
object GetNearestAOECastBy(string sTag, object oCaster)
{
    int nCnt = 1;
    object oAOE = GetNearestObjectByTag(sTag, OBJECT_SELF, nCnt);
    object oReturn = OBJECT_INVALID;
    // Loop
    while(GetIsObjectValid(oAOE) && !GetIsObjectValid(oReturn))
    {
        // Check creator
        if(GetAreaOfEffectCreator(oAOE) == oCaster)
        {
            oReturn = oAOE;
        }
        nCnt++;
        oAOE = GetNearestObjectByTag(sTag, OBJECT_SELF, nCnt);
    }
    return oReturn;
}

// Gets the amount of protections we have - IE globes
int GetOurSpellLevelImmunity()
{
    int nNatural = GetLocalInt(OBJECT_SELF, AI_SPELL_IMMUNE_LEVEL);
    // Stop here, if natural is over 4
    if(nNatural > 4) return nNatural;

    // Big globe affects 4 or lower spells
    if(GetHasSpellEffect(SPELL_GLOBE_OF_INVULNERABILITY, OBJECT_SELF) || nNatural >= 4)
        return 4;
    // Minor globe is 3 or under
    if(GetHasSpellEffect(SPELL_MINOR_GLOBE_OF_INVULNERABILITY, OBJECT_SELF) ||
       // Shadow con version
       GetHasSpellEffect(SPELL_GREATER_SHADOW_CONJURATION_MINOR_GLOBE, OBJECT_SELF) ||
       nNatural >= 3)
        return 3;
    // 2 and under is ethereal visage.
    if(GetHasSpellEffect(SPELL_ETHEREAL_VISAGE, OBJECT_SELF) || nNatural >= 2)
        return 2;
    // Ghostly Visarge affects 1 or 0 level spells, and any spell immunity.
    if(GetHasSpellEffect(SPELL_GHOSTLY_VISAGE, OBJECT_SELF) || nNatural >= 1 ||
       // Or shadow con version.
       GetHasSpellEffect(SPELL_GREATER_SHADOW_CONJURATION_MIRROR_IMAGE, OBJECT_SELF))
        return 1;
    // Return nNatural, which is 0-9
    return FALSE;
}

