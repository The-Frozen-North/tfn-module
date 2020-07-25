//::///////////////////////////////////////////////
//:: Shapechange
//:: NW_S0_ShapeChg.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 22, 2002
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "70_inc_shifter"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_TURNS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis = EffectVisualEffect(VFX_FNF_SUMMON_MONSTER_3);
    effect ePoly;
    int nPoly;
    int nDuration = spell.Level;
    //Enter Metamagic conditions
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2; //Duration is +100%
    }

    //Determine Polymorph subradial type
    if(spell.Id == 392)
    {
        nPoly = POLYMORPH_TYPE_RED_DRAGON;
    }
    else if (spell.Id == 393)
    {
        nPoly = POLYMORPH_TYPE_FIRE_GIANT;
    }
    else if (spell.Id == 394)
    {
        nPoly = POLYMORPH_TYPE_BALOR;
    }
    else if (spell.Id == 395)
    {
        nPoly = POLYMORPH_TYPE_DEATH_SLAAD;
    }
    else if (spell.Id == 396)
    {
        nPoly = POLYMORPH_TYPE_IRON_GOLEM;
    }

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, SPELL_SHAPECHANGE, FALSE));
                                                             //direct id here because of subspells
    //Apply the VFX impact and effects
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, spell.Loc);
    //1.72: new polymorph engine - handles all the magic around polymorph automatically now
    ApplyPolymorph(spell.Target, nPoly, SUBTYPE_MAGICAL, DurationToSeconds(nDuration),FALSE,0.5);
}
