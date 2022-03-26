//::///////////////////////////////////////////////
//:: Glyph of Warding: On Enter
//:: X2_S0_GlphWardA
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This script creates a Glyph of Warding Placeable
    object.

    Check x2_o0_hhb.nss and the Glyph of Warding
    placeable object for details
*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: 2003-09-02
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DamageCap = 5;
    spell.Dice = 8;
    spell.DamageType = DAMAGE_TYPE_SONIC;
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    //Declare major variables
    aoesDeclareMajorVariables();
    if(GetLocalInt(aoe.AOE,"DO_ONCE"))
    {
        return;//fix for situation where cast into pack of creatures
    }
    SetLocalInt(aoe.AOE,"DO_ONCE",TRUE);
    object oEntering = GetEnteringObject();
    location lTarget = GetLocation(aoe.AOE);
    int nDamage;
    int nDice = spell.Level /2;

    if (nDice > spell.DamageCap)
        nDice = spell.DamageCap;
    else if (nDice < 1)
        nDice = 1;

    effect eDam;
    effect eVis = EffectVisualEffect(spell.DmgVfxS);
    effect eExplode = EffectVisualEffect(VFX_FNF_ELECTRIC_EXPLOSION);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, lTarget);

    int nTh = 2;
    string sList, sTarget;
    //Cycle through the targets in the explosion area
    object oTarget = GetNearestObject(OBJECT_TYPE_CREATURE|OBJECT_TYPE_DOOR|OBJECT_TYPE_PLACEABLE,aoe.AOE);
    while(GetIsObjectValid(oTarget) && GetDistanceBetween(oTarget, aoe.AOE) <= 5.0)
    {
        sTarget = ObjectToString(oTarget)+"|";
        if(GetTag(oTarget) != "GLYPH_PLC" && FindSubString(sList,sTarget) < 0)
        {//special workaround for bug in getnearest/inshape functions used in AOE OnEnter script...
            sList+= sTarget;
            if (spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
                //Make SR check
                if (!MyResistSpell(aoe.Creator, oTarget))
                {
                    //calculate damage with proper metamagic
                    nDamage = MaximizeOrEmpower(spell.Dice,nDice,spell.Meta);
                    //Change damage according to Reflex, Evasion and Improved Evasion
                    nDamage = GetSavingThrowAdjustedDamage(nDamage, oTarget, spell.DC, spell.SavingThrow, spell.SaveType, aoe.Creator);

                    if(nDamage > 0)
                    {
                        eDam = EffectDamage(nDamage, spell.DamageType);
                        //Apply VFX impact and damage effect
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
                    }
                }
            }
        }
        //Get next target in the sequence
        oTarget = GetNearestObject(OBJECT_TYPE_CREATURE|OBJECT_TYPE_DOOR|OBJECT_TYPE_PLACEABLE, aoe.AOE, nTh++);
    }
    //VFX placeable holder workaround
    object vfxPlc = GetLocalObject(aoe.AOE,"VFX_PLACEABLE");
    ExecuteScript("x2_o0_glyphude",vfxPlc);
    //we do not need the AoE anymore, lets destroy it
    DestroyObject(aoe.AOE);//,0.1);
}
