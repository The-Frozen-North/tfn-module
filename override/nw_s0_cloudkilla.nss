//::///////////////////////////////////////////////
//:: Cloudkill: On Enter
//:: NW_S0_CloudKillA.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    All creatures with 3 or less HD die, those with
    4 to 6 HD must make a save Fortitude Save or die.
    Those with more than 6 HD take 1d10 Poison damage
    every round.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 17, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- alignment/race immune creatures were ommited
- had double death VFX
- speed decrease was dispellable
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 10;
    spell.DamageType = DAMAGE_TYPE_ACID;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    //Declare major variables
    aoesDeclareMajorVariables();
    object oTarget = GetEnteringObject();
    int nHD = GetHitDice(oTarget);
    effect eDeath = EffectDeath();
    effect eVis = EffectVisualEffect(VFX_IMP_DEATH);
    effect eNeg = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
    effect eSpeed = EffectMovementSpeedDecrease(50);
    effect eVis2 = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink = EffectLinkEffects(eSpeed, eVis2);
    eLink = ExtraordinaryEffect(eLink);

    float fDelay = GetRandomDelay(0.5, 1.5);
    int nDam = MaximizeOrEmpower(spell.Dice,1,spell.Meta);
    effect eDam = EffectDamage(nDam, spell.DamageType);

    if(spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
        //Make SR Check
        if(!MyResistSpell(aoe.Creator, oTarget, fDelay))
        {
            //Determine spell effect based on the targets HD
            if (nHD <= 3)
            {
                if(!GetIsImmune(oTarget, IMMUNITY_TYPE_DEATH, aoe.Creator))
                {
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget));
                }
            }
            else if (nHD >= 4 && nHD <= 6)
            {
                //Make a save or die
                if(!MySavingThrow(spell.SavingThrow, oTarget, spell.DC, SAVING_THROW_TYPE_DEATH, aoe.Creator, fDelay))
                {
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget));
                }
                else
                {
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eNeg, oTarget));
                    if(!MySavingThrow(spell.SavingThrow, oTarget, spell.DC, SAVING_THROW_TYPE_NONE, aoe.Creator, fDelay))
                    {
                        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eSpeed, oTarget);
                    }
                }
            }
            else
            {
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eNeg, oTarget));
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, eSpeed, oTarget);
            }
        }
    }
}
