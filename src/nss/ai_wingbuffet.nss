/************************ [Dragon Wing Buffet] *********************************
    Filename: J_AI_WingBuffet
************************* [Dragon Wing Buffet] *********************************
    "The dragon will launch into the air, knockdown
    all opponents who fail a Reflex Save and then
    land on one of those opponents doing damage
    up to a maximum of the Dragons HD + 10."

    This is modified by Jasperre for use by Dragons in the AI. Instead of
    crashing, using effect appear, disspear, it just uses effect appear.

************************* [History] ********************************************
    Version 1.3 changes
    - Made the "action attack" work better, getting the nearest
      seen and heard instead of the nearest (which may not be seen or heard).
    - Added in random damage for each target!
    - Faction Equal as well as GetIsFriend check.
************************* [Workings] *******************************************
    Executed via. ExecuteScript from the AI file, it is seperate because it is
    almost a new AI ability.
************************* [Arguments] ******************************************
    Arguments: N/A
************************* [Dragon Wing Buffet] ********************************/

void main()
{
    //Declare major variables
    ClearAllActions();// To rid errors.
    effect eKnockDown = EffectKnockdown();
    int nDamage;
    int nDC = GetHitDice(OBJECT_SELF);
    effect eDam;
    effect eVis = EffectVisualEffect(VFX_IMP_PULSE_WIND);
    // Use a delay based on range,
    float fDelay;
    location lSelf = GetLocation(OBJECT_SELF);
    string sMessage = GetName(OBJECT_SELF) + " is using its wing buffet against you!";
    location lTarget;
    float fRandomKnockdown;
    // Pulse of wind applied...
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, lSelf);
    //Apply the VFX impact and effects
    //Get first target in spell area
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, lSelf);
    while(GetIsObjectValid(oTarget))
    {
        lTarget = GetLocation(oTarget);
        fDelay = GetDistanceToObject(oTarget)/20.0;
        // Wind pulse to all
        DelayCommand(fDelay, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, lTarget));
        //Get next target in spell area
        // Do not effect allies.
        if(!GetIsFriend(oTarget) && !GetFactionEqual(oTarget))
        {
            SendMessageToPC(oTarget, sMessage);
            if(GetCreatureSize(oTarget) != CREATURE_SIZE_HUGE)
            {
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
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, lSelf);
    }
    // Do a great flapping  wings on land effect.
    effect eAppear = EffectAppear();
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eAppear, OBJECT_SELF);
    // Attack the nearest seen (so not to stand there for 6 seconds).
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
