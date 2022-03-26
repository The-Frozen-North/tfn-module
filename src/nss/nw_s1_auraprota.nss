//::///////////////////////////////////////////////
//:: Aura of Protection: On Enter
//:: NW_S1_AuraProtA.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Acts as a double strength Magic Circle against
    evil and a Minor Globe for those friends in
    the area.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On:Jan 8, 2002, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- moving bug fixed, now caster gains benefit of aura all the time, (cannot guarantee the others,
thats module-related)
- added missing signal event
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //Declare major variables
    aoesDeclareMajorVariables();
    effect eProt = CreateProtectionFromAlignmentLink(ALIGNMENT_EVIL);
    effect eGlobe = EffectSpellLevelAbsorption(3, 0);
    effect eDur = EffectVisualEffect(VFX_DUR_GLOBE_MINOR);

    effect eLink = EffectLinkEffects(eProt, eGlobe);
    eLink = EffectLinkEffects(eLink, eDur);

    object oTarget = GetEnteringObject();
    //Faction Check
    if(oTarget != aoe.Owner && spellsIsTarget(oTarget, SPELL_TARGET_ALLALLIES, aoe.Creator))
    {
        SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id, FALSE));
        //Apply the VFX impact and effects
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget);
    }
}
