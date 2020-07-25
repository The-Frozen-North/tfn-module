//::///////////////////////////////////////////////
//:: Magic Missile
//:: NW_S0_MagMiss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
// A missile of magical energy darts forth from your
// fingertip and unerringly strikes its target. The
// missile deals 1d4+1 points of damage.
//
// For every two extra levels of experience past 1st, you
// gain an additional missile.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: April 10, 2001
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk, On: May 8, 2001

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 4;
    spell.DamageType = DAMAGE_TYPE_MAGICAL;
    spell.Limit = 5;//maximum 10 missiles
    spell.SavingThrow = SAVING_THROW_NONE;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDamage = 0;
    int nCnt;
    effect eMissile = EffectVisualEffect(VFX_IMP_MIRV);
    effect eVis = EffectVisualEffect(spell.DmgVfxS);
    int nMissiles = (spell.Level + 1)/2;
    float fDist = GetDistanceBetween(spell.Caster, spell.Target);
    float fDelay = fDist/(3.0 * log(fDist) + 2.0);
    float fDelay2, fTime;
    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        //Limit missiles
        if (nMissiles > spell.Limit)
        {
            nMissiles = spell.Limit;
        }
        //Make SR Check
        if (!MyResistSpell(spell.Caster, spell.Target, fDelay))
        {
            //Apply a single damage hit for each missile instead of as a single mass
            for (nCnt = 1; nCnt <= nMissiles; nCnt++)
            {
                //Roll damage
                int nDam = MaximizeOrEmpower(spell.Dice,1,spell.Meta,1);
                fTime = fDelay;
                fDelay2 += 0.1;
                fTime += fDelay2;

                //1.72: this will do nothing by default, but allows to dynamically enforce saving throw
                if(MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, spell.SaveType, spell.Caster))
                {
                    nDamage/= 2;
                }
                //Set damage effect
                effect eDam = EffectDamage(nDam, spell.DamageType);
                //Apply the MIRV and damage effect
                DelayCommand(fTime, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target));
                DelayCommand(fTime, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, spell.Target));
                DelayCommand(fDelay2, ApplyEffectToObject(DURATION_TYPE_INSTANT, eMissile, spell.Target));
            }
        }
        else
        {
            for (nCnt = 1; nCnt <= nMissiles; nCnt++)
            {
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eMissile, spell.Target);
            }
        }
    }
}
