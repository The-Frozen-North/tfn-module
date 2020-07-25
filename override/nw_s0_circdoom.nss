//::///////////////////////////////////////////////
//:: [Circle of Doom]
//:: [NW_S0_CircDoom.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: All enemies of the caster take 1d8 damage +1
//:: per caster level (max 20).  Undead are healed
//:: for the same amount
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk and Keith Soleski
//:: Created On: Jan 31, 2001
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 20, 2001
//:: Update Pass By: Preston W, On: July 25, 2001
/*
Patch 1.70

- Caster level was counted (twice) in the empowered version
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Range = RADIUS_SIZE_MEDIUM;
    spell.Dice = 8;
    spell.DamageType = DAMAGE_TYPE_NEGATIVE;
    spell.SavingThrow = SAVING_THROW_FORT;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    object oTarget;
    effect eDam;
    effect eVis = EffectVisualEffect(spell.DmgVfxL);
    effect eVis2 = EffectVisualEffect(VFX_IMP_HEALING_M);
    effect eFNF = EffectVisualEffect(VFX_FNF_LOS_EVIL_10);
    effect eHeal;
    int nCasterLevel = spell.Level;
    //Limit Caster Level
    if(nCasterLevel > 20)
    {
        nCasterLevel = 20;
    }
    int nDamage;
    float fDelay;
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eFNF, spell.Loc);
    //Get first target in the specified area
    oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    while (GetIsObjectValid(oTarget))
    {
        fDelay = GetRandomDelay();
        //Roll damage
        nDamage = MaximizeOrEmpower(spell.Dice,1,spell.Meta,nCasterLevel);

        //If the target is an allied undead it is healed
        if(spellsIsRacialType(oTarget, RACIAL_TYPE_UNDEAD))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
            //Set the heal effect
            eHeal = EffectHeal(nDamage);
            //Apply the impact VFX and healing effect
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oTarget));
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oTarget));
        }
        else
        {
            if (spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
                //Make an SR Check
                if (!MyResistSpell(spell.Caster, oTarget, fDelay))
                {
                    if (MySavingThrow(spell.SavingThrow, oTarget, spell.DC, spell.SaveType, spell.Caster, fDelay))
                    {
                        nDamage = nDamage/2;
                    }
                    //Set Damage
                    eDam = EffectDamage(nDamage, spell.DamageType);
                    //Apply impact VFX and damage
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                }
            }
        }
        //Get next target in the specified area
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    }
}
