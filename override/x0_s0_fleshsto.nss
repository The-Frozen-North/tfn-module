//::///////////////////////////////////////////////
//:: Flesh to Stone
//:: x0_s0_fleshsto
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
//:: The target freezes in place, standing helpless.
*/
//:://////////////////////////////////////////////
//:: Created By: Brent Knowles
//:: Created On: October 16, 2002
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        DoPetrification(spell.Level, spell.Caster, spell.Target, spell.Id, spell.DC);
    }
}
