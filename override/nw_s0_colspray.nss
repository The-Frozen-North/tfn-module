//::///////////////////////////////////////////////
//:: Color Spray
//:: NW_S0_ColSpray.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    A cone of sparkling lights flashes out in a cone
    from the casters hands affecting all those within
    the Area of Effect.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 25, 2001
//:://////////////////////////////////////////////
/*
Patch 1.72
- spell no longer works on sightless creatures
- range changed to 11.0 to unite with other cone type of spells
Patch 1.71
- zzZZZ vfx could appear on immune creatures
- fixed self targetting which could happen in specific circumstances
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Range = 11.0;
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    int nHD;
    int nDuration;
    float fDelay;
    object oTarget;
    effect eSleep = EffectSleep();
    effect eStun = EffectStunned();
    effect eBlind = EffectBlindness();
    effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

    effect eLink1 = EffectLinkEffects(eSleep, eMind);

    effect eLink2 = EffectLinkEffects(eStun, eMind);
    eLink2 = EffectLinkEffects(eLink2, eDur);

    effect eLink3 = EffectLinkEffects(eBlind, eMind);

    effect eVis1 = EffectVisualEffect(VFX_IMP_SLEEP);
    effect eVis2 = EffectVisualEffect(VFX_IMP_STUN);
    effect eVis3 = EffectVisualEffect(VFX_IMP_BLIND_DEAF_M);


    //Get first object in the spell cone
    oTarget = FIX_GetFirstObjectInShape(SHAPE_SPELLCONE, spell.Range, spell.Loc, TRUE);
    //Cycle through the target until the current object is invalid
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != spell.Caster && spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            fDelay = GetDistanceBetween(spell.Caster, oTarget)/30;
            if(!MyResistSpell(spell.Caster, oTarget, fDelay))
            {
                if(!spellsIsSightless(spell.Target) && !MySavingThrow(spell.SavingThrow, oTarget, spell.DC, SAVING_THROW_TYPE_MIND_SPELLS, spell.Caster, fDelay))
                {
                    nDuration = MaximizeOrEmpower(4,1,spell.Meta,3);
                    //Enter Metamagic conditions
                    if (spell.Meta & METAMAGIC_EXTEND)
                    {
                        nDuration = nDuration *2;  //Duration is +100%
                    }

                    nHD = GetHitDice(oTarget);
                    if(nHD <= 2)
                    {
                         if(!GetIsImmune(oTarget, IMMUNITY_TYPE_SLEEP, spell.Caster) && !GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, spell.Caster))
                         {
                             //workaround to not apply zZZZ effect on immune creatures
                             DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis1, oTarget));
                         }
                         //Apply the VFX impact and effects
                         DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink1, oTarget, RoundsToSeconds(nDuration)));
                    }
                    else if(nHD > 2 && nHD < 5)
                    {
                         nDuration = nDuration - 1;
                         //Apply the VFX impact and effects
                         DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis3, oTarget));
                         DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink3, oTarget, RoundsToSeconds(nDuration)));
                    }
                    else
                    {
                         nDuration = nDuration - 2;
                         //Apply the VFX impact and effects
                         DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oTarget));
                         DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink2, oTarget, RoundsToSeconds(nDuration)));
                    }
                }
            }
        }
        //Get next target in spell area
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPELLCONE, spell.Range, spell.Loc, TRUE);
    }
}
