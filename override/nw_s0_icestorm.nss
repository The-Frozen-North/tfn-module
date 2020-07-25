//::///////////////////////////////////////////////
//:: Ice Storm
//:: NW_S0_IceStorm
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Everyone in the area takes 3d6 Bludgeoning
    and 2d6 Cold damage.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Sept 12, 2001
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_COLD;
    spell.Range = RADIUS_SIZE_HUGE;
    spell.SavingThrow = SAVING_THROW_NONE;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDamage, nDamage2, nDamage3;
    int nVariable = spell.Level/3;
    float fDelay;
    effect eExplode = EffectVisualEffect(VFX_FNF_ICESTORM); //USE THE ICESTORM FNF
    effect eVis = EffectVisualEffect(spell.DmgVfxS);
    effect eDam,eDam2, eDam3;
    //Apply the ice storm VFX at the location captured above.
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, spell.Loc);
    //Declare the spell shape, size and the location.  Capture the first target object in the shape.
    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while (GetIsObjectValid(oTarget))
    {
        if (spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
            fDelay = GetRandomDelay(0.75, 2.25);
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            if (!MyResistSpell(spell.Caster, oTarget, fDelay))
            {
                //Roll damage for each target
                nDamage = MaximizeOrEmpower(spell.Dice,3,spell.Meta);
                nDamage2 = MaximizeOrEmpower(spell.Dice,2,spell.Meta);
                nDamage3 = MaximizeOrEmpower(spell.Dice,nVariable,spell.Meta);

                nDamage2 = nDamage2 + nDamage3;
                //1.72: this will do nothing by default, but allows to dynamically enforce saving throw
                nDamage2 = GetSavingThrowAdjustedDamage(nDamage2, oTarget, spell.DC, spell.SavingThrow, spell.SaveType, spell.Caster);
                //Set the damage effect
                eDam = EffectDamage(nDamage, DAMAGE_TYPE_BLUDGEONING);
                eDam2 = EffectDamage(nDamage2, spell.DamageType);
                // Apply effects to the currently selected target.
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam2, oTarget));
                //This visual effect is applied to the target object not the location as above.  This visual effect
                //represents the impact that erupts on the target not on the ground.
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
             }
        }
        //Select the next target within the spell shape.
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }
}
