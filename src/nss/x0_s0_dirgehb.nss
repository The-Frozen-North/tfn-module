//::///////////////////////////////////////////////
//:: Dirge: Heartbeat
//:: x0_s0_dirgeHB.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 17, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- aoe signalized wrong spell ID
- moving bug fixed, now caster gains benefit of aura all the time, (cannot guarantee the others,
thats module-related)
- AOE effects made undispellable
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.SavingThrow = SAVING_THROW_FORT;
    spell.TargetType = SPELL_TARGET_SELECTIVEHOSTILE;

    //Declare major variables
    aoesDeclareMajorVariables();
    effect eStr, eDex, eLink;
    effect eVis = EffectVisualEffect(VFX_FNF_SOUND_BURST);
    int nGetLastPenalty;

    //Start cycling through the AOE Object for viable targets including doors and placable objects.
    object oTarget = GetFirstInPersistentObject(aoe.AOE);
    while(GetIsObjectValid(oTarget))
    {
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
                    nGetLastPenalty = GetLocalInt(oTarget, "X0_L_LASTPENALTY");
                    // * increase penalty by 2
                    nGetLastPenalty += 2;

                    eStr = EffectAbilityDecrease(ABILITY_STRENGTH, nGetLastPenalty);
                    eDex = EffectAbilityDecrease(ABILITY_DEXTERITY, nGetLastPenalty);
                    //change from sonic effect to bard song...
                    eLink = EffectLinkEffects(eDex, eStr);
                    eLink = ExtraordinaryEffect(eLink);

                    //Apply damage and visuals
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
                    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget);
                    SetLocalInt(oTarget, "X0_L_LASTPENALTY", nGetLastPenalty);
                }
            }
        }
        //Get next target.
        oTarget = GetNextInPersistentObject(aoe.AOE);
    }
}
