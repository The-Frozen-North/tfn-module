/*/////////////////////// [Ability - Dragon Wing Buffet] ///////////////////////
    Filename: J_AI_WingBuffet
///////////////////////// [Ability - Dragon Wing Buffet] ///////////////////////
    "The dragon will launch into the air, knockdown
    all opponents who fail a Reflex Save and then
    land on one of those opponents doing damage
    up to a maximum of the Dragons HD + 10."

    This is modified by Jasperre for use by Dragons in the AI. Instead of
    crashing, using effect appear, disspear, it just uses effect appear.

///////////////////////// [History] ////////////////////////////////////////////
    1.3 - Made the "action attack" work better, getting the nearest
          seen and heard instead of the nearest (which may not be seen or heard).
        - Added in random damage for each target!
        - Faction Equal as well as GetIsFriend check.
    1.4 - Cleaned it up a bit, to be more readable.
///////////////////////// [Workings] ///////////////////////////////////////////
    Executed via. ExecuteScript from the AI file, it is seperate because it is
    almost a new AI ability.
///////////////////////// [Arguments] //////////////////////////////////////////
    Arguments: N/A
///////////////////////// [Ability - Dragon Wing Buffet] /////////////////////*/

void main()
{
    // Stop the creature's actions.
    ClearAllActions();// To rid errors.

    // Declare major variables
    int nDamage;
    int nDC = GetHitDice(OBJECT_SELF);
    location lSelf = GetLocation(OBJECT_SELF);
    string sMessage = GetName(OBJECT_SELF) + " is using its wing buffet against you!";
    location lTarget;
    float fRandomKnockdown;
    // Use a delay based on range,
    float fDelay;

    // Declare effects
    effect eDam;
    effect eKnockDown = EffectKnockdown();
    effect eVis = EffectVisualEffect(VFX_IMP_PULSE_WIND);

    // Pulse of wind applied...
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, lSelf);

    // Get first target in spell area
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, lSelf);
    while(GetIsObjectValid(oTarget))
    {
        // Get thier location (for visual) and the delay.
        lTarget = GetLocation(oTarget);
        fDelay = GetDistanceToObject(oTarget)/20.0;

        // Wind pulse to all
        DelayCommand(fDelay, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, lTarget));

        // Do not effect allies.
        if(!GetIsFriend(oTarget) && !GetFactionEqual(oTarget))
        {
            // Send a message about the wing buffet (allies do not see this)
            SendMessageToPC(oTarget, sMessage);

            // Huge creatures (IE: Dragon size) are not affected.
            if(GetCreatureSize(oTarget) != CREATURE_SIZE_HUGE)
            {
                // A standard (not spell) reflex save negates the damage and knockdown
                if(!ReflexSave(oTarget, nDC))
                {
                    // Randomise damage. (nDC = Hit dice)
                    nDamage = Random(nDC) + 11;

                    // Define the damage
                    eDam = EffectDamage(nDamage, DAMAGE_TYPE_BLUDGEONING);

                    // Randomise knockdown duration, to minimum of 6.0 (1.0/2 = 0.5. + 5.5 = 6.0)
                    fRandomKnockdown = 5.5 + ((IntToFloat(Random(30)) + 1.0)/10.0);

                    // We'll have a windy effect..depending on range
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnockDown, oTarget, fRandomKnockdown));
                }
            }
        }
        // Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, lSelf);
    }

    // Do a great flapping  wings on land effect.
    effect eAppear = EffectAppear();
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eAppear, OBJECT_SELF);

    // Attack the nearest seen (so not to stand there for 6 seconds, but get
    // back in the action!).
    object oNearest = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
    if(GetIsObjectValid(oNearest))
    {
        DelayCommand(1.0, ActionAttack(oNearest));
    }
    else
    {
        oNearest = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_HEARD, CREATURE_TYPE_IS_ALIVE, TRUE);
        if(GetIsObjectValid(oNearest))
        {
            DelayCommand(1.0, ActionAttack(oNearest));
        }
    }
}

