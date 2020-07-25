//::///////////////////////////////////////////////
//:: Turn Undead
//:: NW_S2_TurnDead
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Checks domain powers and class to determine
    the proper turning abilities of the casting
    character.
*/
//:://////////////////////////////////////////////
//:: Created By: Nov 2, 2001
//:: Created On: Preston Watamaniuk
//:://////////////////////////////////////////////
//:: MODIFIED MARCH 5 2003 for Blackguards
//:: Modified November 29, 2003 for Evil Cleric Rebuke/Command

// Checks to see if an evil cleric has control 'slots' to command
// the specified undead
// if TRUE, the cleric has enough levels of control to control the undead
// if FALSE, the cleric will rebuke the undead instead
int CanCommand(int nClassLevel, int nTargetHD) {
    int nSlots = GetLocalInt(OBJECT_SELF, "wb_clr_comm_slots");
    int nNew = nSlots + nTargetHD;
    //FloatingTextStringOnCreature("The variable is " + IntToString(nSlots), OBJECT_SELF);
    if(nClassLevel >= nNew) {
        return TRUE;
    }
    return FALSE;
}

void AddCommand(int nTargetHD) {
    int nSlots = GetLocalInt(OBJECT_SELF, "wb_clr_comm_slots");
    SetLocalInt(OBJECT_SELF, "wb_clr_comm_slots", nSlots + nTargetHD);
}

void SubCommand(int nTargetHD) {
    int nSlots = GetLocalInt(OBJECT_SELF, "wb_clr_comm_slots");
    SetLocalInt(OBJECT_SELF, "wb_clr_comm_slots", nSlots - nTargetHD);
}

void RebukeUndead(int nTurnLevel, int nTurnHD, int nVermin, int nElemental, int nConstructs, int nOutsider, int nClassLevel) {
    //Gets all creatures in a 20m radius around the caster and rebukes them or not.  If the creatures
    //HD are 1/2 or less of the nClassLevel then the creature is commanded (dominated).
    int nCnt = 1;
    int nHD, nRacial, nHDCount, bValid, nDamage;
    nHDCount = 0;
    effect eVis = EffectVisualEffect(VFX_IMP_PULSE_NEGATIVE);
    effect eVisTurn = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DOMINATED);
    effect eDamage;
    effect eTurned = EffectCutsceneParalyze();
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink = EffectLinkEffects(eVisTurn, eTurned);
    eLink = EffectLinkEffects(eLink, eDur);

    effect eDeath = SupernaturalEffect(EffectCutsceneDominated());
    effect eDomin = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);
    effect eDeathLink = EffectLinkEffects(eDeath, eDomin);

    effect eImpactVis = EffectVisualEffect(VFX_FNF_LOS_EVIL_30);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpactVis, GetLocation(OBJECT_SELF));

    //Get nearest enemy within 20m (60ft)
    //Why are you using GetNearest instead of GetFirstObjectInShape
    object oTarget = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE , OBJECT_SELF, nCnt,CREATURE_TYPE_PERCEPTION , PERCEPTION_SEEN);
    while(GetIsObjectValid(oTarget) && nHDCount < nTurnHD && GetDistanceToObject(oTarget) <= 20.0)
    {
        if(!GetIsFriend(oTarget))
        {
            nHD = GetHitDice(oTarget) + GetTurnResistanceHD(oTarget);
            nRacial = GetRacialType(oTarget);
            if(nHD <= nTurnLevel && nHD <= (nTurnHD - nHDCount))
            {
                //Check the various domain turning types
                if(nRacial == RACIAL_TYPE_UNDEAD)
                {
                    bValid = TRUE;
                }
                else if (nRacial == RACIAL_TYPE_VERMIN && nVermin > 0)
                {
                    bValid = TRUE;
                }
                else if (nRacial == RACIAL_TYPE_ELEMENTAL && nElemental > 0)
                {
                    bValid = TRUE;
                }
                else if (nRacial == RACIAL_TYPE_CONSTRUCT && nConstructs > 0)
                {
                    SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_TURN_UNDEAD));
                    nDamage = d3(nTurnLevel);
                    eDamage = EffectDamage(nDamage, DAMAGE_TYPE_MAGICAL);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oTarget);
                    nHDCount += nHD;
                }
                else if (nRacial == RACIAL_TYPE_OUTSIDER && nOutsider > 0)
                {
                    bValid = TRUE;
                }

                //Apply results of the turn
                if( bValid == TRUE)
                {
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
                    //if(IntToFloat(nClassLevel)/2.0 >= IntToFloat(nHD))
                    //{

                    if((nClassLevel/2) >= nHD && CanCommand(nClassLevel, nHD))
                    {
                        //Fire cast spell at event for the specified target
                        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_TURN_UNDEAD));
                        //Destroy the target
                        DelayCommand(0.1f, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDeathLink, oTarget, RoundsToSeconds(nClassLevel + 5)));
                        //AssignCommand(oTarget, ClearAllActions());
                        //SetIsTemporaryFriend(oTarget, OBJECT_SELF, TRUE, RoundsToSeconds(nClassLevel + 5));
                        AddCommand(nHD);
                        DelayCommand(RoundsToSeconds(nClassLevel + 5), SubCommand(nHD));
                    }
                    else
                    {
                        //Turn the target
                        //Fire cast spell at event for the specified target
                        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_TURN_UNDEAD));
                        //AssignCommand(oTarget, ActionMoveAwayFromObject(OBJECT_SELF, TRUE));
                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nClassLevel + 5));
                    }
                    nHDCount = nHDCount + nHD;
                }
            }
            bValid = FALSE;
        }
        nCnt++;
        oTarget = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE , OBJECT_SELF, nCnt,CREATURE_TYPE_PERCEPTION , PERCEPTION_SEEN);
    }
}

