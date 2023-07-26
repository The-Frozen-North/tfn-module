/************************ [On Spell Cast At] ***********************************
    Filename: j_ai_onspellcast or nw_c2_defaultb
************************* [On Spell Cast At] ***********************************
    What does this do? Well...
    - Any AOE spell effects are set in a timer, so we can react to them right
    - Reacts to hostile casters, or allies in combat

    And the normal attack :-)
************************* [History] ********************************************
    1.3 - Added special AOE checks.
        - Hide checks.
************************* [Workings] *******************************************
    This is fired when EventSpellCastAt(object oCaster, int nSpell, int bHarmful=TRUE)
    is signaled on the creature.

    GetLastSpellCaster() = oCaster (Door, Placeable, Creature who cast it)
    GetLastSpell()       = nSpell (The spell cast at us)
    GetLastSpellHarmful()= bHarmful (If it is harmful!)
************************* [Arguments] ******************************************
    Arguments: GetLastSpellCaster, GetLastSpellHarmful GetLastSpell()
************************* [On Spell Cast At] **********************************/

#include "j_inc_other_ai"

// Sets a local timer if the spell is an AOE one
void SetAOESpell(int iSpellCast, object oCaster);
// Gets the nearest AOE cast by oCaster, of sTag.
object GetNearestAOECastBy(string sTag, object oCaster);
// Gets the amount of protections we have - IE globes
int GetOurSpellLevelImmunity();

void main()
{
    // Pre-heartbeat-event
    if(FireUserEvent(AI_FLAG_UDE_SPELL_CAST_AT_PRE_EVENT, EVENT_SPELL_CAST_AT_PRE_EVENT))
        // We may exit if it fires
        if(ExitFromUDE(EVENT_SPELL_CAST_AT_PRE_EVENT)) return;

    // AI status check. Is the AI on?
    if(GetAIOff()) return;

    object oCaster = GetLastSpellCaster();
    int iHarmful = GetLastSpellHarmful();
    int iSpellCast = GetLastSpell();
    object oAttackerOfCaster;

    // If harmful, we set the spell to a timer, if an AOE one.
    if(iHarmful && GetIsObjectValid(oCaster))
    {
        // Might set AOE spell to cast.
        SetAOESpell(iSpellCast, oCaster);
    }
    // If not a creature, probably an AOE or trap.
    if(GetObjectType(oCaster) != OBJECT_TYPE_CREATURE)
    {
        // 67: "[Spell] Caster isn't a creature! May look for target [Caster] " + GetName(oCaster)
        DebugActionSpeakByInt(67, oCaster);
        // Attack anyone else around
        if(!CannotPerformCombatRound())
        {
            DetermineCombatRound();
        }
    }
    else if(GetIsObjectValid(oCaster) && !GetIsDM(oCaster) &&
           !GetIgnore(oCaster) && oCaster != OBJECT_SELF && !GetIsDead(oCaster))
    {
        // 1.3 changes here:
        // - We do NOT need to know if it is hostile or not, except if it is hostile
        //   and they are not our faction! We do, however, use iHarmful for speakstrings.
        if(!GetFactionEqual(oCaster))
        {
            // If harmful, we attack anyone! (and if is enemy)
            if(iHarmful || GetIsEnemy(oCaster))
            {
                if(iHarmful)
                {
                    // Hostile spell speaksting, if set.
                    SpeakArrayString(AI_TALK_ON_HOSTILE_SPELL_CAST_AT);
                }
                // Turn of hiding check
                TurnOffHiding(oCaster);
                // Attack
                AISpeakString(I_WAS_ATTACKED);
                // We attack
                if(!CannotPerformCombatRound())
                {
                    // 68: "[Spell:Enemy/Hostile] Not in combat. Attacking: [Caster] " + GetName(oCaster)
                    DebugActionSpeakByInt(68, oCaster);
                    DetermineCombatRound(oCaster);
                }
            }
        }
        // Else, faction is equal, we normally ignore, and only move to attack.
        else
        {
            // Spawn in condition hostile thingy
            if(GetSpawnInCondition(AI_FLAG_OTHER_CHANGE_FACTIONS_TO_HOSTILE_ON_ATTACK, AI_OTHER_MASTER))
            {
                if(!GetIsEnemy(oCaster))
                {
                    AdjustReputation(oCaster, OBJECT_SELF, -100);
                }
            }
            // We move to the person, if they are attacking something we cannot see...
            AISpeakString(CALL_TO_ARMS);

            // Not in combat
            if(!CannotPerformCombatRound())
            {
                // 69: "[Spell] (ally). Not in combat. May Attack/Move [Caster] " + GetName(oCaster)
                DebugActionSpeakByInt(69, oCaster);
                ClearAllActions();
                // Check thier target. Might not be valid (IE AOE spell at location)
                oAttackerOfCaster = GetAttackTarget(oCaster);
                // - Faster then DetermineCombatRound(); and looping targets until
                //   we get this ally, and get this attacker! :-)
                if(GetIsObjectValid(oAttackerOfCaster))
                {
                    // Move to the attack target, and wait for a proper on
                    // perception event (as we are not currently in combat)
                    ActionMoveToObject(oCaster, TRUE);
                }
                /* wtf why move to it if not valid
                else
                {
                    // Move to the caster otherwise
                    ActionMoveToObject(oCaster, TRUE);
                }
                */
            }
        }
    }
    // Fire End-spell cast at-UDE
    FireUserEvent(AI_FLAG_UDE_SPELL_CAST_AT_EVENT, EVENT_SPELL_CAST_AT_EVENT);
}

