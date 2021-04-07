//::///////////////////////////////////////////////
//:: Polymorph Self
//:: NW_S0_PolySelf.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The PC is able to changed their form to one of
    several forms.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 21, 2002
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
    effect eVis = EffectVisualEffect(VFX_IMP_POLYMORPH);
    effect ePoly;
    int nPoly;
    int nDuration = spell.Level;
    //Enter Metamagic conditions
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2; //Duration is +100%
    }

    //Determine Polymorph subradial type
    if(spell.Id == 387)
    {
        nPoly = POLYMORPH_TYPE_GIANT_SPIDER;
    }
    else if (spell.Id == 388)
    {
        nPoly = POLYMORPH_TYPE_TROLL;
    }
    else if (spell.Id == 389)
    {
        nPoly = POLYMORPH_TYPE_UMBER_HULK;
    }
    else if (spell.Id == 390)
    {
        nPoly = POLYMORPH_TYPE_PIXIE;
    }
    else if (spell.Id == 391)
    {
        nPoly = POLYMORPH_TYPE_ZOMBIE;
    }

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, SPELL_POLYMORPH_SELF, FALSE));
    //Apply the VFX impact and effects
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
    //1.72: new polymorph engine - handles all the magic around polymorph automatically now
    ApplyPolymorph(spell.Target, nPoly, SUBTYPE_MAGICAL, DurationToSeconds(nDuration));
}
