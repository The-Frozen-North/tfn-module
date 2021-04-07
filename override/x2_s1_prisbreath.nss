//::///////////////////////////////////////////////
//:: Prismatic Dragon Prismatic Breath
//:: X2_S1_PrisSpray
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
//:: Sends out a prismatic cone that has a random
//:: effect for each target struck.
//:: Save is 10+1/2HD+con modfifier
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: Aug 09, 2003
//:://////////////////////////////////////////////
/*
Patch 1.71

- duration of blindness unified with other breaths (was several times higher than other breaths)
- delay for VFX corrected (was always 0.5 for all targets)
- added saving throw subtype (paralyse) versus paralyse effect
- poison made extraordinary
> breath weapon damage and DC calculation changed in order to allow higher values
for custom content dragons with 40+ HD. DC calculation is now 10+1/2 dragon's HD+
dragon's constitution modifier.
*/

int ApplyPrismaticEffect(int nEffect, object oTarget);

#include "70_inc_spells"
#include "70_inc_dragons"
#include "x0_i0_spells"

void main()
{
    //Declare major variables
    int nDuration = GetDragonBreathNumDice()/2;
    int nRandom;
    int nHD;
    int nVisual;
    effect eVisual;
    int bTwoEffects;
    float fDelay;

    //Get first target in the spell area
    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPELLCONE, 20.0, GetSpellTargetLocation());
    while (GetIsObjectValid(oTarget))
    {
        if (oTarget != OBJECT_SELF && spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId()));
            //Set the delay to apply to effects based on the distance to the target
            fDelay = 0.5 + GetDistanceBetween(OBJECT_SELF, oTarget)/20;
            //Blind the target if they are less than 9 HD
            nHD = GetHitDice(oTarget);
            if (nHD <= 8)
            {
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectBlindness(), oTarget, RoundsToSeconds(nDuration)));
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
        //Get next target in the spell area
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPELLCONE, 20.0, GetSpellTargetLocation());
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
    int nDC = GetDragonBreathDC();
    int nDamage;
    effect ePrism;
    effect eVis;
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink;
    int nVis;
    float fDelay = 0.5 + GetDistanceBetween(OBJECT_SELF, oTarget)/20;
    //Based on the random number passed in, apply the appropriate effect and set the visual to
    //the correct constant
    switch(nEffect)
    {
        case 1://fire
            nDamage = 20;
            nVis = VFX_IMP_FLAME_S;
            nDamage = GetSavingThrowAdjustedDamage(nDamage, oTarget, nDC, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_FIRE);
            ePrism = EffectDamage(nDamage, DAMAGE_TYPE_FIRE);
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, ePrism, oTarget));
        break;
        case 2: //Acid
            nDamage = 40;
            nVis = VFX_IMP_ACID_L;
            nDamage = GetSavingThrowAdjustedDamage(nDamage, oTarget, nDC, SAVING_THROW_TYPE_ACID);
            ePrism = EffectDamage(nDamage, DAMAGE_TYPE_ACID);
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, ePrism, oTarget));
        break;
        case 3: //Electricity
            nDamage = 80;
            nVis = VFX_IMP_LIGHTNING_S;
            nDamage = GetSavingThrowAdjustedDamage(nDamage, oTarget, nDC, SAVING_THROW_TYPE_ELECTRICITY);
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
                if (MySavingThrow(SAVING_THROW_FORT, oTarget, nDC, /*SAVING_THROW_TYPE_PARALYSE*/20, OBJECT_SELF, fDelay) == 0)
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

                if (!MySavingThrow(SAVING_THROW_WILL, oTarget, nDC, SAVING_THROW_TYPE_MIND_SPELLS, OBJECT_SELF, fDelay))
                {
                    nVis = VFX_IMP_CONFUSION_S;
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(10)));
                }
            }
        break;
        case 7: //Death
            {
                if (!MySavingThrow(SAVING_THROW_WILL, oTarget, nDC, SAVING_THROW_TYPE_DEATH, OBJECT_SELF, fDelay))
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
