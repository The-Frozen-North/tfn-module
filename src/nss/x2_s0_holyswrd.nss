//::///////////////////////////////////////////////
//:: Holy Sword
//:: X2_S0_HolySwrd
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
  Grants holy avenger properties.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 28, 2002
//:://////////////////////////////////////////////
//:: Updated by Andrew Nobbs May 08, 2003
//:: 2003-07-07: Stacking Spell Pass, Georg Zoeller
/*
Patch 1.72
- the duration visual effect is no longer dispellable
Patch 1.71
- VFX added if cast on weapon on ground
- holy avenger itemproperty will be correctly extended when recast before expiration
*/

#include "70_inc_spells"
#include "x2_i0_spells"
#include "x2_inc_spellhook"

void AddHolyAvengerEffectToWeapon(object oMyWeapon, float fDuration)
{
    if(GetModuleSwitchValue("72_DISABLE_WEAPON_BOOST_STACKING"))
    {
        IPRemoveAllItemProperties(oMyWeapon,DURATION_TYPE_TEMPORARY);
    }
    if(!IPGetItemHasProperty(oMyWeapon,ItemPropertyHolyAvenger(),DURATION_TYPE_PERMANENT,TRUE))
    {
        //IPSafeAddItemProperty(oMyWeapon,ItemPropertyEnhancementBonus(2), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING ,FALSE,TRUE);
        IPSafeAddItemProperty(oMyWeapon,ItemPropertyHolyAvenger(), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING,FALSE,TRUE);
    }
}

#include "x2_inc_toollib"

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
    effect eVis = EffectVisualEffect(VFX_IMP_GOOD_HELP);
    effect eDur = ExtraordinaryEffect(EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE));
    int nDuration = spell.Level;

    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration * 2; //Duration is +100%
    }

    object oMyWeapon = IPGetTargetedOrEquippedMeleeWeapon();
    object oPossessor = GetItemPossessor(oMyWeapon);

    if(GetIsObjectValid(oMyWeapon))
    {
        SignalEvent(oMyWeapon, EventSpellCastAt(OBJECT_SELF, GetSpellId(), FALSE));
        if(GetIsObjectValid(oPossessor))
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oPossessor);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, oPossessor, DurationToSeconds(nDuration));
        }
        else
        {
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, spell.Loc);
        }
        AddHolyAvengerEffectToWeapon(oMyWeapon, DurationToSeconds(nDuration));
        TLVFXPillar(VFX_IMP_GOOD_HELP, spell.Loc, 4, 0.0, 6.0);
        DelayCommand(1.0, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_SUPER_HEROISM), spell.Loc));
    }
    else
    {
        FloatingTextStrRefOnCreature(83615, spell.Caster);
    }
}
