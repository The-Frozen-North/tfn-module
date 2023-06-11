//::///////////////////////////////////////////////
//:: Mordenkainen's Disjunction
//:: NW_S0_MordDisj.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Massive Dispel Magic and Spell Breach rolled into one
    If the target is a general area of effect they lose
    6 spell protections.  If it is an area of effect everyone
    in the area loses 2 spells protections.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 7, 2002
//:: Updated On: Oct 20, 2003, Georg Zoeller
//:://////////////////////////////////////////////
/*
Patch 1.72
- caster level is now limited to 40 as per description
- dispells two spells when used in aoe as per description
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Limit = 40;
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
    effect  eVis        = EffectVisualEffect(VFX_IMP_HEAD_ODD);
    effect  eImpact     = EffectVisualEffect(VFX_FNF_DISPEL_DISJUNCTION);
    int      nCasterLevel = spell.Level;

    //--------------------------------------------------------------------------
    // Mordenkainen's Disjunction is capped at caster level 40
    //--------------------------------------------------------------------------
    if(nCasterLevel > spell.Limit)
    {
        nCasterLevel = spell.Limit;
    }

    if (GetIsObjectValid(spell.Target))
    {
        //----------------------------------------------------------------------
        // Targeted Dispel - Dispel all
        //----------------------------------------------------------------------
        spellsDispelMagic(spell.Target, spell.Level, eVis, eImpact,TRUE,TRUE);
    }
    else
    {
        //----------------------------------------------------------------------
        // Area of Effect - Only dispel best effect
        //----------------------------------------------------------------------

        //Apply the VFX impact and effects
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spell.Loc);
        object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_AREA_OF_EFFECT | OBJECT_TYPE_PLACEABLE);
        while (GetIsObjectValid(oTarget))
        {
            if(GetObjectType(oTarget) == OBJECT_TYPE_AREA_OF_EFFECT)
            {
                //--------------------------------------------------------------
                // Handle Area of Effects
                //--------------------------------------------------------------
                spellsDispelAoE(oTarget,spell.Caster,spell.Level);

            }
            else if (GetObjectType(oTarget) == OBJECT_TYPE_PLACEABLE)
            {
                SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            }
            else
            {
                spellsDispelMagic(oTarget, spell.Level, eVis, eImpact, FALSE, TRUE);
                effect eNull;
                spellsDispelMagic(oTarget, spell.Level, eNull, eNull, FALSE, FALSE);
            }
            oTarget = GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_AREA_OF_EFFECT | OBJECT_TYPE_PLACEABLE);
        }
    }
}
