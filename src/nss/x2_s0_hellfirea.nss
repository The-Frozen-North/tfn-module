//::///////////////////////////////////////////////
//:: Aura of Hellfire on Enter
//:: NW_S1_AuraElecA.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Prolonged exposure to the aura of the creature
    causes fire damage to all within the aura.
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    aoesDeclareMajorVariables();
    int nDamage;
    effect eDam;
    effect eVis = EffectVisualEffect(VFX_IMP_FLAME_M);
    //Get first target in spell area
    object oTarget = GetEnteringObject();
    if(oTarget != aoe.Owner && spellsIsTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE, aoe.Creator))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
        //Roll damage
        nDamage = d6(6);
        //Make a saving throw check
        if(MySavingThrow(SAVING_THROW_FORT, oTarget, spell.DC, SAVING_THROW_TYPE_FIRE, aoe.Creator))
        {
            nDamage = nDamage/2;
        }
        //Set the damage effect
        eDam = EffectDamage(nDamage, DAMAGE_TYPE_FIRE);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
    }
}
