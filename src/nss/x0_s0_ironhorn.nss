//::///////////////////////////////////////////////
//:: Balagarn's Iron Horn
//::
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
// Create a virbration that shakes creatures off their feet.
// Make a strength check as if caster has strength 20
// against all enemies in area
// Changes it so its not a cone but a radius.
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: July 22 2002
//:://////////////////////////////////////////////
//:: Last Updated By: Andrew Nobbs May 01, 2003
/*
Patch 1.71

- added special workaround to handle the way this spell is cast by default AI
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Range = RADIUS_SIZE_COLOSSAL;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    if(spell.Target != spell.Caster && GetIsObjectValid(spell.Target) && !GetFactionEqual(spell.Caster,spell.Target))
    {
        //fix for AI that is cheat-casting this spell onto enemies while its personal range
        spell.Target = spell.Caster;
        spell.Loc = GetLocation(spell.Caster);
    }
    float fDelay;
    effect eExplode = EffectVisualEffect(VFX_FNF_HOWL_WAR_CRY);
    effect eVis = EffectVisualEffect(VFX_IMP_HEAD_NATURE);
    effect eShake = EffectVisualEffect(VFX_FNF_SCREEN_BUMP);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eShake, spell.Target, RoundsToSeconds(d3()));
    //Apply epicenter explosion on caster
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, spell.Loc);
    //Declare the spell shape, size and the location.  Capture the first target object in the shape.
    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while (GetIsObjectValid(oTarget))
    {
        // * spell should not affect the caster
        if (oTarget != spell.Target && spellsIsTarget(oTarget, spell.TargetType, spell.Target))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Target, spell.Id));
            //Get the distance between the explosion and the target to calculate delay
            fDelay = GetDistanceBetweenLocations(spell.Loc, GetLocation(oTarget))/20;
            if (!MyResistSpell(spell.Target, oTarget, fDelay))
            {
                effect eTrip = EffectKnockdown();
                // * DO a strength check vs. Strength 20
                if (d20() + GetAbilityScore(oTarget, ABILITY_STRENGTH) <= 20 + d20())
                {
                    // Apply effects to the currently selected target.
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTrip, oTarget, 6.0));
                    //This visual effect is applied to the target object not the location as above.  This visual effect
                    //represents the flame that erupts on the target not on the ground.
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                }
                else
                    FloatingTextStrRefOnCreature(2750, spell.Target, FALSE);
             }
        }
       //Select the next target within the spell shape.
       oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    }
}
