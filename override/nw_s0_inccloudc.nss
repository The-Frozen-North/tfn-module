//::///////////////////////////////////////////////
//:: Incendiary Cloud
//:: NW_S0_IncCloudC.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Objects within the AoE take 4d6 fire damage
    per round.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 17, 2001
//:://////////////////////////////////////////////
//:: Updated By: GeorgZ 2003-08-21: Now affects doors and placeables as well

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_FIRE;
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    //Declare major variables
    aoesDeclareMajorVariables();
    int nDamage;
    effect eDam;
    //Declare and assign personal impact visual effect.
    effect eVis = EffectVisualEffect(spell.DmgVfxS);
    float fDelay;
    //Capture the first target object in the shape.

    //--------------------------------------------------------------------------
    // GZ 2003-Oct-15
    // When the caster is no longer there, all functions calling
    // GetAreaOfEffectCreator will fail. Its better to remove the barrier then
    //--------------------------------------------------------------------------
    if (aoe.Creator != OBJECT_INVALID && !GetIsObjectValid(aoe.Creator))
    {
        DestroyObject(aoe.AOE);
        return;
    }


    object oTarget = GetFirstInPersistentObject(aoe.AOE,OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    //Declare the spell shape, size and the location.
    while(GetIsObjectValid(oTarget))
    {
        if(spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
        {
            fDelay = GetRandomDelay(0.5, 2.0);
            //Make SR check, and appropriate saving throw(s).
            if(!MyResistSpell(aoe.Creator, oTarget, fDelay))
            {
                SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
                //Roll damage.
                nDamage = MaximizeOrEmpower(spell.Dice,4,spell.Meta);
                //Adjust damage for Reflex Save, Evasion and Improved Evasion
                nDamage = GetSavingThrowAdjustedDamage(nDamage, oTarget, spell.DC, spell.SavingThrow, spell.SaveType, aoe.Creator);

                if(nDamage > 0)
                {
                    // Apply effects to the currently selected target.
                    eDam = EffectDamage(nDamage, spell.DamageType);
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                }
            }
        }
        //Select the next target within the spell shape.
        oTarget = GetNextInPersistentObject(aoe.AOE,OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }
}
