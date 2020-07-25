//::///////////////////////////////////////////////
//:: Earthquake
//:: X0_S0_Earthquake
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
// Ground shakes. 1d6 damage, max 10d6
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: July 22 2002
//:://////////////////////////////////////////////
//:: Last Updated By: Andrew Nobbs May 01, 2003

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 6;
    spell.DamageCap = 10;
    spell.DamageType = DAMAGE_TYPE_BLUDGEONING;
    spell.Range = RADIUS_SIZE_COLOSSAL;
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.SR = NO;
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
    effect eExplode = EffectVisualEffect(VFX_FNF_LOS_NORMAL_30);
    effect eVis = EffectVisualEffect(VFX_IMP_HEAD_NATURE);
    effect eDam;
    effect eShake = EffectVisualEffect(356);
    //Limit Caster level for the purposes of damage
    if (nCasterLvl > spell.DamageCap)
    {
        nCasterLvl = spell.DamageCap;
    }
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eShake, spell.Caster, RoundsToSeconds(6));

    //Apply epicenter explosion on caster
    //ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, GetLocation(OBJECT_SELF));


    //Declare the spell shape, size and the location.  Capture the first target object in the shape.
    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while (GetIsObjectValid(oTarget))
    {
        if (oTarget != spell.Caster && spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            //Get the distance between the explosion and the target to calculate delay
            fDelay = GetDistanceBetweenLocations(spell.Loc, GetLocation(oTarget))/20;
            //1.72: this will do nothing by default, but allows to dynamically enforce spell resistance
            if (spell.SR != YES || !MyResistSpell(spell.Caster, oTarget, fDelay))
            {
                nDamage = MaximizeOrEmpower(spell.Dice, nCasterLvl, spell.Meta);
                //Adjust the damage based on the Reflex Save, Evasion and Improved Evasion. (Don't bother for caster)
                nDamage = GetSavingThrowAdjustedDamage(nDamage, oTarget, spell.DC, spell.SavingThrow, SAVING_THROW_TYPE_NONE, spell.Caster);
                //Set the damage effect
                eDam = EffectDamage(nDamage, spell.DamageType);
                // * caster can't be affected by the spell
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
