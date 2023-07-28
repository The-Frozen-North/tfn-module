//::///////////////////////////////////////////////
//:: Shelgarn's Persistent Blade
//:: X2_S0_PersBlde
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Summons a dagger to battle for the caster
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 26, 2002
//:://////////////////////////////////////////////
//:: Last Updated By: Georg Zoeller, Aug 2003
/*
Patch 1.71

- enhancement bonus wasn't calculated properly
- damage reduction was 25 instead of 5
*/

#include "70_inc_spells"
#include "x2_i0_spells"
#include "inc_general"
#include "x2_inc_spellhook"

//Creates the weapon that the creature will be using.
void spellsCreateItemForSummoned(object oCaster, int nStat)
{
    //Declare major variables
    nStat/= 2;
    object oSummon = GetAssociate(ASSOCIATE_TYPE_SUMMONED, oCaster);
    object oWeapon;
    if (GetIsObjectValid(oSummon))
    {
        //Create item on the creature, epuip it and add properties.
        oWeapon = CreateItemOnObject("NW_WSWDG001", oSummon);
        // GZ: Fix for weapon being dropped when killed
        SetDroppableFlag(oWeapon, FALSE);
        AssignCommand(oSummon, ActionEquipItem(oWeapon, INVENTORY_SLOT_RIGHTHAND));
        // GZ: Check to prevent invalid item properties from being applies
        if (nStat > 0)
        {
            AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyAttackBonus(nStat > 20 ? 20 : nStat), oWeapon);
        }
        AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyDamageReduction(IP_CONST_DAMAGEREDUCTION_1, IP_CONST_DAMAGESOAK_5_HP), oWeapon);
    }
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
    int nDuration = spell.Level/2;
    if (nDuration < 1)
    {
        nDuration = 1;
    }
    effect eSummon = EffectSummonCreature("X2_S_FAERIE001");
    effect eVis = EffectVisualEffect(VFX_FNF_SUMMON_MONSTER_1);
    //Make metamagic check for extend
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2;   //Duration is +100%
    }
    //Apply the VFX impact and summon effect
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eVis, spell.Loc);
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eSummon, spell.Loc, DurationToSeconds(nDuration));

    //enhancement bonus calculation
    int nStat;
    // cast from scroll or wand, we just assume +5 ability modifier
    if(spell.Item != OBJECT_INVALID)
    {
        nStat = 5;
    }
    else if(spell.Class == CLASS_TYPE_WIZARD)
    {
        nStat = GetAbilityModifier(ABILITY_INTELLIGENCE, spell.Caster);
    }
    else
    {
        nStat = GetAbilityModifier(ABILITY_CHARISMA, spell.Caster);
    }
    if (GetIsPC(spell.Caster))
    {
        IncrementPlayerStatistic(spell.Caster, "creatures_summoned");
    }
    DelayCommand(1.0, spellsCreateItemForSummoned(spell.Caster,nStat));
}
