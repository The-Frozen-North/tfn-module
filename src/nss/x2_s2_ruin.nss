//::///////////////////////////////////////////////
//:: Greater Ruin
//:: X2_S2_Ruin
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
// The caster deals 35d6 damage to a single target
   fort save for half damage
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 18, 2002
//:://////////////////////////////////////////////
/*
Patch 1.70

- spell now same as any non-epic direct target spell can hurt even neutral target
*/

#include "70_inc_spells"
#include "x2_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Limit = 35;//damage is limited to 35d6
    spell.SavingThrow = SAVING_THROW_FORT;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    float fDist = GetDistanceBetween(spell.Caster, spell.Target);
    float fDelay = fDist/(3.0 * log(fDist) + 2.0);

    int nSpellDC = GetEpicSpellSaveDC(spell.Caster);

    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        //Roll damage
        int nDam = d6(spell.Limit);
        //Set damage effect

        if(MySavingThrow(spell.SavingThrow, spell.Target, nSpellDC, SAVING_THROW_TYPE_SPELL, spell.Caster))
        {
            nDam /=2;
        }

        effect eDam = EffectDamage(nDam, DAMAGE_TYPE_POSITIVE, DAMAGE_POWER_PLUS_TWENTY);
        ApplyEffectAtLocation (DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SCREEN_SHAKE), spell.Loc);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_GREATER_RUIN), spell.Target);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_COM_BLOOD_CRT_RED), spell.Target);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_COM_CHUNK_BONE_MEDIUM), spell.Target);
        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target));
    }
}
