//::///////////////////////////////////////////////
//:: Prayer
//:: NW_S0_Prayer.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Allies gain +1 Attack, damage, saves, skill checks
    Enemies gain -1 to these stats
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 25, 2001
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 22, 2001

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "inc_spells"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.Range = RADIUS_SIZE_COLOSSAL;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect ePosVis = EffectVisualEffect(VFX_IMP_HOLY_AID);
    effect eNegVis = EffectVisualEffect(VFX_IMP_DOOM);
    effect eImpact = EffectVisualEffect(VFX_FNF_LOS_HOLY_30);

    int nBonus = 1;
    effect eBonAttack = EffectAttackIncrease(nBonus);
    effect eBonSave = EffectSavingThrowIncrease(SAVING_THROW_ALL, nBonus);
    effect eBonDam = EffectDamageIncrease(nBonus, DAMAGE_TYPE_BLUDGEONING|DAMAGE_TYPE_SLASHING|DAMAGE_TYPE_PIERCING);
    effect eBonSkill = EffectSkillIncrease(SKILL_ALL_SKILLS, nBonus);
    effect ePosDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);


    effect ePosLink = EffectLinkEffects(eBonAttack, eBonSave);
    ePosLink = EffectLinkEffects(ePosLink, eBonDam);
    ePosLink = EffectLinkEffects(ePosLink, eBonSkill);
    ePosLink = EffectLinkEffects(ePosLink, ePosDur);

    effect eNegAttack = EffectAttackDecrease(nBonus);
    effect eNegSave = EffectSavingThrowDecrease(SAVING_THROW_ALL, nBonus);
    effect eNegDam = EffectDamageDecrease(nBonus, DAMAGE_TYPE_BLUDGEONING|DAMAGE_TYPE_SLASHING|DAMAGE_TYPE_PIERCING);
    effect eNegSkill = EffectSkillDecrease(SKILL_ALL_SKILLS, nBonus);
    effect eNegDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);


    effect eNegLink = EffectLinkEffects(eNegAttack, eNegSave);
    eNegLink = EffectLinkEffects(eNegLink, eNegDam);
    eNegLink = EffectLinkEffects(eNegLink, eNegSkill);
    eNegLink = EffectLinkEffects(eNegLink, eNegDur);

    int nDuration = spell.Level;
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
        if(spellsIsTarget(oTarget, SPELL_TARGET_ALLALLIES, spell.Caster))
        {
            //Fire spell cast at event for target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
            //Apply VFX impact and bonus effects
            DisplaceSpell(oTarget, SPELL_BATTLETIDE, "Battletide");
            ApplyEffectToObject(DURATION_TYPE_INSTANT, ePosVis, oTarget);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ePosLink, oTarget, DurationToSeconds(nDuration));
        }
        else if (spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
            //Fire spell cast at event for target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            if(!MyResistSpell(spell.Caster, oTarget))
            {
                //Apply VFX impact and bonus effects
                RemoveClericAttackDamageBonusSpellEffects(spell.Caster);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eNegVis, oTarget);
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eNegLink, oTarget, DurationToSeconds(nDuration));
            }
        }
        //Get the next target in the specified area around the caster
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    }
}
