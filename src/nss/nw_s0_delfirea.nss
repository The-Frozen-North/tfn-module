//::///////////////////////////////////////////////
//:: Delayed Blast Fireball: On Enter
//:: NW_S0_DelFireA.nss
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
//:: Georg: Removed Spellhook, fixed damage cap
//:: Created By: Preston Watamaniuk
//:: Created On: July 27, 2001
//:://////////////////////////////////////////////
/*
Patch 1.72

- added delay based on position from center of the AOE into effect and feedback applications
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
    spell.Range = RADIUS_SIZE_HUGE;
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    //Declare major variables
    aoesDeclareMajorVariables();
    if(GetLocalInt(aoe.AOE, "NW_SPELL_DELAY_BLAST_FIREBALL"))
    {
        return;
    }
    object oTarget = GetEnteringObject();
    location lTarget = GetLocation(aoe.AOE);
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
    //Check the faction of the entering object to make sure the entering object is not in the casters faction
    if(spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
    {
        SetLocalInt(aoe.AOE, "NW_SPELL_DELAY_BLAST_FIREBALL", TRUE);
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, lTarget);
        //Cycle through the targets in the explosion area
        oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
        while(GetIsObjectValid(oTarget))
        {
            if(spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
                //Get the distance between the explosion and the target to calculate delay
                fDelay = GetDistanceBetweenLocations(GetLocation(aoe.AOE), GetLocation(oTarget))/20;
                //Make SR check
                if(!MyResistSpell(aoe.Creator, oTarget, fDelay))
                {
                    nDamage = MaximizeOrEmpower(spell.Dice,nCasterLevel,spell.Meta);
                    //Change damage according to Reflex, Evasion and Improved Evasion
                    nDamage = GetSavingThrowAdjustedDamage(nDamage, oTarget, spell.DC, spell.SavingThrow, spell.SaveType, aoe.Creator);

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
            oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, spell.Range, lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
        }
        DestroyObject(aoe.AOE, 1.0);
    }
}
