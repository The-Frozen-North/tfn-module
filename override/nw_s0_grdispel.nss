//::///////////////////////////////////////////////
//:: Greater Dispelling
//:: NW_S0_GrDispel.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 7, 2002
//:: Updated On: Oct 20, 2003, Georg Zoeller
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Range = RADIUS_SIZE_LARGE;
    spell.SR = NO;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect   eVis         = EffectVisualEffect(VFX_IMP_BREACH);
    effect   eImpact      = EffectVisualEffect(VFX_FNF_DISPEL_GREATER);
    int      nCasterLevel = spell.Level;

    //--------------------------------------------------------------------------
    // Greater Dispell Magic is capped at caster level 15
    //--------------------------------------------------------------------------
    if(nCasterLevel > 15)
    {
        nCasterLevel = 15;
    }

    if (GetIsObjectValid(spell.Target))
    {
        //----------------------------------------------------------------------
        // Targeted Dispel - Dispel all
        //----------------------------------------------------------------------
        spellsDispelMagic(spell.Target, nCasterLevel, eVis, eImpact);
    }
    else
    {
        //----------------------------------------------------------------------
        // Area of Effect - Only dispel best effect
        //----------------------------------------------------------------------
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spell.Loc);
        object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_AREA_OF_EFFECT | OBJECT_TYPE_PLACEABLE);
        while (GetIsObjectValid(oTarget))
        {
            if(GetObjectType(oTarget) == OBJECT_TYPE_AREA_OF_EFFECT)
            {
                //--------------------------------------------------------------
                // Handle Area of Effects
                //--------------------------------------------------------------
                spellsDispelAoE(oTarget, spell.Caster, nCasterLevel);
            }
            else if (GetObjectType(oTarget) == OBJECT_TYPE_PLACEABLE)
            {
                SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            }
            else
            {
                spellsDispelMagic(oTarget, nCasterLevel, eVis, eImpact, FALSE);
            }
            oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_AREA_OF_EFFECT | OBJECT_TYPE_PLACEABLE);
        }
    }
}
