//::///////////////////////////////////////////////
//:: Tensor's Transformation
//:: NW_S0_TensTrans.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Gives the caster the following bonuses:
        +1 Attack per 2 levels
        +4 Natural AC
        20 STR and DEX and CON
        1d6 Bonus HP per level
        +5 on Fortitude Saves
        -10 Intelligence
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 26, 2001
//:://////////////////////////////////////////////
//: Sep2002: losing hit-points won't get rid of the rest of the bonuses
/*
Patch 1.72

- fixed nonfunctional spell overrides
- fixed losing polymorph bonuses when repolymorph happens
- fixed not losing temp HPs when the polymorph was canceled
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "70_inc_shifter"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;

    if (!X2PreSpellCastCode())
    {
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    //----------------------------------------------------------------------------
    // GZ, Nov 3, 2003
    // There is a serious problems with creatures turning into unstoppable killer
    // machines when affected by tensors transformation. NPC AI can't handle that
    // spell anyway, so I added this code to disable the use of Tensors by any
    // NPC.
    //----------------------------------------------------------------------------
    if (!GetIsPC(spell.Target) && !GetLocalInt(spell.Target,"70_ALLOW_SHAPECHANGE"))
    {
        WriteTimestampedLogEntry(GetName(spell.Target) + "[" + GetTag (spell.Target) +"] tried to cast Tensors Transformation. Bad! Remove that spell from the creature");
        return;
    }
    int nDuration = spell.Level;
    //Determine bonus HP
    int nHP = MaximizeOrEmpower(6,spell.Level,spell.Meta);

    //Metamagic
    if(spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration *= 2;
    }
    //Declare effects
    effect eAttack = EffectAttackIncrease(spell.Level/2);
    effect eSave = EffectSavingThrowIncrease(SAVING_THROW_FORT, 5);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eSwing = EffectModifyAttacks(2);

    effect eLink = EffectLinkEffects(eAttack, eSave);
    eLink = EffectLinkEffects(eLink, eDur);
    eLink = EffectLinkEffects(eLink, eSwing);
    effect eHP = EffectTemporaryHitpoints(nHP);
    effect eVis = EffectVisualEffect(VFX_IMP_SUPER_HEROISM);

    //Signal Spell Event
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eHP, spell.Target, DurationToSeconds(nDuration));
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
    //1.72: new polymorph engine - handles all the magic around polymorph automatically now
    ApplyPolymorph(spell.Target, POLYMORPH_TYPE_DOOM_KNIGHT, SUBTYPE_MAGICAL, DurationToSeconds(nDuration));
}