// Sets a local timer if the spell is an AOE one
void SetAOESpell(int iSpellCast, object oCaster)
{
    // Check it is one we can check
    int iStop = TRUE;
    switch(iSpellCast)
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
            iStop = FALSE;
        }
        break;
    }
    // Check immune level
    int iImmuneLevel = GetOurSpellLevelImmunity();
    if(iImmuneLevel >= i9)
    {
        iStop = TRUE;
    }
    // Check
    if(iStop == TRUE)
    {
        return;
    }
    // We do use intelligence here...
    int iAIInt = GetBoundriedAIInteger(AI_INTELLIGENCE);
    int iIgnoreSaves;
    int iIgnoreImmunities;
    object oAOE;

    // If it is low, we ignore all things that we could ignore with it...
    if(iAIInt <= i3)
    {
        iIgnoreSaves = TRUE;
        iIgnoreImmunities = TRUE;
    }
    // Average ignores saves
    else if(iAIInt <= i7)
    {
        iIgnoreSaves = TRUE;
        iIgnoreImmunities = FALSE;
    }
    // Else, we do both.
    else
    {
        iIgnoreSaves = FALSE;
        iIgnoreImmunities = FALSE;
    }

    int SetAOE = FALSE;// TRUE means set to timer
    int iSaveDC = i11;

    // Get the caster DC, the most out of WIS, INT or CHA...
    int iInt = GetAbilityModifier(ABILITY_INTELLIGENCE, oCaster);
    int iWis = GetAbilityModifier(ABILITY_WISDOM, oCaster);
    int iCha = GetAbilityModifier(ABILITY_CHARISMA, oCaster);

    if(iInt > iWis && iInt > iCha)
    {
        iSaveDC += iInt;
    }
    else if(iWis > iCha)
    {
        iSaveDC += iWis;
    }
    else
    {
        iSaveDC += iCha;
    }
    // Note:
    // - No reaction type/friendly checks. Signal Event is only fired if the
    //   spell WILL pierce any PvP/Friendly/Area settings

    // We check immunities here, please note...
    switch(iSpellCast)
    {
        // First: IS GetIsReactionTypeHostile ones.
        case SPELL_EVARDS_BLACK_TENTACLES:
        // Fortitude save, but if we are immune to the hits, its impossible to hurt us
        {
            // If save immune OR AC immune, we ignore this.
            if(i25 >= GetAC(OBJECT_SELF) && iImmuneLevel < i4 &&
             ((GetFortitudeSavingThrow(OBJECT_SELF) < iSaveDC + i2) || iIgnoreSaves))
            {
                SetAOE = TRUE;
                // Nearest string of tag
                oAOE = GetNearestAOECastBy(AI_AOE_PER_EVARDS_BLACK_TENTACLES, oCaster);
            }
        }
        case SPELL_SPIKE_GROWTH:
        case SPELL_VINE_MINE_HAMPER_MOVEMENT:
        // d4 damage. LOTS of speed loss.
        // Reflex save, or immunity, would stop the speed
        {
            if(iImmuneLevel < i3 &&
              (!GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_MOVEMENT_SPEED_DECREASE) || iIgnoreImmunities) &&
              ((GetReflexSavingThrow(OBJECT_SELF) < iSaveDC + i5) || iIgnoreSaves))
            {
                SetAOE = TRUE;
                // Both use ENTANGLE AOE's
                oAOE = GetNearestAOECastBy(AI_AOE_PER_ENTANGLE, oCaster);
            }
        }
        break;
        case SPELL_ENTANGLE:
        case SPELL_VINE_MINE_ENTANGLE:
        {
            if(iImmuneLevel < i1 &&
             (!GetHasFeat(FEAT_WOODLAND_STRIDE) || iIgnoreImmunities) &&
             (!GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_ENTANGLE) || iIgnoreImmunities) &&
             ((GetReflexSavingThrow(OBJECT_SELF) < iSaveDC + i4) || iIgnoreSaves))
            {
                SetAOE = TRUE;
                // Both use ENTANGLE AOE's
                oAOE = GetNearestAOECastBy(AI_AOE_PER_ENTANGLE, oCaster);
            }
        }
        break;
        case SPELL_WEB:
        {
            if(iImmuneLevel < i1 &&
              (!GetHasFeat(FEAT_WOODLAND_STRIDE) || iIgnoreImmunities) &&
              (!GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_ENTANGLE) || iIgnoreImmunities) &&
              ((GetReflexSavingThrow(OBJECT_SELF) < iSaveDC + i4) || iIgnoreSaves))
            {
                SetAOE = TRUE;
                // Web AOE
                oAOE = GetNearestAOECastBy(AI_AOE_PER_WEB, oCaster);
            }
        }
        break;
        // Fort save
        case SPELL_STINKING_CLOUD:
        {
            if(iImmuneLevel < i3 &&
              (!GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_POISON) || iIgnoreImmunities) &&
              (!GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_DAZED) || iIgnoreImmunities) &&
              ((GetFortitudeSavingThrow(OBJECT_SELF) < iSaveDC + i6) || iIgnoreSaves))
            {
                SetAOE = TRUE;
                // Stinking cloud persistant AOE.
                oAOE = GetNearestAOECastBy(AI_AOE_PER_FOGSTINK, oCaster);
            }
        }
        break;
        // Fort save
        case SPELL_CLOUD_OF_BEWILDERMENT:
        {
            if(iImmuneLevel < i2 &&
              ((GetFortitudeSavingThrow(OBJECT_SELF) < iSaveDC + i7) || iIgnoreSaves))
            {
                SetAOE = TRUE;
                // Bewilderment cloud persistant AOE.
                oAOE = GetNearestAOECastBy(AI_AOE_PER_FOGBEWILDERMENT, oCaster);
            }
        }
        break;
        // Special: Mind save is the effect.
        case SPELL_STONEHOLD:
        {
            if(iImmuneLevel < i6 &&
              (!GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_MIND_SPELLS) || iIgnoreImmunities) &&
              ((GetWillSavingThrow(OBJECT_SELF) < iSaveDC + i7) || iIgnoreSaves))
            {
                SetAOE = TRUE;
                // Stonehold persistant AOE.
                oAOE = GetNearestAOECastBy(AI_AOE_PER_STONEHOLD, oCaster);
            }
        }
        break;
        // Special: EFFECT_TYPE_SAVING_THROW_DECREASE is the effect.
        case SPELL_MIND_FOG:
        {
            if(iImmuneLevel < i5 &&
              (!GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_SAVING_THROW_DECREASE) || iIgnoreImmunities) &&
              ((GetWillSavingThrow(OBJECT_SELF) < iSaveDC + i6) || iIgnoreSaves))
            {
                SetAOE = TRUE;
                // Mind fog
                oAOE = GetNearestAOECastBy(AI_AOE_PER_FOGMIND, oCaster);
            }
        }
        break;
        // Special: Feats, knockdown
        case SPELL_GREASE:
        {
            if(iImmuneLevel < i1 &&
              (!GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_KNOCKDOWN) || iIgnoreImmunities) &&
              (!GetHasFeat(FEAT_WOODLAND_STRIDE, OBJECT_SELF) || iIgnoreImmunities) &&
              ((GetReflexSavingThrow(OBJECT_SELF) < iSaveDC + i2) || iIgnoreSaves))
            {
                SetAOE = TRUE;
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
            if(iImmuneLevel < i6 &&
               (((GetReflexSavingThrow(OBJECT_SELF) < iSaveDC + i6) &&
                  !GetHasFeat(FEAT_IMPROVED_EVASION) &&
                  !GetHasFeat(FEAT_EVASION)) || iIgnoreSaves))
            {
                SetAOE = TRUE;
                if(iSpellCast == SPELL_BLADE_BARRIER)
                {
                    // BB
                    oAOE = GetNearestAOECastBy(AI_AOE_PER_WALLBLADE, oCaster);
                }
                else if(iSpellCast == SPELL_INCENDIARY_CLOUD)
                {
                    // Fog of fire
                    oAOE = GetNearestAOECastBy(AI_AOE_PER_FOGFIRE, oCaster);
                }
                else if(iSpellCast == SPELL_WALL_OF_FIRE)
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
            if(iImmuneLevel < i6)
            {
                SetAOE = TRUE;
                if(iSpellCast == SPELL_ACID_FOG)
                {
                    // Acid fog
                    oAOE = GetNearestAOECastBy(AI_AOE_PER_FOGACID, oCaster);
                }
                else if(iSpellCast == SPELL_CLOUDKILL)
                {
                    // Cloud Kill
                    oAOE = GetNearestAOECastBy(AI_AOE_PER_FOGKILL, oCaster);
                }
                else if(iSpellCast == SPELL_CREEPING_DOOM)
                {
                    // Creeping doom
                    oAOE = GetNearestAOECastBy(AI_AOE_PER_CREEPING_DOOM, oCaster);
                }
            }
        }
        // Storm - because the AI likes it, we stay in it if it is ours :-)
        case SPELL_STORM_OF_VENGEANCE: // Reflex partial. No check, always damages.
        {
            if(oCaster != OBJECT_SELF && iImmuneLevel < i9)
            {
                SetAOE = TRUE;
                // Storm of vengance
                oAOE = GetNearestAOECastBy(AI_AOE_PER_STORM, oCaster);
            }
        }
    }
    if(SetAOE)
    {
        if(!GetLocalTimer(AI_TIMER_AOE_SPELL_EVENT + IntToString(iSpellCast)))
        {
            SetLocalTimer(AI_TIMER_AOE_SPELL_EVENT + IntToString(iSpellCast), f18);
            // Set nearest AOE
            if(GetIsObjectValid(oAOE))
            {
                // Set nearest AOE of this spell to the local
                object oNearest = GetAIObject(AI_TIMER_AOE_SPELL_EVENT + IntToString(iSpellCast));
                if(GetDistanceToObject(oAOE) < GetDistanceToObject(oNearest) ||
                  !GetIsObjectValid(oNearest))
                {
                    SetAIObject(AI_TIMER_AOE_SPELL_EVENT + IntToString(iSpellCast), oAOE);
                }
            }
        }
    }
}
// Gets the nearest AOE cast by oCaster, of sTag.
object GetNearestAOECastBy(string sTag, object oCaster)
{
    int iCnt = i1;
    object oAOE = GetNearestObjectByTag(sTag, OBJECT_SELF, iCnt);
    object oReturn = OBJECT_INVALID;
    // Loop
    while(GetIsObjectValid(oAOE) && !GetIsObjectValid(oReturn))
    {
        // Check creator
        if(GetAreaOfEffectCreator(oAOE) == oCaster)
        {
            oReturn = oAOE;
        }
        iCnt++;
        oAOE = GetNearestObjectByTag(sTag, OBJECT_SELF, iCnt);
    }
    return oReturn;
}

