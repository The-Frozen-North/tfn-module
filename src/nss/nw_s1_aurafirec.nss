//::///////////////////////////////////////////////
//:: Aura of Fire on Heartbeat
//:: NW_S1_AuraElecC.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Prolonged exposure to the aura of the creature
    causes fire damage to all within the aura.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 25, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- DC corrected
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //Declare major variables
    aoesDeclareMajorVariables();
    int nHD = GetHitDice(aoe.Creator);
    int nDC = 10 + nHD/3;
    nHD = nHD/3+1;
    int nDamage;
    effect eDam;
    effect eVis = EffectVisualEffect(VFX_IMP_FLAME_S);
    //Get first target in spell area
    object oTarget = GetFirstInPersistentObject(aoe.AOE);
    while(GetIsObjectValid(oTarget))
    {
        if(spellsIsTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE, aoe.Creator))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
            //Roll damage
            nDamage = d4(nHD);
            //Make a saving throw check
            if(MySavingThrow(SAVING_THROW_FORT, oTarget, nHD, SAVING_THROW_TYPE_FIRE, aoe.Creator))
            {
                nDamage = nDamage / 2;
            }
            //Set the damage effect
            eDam = EffectDamage(nDamage, DAMAGE_TYPE_FIRE);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
        }
        //Get next target in spell area
        oTarget = GetNextInPersistentObject(aoe.AOE);
    }
}
