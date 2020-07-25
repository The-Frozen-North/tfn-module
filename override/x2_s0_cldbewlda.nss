//::///////////////////////////////////////////////
//:: Cloud of Bewilderment
//:: X2_S0_CldBewldA
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    A cone of noxious air goes forth from the caster.
    Enemies in the area of effect are stunned and blinded
    1d6 rounds. Foritude save negates effect.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: November 04, 2002
//:://////////////////////////////////////////////
/*
Patch 1.70

- alignment immune creatures were ommited
- added delay into SR and saving throw's VFX
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.SavingThrow = SAVING_THROW_FORT;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    //Declare major variables
    aoesDeclareMajorVariables();
    int nRounds;
    effect eStun = EffectStunned();
    effect eBlind = EffectBlindness();
    eStun = EffectLinkEffects(eBlind,eStun);
    effect eVis = EffectVisualEffect(VFX_DUR_BLIND);
    float fDelay;
    //Get the first object in the persistant area
    object oTarget = GetEnteringObject();
    if(spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
    {
        fDelay = GetRandomDelay(0.75, 1.75); //delay in aoe entrance? weeell...
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
        //Make a SR check
        if(!MyResistSpell(aoe.Creator, oTarget))
        {
            //Make a Fort Save
            if(!MySavingThrow(spell.SavingThrow, oTarget, spell.DC, SAVING_THROW_TYPE_POISON, aoe.Creator))
            {
                if(!GetIsImmune(oTarget, IMMUNITY_TYPE_POISON, aoe.Creator))
                {
                    nRounds = MaximizeOrEmpower(6,1,spell.Meta);
                    //Apply the VFX impact and linked effects
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eStun, oTarget, RoundsToSeconds(nRounds)));
                }
            }
        }
    }
}