// Gets the amount of protections we have - IE globes
int GetOurSpellLevelImmunity()
{
    int iNatural = GetLocalInt(OBJECT_SELF, AI_SPELL_IMMUNE_LEVEL);
    // Stop here, if natural is over 4
    if(iNatural > i4) return iNatural;

    // Big globe affects 4 or lower spells
    if(GetHasSpellEffect(SPELL_GLOBE_OF_INVULNERABILITY, OBJECT_SELF) || iNatural >= i4)
        return i4;
    // Minor globe is 3 or under
    if(GetHasSpellEffect(SPELL_MINOR_GLOBE_OF_INVULNERABILITY, OBJECT_SELF) ||
       // Shadow con version
       GetHasSpellEffect(SPELL_GREATER_SHADOW_CONJURATION_MINOR_GLOBE, OBJECT_SELF) ||
       iNatural >= i3)
        return i3;
    // 2 and under is ethereal visage.
    if(GetHasSpellEffect(SPELL_ETHEREAL_VISAGE, OBJECT_SELF) || iNatural >= i2)
        return i2;
    // Ghostly Visarge affects 1 or 0 level spells, and any spell immunity.
    if(GetHasSpellEffect(SPELL_GHOSTLY_VISAGE, OBJECT_SELF) || iNatural >= i1 ||
       // Or shadow con version.
       GetHasSpellEffect(SPELL_GREATER_SHADOW_CONJURATION_MIRROR_IMAGE, OBJECT_SELF))
        return i1;
    // Return iNatural, which is 0-9
    return FALSE;
}
