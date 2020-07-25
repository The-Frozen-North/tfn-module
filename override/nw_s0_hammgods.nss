//::///////////////////////////////////////////////
//:: Hammer of the Gods
//:: [NW_S0_HammGods.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Does 1d8 damage to all enemies within the
//:: spells 20m radius and dazes them if a
//:: Will save is failed.
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 12, 2001
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 21, 2001
//:: Update Pass By: Preston W, On: Aug 1, 2001

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DamageCap = 5;
    spell.Dice = 8;
    spell.DamageType = DAMAGE_TYPE_DIVINE;
    spell.Range = RADIUS_SIZE_HUGE;
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_SELECTIVEHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eDam;
    effect eDaze = EffectDazed();
    effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

    effect eLink = EffectLinkEffects(eMind, eDaze);
    eLink = EffectLinkEffects(eLink, eDur);

    effect eVis = EffectVisualEffect(VFX_IMP_DIVINE_STRIKE_HOLY);
    effect eStrike = EffectVisualEffect(VFX_FNF_STRIKE_HOLY);
    float fDelay;
    int nDamageDice = spell.Level/2;
    if(nDamageDice < 1)
    {
        nDamageDice = 1;
    }
    //Limit caster level
    if (nDamageDice > spell.DamageCap)
    {
        nDamageDice = spell.DamageCap;
    }
    int nDamage;
    //Apply the holy strike VFX
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eStrike, spell.Loc);
    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    while (GetIsObjectValid(oTarget))
    {
       //Make faction checks
        if (spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            //Make SR Check
            if (!MyResistSpell(spell.Caster, oTarget))
            {
                fDelay = GetRandomDelay(0.6, 1.3);
                //Roll damage
                nDamage = MaximizeOrEmpower(spell.Dice,nDamageDice,spell.Meta);
                //Make a will save for half damage and negation of daze effect
                if (MySavingThrow(spell.SavingThrow, oTarget, spell.DC, spell.SaveType, spell.Caster, 0.5))
                {
                    nDamage = nDamage / 2;
                }
                else
                {
                    //Apply daze effect
                    DelayCommand(0.5, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(d6())));
                }
                //Set damage effect
                eDam = EffectDamage(nDamage, spell.DamageType);
                //Apply the VFX impact and damage effect
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
             }
        }
        //Get next target in shape
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    }
}
