//::///////////////////////////////////////////////
//:: Acid Fog: On Enter
//:: NW_S0_AcidFogA.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    All creatures within the AoE take 2d6 acid damage
    per round and upon entering if they fail a Fort Save
    their movement is halved.

    **EDITED Nov 18/02 - Keith Warner**
    Only enemies should take the dirge damage
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 17, 2001
//:://////////////////////////////////////////////
/*
Patch 1.71

- aoe signalized wrong spell ID
- moving bug fixed, now caster gains benefit of aura all the time, (cannot guarantee the others,
thats module-related)
- AOE effects made undispellable
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.SavingThrow = SAVING_THROW_FORT;
    spell.TargetType = SPELL_TARGET_SELECTIVEHOSTILE;

    //Declare major variables
    aoesDeclareMajorVariables();
    object oTarget = GetEnteringObject();

    if(oTarget != aoe.Owner && spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
    {
        //Fire cast spell at event for the target
        SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
        //Spell resistance check
        if(!MyResistSpell(aoe.Creator, oTarget))
        {
            //Make a Fortitude Save to avoid the effects of the movement hit.
            if(!MySavingThrow(spell.SavingThrow, oTarget, spell.DC, SAVING_THROW_TYPE_NONE, aoe.Creator))
            {
                int nGetLastPenalty = GetLocalInt(oTarget, "X0_L_LASTPENALTY");
                // * increase penalty by 2
                nGetLastPenalty += 2;

                effect eStr = EffectAbilityDecrease(ABILITY_STRENGTH, nGetLastPenalty);
                effect eDex = EffectAbilityDecrease(ABILITY_DEXTERITY, nGetLastPenalty);
                //change from sonic effect to bard song...
                effect eVis = EffectVisualEffect(VFX_FNF_SOUND_BURST);
                effect eLink = EffectLinkEffects(eDex, eStr);
                eLink = ExtraordinaryEffect(eLink);

                //Apply damage and visuals
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget);
                SetLocalInt(oTarget, "X0_L_LASTPENALTY", nGetLastPenalty);
            }
        }
    }
}
