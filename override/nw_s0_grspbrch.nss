//::///////////////////////////////////////////////
//:: Greater Spell Breach
//:: NW_S0_GrSpBrch.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Removes 4 spell defenses from an enemy mage.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 7, 2002
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.SR = NO;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    effect eSR = EffectSpellResistanceDecrease(5);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

    effect eVis = EffectVisualEffect(VFX_IMP_BREACH);
    int nCnt, nIdx, nSpell;
    string sFeedback = "<cÍþ>"+GetStringByStrRef(13623)+"</c> : <c›þþ>"+GetName(spell.Target)+"</c> : <cÍþ>";
    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        //1.72: this will do nothing by default, but allows to dynamically enforce spell resistance
        if (spell.SR != YES || !MyResistSpell(spell.Caster, spell.Target))
        {
            //Search through and remove protections.
            while(nCnt <= NW_I0_SPELLS_MAX_BREACH && nIdx < 4)
            {
                nSpell = GetSpellBreachProtection(nCnt);
                if(RemoveProtections(nSpell, spell.Target, nCnt))
                {
                    nIdx++;
                    sFeedback+= GetStringByStrRef(StringToInt(Get2DAString("spells","Name",nSpell)))+", ";
                }
                nCnt++;
            }
            if(nIdx > 0)
            {
                if(GetIsPC(spell.Target))
                {
                    sFeedback = GetStringLeft(sFeedback,GetStringLength(sFeedback)-2)+"</c>";
                    SendMessageToPC(spell.Target,sFeedback);
                }
            }
            effect eLink = EffectLinkEffects(eDur, eSR);
            //--------------------------------------------------------------------------
            // This can not be dispelled
            //--------------------------------------------------------------------------
            eLink = ExtraordinaryEffect(eLink);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(10));
        }
    }
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
}
