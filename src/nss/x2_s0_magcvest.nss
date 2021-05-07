//::///////////////////////////////////////////////
//:: Magic Vestment
//:: X2_S0_MagcVest
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
  Grants a +1 AC bonus to armor touched per 3 caster
  levels (maximum of +5).
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 28, 2002
//:://////////////////////////////////////////////
//:: Updated by Andrew Nobbs May 09, 2003
//:: 2003-07-29: Rewritten, Georg Zoeller
/*
Patch 1.72
- the duration visual effect is no longer dispellable
Patch 1.70
- never auto-targetted any shield if cast at character (without armor)
- VFX added if cast on weapon on ground
*/

#include "70_inc_spells"
#include "x2_i0_spells"
#include "x2_inc_spellhook"

void AddACBonusToArmor(object oMyArmor, float fDuration, int nAmount)
{
    IPSafeAddItemProperty(oMyArmor,ItemPropertyACBonus(nAmount), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);
}

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_HOURS;
    spell.Limit = 5;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis = EffectVisualEffect(VFX_IMP_GLOBE_USE);
    effect eDur = ExtraordinaryEffect(EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE));

    int nDuration  = spell.Level;
    int nAmount = spell.Level/4;
    if (nAmount < 0)
    {
        nAmount = 1;
    }
    else if (nAmount > spell.Limit)
    {
        nAmount = spell.Limit;
    }

    object oMyArmor = IPGetTargetedOrEquippedArmor(TRUE);
    object oPossessor = GetItemPossessor(oMyArmor);

    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration * 2; //Duration is +100%
    }

    if(GetIsObjectValid(oMyArmor))
    {
        SignalEvent(oPossessor, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
        if(GetIsObjectValid(oPossessor))
        {
            DelayCommand(1.3, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oPossessor));
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, oPossessor, DurationToSeconds(nDuration));
        }
        else
        {
            DelayCommand(1.3, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, spell.Loc));
        }
        AddACBonusToArmor(oMyArmor, DurationToSeconds(nDuration), nAmount);
    }
    else
    {
        FloatingTextStrRefOnCreature(83826, spell.Caster);
    }
}
