//::///////////////////////////////////////////////
//:: Slow
//:: NW_S0_Slow.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Character can take only one partial action
    per round.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 29, 2001
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 25, 2001
/*
Patch 1.71

- target pool was decreased only in case of failed SR check and saving throw
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.Range = RADIUS_SIZE_COLOSSAL;
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_SELECTIVEHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eSlow = EffectSlow();
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink = EffectLinkEffects(eSlow, eDur);

    effect eVis = EffectVisualEffect(VFX_IMP_SLOW);
    effect eImpact = EffectVisualEffect(VFX_FNF_LOS_NORMAL_30);
    //Determine spell duration as an integer for later conversion to Rounds, Turns or Hours.
    int nDuration = spell.Level;
    int nCount = 0;

    //Metamagic check for extend
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2;   //Duration is +100%
    }
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spell.Loc);
    //Declare the spell shape, size and the location.  Capture the first target object in the shape.
    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    //Cycle through the targets within the spell shape until an invalid object is captured or the number of
    //targets affected is equal to the caster level.
    while(GetIsObjectValid(oTarget) && nCount < spell.Level)
    {
        if (spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            if (!MyResistSpell(spell.Caster, oTarget) && !/*Will Save*/ MySavingThrow(spell.SavingThrow, oTarget, spell.DC, SAVING_THROW_TYPE_NONE,spell.Caster))
            {
                //Apply the slow effect and VFX impact
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, DurationToSeconds(nDuration));
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
            }
            //Count the number of creatures affected
            nCount++;
        }
        //Select the next target within the spell shape.
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    }
}
