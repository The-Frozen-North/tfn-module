//::///////////////////////////////////////////////
//:: [Sound Burst]
//:: [NW_S0_SndBurst.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Does 1d8 damage to all creatures in a 10ft
//:: radius.  Will save or the creature is stunned
//:: for 1 round.
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 31, 2001
//:://////////////////////////////////////////////
//:: Last Updated By: Georg Z, Oct. 2003
/*
Patch 1.71

- deaf/silenced creatures are not affected by stun anymore (sound descriptor)
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 8;
    spell.DamageType = DAMAGE_TYPE_SONIC;
    spell.Range = RADIUS_SIZE_MEDIUM;
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDamage;
    effect eStun = EffectStunned();
    effect eVis = EffectVisualEffect(spell.DmgVfxS);
    effect eFNF = EffectVisualEffect(VFX_FNF_SOUND_BURST);
    effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

    effect eLink = EffectLinkEffects(eStun, eMind);
    eLink = EffectLinkEffects(eLink, eDur);

    effect eDam;
    //Apply the FNF to the spell location
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT,eFNF, spell.Loc);
    //Get the first target in the spell area
    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    while (GetIsObjectValid(oTarget))
    {
        if (spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            //Make a SR check
            if(!MyResistSpell(spell.Caster, oTarget))
            {
                //Roll damage
                nDamage = MaximizeOrEmpower(spell.Dice,1,spell.Meta);
                //Make a Will roll to avoid being stunned
                if(GetIsAbleToHear(oTarget) && !MySavingThrow(spell.SavingThrow, oTarget, spell.DC, spell.SaveType, spell.Caster))
                {
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(2));
                }
                //Set the damage effect
                eDam = EffectDamage(nDamage, spell.DamageType);
                //Apply the VFX impact and damage effect
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis,oTarget);
                DelayCommand(0.01, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam,oTarget));
            }
        }
        //Get the next target in the spell area
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    }
}
