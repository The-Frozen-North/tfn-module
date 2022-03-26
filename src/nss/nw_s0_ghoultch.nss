//::///////////////////////////////////////////////
//:: Ghoul Touch
//:: NW_S0_GhoulTch.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The caster attempts a touch attack on a target
    creature.  If successful creature must save
    or be paralyzed. Target exudes a stench that
    causes all enemies to save or be stricken with
    -2 Attack, Damage, Saves and Skill Checks for
    1d6+2 rounds.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 7, 2001
//:://////////////////////////////////////////////

/*  Georg 2003-09-11
    - Put in melee touch attack check, as the fixed attack bonus is now calculated correctly
 */

/*
Patch 1.72
- touch attack will be skipped in case a target is a caster himself
Patch 1.71
- the cloud AOE won't be created if the target is immune to paralysis
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.SavingThrow = SAVING_THROW_FORT;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables including Area of Effect Object
    spellsDeclareMajorVariables();
    effect eAOE = EffectAreaOfEffect(AOE_PER_FOGGHOUL);
    effect eParal = EffectParalyze();
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eDur2 = EffectVisualEffect(VFX_DUR_PARALYZED);

    effect eLink = EffectLinkEffects(eDur2, eDur);
    eLink = EffectLinkEffects(eLink, eParal);
    //calculate the duration with proper metamagic handling
    int nDuration = d6(1)+2;

    if(spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2; //Duration is +100%
    }
    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        //Make a touch attack to afflict target
        if(spell.Target == spell.Caster || TouchAttackMelee(spell.Target)>0)
        {
            //SR and Saves
            if(!MyResistSpell(spell.Caster, spell.Target))
            {
                if(!GetIsImmune(spell.Target,IMMUNITY_TYPE_PARALYSIS,spell.Caster) && !GetIsImmune(spell.Target,IMMUNITY_TYPE_MIND_SPELLS,spell.Caster))
                {
                    /*Fort Save*/
                    if(!MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, SAVING_THROW_TYPE_NEGATIVE, spell.Caster))
                    {
                        //Create an instance of the AOE Object using the Apply Effect function
                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, RoundsToSeconds(nDuration));
                        ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, spell.Loc, RoundsToSeconds(nDuration));
                        spellsSetupNewAOE("VFX_PER_FOGGHOUL","");
                    }
                }
                else
                {
                    //engine workaround to print immunity feedback
                    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eParal, spell.Target);
                }
            }
        }
    }
}