void TurnUndead(int nTurnLevel, int nTurnHD, int nVermin, int nElemental, int nConstructs, int nOutsider, int nClassLevel) {
    //Gets all creatures in a 20m radius around the caster and turns them or not.  If the creatures
    //HD are 1/2 or less of the nClassLevel then the creature is destroyed.
    int nCnt = 1;
    int nHD, nRacial, nHDCount, bValid, nDamage;
    nHDCount = 0;
    effect eVis = EffectVisualEffect(VFX_IMP_SUNSTRIKE);
    effect eVisTurn = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);
    effect eDamage;
    effect eTurned = EffectTurned();
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink = EffectLinkEffects(eVisTurn, eTurned);
    eLink = EffectLinkEffects(eLink, eDur);

    effect eDeath = SupernaturalEffect(EffectDeath(TRUE));

    effect eImpactVis = EffectVisualEffect(VFX_FNF_LOS_HOLY_30);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpactVis, GetLocation(OBJECT_SELF));

    //Get nearest enemy within 20m (60ft)
    //Why are you using GetNearest instead of GetFirstObjectInShape
    object oTarget = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE , OBJECT_SELF, nCnt,CREATURE_TYPE_PERCEPTION , PERCEPTION_SEEN);
    while(GetIsObjectValid(oTarget) && nHDCount < nTurnHD && GetDistanceToObject(oTarget) <= 20.0)
    {
        if(!GetIsFriend(oTarget))
        {
            nHD = GetHitDice(oTarget) + GetTurnResistanceHD(oTarget);
            nRacial = GetRacialType(oTarget);
            if(nHD <= nTurnLevel && nHD <= (nTurnHD - nHDCount))
            {
                //Check the various domain turning types
                if(nRacial == RACIAL_TYPE_UNDEAD)
                {
                    bValid = TRUE;
                }
                else if (nRacial == RACIAL_TYPE_VERMIN && nVermin > 0)
                {
                    bValid = TRUE;
                }
                else if (nRacial == RACIAL_TYPE_ELEMENTAL && nElemental > 0)
                {
                    bValid = TRUE;
                }
                else if (nRacial == RACIAL_TYPE_CONSTRUCT && nConstructs > 0)
                {
                    SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_TURN_UNDEAD));
                    nDamage = d3(nTurnLevel);
                    eDamage = EffectDamage(nDamage, DAMAGE_TYPE_MAGICAL);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oTarget);
                    nHDCount += nHD;
                }
                else if (nRacial == RACIAL_TYPE_OUTSIDER && nOutsider > 0)
                {
                    bValid = TRUE;
                }

                //Apply results of the turn
                if( bValid == TRUE)
                {
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
                    //if(IntToFloat(nClassLevel)/2.0 >= IntToFloat(nHD))
                    //{

                    if((nClassLevel/2) >= nHD)
                    {
                        //Fire cast spell at event for the specified target
                        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_TURN_UNDEAD));
                        //Destroy the target
                        DelayCommand(0.1f, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget));
                    }
                    else
                    {
                        //Turn the target
                        //Fire cast spell at event for the specified target
                        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_TURN_UNDEAD));
                        AssignCommand(oTarget, ActionMoveAwayFromObject(OBJECT_SELF, TRUE));
                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nClassLevel + 5));
                    }
                    nHDCount = nHDCount + nHD;
                }
            }
            bValid = FALSE;
        }
        nCnt++;
        oTarget = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE , OBJECT_SELF, nCnt,CREATURE_TYPE_PERCEPTION , PERCEPTION_SEEN);
    }
}

