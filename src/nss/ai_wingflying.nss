/*/////////////////////// [Ability - Dragon Flying] ////////////////////////////
    Filename: J_AI_WingFlying
///////////////////////// [Ability - Dragon Flying] ////////////////////////////
    Hey, a dragon can fly (if we are set to, mind you!) this is executed from
    the default AI, using local objects to "fly" to, a duration based on the
    distance between the 2 places.

    When we fly down, we apply knockdown to the targets in the area's affected
    if not huge size, like wing buffet.

    NOTE:

    - Can be used with NPC's who are not dragons, but if they are not huge,
      the damage is not done (only the pulses at thier location and the target
      location)
///////////////////////// [History] ////////////////////////////////////////////
    1.3 - Added
    1.4 - Added an actual spell event fire for the damage. It might not have
          registered with some hostile monsters otherwise! (EG: DR)
///////////////////////// [Workings] ///////////////////////////////////////////
    Executed via. ExecuteScript from the AI file, it is seperate because it is
    almost a new AI ability.

    It is a 6 second or more fly - note it adds 1/10 second more for each
    1M between targets. Not too much, but enough.

    Does damage to landing and taking off sites too :-)
///////////////////////// [Arguments] //////////////////////////////////////////
    Arguments: N/A
///////////////////////// [Ability - Dragon Flying] //////////////////////////*/

#include "inc_ai_constants"

// Damages area with blast of flying
void DoDamageToArea(location lLocation);

void main()
{
    // Get the target location
    object oJumpTo = GetAIObject(AI_FLYING_TARGET);
    location lJumpTo = GetLocation(oJumpTo);

    DeleteAIObject(AI_FLYING_TARGET);

    // Errors
    if(!GetIsObjectValid(oJumpTo)) return;

    ClearAllActions();// To rid errors.
    SetFacingPoint(GetPosition(oJumpTo));

    // Get location of ourselves, to damage those as we fly away.
    location lSelf = GetLocation(OBJECT_SELF);
    // Jump to the next location, using a delay of 3.0 seconds + Distance/10
    float fDuration = 3.0 + (GetDistanceBetweenLocations(lSelf, lJumpTo)/10.0);

    if(GetCreatureSize(OBJECT_SELF) == CREATURE_SIZE_HUGE)
    {
        // Damage instantly
        DelayCommand(1.0, DoDamageToArea(lSelf));
        // Delay the jump down damage - a little extra delay mind you.
        DelayCommand(fDuration + 1.2, DoDamageToArea(lJumpTo));
    }
    else
    {
        // Visual effects only
        effect eImpact = EffectVisualEffect(VFX_IMP_PULSE_WIND);
        // Pulse of wind applied...
        DelayCommand(1.0, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, lSelf));
        // Delay the new wind
        DelayCommand(fDuration + 1.2, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, lJumpTo));
    }
    // New determine combat round - via. Action attacking.
    DelayCommand(fDuration + 1.5, ActionAttack(oJumpTo));

    effect eFly = EffectDisappearAppear(lJumpTo);
    DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eFly, OBJECT_SELF, fDuration - 1.0));
}

// Damages area with blast of flying
void DoDamageToArea(location lLocation)
{
    // Declare effects
    effect eKnockDown = EffectKnockdown();
    int nDamage;
    int nDC = GetHitDice(OBJECT_SELF);
    effect eDam;
    effect eVis = EffectVisualEffect(VFX_IMP_PULSE_WIND);
    // Use a delay based on range,
    float fDelay;

    string sMessage = GetName(OBJECT_SELF) + " is flying!";
    location lTarget;
    float fRandomKnockdown;
    // Pulse of wind applied...
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, lLocation);
    //Apply the VFX impact and effects
    //Get first target in spell area
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, lLocation);
    while(GetIsObjectValid(oTarget))
    {
        lTarget = GetLocation(oTarget);
        fDelay = GetDistanceBetweenLocations(lTarget, lLocation)/20.0;
        // Visual wind pulse
        DelayCommand(fDelay, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, lTarget));
        //Get next target in spell area
        // Do not effect allies.
        if(!GetIsFriend(oTarget) && !GetFactionEqual(oTarget))
        {
            SendMessageToPC(oTarget, sMessage);
            // Can't knock over huge things!
            if(GetCreatureSize(oTarget) != CREATURE_SIZE_HUGE)
            {
                // Signal spell cast at event
                // * Using: SPELLABILITY_DRAGON_WING_BUFFET - just so something is used
                SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_DRAGON_WING_BUFFET));

                // Reflex save for damage
                if(!ReflexSave(oTarget, nDC))
                {
                    // Randomise damage. (nDC = Hit dice)
                    nDamage = Random(nDC) + 11;
                    eDam = EffectDamage(nDamage, DAMAGE_TYPE_BLUDGEONING);
                    // Randomise knockdown, to minimum of 6.0 (1.0/2 = 0.5. + 5.5 = 6.0)
                    fRandomKnockdown = 5.5 + ((IntToFloat(Random(30)) + 1.0)/10.0);
                    // We'll have a windy effect..depending on range
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnockDown, oTarget, fRandomKnockdown));
                }
            }
        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, lLocation);
    }
}

