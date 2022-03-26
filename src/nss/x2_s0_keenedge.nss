//::///////////////////////////////////////////////
//:: Keen Edge
//:: X2_S0_KeenEdge
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
  Adds the keen property to one melee weapon,
  increasing its critical threat range.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 28, 2002
//:://////////////////////////////////////////////
//:: Updated by Andrew Nobbs May 08, 2003
//:: 2003-07-07: Stacking Spell Pass, Georg Zoeller
//:: 2003-07-17: Complete Rewrite to make use of Item Property System
/*
Patch 1.72
- the duration visual effect is no longer dispellable
Patch 1.70
- VFX added if cast on weapon on ground
*/

#include "70_inc_spells"
#include "x2_i0_spells"
#include "x2_inc_spellhook"

void AddKeenEffectToWeapon(object oMyWeapon, float fDuration)
{
    if(GetModuleSwitchValue("72_DISABLE_WEAPON_BOOST_STACKING"))
    {
        IPRemoveAllItemProperties(oMyWeapon,DURATION_TYPE_TEMPORARY);
    }
    IPSafeAddItemProperty(oMyWeapon, ItemPropertyKeen(), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);
}

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_TURNS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis = EffectVisualEffect(VFX_IMP_SUPER_HEROISM);
    effect eDur = ExtraordinaryEffect(EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE));
    int nDuration = 10 * spell.Level;

    object oMyWeapon = IPGetTargetedOrEquippedMeleeWeapon();
    object oPossessor = GetItemPossessor(oMyWeapon);

    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration * 2; //Duration is +100%
    }

    if(GetIsObjectValid(oMyWeapon))
    {
        //if the possessor isn't valid, nothing should happen
        SignalEvent(oPossessor, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

        if (GetSlashingWeapon(oMyWeapon))
        {
            if(GetIsObjectValid(oPossessor))
            {
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oPossessor);
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, oPossessor, DurationToSeconds(nDuration));
            }
            else
            {
                ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, spell.Loc);
            }
            AddKeenEffectToWeapon(oMyWeapon, DurationToSeconds(nDuration));
        }
        else
        {
            FloatingTextStrRefOnCreature(83621, spell.Caster); // not a slashing weapon
        }
    }
    else
    {
        FloatingTextStrRefOnCreature(83615, spell.Caster);
    }
}
