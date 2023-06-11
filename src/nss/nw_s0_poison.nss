//::///////////////////////////////////////////////
//:: Poison
//:: NW_S0_Poison.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Must make a touch attack. If successful the target
    is struck down with wyvern poison.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 22, 2001
//:://////////////////////////////////////////////
/*
Patch 1.72
- the spell will now stack, even without MODULE_SWITCH_ALLOW_POISON_STACKING enabled
- made the spell to use DC calculated from caster ability and spell level instead of static DC of large scorpion venom
Patch 1.71
- poison made extraordinary
*/

#include "70_inc_spells"
#include "70_inc_poison"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void ApplySecondaryPoison(object oTarget, int nSavingThrow, int nDC)
{
    if(GetIsImmune(oTarget, IMMUNITY_TYPE_POISON, OBJECT_SELF))
    {
        //engine workaround to print immunity feedback
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectPoison(POISON_LARGE_SCORPION_VENOM), oTarget);
    }
    else
    {
        if(!MySavingThrow(nSavingThrow, oTarget, nDC, SAVING_THROW_TYPE_POISON, OBJECT_SELF))
        {
            //Apply the poison effect and VFX impact
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_POISON_S), oTarget);
            object oCreator = GetPoisonEffectCreator(oTarget);
            AssignCommand(oCreator, ApplyEffectToObject(DURATION_TYPE_PERMANENT, ExtraordinaryEffect(EffectAbilityDecrease(ABILITY_STRENGTH,d6())), oTarget));
        }
    }
}

void main()
{
    if(GetLastRunScriptEffectScriptType() == RUNSCRIPT_EFFECT_SCRIPT_TYPE_ON_INTERVAL)
    {
        object oTarget = OBJECT_SELF;
        effect ePoison = GetLastRunScriptEffect();
        object oCreator = GetEffectCreator(ePoison);
        string sData = GetEffectString(ePoison,0);
        int nSavingThrow = StringToInt(GetStringLeft(sData,1));
        int nDC = StringToInt(GetStringRight(sData,GetStringLength(sData)-2));
        AssignCommand(oCreator,ApplySecondaryPoison(oTarget,nSavingThrow,nDC));
        return;
    }
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.SavingThrow = SAVING_THROW_FORT;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect ePoison = EffectPoison(POISON_LARGE_SCORPION_VENOM);
    ePoison = ExtraordinaryEffect(ePoison);
    int nTouch = 1;//seems that touch attack was removed from some reason, let it be then
    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        //Make touch attack
        if (nTouch > 0)
        {
            //Make SR Check
            if (!MyResistSpell(spell.Caster, spell.Target))
            {
                if(GetIsImmune(spell.Target, IMMUNITY_TYPE_POISON, spell.Caster))
                {
                    //engine workaround to print immunity feedback
                    ApplyEffectToObject(DURATION_TYPE_PERMANENT, ePoison, spell.Target);
                }
                else if(!MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, SAVING_THROW_TYPE_POISON, spell.Caster))
                {
                    //duplicating the large scorpion venom's effects
                    ePoison = EffectVisualEffect(VFX_DUR_CESSATE_NEUTRAL);
                    ePoison = EffectLinkEffects(ePoison,EffectIcon(20));
                    ePoison = EffectLinkEffects(ePoison,EffectRunScript("","","nw_s0_poison",60.0,IntToString(spell.SavingThrow)+","+IntToString(spell.DC)));
                    ePoison = ExtraordinaryEffect(ePoison);

                    //Apply the poison effect and VFX impact
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_POISON_S), spell.Target);
                    ApplyEffectToObject(DURATION_TYPE_PERMANENT, ePoison, spell.Target);
                    object oCreator = GetPoisonEffectCreator(spell.Caster);
                    AssignCommand(oCreator, ApplyEffectToObject(DURATION_TYPE_PERMANENT, ExtraordinaryEffect(EffectAbilityDecrease(ABILITY_STRENGTH,d6())), spell.Target));
                }
            }
        }
    }
}
