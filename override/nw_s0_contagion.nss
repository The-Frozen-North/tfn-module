//::///////////////////////////////////////////////
//:: Contagion
//:: NW_S0_Contagion.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The target must save or be struck down with
    Blidning Sickness, Cackle Fever, Filth Fever
    Mind Fire, Red Ache, the Shakes or Slimy Doom.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: June 6, 2001
//:://////////////////////////////////////////////
/*
Patch 1.71

- disease made extraordinary
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nRand = Random(7)+1;
    int nDisease;
    //Use a random seed to determine the disease that will be delivered.
    switch (nRand)
    {
        case 1:
            nDisease = DISEASE_BLINDING_SICKNESS;
        break;
        case 2:
            nDisease = DISEASE_CACKLE_FEVER;
        break;
        case 3:
            nDisease = DISEASE_FILTH_FEVER;
        break;
        case 4:
            nDisease = DISEASE_MINDFIRE;
        break;
        case 5:
            nDisease = DISEASE_RED_ACHE;
        break;
        case 6:
            nDisease = DISEASE_SHAKES;
        break;
        case 7:
            nDisease = DISEASE_SLIMY_DOOM;
        break;
    }
    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        effect eDisease = EffectDisease(nDisease);
        eDisease = ExtraordinaryEffect(eDisease);
        //Make SR check
        if (!MyResistSpell(spell.Caster, spell.Target))
        {
            //The effect is permament because the disease subsystem has its own internal resolution
            //system in place.
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eDisease, spell.Target);
        }
    }
}
