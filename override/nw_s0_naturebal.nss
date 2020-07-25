//::///////////////////////////////////////////////
//:: Natures Balance
//:: NW_S0_NatureBal.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Reduces the SR of all enemies by 1d4 per 5 caster
    levels for 1 round per 3 caster levels. Also heals
    all friends for 3d8 + Caster Level
    Radius is 15 feet from the caster.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: June 22, 2001
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 22, 2001
/*
Patch 1.70

- added delay into SR VFX
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.Range = RADIUS_SIZE_LARGE;
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eHeal;
    effect eVis = EffectVisualEffect(VFX_IMP_HEALING_L);
    effect eSR;
    effect eVis2 = EffectVisualEffect(VFX_IMP_BREACH);
    effect eNature = EffectVisualEffect(VFX_FNF_NATURES_BALANCE);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

    int nRand, nNumDice;
    //Determine spell duration as an integer for later conversion to Rounds, Turns or Hours.
    int nDuration = spell.Level/3;
    if(nDuration < 1)
    {//safety check in case unwary builder set NPC's caster level for this spell under 4
    nDuration = 1;
    }
    float fDelay;
    //Set off fire and forget visual
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eNature, spell.Loc);
    //Declare the spell shape, size and the location.  Capture the first target object in the shape.
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2;   //Duration is +100%
    }

    nNumDice = spell.Level / 5;
    if(nNumDice < 1)
    {
        nNumDice = 1;
    }

    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while(GetIsObjectValid(oTarget))
    {
        fDelay = GetRandomDelay();
        //Check to see how the caster feels about the targeted object
        if(spellsIsTarget(oTarget, SPELL_TARGET_ALLALLIES, spell.Caster))
        {
              //Fire cast spell at event for the specified target
              SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
              nRand = MaximizeOrEmpower(8,3,spell.Meta,spell.Level);

              eHeal = EffectHeal(nRand);
              //Apply heal effects
              DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oTarget));
              DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
        }
        else if (spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            //Check for saving throw
            if (!MySavingThrow(spell.SavingThrow, oTarget, spell.DC, SAVING_THROW_TYPE_NONE, spell.Caster, fDelay))
            {
                nRand = MaximizeOrEmpower(4,nNumDice,spell.Meta);
                eSR = EffectSpellResistanceDecrease(nRand);
                effect eLink = EffectLinkEffects(eSR, eDur);
                //Apply reduce SR effects
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, DurationToSeconds(nDuration)));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oTarget));
            }
        }
        //Select the next target within the spell shape.
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    }
}
