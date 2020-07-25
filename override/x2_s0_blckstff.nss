//::///////////////////////////////////////////////
//:: Blackstaff
//:: X2_S0_Blckstff
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
  Adds +4 enhancement bonus, On Hit: Dispel.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 29, 2002
//:://////////////////////////////////////////////
//:: Updated by Andrew Nobbs May 07, 2003
//:: 2003-07-07: Stacking Spell Pass, Georg Zoeller
//:: 2003-07-15: Complete Rewrite to make use of Item Property System
/*
Patch 1.72
- allowed to cast on a magic staff
- the duration visual effect is no longer dispellable
Patch 1.70
- VFX added if cast on weapon on ground
*/

#include "70_inc_spells"
#include "x2_i0_spells"
#include "x2_inc_spellhook"

void AddBlackStaffEffectOnWeapon (object oTarget, float fDuration)
{
    if(GetModuleSwitchValue("72_DISABLE_WEAPON_BOOST_STACKING"))
    {
        IPRemoveAllItemProperties(oTarget,DURATION_TYPE_TEMPORARY);
    }
    IPSafeAddItemProperty(oTarget, ItemPropertyEnhancementBonus(4), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);
    IPSafeAddItemProperty(oTarget, ItemPropertyOnHitProps(IP_CONST_ONHIT_DISPELMAGIC, IP_CONST_ONHIT_SAVEDC_16), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
    IPSafeAddItemProperty(oTarget, ItemPropertyVisualEffect(ITEM_VISUAL_EVIL), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);
}

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis = EffectVisualEffect(VFX_IMP_EVIL_HELP);
    effect eDur = ExtraordinaryEffect(EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE));
    int nDuration = spell.Level;

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

        if (GetBaseItemType(oMyWeapon) == BASE_ITEM_QUARTERSTAFF || GetBaseItemType(oMyWeapon) == BASE_ITEM_MAGICSTAFF)
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
            AddBlackStaffEffectOnWeapon(oMyWeapon, DurationToSeconds(nDuration));
        }
        else
        {
            FloatingTextStrRefOnCreature(83620, spell.Caster);  // not a qstaff
        }
    }
    else
    {
        FloatingTextStrRefOnCreature(83615, spell.Caster);
    }
}
