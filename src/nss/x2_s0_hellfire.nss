//::///////////////////////////////////////////////
//:: Aura of Fire
//:: NW_S1_AuraFire.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Upon entering the aura of the creature the player
    must make a will save or be stunned.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 25, 2001
//:://////////////////////////////////////////////

#include "70_inc_spells"
//#include "x2_inc_spellhook"

void BurstWeapon(object oWeapon, float fDur)
{
    itemproperty ipFlames = ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_FIRE, IP_CONST_DAMAGEBONUS_2d8);
    DelayCommand(2.0, AddItemProperty(DURATION_TYPE_TEMPORARY, ipFlames, oWeapon, fDur));
}

void main()
{
    /*//Set and apply AOE object
    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    } */
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis = EffectVisualEffect(VFX_DUR_ELEMENTAL_SHIELD);
    int nDuration = spell.Level;
    effect eShield = EffectDamageShield(nDuration, DAMAGE_BONUS_2d6, DAMAGE_TYPE_FIRE);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eFire = EffectDamageImmunityIncrease(DAMAGE_TYPE_FIRE, 100);

    //Link effects
    effect eLink = EffectLinkEffects(eShield, eFire);
    eLink = EffectLinkEffects(eLink, eDur);
    eLink = EffectLinkEffects(eLink, eVis);

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

    //Enter Metamagic conditions
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration * 2; //Duration is +100%
    }
    //Apply the VFX impact and effects
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
    effect eAOE = EffectAreaOfEffect(AOE_MOB_FIRE, "x2_s0_hellfirea", "x2_s0_hellfirec", "x2_s0_hellfireb");
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAOE, spell.Target, DurationToSeconds(nDuration));
    spellsSetupNewAOE("VFX_MOB_FIRE","x2_s0_hellfirec");

    // weapon burst into flames... (with a little delay so enemies can see the weapon bursting).
    object oWeaponRight = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, spell.Target);
    object oWeaponLeft = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, spell.Target);
    if(oWeaponRight != OBJECT_INVALID)
        BurstWeapon(oWeaponRight, DurationToSeconds(nDuration));
    if(oWeaponLeft != OBJECT_INVALID)
        BurstWeapon(oWeaponLeft, DurationToSeconds(nDuration));
}
