/*/////////////////////// [On Damaged] /////////////////////////////////////////
    Filename: nw_c2_default6 or J_AI_OnDamaged
///////////////////////// [On Damaged] /////////////////////////////////////////
    We attack any damager if same area (and not already fighting
    then search for enemies (defaults to searching if there are no enemies left).
///////////////////////// [History] ////////////////////////////////////////////
    1.3 - If we have a damager, not equal faction, and not a DM...
            - We set Max Elemental damage.
        - Sets the highest damager and amount (if the new damager is seen/heard)
        - Polymorph improved a little
        - Hide check
        - Morale penalty (if set)
    1.4 - Elemental damage fixed with bugfixed introduced in later patches.
        - Moved things around, more documentation, a little more ordered.
        - Added the missing silent shout strings to get allies to attack.
        - Damaged taunting will not happen if we are dead.
///////////////////////// [Workings] ///////////////////////////////////////////
    Now with fixes, we can correctly set physical damage done (and elemental
    damage).

    Otherwise, this acts like a hositile spell, or a normal attack or pickpocket
    attempt would - and attack the damn person who dares damage us!
///////////////////////// [Arguments] //////////////////////////////////////////
    Arguments: GetTotalDamageDealt, GetLastDamager, GetCurrentHitPoints (and max),
               GetDamageDealtByType (must be done seperatly for each, doesn't count melee damage)
///////////////////////// [On Damaged] ///////////////////////////////////////*/

#include "J_INC_OTHER_AI"

