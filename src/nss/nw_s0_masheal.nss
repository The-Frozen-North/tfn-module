//::///////////////////////////////////////////////
//:: Mass Heal
//:: [NW_S0_MasHeal.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Heals all friendly targets within 10ft to full
//:: unless they are undead.
//:: If undead they reduced to 1d4 HP.
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: April 11, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- dying targets wasn't healed to their maximum hitpoints
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DamageType = DAMAGE_TYPE_POSITIVE;
    spell.Range = RADIUS_SIZE_MEDIUM;
    spell.SavingThrow = SAVING_THROW_NONE;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eKill;
    effect eVis = EffectVisualEffect(spell.DmgVfxL);
    effect eHeal;
    effect eVis2 = EffectVisualEffect(VFX_IMP_HEALING_G);
    effect eStrike = EffectVisualEffect(VFX_FNF_LOS_HOLY_10);
    int nTouch, nModify, nDamage, nHeal;
    float fDelay;

    //Apply VFX area impact
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eStrike, spell.Loc);
    //Get first target in spell area
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    while(GetIsObjectValid(oTarget))
    {
        fDelay = GetRandomDelay();
        //Check to see if the target is an undead
        if (spellsIsRacialType(oTarget, RACIAL_TYPE_UNDEAD))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            //Make a touch attack
            nTouch = TouchAttackRanged(oTarget);
            if (nTouch > 0)
            {
                if(spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
                {
                    //Make an SR check
                    if (!MyResistSpell(spell.Caster, oTarget, fDelay))
                    {
                        //Roll damage
                        nModify = d4();
                        //make metamagic check
                        if (spell.Meta & METAMAGIC_MAXIMIZE)
                        {
                            nModify = 1;
                        }
                        //Detemine the damage to inflict to the undead
                        nDamage =  GetCurrentHitPoints(oTarget) - nModify;
                        //1.72: this will do nothing by default, but allows to dynamically enforce saving throw
                        if(MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, spell.SaveType, spell.Caster))
                        {
                            nDamage/= 2;
                        }
                        //Set the damage effect
                        eKill = EffectDamage(nDamage, spell.DamageType);
                        //Apply the VFX impact and damage effect
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eKill, oTarget));
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                    }
                }
            }
        }
        else//not an undead
        {
            //Make a faction check
            if(spellsIsTarget(oTarget, SPELL_TARGET_ALLALLIES, spell.Caster))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
                //Determine amount to heal
                nHeal = GetMaxHitPoints(oTarget) - GetCurrentHitPoints(oTarget);
                //Set the damage effect
                eHeal = EffectHeal(nHeal);
                //Apply the VFX impact and heal effect
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oTarget));
            }
        }
        //Get next target in the spell area
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    }
}
