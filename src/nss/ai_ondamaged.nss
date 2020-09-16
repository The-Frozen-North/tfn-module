/************************ [On Damaged] *****************************************
    Filename: nw_c2_default6 or ai_ondamaged
************************* [On Damaged] *****************************************
    We attack any damager if same area (and not already fighting
    then search for enemies (defaults to searching if there are no enemies left).
************************* [History] ********************************************
    1.3 - If we have a damager, not equal faction, and not a DM...
            - We set Max Elemental damage.
        - Sets the highest damager and amount (if the new damager is seen/heard)
        - Polymorph improved a little
        - Hide check
        - Morale penalty (if set)
************************* [Workings] *******************************************
    GetDamageDealtByType() will not work with proper phisical attacks - a workaround
    is GetTotalDamageDealt() - All GetDamageDealtByType(). This means it will
    get everything not applied with EffectDamage() which normally fires this
    script.
************************* [Arguments] ******************************************
    Arguments: GetTotalDamageDealt, GetLastDamager, GetCurrentHitPoints (and max),
               GetDamageDealtByType (must be done seperatly for each, doesn't count melee damage)
************************* [On Damaged] ****************************************/

#include "inc_ai_other"
void main()
{
    // Pre-damaged-event
    if(FireUserEvent(AI_FLAG_UDE_DAMAGED_PRE_EVENT, EVENT_DAMAGED_PRE_EVENT))
        // We may exit if it fires
        if(ExitFromUDE(EVENT_DAMAGED_PRE_EVENT)) return;

    // AI status check. Is the AI on?
    if(GetAIOff()) return;

    // Define Objects/Integers.
    int iDamage = GetTotalDamageDealt();
    object oDamager = GetLastDamager();
    // Check to see if we will polymorph.
    int iPolymorph = GetAIConstant(AI_POLYMORPH_INTO);

    // Polymorph check.
    if(iPolymorph >= i0)
    {
        if(!GetHasEffect(EFFECT_TYPE_POLYMORPH))// We won't polymorph if already so
        {
            effect eShape = SupernaturalEffect(EffectPolymorph(iPolymorph));
            effect eVis = EffectVisualEffect(VFX_FNF_SUMMON_UNDEAD);
            DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_PERMANENT, eShape, OBJECT_SELF));
            DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, OBJECT_SELF));
        }
        SetAIConstant(AI_POLYMORPH_INTO, -1);// We set it to invalid (sets to 0).
    }
    // First, we check AOE spells...
    if(GetObjectType(oDamager) == OBJECT_TYPE_AREA_OF_EFFECT)
    {
        // Set the damage done by it (the last damage)
        // Set to the tag of the AOE, prefixed AI style to be sure.
        // - Note, doesn't matter about things like
        if(iDamage > i1)
        {
            // Set it to object to string, which we will delete later anywho.
            SetAIInteger(ObjectToString(oDamager), iDamage);
        }
    }
    // Hostile attacker...
    else if(GetIsObjectValid(oDamager) && !GetFactionEqual(oDamager) &&
           !GetIsDM(oDamager)&& !GetIgnore(oDamager))
    {
        // Adjust automatically if set. (and not an AOE)
        if(GetSpawnInCondition(AI_FLAG_OTHER_CHANGE_FACTIONS_TO_HOSTILE_ON_ATTACK, AI_OTHER_MASTER))
        {
            if(!GetIsEnemy(oDamager) && !GetFactionEqual(oDamager))
            {
                AdjustReputation(oDamager, OBJECT_SELF, -100);
            }
        }
        // Set the max elemental damage done, for better use of elemental protections.
        // This is set for the most damage...so it could be 1 (for a +1 fire weapon, any
        // number of hits) or over 50 (good fireball).
        // Need to have protection single (IE including elemental ones) ready.
        if(GetSpawnInCondition(AI_VALID_TALENT_BENEFICIAL_PROTECTION_SINGLE, AI_VALID_SPELLS))
        {
            // Please make sure | works! By Blind Io!
            int iDamageDone = GetDamageDealtByType(DAMAGE_TYPE_ACID |
                                DAMAGE_TYPE_COLD | DAMAGE_TYPE_ELECTRICAL |
                                DAMAGE_TYPE_FIRE | DAMAGE_TYPE_SONIC);
            if(iDamageDone > GetAIInteger(MAX_ELEMENTAL_DAMAGE))
            {
                SetAIInteger(MAX_ELEMENTAL_DAMAGE, iDamageDone);
            }
            // Set the last damage done, may set to 0 of course :-P
            SetAIInteger(LAST_ELEMENTAL_DAMAGE, iDamageDone);
        }

        // Turn of hiding, a timer to activate Hiding in the main file. This is
        // done in each of the events, with the opposition checking seen/heard.
        TurnOffHiding(oDamager);

        // Speak the damaged string, if applicable.
        SpeakArrayString(AI_TALK_ON_DAMAGED);

        // Morale: We may get a penalty if it does more than a cirtain amount of HP damage.
        // Other: We set highest damager and amount.
        if(iDamage > i0)
        {
            if(!GetSpawnInCondition(AI_FLAG_FLEEING_FEARLESS, AI_TARGETING_FLEE_MASTER))
            {
                int iToDamage = GetBoundriedAIInteger(AI_DAMAGE_AT_ONCE_FOR_MORALE_PENALTY, GetMaxHitPoints()/i6, GetMaxHitPoints(), i1);
                int iPenalty = GetBoundriedAIInteger(AI_DAMAGE_AT_ONCE_PENALTY, i6, i50, i1);
                if(iDamage > iToDamage)
                {
                    // 61: "[Damaged] Morale Penalty for 600 seconds [Penalty]" + IntToString(iPenalty)
                    DebugActionSpeakByInt(61, OBJECT_INVALID, iPenalty);
                    // Apply penalty
                    SetMoralePenalty(iPenalty, 300.0);
                }
            }
            object oHighestDamager = GetAIObject(AI_HIGHEST_DAMAGER);
            int iHighestDamage = GetAIInteger(AI_HIGHEST_DAMAGE_AMOUNT);
            // If the original was not valid...or not seen/heard, we delete it whatever.
            if(!GetIsObjectValid(oHighestDamager) ||
              (!GetObjectSeen(oHighestDamager) && !GetObjectHeard(oHighestDamager)))
            {
                DeleteAIObject(AI_HIGHEST_DAMAGER);
                DeleteAIInteger(AI_HIGHEST_DAMAGE_AMOUNT);
            }
            // Set the highest damager.
            if((GetObjectSeen(oDamager) || GetObjectHeard(oDamager)) &&
                iDamage >= iHighestDamage)
            {
                SetAIObject(AI_HIGHEST_DAMAGER, oDamager);
                SetAIInteger(AI_HIGHEST_DAMAGE_AMOUNT, iDamage);
            }
            // Phisical damage - only sets if the last damager is the last attacker.
            if(GetAIObject(AI_STORED_LAST_ATTACKER) == oDamager)
            {
                int iHighestPhisicalDamage = GetAIInteger(AI_HIGHEST_PHISICAL_DAMAGE_AMOUNT);
                int iPhisicalDamage = iDamage -
                // This relies upon the bug that these damage types only return damage
                // from EffectDamage, and melee damage is any that remains. Wish it was
                // fixed though...
                GetDamageDealtByType(DAMAGE_TYPE_ACID | DAMAGE_TYPE_BLUDGEONING |
                                     DAMAGE_TYPE_COLD | DAMAGE_TYPE_DIVINE |
                                     DAMAGE_TYPE_ELECTRICAL | DAMAGE_TYPE_FIRE |
                                     DAMAGE_TYPE_MAGICAL | DAMAGE_TYPE_NEGATIVE |
                                     DAMAGE_TYPE_PIERCING | DAMAGE_TYPE_POSITIVE |
                                     DAMAGE_TYPE_SLASHING | DAMAGE_TYPE_SONIC);
                if(iHighestPhisicalDamage < iPhisicalDamage)
                {
                    SetAIInteger(AI_HIGHEST_PHISICAL_DAMAGE_AMOUNT, iPhisicalDamage);
                }
            }
        }
        // If we are not attacking anything, and not in combat, react!
        if(!CannotPerformCombatRound())
        {
            // 62: "[Damaged] Not in combat: DCR [Damager]" + GetName(oDamager)
            DebugActionSpeakByInt(62, oDamager);
            if(GetArea(oDamager) == GetArea(OBJECT_SELF))
            {
                DetermineCombatRound(oDamager);
            }
            else
            {
                DetermineCombatRound();
            }
        }
    }
    else  // Else it is friendly, or invalid damager
    {
        if(!CannotPerformCombatRound())
        {
            // 63: [Damaged] Not in combat: DCR. Ally hit us. [Damager(Ally?)]" + GetName(oDamager)
            DebugActionSpeakByInt(63, oDamager);
            DetermineCombatRound();
        }
    }
    // User defined event - for normally immoral creatures.
    if(GetCurrentHitPoints() == i1)
    {
        // Fire the immortal damaged at 1 HP event.
        FireUserEvent(AI_FLAG_UDE_DAMAGED_AT_1_HP, EVENT_DAMAGED_AT_1_HP);
    }
    // Fire End of Damaged event
    FireUserEvent(AI_FLAG_UDE_DAMAGED_EVENT, EVENT_DAMAGED_EVENT);
}