void main()
{
    // Pre-damaged-event. Returns TRUE if we interrupt this script call.
    if(FirePreUserEvent(AI_FLAG_UDE_DAMAGED_PRE_EVENT, EVENT_DAMAGED_PRE_EVENT)) return;

    // AI status check. Is the AI on?
    if(GetAIOff()) return;

    // Define Objects/Integers.
    int nDamage = GetTotalDamageDealt();
    object oDamager = GetLastDamager();
    // Check to see if we will polymorph.
    int nPolymorph = GetAIConstant(AI_POLYMORPH_INTO);

    // Total up the physical damage

    // Polymorph check.
    if(nPolymorph >= 0)
    {
        // We won't polymorph if already so
        if(!GetHasEffect(EFFECT_TYPE_POLYMORPH))
        {
            // Polymorph into the requested shape. Cannot be dispelled.
            effect eShape = SupernaturalEffect(EffectPolymorph(nPolymorph));
            effect eVis = EffectVisualEffect(VFX_FNF_SUMMON_UNDEAD);
            DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_PERMANENT, eShape, OBJECT_SELF));
            DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, OBJECT_SELF));
        }
        DeleteAIConstant(AI_POLYMORPH_INTO);// We set it to invalid (sets to 0).
    }
    // First, we check AOE spells...
    if(GetObjectType(oDamager) == OBJECT_TYPE_AREA_OF_EFFECT)
    {
        // Set the damage done by it (the last damage)
        // Set to the tag of the AOE, prefixed AI style to be sure.
        // - Note, doesn't matter about things like
        if(nDamage > 0)
        {
            // Set it to object to string, which we will delete later anywho.
            SetAIInteger(ObjectToString(oDamager), nDamage);
        }
    }
    // Hostile attacker...but it doesn't matter (at the moment) if they even
    // did damage.
    // * GetIgnoreNoFriend() wrappers DM, Validity, Faction Equal and Dead checks in one
    else if(!GetIgnoreNoFriend(oDamager))
    {
        // Adjust automatically if set. (and not an AOE)
        if(GetSpawnInCondition(AI_FLAG_OTHER_CHANGE_FACTIONS_TO_HOSTILE_ON_ATTACK, AI_OTHER_MASTER))
        {
            if(!GetIsEnemy(oDamager) && !GetFactionEqual(oDamager))
            {
                AdjustReputation(oDamager, OBJECT_SELF, -100);
            }
        }

        // Turn of hiding, a timer to activate Hiding in the main file. This is
        // done in each of the events, with the opposition checking seen/heard.
        TurnOffHiding(oDamager);

        // Did they do damage to use? (IE: No DR) Some things are inapproprate
        // to check if no damage was actually done.
        if(nDamage > 0)
        {
            // Speak the damaged string, if applicable.
            // * Don't speak when dead. 1.4 change (an obvious one to make)
            if(CanSpeak())
            {
                SpeakArrayString(AI_TALK_ON_DAMAGED);
            }
            // 1.4 note: These two variables are currently *unused* apart from
            // healing. When healing a being (even another NPC) they are checked
            // for massive damage. Can not bother to set the highest damager for now.
            // NEW:
            int nHighestDamage = GetAIInteger(AI_HIGHEST_DAMAGE_AMOUNT);
            if(nDamage >= nHighestDamage)
            {
                SetAIInteger(AI_HIGHEST_DAMAGE_AMOUNT, nDamage);
            }

            /* OLD:

            // Get the previous highest damager, and highest damage amount
            object oHighestDamager = GetAIObject(AI_HIGHEST_DAMAGER);
            int nHighestDamage = GetAIInteger(AI_HIGHEST_DAMAGE_AMOUNT);
            // Set the highest damager, if they are seen or heard, and have done loads.
            if((GetObjectSeen(oDamager) || GetObjectHeard(oDamager)) &&
                nDamage >= nHighestDamage || !GetIsObjectValid(oHighestDamager))
            {
                SetAIObject(AI_HIGHEST_DAMAGER, oDamager);
                SetAIInteger(AI_HIGHEST_DAMAGE_AMOUNT, nDamage);
            }
            // Else, if the original was not valid...or not seen/heard, we
            // delete it so we don't bother to use it later.
            else if(!GetIsObjectValid(oHighestDamager) ||
              (!GetObjectSeen(oHighestDamager) && !GetObjectHeard(oHighestDamager)))
            {
                DeleteAIObject(AI_HIGHEST_DAMAGER);
                DeleteAIInteger(AI_HIGHEST_DAMAGE_AMOUNT);
            }
            */

            // Get all the physical damage. Elemental damage is then nDamage minus
            // the physical damage.
            int nPhysical = GetDamageDealtByType(DAMAGE_TYPE_BASE_WEAPON |
                                                 DAMAGE_TYPE_BLUDGEONING |
                                                 DAMAGE_TYPE_PIERCING |
                                                 DAMAGE_TYPE_SLASHING);
            // If they are all -1, then we make nPhysical 0.
            if(nPhysical <= -1) nPhysical = 0;

            // Physical damage - only sets if the last damager is the last attacker.
            if(GetAIObject(AI_STORED_LAST_ATTACKER) == oDamager)
            {
                // Get the previous highest damage and test it
                if(nPhysical > GetAIInteger(AI_HIGHEST_PHISICAL_DAMAGE_AMOUNT))
                {
                    // If higher, and was a melee/ranged attacker, set it.
                    // This does include other additional physical damage - EG:
                    // weapon property: Bonus Damage.
                    SetAIInteger(AI_HIGHEST_PHISICAL_DAMAGE_AMOUNT, nPhysical);
                }
            }

            // Set the max elemental damage done, for better use of elemental
            // protections. This is set for the most damage...so it could be
            // 1 (for a +1 fire weapon, any number of hits) or over 50 (good
            // fireball/flame storm etc.)
            int nElemental = nDamage - nPhysical;
            if(nElemental > GetAIInteger(MAX_ELEMENTAL_DAMAGE))
            {
                SetAIInteger(MAX_ELEMENTAL_DAMAGE, nElemental);
            }
            // Set the last damage done, may set to 0 of course :-P
            // * This is only set if they did damage us at all, however.
            SetAIInteger(LAST_ELEMENTAL_DAMAGE, nElemental);

            // Morale: We may get a penalty if it does more than a cirtain amount of HP damage.
            // Other: We set highest damager and amount.
            if(!GetSpawnInCondition(AI_FLAG_FLEEING_FEARLESS, AI_TARGETING_FLEE_MASTER))
            {
                // Get penalty and how much damage at once needs to be done
                int nPenalty = GetBoundriedAIInteger(AI_DAMAGE_AT_ONCE_PENALTY, 6, 50, 1);
                int nToDamage = GetBoundriedAIInteger(AI_DAMAGE_AT_ONCE_FOR_MORALE_PENALTY, GetMaxHitPoints()/6, GetMaxHitPoints(), 1);
                if(nDamage > nToDamage)
                {
                    // 61: "[Damaged] Morale Penalty for 600 seconds [Penalty]" + IntToString(iPenalty)
                    DebugActionSpeakByInt(61, OBJECT_INVALID, nPenalty);
                    // Apply penalty
                    SetMoralePenalty(nPenalty, 300.0);
                }
            }
        }
        // If we are not attacking anything, and not in combat, react!
        if(!CannotPerformCombatRound())
        {
            // 62: "[Damaged] Not in combat: DCR [Damager]" + GetName(oDamager)
            DebugActionSpeakByInt(62, oDamager);

            // Check if they are in the same area. Can be a left AOE spell.
            // Don't attack purposly across area's.
            if(GetArea(oDamager) == GetArea(OBJECT_SELF))
            {
                // Shout to allies to attack the enemy who attacked me
                AISpeakString(AI_SHOUT_I_WAS_ATTACKED);

                DetermineCombatRound(oDamager);
            }
            else
            {
                // Shout to allies to attack, or be prepared.
                AISpeakString(AI_SHOUT_CALL_TO_ARMS);

                DetermineCombatRound();
            }
        }
        else
        {
            // Shout to allies to attack, or be prepared.
            AISpeakString(AI_SHOUT_CALL_TO_ARMS);
        }
    }
    // Else it is friendly, or invalid damager
    else
    {
        // Still will react - eg: A left AOE spell (which might mean a battle
        // just happened)
        if(!CannotPerformCombatRound())
        {
            // Shout to allies to attack generally. No target to specifically attack,
            // as it is an ally.
            AISpeakString(AI_SHOUT_CALL_TO_ARMS);

            // 63: [Damaged] Not in combat: DCR. Ally hit us. [Damager(Ally?)]" + GetName(oDamager)
            DebugActionSpeakByInt(63, oDamager);
            DetermineCombatRound();
        }
        else
        {
            // Shout to allies to attack, or be prepared.
            AISpeakString(AI_SHOUT_CALL_TO_ARMS);
        }
    }
    // User defined event - for normally immoral creatures.
    if(GetCurrentHitPoints() == 1)
    {
        // Fire the immortal damaged at 1 HP event.
        FireUserEvent(AI_FLAG_UDE_DAMAGED_AT_1_HP, EVENT_DAMAGED_AT_1_HP);
    }
    // Fire End of Damaged event
    FireUserEvent(AI_FLAG_UDE_DAMAGED_EVENT, EVENT_DAMAGED_EVENT);
}
