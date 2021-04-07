//::///////////////////////////////////////////////
//:: [Mass Charm]
//:: [NW_S0_MsCharm.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The caster attempts to charm a group of individuals
    who's HD can be no more than his level combined.
    The spell starts checking the area and those that
    fail a will save are charmed.  The affected persons
    are Charmed for 1 round per 2 caster levels.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 29, 2001
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk, On: April 10, 2001
//:: VFX Pass By: Preston W, On: June 22, 2001
/*
Patch 1.71

- was doing charm effect even for players (replaced for daze in this case)
- HD pool check corrected (if found target with HD matching HD pool)
- HD pool decreased also in case of spell being resisted
- added scaling by difficulty into duration
- added delay into SR and saving throw's VFX
- extended duration corrected to calculate twice of normal duration as usual
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
    effect eCharm = EffectCharmed();
    effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);
    effect eImpact = EffectVisualEffect(VFX_FNF_LOS_NORMAL_20);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

    effect eLink = EffectLinkEffects(eMind, eDur);

    effect eVis = EffectVisualEffect(VFX_IMP_CHARM);
    int nDuration = spell.Level/2;
    float fDelay;
    int nAmount = spell.Level * 2;
    //Check for metamagic extend
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration * 2;
    }

    effect scaledEffect;
    int scaledDuration;

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spell.Loc);

    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    while (GetIsObjectValid(oTarget) && nAmount > 0)
    {
        if (spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
            fDelay = GetRandomDelay();
            //Check that the target is humanoid
            if(AmIAHumanoid(oTarget) && nAmount >= GetHitDice(oTarget))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
                //Make an SR check
                if (!MyResistSpell(spell.Caster, oTarget, fDelay))
                {
                    //Make a Will save to negate
                    if (!MySavingThrow(spell.SavingThrow, oTarget, spell.DC, SAVING_THROW_TYPE_MIND_SPELLS, spell.Caster, fDelay))
                    {
                        scaledEffect = GetScaledEffect(eCharm, oTarget);
                        scaledEffect = EffectLinkEffects(eLink, scaledEffect);
                        scaledDuration = GetScaledDuration(nDuration, oTarget);

                        //Apply the linked effects and the VFX impact
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, scaledEffect, oTarget, DurationToSeconds(scaledDuration)));
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                    }
                    //Add the creatures HD to the count of affected creatures
                    //nCnt = nCnt + GetHitDice(oTarget);
                }
                nAmount = nAmount - GetHitDice(oTarget);
            }
        }
        //Get next target in spell area
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    }
}
