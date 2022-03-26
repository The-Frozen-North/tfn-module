//::///////////////////////////////////////////////
//:: Scintillating Sphere
//:: X2_S0_ScntSphere
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
// A scintillating sphere is a burst of electricity
// that detonates with a low roar and inflicts 1d6
// points of damage per caster level (maximum of 10d6)
// to all creatures within the area. Unattended objects
// also take damage. The explosion creates almost no pressure.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 25 , 2002
//:://////////////////////////////////////////////
//:: Last Updated By: Andrew Nobbs, 02/06/2003

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DamageCap = 10;
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_ELECTRICAL;
    spell.Range = RADIUS_SIZE_HUGE;
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nCasterLvl = spell.Level;
    int nDamage;
    float fDelay;
    effect eExplode = EffectVisualEffect(VFX_FNF_ELECTRIC_EXPLOSION);
    effect eVis = EffectVisualEffect(spell.DmgVfxS);
    effect eDam;

    //Limit Caster level for the purposes of damage
    if (nCasterLvl > spell.DamageCap)
    {
        nCasterLvl = spell.DamageCap;
    }
    //Apply the fireball explosion at the location captured above.
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, spell.Loc);
    //Declare the spell shape, size and the location.  Capture the first target object in the shape.
    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while (GetIsObjectValid(oTarget))
    {
        if(spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            //Get the distance between the explosion and the target to calculate delay
            fDelay = GetDistanceBetweenLocations(spell.Loc, GetLocation(oTarget))/20;
            if (!MyResistSpell(spell.Caster, oTarget, fDelay))
            {
                //Roll damage for each target
                nDamage = MaximizeOrEmpower(spell.Dice,nCasterLvl,spell.Meta);
                //Adjust the damage based on the Reflex Save, Evasion and Improved Evasion.
                nDamage = GetSavingThrowAdjustedDamage(nDamage, oTarget, spell.DC, spell.SavingThrow, spell.SaveType, spell.Caster);
                //Set the damage effect
                eDam = EffectDamage(nDamage, spell.DamageType);
                if(nDamage > 0)
                {
                    // Apply effects to the currently selected target.
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                    //This visual effect is applied to the target object not the location as above.  This visual effect
                    //represents the flame that erupts on the target not on the ground.
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                }
             }
        }
        //Select the next target within the spell shape.
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }
}
