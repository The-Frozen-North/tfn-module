//::///////////////////////////////////////////////
//:: Bane
//:: X0_S0_Bane.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    All enemies within 30ft of the caster gain a
    -1 attack penalty and a -1 save penalty vs fear
    effects
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 24, 2001
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 20, 2001
/*
Patch 1.70

- spell didn't removed invisibility/GS effect
- missing delay for SR and saving throw VFX added
- immunity feedback corrected
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_TURNS;
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
    effect eVis = EffectVisualEffect(VFX_IMP_HEAD_EVIL);
    effect eImpact = EffectVisualEffect(VFX_FNF_LOS_EVIL_30);
    effect eAttack = EffectAttackDecrease(1);
    effect eSave = EffectSavingThrowDecrease(SAVING_THROW_ALL, 1, SAVING_THROW_TYPE_FEAR);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eAttack, eSave);
    eLink = EffectLinkEffects(eLink, eDur);
    int nDuration = spell.Level;
    float fDelay;
    //Metamagic duration check
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2;   //Duration is +100%
    }
    //Apply Impact
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spell.Loc);

    //Get the first target in the radius around the caster
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    while(GetIsObjectValid(oTarget))
    {
        if (spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
             //Fire spell cast at event for target
             SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));//this spell is harmful
             fDelay = GetRandomDelay(0.4, 1.1);//random delay so each target gets affected in different moment
             if (!MyResistSpell(spell.Caster, oTarget, fDelay))
             {
                /*Will Save*/
                if(!MySavingThrow(spell.SavingThrow, oTarget, spell.DC, SAVING_THROW_TYPE_MIND_SPELLS, spell.Caster, fDelay))
                {
                    if(!GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, spell.Caster))
                    {
                        //Apply VFX impact and bonus effects
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, DurationToSeconds(nDuration)));
                    }
                    else
                    {
                        //* Engine workaround for mind affecting spell without mind effect
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectDazed(), oTarget, 1.0));
                    }
                }
            }
        }
        //Get the next target in the specified area around the caster
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    }
}
