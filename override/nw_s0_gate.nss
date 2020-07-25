//::///////////////////////////////////////////////
//:: Gate
//:: NW_S0_Gate.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
//:: Summons a Balor to fight for the caster.
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: April 12, 2001
//:://////////////////////////////////////////////
/*
Patch 1.71

- NPC casters will always summon balor using EffectSummon from AI implementation reasons
*/
void CreateBalor(location lLoc);

#include "70_inc_spells"
#include "x2_inc_spellhook"

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
    int nDuration = spell.Level;
    effect eSummon;
    effect eVis = EffectVisualEffect(VFX_FNF_SUMMON_GATE);
    //Make metamagic extend check
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2;   //Duration is +100%
    }
    //Summon the Balor and apply the VFX impact
    //ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, GetSpellTargetLocation());

    if(GetHasSpellEffect(SPELL_PROTECTION_FROM_EVIL) ||
       GetHasSpellEffect(SPELL_MAGIC_CIRCLE_AGAINST_EVIL) ||
       GetHasSpellEffect(SPELL_HOLY_AURA))
    {
        eSummon = EffectSummonCreature("NW_S_BALOR",VFX_FNF_SUMMON_GATE,3.0);
        DelayCommand(3.0, ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eSummon, spell.Loc, DurationToSeconds(nDuration)));
    }
    else if(!GetIsPC(spell.Caster))
    {
        eSummon = EffectSummonCreature("NW_S_BALOR_EVIL",VFX_FNF_SUMMON_GATE,3.0);
        DelayCommand(3.0, ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eSummon, spell.Loc, DurationToSeconds(nDuration)));
    }
    else
    {
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, spell.Loc);
        DelayCommand(3.0, CreateBalor(spell.Loc));
    }
}

void CreateBalor(location lLoc)
{
    object oBalor = CreateObject(OBJECT_TYPE_CREATURE, "NW_S_BALOR_EVIL", lLoc);
    DestroyObject(oBalor,60.0);
    effect e = EffectVisualEffect(VFX_IMP_UNSUMMON);
    DelayCommand(59.5,ApplyEffectAtLocation(DURATION_TYPE_INSTANT,e,GetLocation(oBalor)));
}
