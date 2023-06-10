//::///////////////////////////////////////////////
//:: Healing Circle
//:: NW_S0_HealCirc
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
// Positive energy spreads out in all directions
// from the point of origin, curing 1d8 points of
// damage plus 1 point per caster level (maximum +20)
// to nearby living allies.
//
// Like cure spells, healing circle damages undead in
// its area rather than curing them.
*/
//:://////////////////////////////////////////////
//:: Created By: Noel Borstad
//:: Created On: Oct 18,2000
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 20, 2001
//:: Update Pass By: Preston W, On: Aug 1, 2001
/*
Patch 1.71

- added missing saving throw subtype as per spell's descriptor
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 8;
    spell.DamageType = DAMAGE_TYPE_POSITIVE;
    spell.Range = RADIUS_SIZE_LARGE;
    spell.SavingThrow = SAVING_THROW_FORT;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    object oTarget;
    int nCasterLvl = spell.Level;
    int nDamagen, nModify, nHP;
    effect eKill;
    effect eHeal;
    effect eVis = EffectVisualEffect(spell.DmgVfxL);
    effect eVis2 = EffectVisualEffect(VFX_IMP_HEALING_M);
    effect eImpact = EffectVisualEffect(VFX_FNF_LOS_HOLY_20);
    float fDelay;
    //Limit caster level
    if (nCasterLvl > 20)
    {
        nCasterLvl = 20;
    }
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spell.Loc);
    //Get first target in shape
    oTarget = GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    while (GetIsObjectValid(oTarget))
    {
        fDelay = GetRandomDelay();
        //Check if racial type is undead
        if (spellsIsRacialType(oTarget, RACIAL_TYPE_UNDEAD))
        {
            if(spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
                //Make SR check
                if (!MyResistSpell(spell.Caster, oTarget, fDelay))
                {
                    nModify = MaximizeOrEmpower(spell.Dice,1,spell.Meta,nCasterLvl);

                    //Make Fort save
                    if (MySavingThrow(spell.SavingThrow, oTarget, spell.DC, spell.SaveType, spell.Caster, fDelay))
                    {
                        nModify /= 2;
                    }

                    //Set damage effect
                    eKill = EffectDamage(nModify, spell.DamageType);
                    //Apply damage effect and VFX impact
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eKill, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                }
            }
        }
        else
        {
            // * May 2003: Heal Neutrals as well
            if(spellsIsTarget(oTarget, SPELL_TARGET_ALLALLIES, spell.Caster))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
                nHP = MaximizeOrEmpower(spell.Dice,1,spell.Meta,nCasterLvl);

                //Set healing effect
                eHeal = EffectHeal(nHP);
                //Apply heal effect and VFX impact
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oTarget));
            }
        }
        //Get next target in the shape
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    }
}
