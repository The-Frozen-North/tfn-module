//::///////////////////////////////////////////////
//:: Magic Cirle Against Good
//:: NW_S0_CircGoodA
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Add basic protection from good effects to
    entering allies.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 20, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- moving bug fixed, now caster gains benefit of aura all the time, (cannot guarantee the others,
thats module-related)
- AOE effects made undispellable
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.TargetType = SPELL_TARGET_ALLALLIES;

    aoesDeclareMajorVariables();
    object oTarget = GetEnteringObject();
    if(!GetHasSpellEffect(spell.Id,oTarget) && spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
    {
        //Declare major variables
        //int nDuration = GetCasterLevel(OBJECT_SELF);
        //effect eVis = EffectVisualEffect(VFX_IMP_EVIL_HELP);
        effect eLink = CreateProtectionFromAlignmentLink(ALIGNMENT_GOOD);
        eLink = ExtraordinaryEffect(eLink);

        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id, FALSE));

        //Apply the VFX impact and effects
        //ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget);
     }
}
