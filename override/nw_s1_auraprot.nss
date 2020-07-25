//::///////////////////////////////////////////////
//:: Aura of Protection
//:: NW_S1_AuraProt.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Acts as a double strength Magic Circle against
    evil and a Minor Globe for those friends in
    the area.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: March 18, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- was dispellable
*/

#include "70_inc_spells"
#include "nw_i0_spells"

void main()
{
    //Declare major variables including Area of Effect Object
    spellsDeclareMajorVariables();
    effect eAOE = EffectAreaOfEffect(AOE_MOB_PROTECTION);
    effect eProt = CreateProtectionFromAlignmentLink(ALIGNMENT_EVIL);
    effect eGlobe = EffectSpellLevelAbsorption(3, 0);
    effect eDur = EffectVisualEffect(VFX_DUR_GLOBE_MINOR);

    effect eLink = EffectLinkEffects(eProt, eGlobe);
    eLink = EffectLinkEffects(eLink, eDur);
    eLink = EffectLinkEffects(eLink, eAOE);

    int nDuration = spell.Level/2;
    //Make sure duration does no equal 0
    if(nDuration < 1)
    {
        nDuration = 1;
    }
    //Create an instance of the AOE Object using the Apply Effect function
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(eLink), spell.Caster, TurnsToSeconds(nDuration));
    object oAOE = spellsSetupNewAOE("VFX_MOB_PROTECTION");
    SetAreaOfEffectUndispellable(oAOE);
}
