//::///////////////////////////////////////////////
//:: Tide of Battle
//:: x2_s0_TideBattle
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Uses spell effect to cause d100 damage to
    all enemies and friends around pc, including pc.
    (Area effect always centered on PC)
    Minimum 30 points of damage will be done to each target
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: Jan 2/03
//:://////////////////////////////////////////////
//:: Updated by: Andrew Nobbs
//:: Updated on: March 28, 2003

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DamageType = DAMAGE_TYPE_DIVINE;
    spell.Range = RADIUS_SIZE_COLOSSAL;
    spell.Limit = 100;//damage is random 1-100, but minimally 30
    spell.SavingThrow = SAVING_THROW_NONE;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis = EffectVisualEffect(VFX_IMP_DEATH_WARD);
    effect eVis2 = EffectVisualEffect(VFX_FNF_METEOR_SWARM);
    effect eDamage;
    effect eLink;
    int nDamage;

    //Apply Spell Effects
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis2, spell.Loc);

    //ApplyDamage and Effects to all targets in area
    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    float fDelay;
    while(GetIsObjectValid(oTarget))
    {
        if (spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
            fDelay = GetRandomDelay();
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            nDamage = Random(spell.Limit)+1;
            if (nDamage < 30)
            {
                nDamage = 30;
            }
            //1.72: this will do nothing by default, but allows to dynamically enforce saving throw
            if(MySavingThrow(spell.SavingThrow, oTarget, spell.DC, spell.SaveType, spell.Caster))
            {
                nDamage/= 2;
            }
            //Set damage type and amount
            eDamage = EffectDamage(nDamage, spell.DamageType);
            //Link visual and damage effects
            eLink = EffectLinkEffects(eVis, eDamage);
            //Apply effects to oTarget
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, oTarget));
        }
        //Get next target in shape
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    }
}