void main()
{
    int nClericLevel = GetLevelByClass(CLASS_TYPE_CLERIC);
    int nPaladinLevel = GetLevelByClass(CLASS_TYPE_PALADIN);
    int nBlackguardlevel = GetLevelByClass(CLASS_TYPE_BLACKGUARD);
    int nTotalLevel =  GetHitDice(OBJECT_SELF);

    int nTurnLevel = nClericLevel;
    int nClassLevel = nClericLevel;


    if((nPaladinLevel - 2) > nClericLevel)
    {
        nClassLevel = nPaladinLevel -2;
        nTurnLevel = nPaladinLevel - 2;
    }
    // * April 2003
    // * Change from official rules for balance purposes
    // * Blackguard gets to turn at 'character level' - 2 not class level
    // * otherwise the ability is rather useless
    if ( (nBlackguardlevel > 0) && ( nTotalLevel - 2 > nClassLevel) )
    {
        nClassLevel = nTotalLevel - 2;
        nTurnLevel = nTotalLevel - 2;
    }

    //Flags for bonus turning types
    int nElemental = GetHasFeat(FEAT_AIR_DOMAIN_POWER) + GetHasFeat(FEAT_EARTH_DOMAIN_POWER) + GetHasFeat(FEAT_FIRE_DOMAIN_POWER) + GetHasFeat(FEAT_WATER_DOMAIN_POWER);
    int nVermin = GetHasFeat(FEAT_PLANT_DOMAIN_POWER) + GetHasFeat(FEAT_ANIMAL_COMPANION);
    int nConstructs = GetHasFeat(FEAT_DESTRUCTION_DOMAIN_POWER);
    int nOutsider = GetHasFeat(FEAT_GOOD_DOMAIN_POWER) + GetHasFeat(FEAT_EVIL_DOMAIN_POWER);

    //Flag for improved turning ability
    int nSun = GetHasFeat(FEAT_SUN_DOMAIN_POWER);

    //Make a turning check roll, modify if have the Sun Domain
    int nChrMod = GetAbilityModifier(ABILITY_CHARISMA);
    int nTurnCheck = d20() + nChrMod;              //The roll to apply to the max HD of undead that can be turned --> nTurnLevel
    int nTurnHD = d6(2) + nChrMod + nClassLevel;   //The number of HD of undead that can be turned.

    if(nSun == TRUE)
    {
        nTurnCheck += d4();
        nTurnHD += d6();
    }
    //Determine the maximum HD of the undead that can be turned.
    if(nTurnCheck <= 0)
    {
        nTurnLevel -= 4;
    }
    else if(nTurnCheck >= 1 && nTurnCheck <= 3)
    {
        nTurnLevel -= 3;
    }
    else if(nTurnCheck >= 4 && nTurnCheck <= 6)
    {
        nTurnLevel -= 2;
    }
    else if(nTurnCheck >= 7 && nTurnCheck <= 9)
    {
        nTurnLevel -= 1;
    }
    else if(nTurnCheck >= 10 && nTurnCheck <= 12)
    {
        //Stays the same
    }
    else if(nTurnCheck >= 13 && nTurnCheck <= 15)
    {
        nTurnLevel += 1;
    }
    else if(nTurnCheck >= 16 && nTurnCheck <= 18)
    {
        nTurnLevel += 2;
    }
    else if(nTurnCheck >= 19 && nTurnCheck <= 21)
    {
        nTurnLevel += 3;
    }
    else if(nTurnCheck >= 22)
    {
        nTurnLevel += 4;
    }

    int nAlign = GetAlignmentGoodEvil(OBJECT_SELF);
    if(nAlign == ALIGNMENT_EVIL) {
        RebukeUndead(nTurnLevel, nTurnHD, nVermin, nElemental, nConstructs, nOutsider, nClassLevel);
    }
    else {
        TurnUndead(nTurnLevel, nTurnHD, nVermin, nElemental, nConstructs, nOutsider, nClassLevel);
    }
}
