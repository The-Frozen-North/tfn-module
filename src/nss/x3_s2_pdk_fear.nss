//::///////////////////////////////////////////////
//:: Purple Dragon Knight - Fear ability
//:: x3_s2_pdk_fear.nss
//:://////////////////////////////////////////////
//:: Identical to the Fear Spell, except it uses
//:: the PDK's character level
//:://////////////////////////////////////////////
//:: Created By: Stratovarius
//:: Created On: Sept 22, 2005
//:://////////////////////////////////////////////

/*
Patch 1.72

- added missing effect and duration scalling by game difficulty
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.Range = RADIUS_SIZE_LARGE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    // Declare/assign major variables
    spellsDeclareMajorVariables();
    float fDelay;// For delay value
    int nDuration = GetHitDice(spell.Caster);// Determine duration based on level
    effect eFear = EffectFrightened();// Get Frightened effect
    effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);// Get VFX
    effect eImpact = EffectVisualEffect(VFX_FNF_LOS_NORMAL_20);// Get VFX
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);// Get VFX

    // Link the fear and mind effects
    effect eLink;
    eMind = EffectLinkEffects(eDur, eMind);

    // Apply Impact
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spell.Loc);

    // Get first target in the spell cone
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);

    // Keep processing targets until no valid ones left
    while(GetIsObjectValid(oTarget))
    {
        if (spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, spell.Caster))
        {
            fDelay = GetRandomDelay();

            // Cause the SpellCastAt event to be triggered on oTarget
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, SPELL_FEAR));

            // Make SR Check
            if(!MyResistSpell(spell.Caster, oTarget, fDelay))
            {
                //Make a will save
                if(!MySavingThrow(SAVING_THROW_WILL, oTarget, spell.DC, SAVING_THROW_TYPE_FEAR, spell.Caster, fDelay))
                {
                    eLink = GetScaledEffect(eFear, oTarget);
                    eLink = EffectLinkEffects(eLink, eMind);
                    //Apply the linked effects and the VFX impact
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, DurationToSeconds(GetScaledDuration(nDuration,oTarget))));
                }
            }
        }
        //Get next target in the spell cone
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    }
}
