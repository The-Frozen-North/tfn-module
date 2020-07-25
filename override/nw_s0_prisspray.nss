//::///////////////////////////////////////////////
//:: Prismatic Spray
//:: [NW_S0_PrisSpray.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Sends out a prismatic cone that has a random
//:: effect for each target struck.
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Dec 19, 2000
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk, On: April 11, 2001
//:: Last Updated By: Aidan Scanlan On: April 11, 2001
//:: Last Updated By: Preston Watamaniuk, On: June 11, 2001
/*
Patch 1.71

- cone could in certain circumstances affect caster
- delay for VFX corrected (was always 0.5 for all targets)
- added saving throw subtype (paralyse) versus paralyse effect
- poison made extraordinary
*/

int ApplyPrismaticEffect(int nEffect, object oTarget);

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Range = 11.0;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nRandom;
    int nHD;
    int nVisual;
    effect eVisual;
    int bTwoEffects;
    //Set the delay to apply to effects based on the distance to the target
    float fDelay;
    //Get first target in the spell area
    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPELLCONE, spell.Range, spell.Loc);
    while (GetIsObjectValid(oTarget))
    {
        if (oTarget != spell.Caster && spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
            fDelay = 0.5 + GetDistanceBetween(spell.Caster, oTarget)/20;
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            //Make an SR check
            if (!MyResistSpell(spell.Caster, oTarget, fDelay))
            {
                //Blind the target if they are less than 9 HD
                nHD = GetHitDice(oTarget);
                if (nHD <= 8)
                {
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectBlindness(), oTarget, RoundsToSeconds(spell.Level)));
                }
                //Determine if 1 or 2 effects are going to be applied
                nRandom = d8();
                if(nRandom == 8)
                {
                    //Get the visual effect
                    nVisual = ApplyPrismaticEffect(Random(7) + 1, oTarget);
                    nVisual = ApplyPrismaticEffect(Random(7) + 1, oTarget);
                }
                else
                {
                    //Get the visual effect
                    nVisual = ApplyPrismaticEffect(nRandom, oTarget);
                }
                //Set the visual effect
                if(nVisual != 0)
                {
                    eVisual = EffectVisualEffect(nVisual);
                    //Apply the visual effect
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, oTarget));
                }
            }
        }
        //Get next target in the spell area
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPELLCONE, spell.Range, spell.Loc);
    }
}

///////////////////////////////////////////////////////////////////////////////
//  ApplyPrismaticEffect
///////////////////////////////////////////////////////////////////////////////
/*  Given a reference integer and a target, this function will apply the effect
    of corresponding prismatic cone to the target.  To have any effect the
    reference integer (nEffect) must be from 1 to 7.*/
///////////////////////////////////////////////////////////////////////////////
//  Created By: Aidan Scanlan On: April 11, 2001
///////////////////////////////////////////////////////////////////////////////

int ApplyPrismaticEffect(int nEffect, object oTarget)
{
    int nDamage;
    effect ePrism;
    effect eVis;
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink;
    int nVis;
    float fDelay = 0.5 + GetDistanceBetween(spell.Caster, oTarget)/20;
    //Based on the random number passed in, apply the appropriate effect and set the visual to
    //the correct constant
    switch(nEffect)
    {
        case 1://fire
            nDamage = 20;
            nVis = VFX_IMP_FLAME_S;
            nDamage = GetSavingThrowAdjustedDamage(nDamage, oTarget, spell.DC, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_FIRE, spell.Caster);
            ePrism = EffectDamage(nDamage, DAMAGE_TYPE_FIRE);
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, ePrism, oTarget));
        break;
        case 2: //Acid
            nDamage = 40;
            nVis = VFX_IMP_ACID_L;
            nDamage = GetSavingThrowAdjustedDamage(nDamage, oTarget, spell.DC, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_ACID, spell.Caster);
            ePrism = EffectDamage(nDamage, DAMAGE_TYPE_ACID);
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, ePrism, oTarget));
        break;
        case 3: //Electricity
            nDamage = 80;
            nVis = VFX_IMP_LIGHTNING_S;
            nDamage = GetSavingThrowAdjustedDamage(nDamage, oTarget, spell.DC, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_ELECTRICITY, spell.Caster);
            ePrism = EffectDamage(nDamage, DAMAGE_TYPE_ELECTRICAL);
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, ePrism, oTarget));
        break;
        case 4: //Poison
            {
                effect ePoison = EffectPoison(POISON_BEBILITH_VENOM);
                ePoison = ExtraordinaryEffect(ePoison);
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, ePoison, oTarget));
            }
        break;
        case 5: //Paralyze
            {
                effect eDur2 = EffectVisualEffect(VFX_DUR_PARALYZED);
                if (!MySavingThrow(SAVING_THROW_FORT, oTarget, spell.DC, /*SAVING_THROW_TYPE_PARALYSE*/20, spell.Caster))
                {
                    ePrism = EffectParalyze();
                    eLink = EffectLinkEffects(eDur, ePrism);
                    eLink = EffectLinkEffects(eLink, eDur2);
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(10)));
                }
            }
        break;
        case 6: //Confusion
            {
                effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
                ePrism = EffectConfused();
                eLink = EffectLinkEffects(eMind, ePrism);
                eLink = EffectLinkEffects(eLink, eDur);

                if (!MySavingThrow(SAVING_THROW_WILL, oTarget, spell.DC, SAVING_THROW_TYPE_MIND_SPELLS, spell.Caster, fDelay))
                {
                    nVis = VFX_IMP_CONFUSION_S;
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(10)));
                }
            }
        break;
        case 7: //Death
            {
                if (!MySavingThrow(SAVING_THROW_WILL, oTarget, spell.DC, SAVING_THROW_TYPE_DEATH, spell.Caster, fDelay))
                {
                    //nVis = VFX_IMP_DEATH;
                    ePrism = EffectDeath();
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, ePrism, oTarget));
                }
            }
        break;
    }
    return nVis;
}
