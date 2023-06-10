//::///////////////////////////////////////////////
//:: Delayed Blast Fireball
//:: NW_S0_DelFirebal.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The caster creates a trapped area which detects
    the entrance of enemy creatures into 3 m area
    around the spell location.  When tripped it
    causes a fiery explosion that does 1d6 per
    caster level up to a max of 20d6 damage.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 27, 2001
//:://////////////////////////////////////////////
/*
Patch 1.72

- when cast directly on single target make explosion immediately without making AOE
object, this modification is especially useful for PWs as AOEs have negative impact
on monster AI and lags
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DamageCap = 20;
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_FIRE;
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.Range = RADIUS_SIZE_HUGE;
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables including Area of Effect Object
    spellsDeclareMajorVariables();
    //spell cast directly on single target
    if(spell.Target != OBJECT_INVALID && spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        int nDamage;
        float fDelay;
        int nCasterLevel = spell.Level;
        //Limit caster level
        if(nCasterLevel > spell.DamageCap)
        {
            nCasterLevel = spell.DamageCap;
        }
        effect eDam;
        effect eExplode = EffectVisualEffect(VFX_FNF_FIREBALL);
        effect eVis = EffectVisualEffect(spell.DmgVfxL);
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, spell.Loc);
        //Cycle through the targets in the explosion area
        object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
        while(GetIsObjectValid(oTarget))
        {
            if(spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
                //Get the distance between the explosion and the target to calculate delay
                fDelay = GetDistanceBetweenLocations(spell.Loc, GetLocation(oTarget))/20;
                //Make SR check
                if(!MyResistSpell(spell.Caster, oTarget, fDelay))
                {
                    nDamage = MaximizeOrEmpower(spell.Dice,nCasterLevel,spell.Meta);
                    //Change damage according to Reflex, Evasion and Improved Evasion
                    nDamage = GetSavingThrowAdjustedDamage(nDamage, oTarget, spell.DC, spell.SavingThrow, spell.SaveType, spell.Caster);

                    if(nDamage > 0)
                    {
                        //Set up the damage effect
                        eDam = EffectDamage(nDamage, spell.DamageType);
                        //Apply VFX impact and damage effect
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                    }
                }
            }
            //Get next target in the sequence
            oTarget = GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
        }
    }
    else
    {
        effect eAOE = EffectAreaOfEffect(AOE_PER_DELAY_BLAST_FIREBALL);
        int nDuration = spell.Level / 2;
        //Make sure the duration is at least one round
        if(nDuration == 0)
        {
            nDuration = 1;
        }
        //Check Extend metamagic feat.
        if(spell.Meta & METAMAGIC_EXTEND)
        {
           nDuration = nDuration *2;//Duration is +100%
        }
        //Create an instance of the AOE Object using the Apply Effect function
        ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, spell.Loc, DurationToSeconds(nDuration));
        spellsSetupNewAOE("VFX_PER_DELAY_BLAST_FIREBALL");
    }
}
