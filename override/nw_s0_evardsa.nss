//::///////////////////////////////////////////////
//:: Evards Black Tentacles: On Enter
//:: NW_S0_EvardsA
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Upon entering the mass of rubbery tentacles the
    target is struck by 1d4 +1/lvl tentacles.  Each
    makes a grapple check. If it succeeds then
    it does 1d6+4damage and the target must make
    a Fortitude Save versus paralysis or be paralyzed
    for 1 round.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 23, 2001
//:://////////////////////////////////////////////
//:: GZ: Removed SR, its not there by the book
/*
Patch 1.70

- saving throw subtype changed to paralyse
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_BLUDGEONING;
    spell.SavingThrow = SAVING_THROW_FORT;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    //Declare major variables
    aoesDeclareMajorVariables();
    object oTarget = GetEnteringObject();
    effect eParal = EffectParalyze();
    effect eDur = EffectVisualEffect(VFX_DUR_PARALYZED);
    effect eLink = EffectLinkEffects(eDur, eParal);
    effect eDam;

    int nDamage = 0;
    int nHits;
    float fDelay;
    int nNumberTargets = 0;
    int nMinimumTargets = 2;
    int nDieDam;
    int nTargetSize;
    int nTentacleGrappleCheck;
    int nOpposedGrappleCheck;
    int nOppossedGrappleCheckModifiers;
    int nTentaclesPerTarget;
    int nCasterLevel = spell.Level;

    if(GetCreatureSize(oTarget) < CREATURE_SIZE_MEDIUM)
    {
        // Some visual feedback that the spell doesn't affect creatures of this type.
        effect eFail = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
        fDelay = GetRandomDelay(0.75, 1.5);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eFail, oTarget,fDelay);
        return;
    }

    if(nCasterLevel > 20)
    {
        nCasterLevel = 20;
    }
    //calculate the tentacles number with proper metamagic handling
    nTentaclesPerTarget = MaximizeOrEmpower(4,1,spell.Meta,nCasterLevel);

    oTarget = GetFirstInPersistentObject(aoe.AOE);
    while(GetIsObjectValid(oTarget))
    {
        if(GetCreatureSize(oTarget) >= CREATURE_SIZE_MEDIUM)
        {
            if(spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
            {
                nNumberTargets++;
            }
        }
        oTarget = GetNextInPersistentObject(aoe.AOE);
    }

    oTarget = GetEnteringObject();
    if (nNumberTargets >= 0)
    {
        if(spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));

            // Distribute the tentacle between all valid targets.
            if(nNumberTargets < nMinimumTargets)
            {
               // If there is only one target in the area, then only a portion of the tentacles should be able to reach them.
                nTentaclesPerTarget = nTentaclesPerTarget/nMinimumTargets;
            }
            else
            {
                nTentaclesPerTarget = nTentaclesPerTarget/nNumberTargets;
            }

            nOppossedGrappleCheckModifiers = GetBaseAttackBonus(oTarget) + GetAbilityModifier(ABILITY_STRENGTH,oTarget);
            nTargetSize = GetCreatureSize(oTarget);
            if(nTargetSize == CREATURE_SIZE_LARGE)
            {
                nOppossedGrappleCheckModifiers = nOppossedGrappleCheckModifiers + 4;
            }
            else if(nTargetSize == CREATURE_SIZE_HUGE)
            {
                nOppossedGrappleCheckModifiers = nOppossedGrappleCheckModifiers + 8;
            }

            for(nHits = nTentaclesPerTarget; nHits > 0; nHits--)
            {
                // Grapple Check.
                nTentacleGrappleCheck = d20() + nCasterLevel + 8; // Str(4) + Large Tentacle(4)
                nOpposedGrappleCheck = d20() + nOppossedGrappleCheckModifiers;

                if(nTentacleGrappleCheck >= nOpposedGrappleCheck)
                {
                    //calculate the damage value with proper metamagic handling
                    nDieDam = MaximizeOrEmpower(spell.Dice,1,spell.Meta,4);

                    nDamage = nDamage + nDieDam;

                    fDelay = GetRandomDelay(1.0, 2.2);
                    eDam = EffectDamage(nDieDam, spell.DamageType, DAMAGE_POWER_PLUS_TWO);
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                }
            }

            if(nDamage > 0)
            {
                if(!MySavingThrow(spell.SavingThrow, oTarget, spell.DC, /*SAVING_THROW_TYPE_PARALYSE*/20, aoe.Creator, fDelay))
                {
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(1)));
                }
            }
        }
    }
}
