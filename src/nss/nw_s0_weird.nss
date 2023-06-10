//::///////////////////////////////////////////////
//:: Weird
//:: NW_S0_Weird
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    All enemies in LOS of the spell must make 2 saves or die.
    Even IF the fortitude save is succesful, they will still take
    3d6 damage.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: DEc 14 , 2001
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk, On: April 10, 2001
//:: VFX Pass By: Preston W, On: June 27, 2001
/*
Patch 1.70

- had double death VFX
- missing death VFX when spell killed creature lower than 4HD
- second saving throw subtype changed to fear (as per spell's descriptors)
- missing feedback when target was fear or mind spells immune
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_MAGICAL;
    spell.Range = RADIUS_SIZE_COLOSSAL;
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
    effect eVis = EffectVisualEffect(VFX_IMP_SONIC);
    effect eVis2 = EffectVisualEffect(VFX_IMP_DEATH);
    effect eWeird = EffectVisualEffect(VFX_FNF_WEIRD);
    effect eAbyss = EffectVisualEffect(VFX_DUR_ANTI_LIGHT_10);
    int nDamage;
    float fDelay;

    //Apply the FNF VFX impact
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eWeird, spell.Loc);
    //Get the first target in the spell area
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    while (GetIsObjectValid(oTarget))
    {
        //Make a faction check
        if (spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
            fDelay = GetRandomDelay(3.0, 4.0);
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            //Make an SR Check
            if(!MyResistSpell(spell.Caster, oTarget, fDelay))
            {
                if (!GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, spell.Caster) && !GetIsImmune(oTarget, IMMUNITY_TYPE_FEAR, spell.Caster))
                {
                    if(GetHitDice(oTarget) >= 4)
                    {
                        //Make a Will save against mind-affecting
                        if(!MySavingThrow(spell.SavingThrow, oTarget, spell.DC, SAVING_THROW_TYPE_MIND_SPELLS, spell.Caster, fDelay))
                        {
                            //Make a fortitude save against death
                            if(MySavingThrow(SAVING_THROW_FORT, oTarget, spell.DC, SAVING_THROW_TYPE_FEAR, spell.Caster, fDelay))
                            {
                                // * I made my saving throw but I still have to take the 3d6 damage
                                //Roll damage
                                nDamage = MaximizeOrEmpower(spell.Dice,3,spell.Meta);
                                //Set damage effect
                                eDam = EffectDamage(nDamage, spell.DamageType);
                                //Apply VFX Impact and damage effect
                                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                            }
                            else
                            {
                                // * I failed BOTH saving throws. Now I die.
                                //Apply VFX impact and death effect
                                //DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oTarget));
                                effect eDeath = EffectDeath();
                                // Need to make this supernatural, so that it ignores death immunity.
                                eDeath = SupernaturalEffect(eDeath);
                                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget));
                            }
                        } // Will save
                    }
                    else
                    {
                        // * I have less than 4HD, I die.
                        //Apply VFX impact and death effect
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oTarget));
                        effect eDeath = EffectDeath();
                        // Need to make this supernatural, so that it ignores death immunity.
                        eDeath = SupernaturalEffect( eDeath );
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget));
                    }
                }
                else //fear or mind spells immune
                {
                    //engine workaround to get proper feedback and VFX
                    eVis = EffectVisualEffect(VFX_IMP_MAGIC_RESISTANCE_USE);
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectFrightened(), oTarget, 1.0));
                }
            }
        }
        //Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    }
}
