//::///////////////////////////////////////////////
//:: Word of Faith
//:: [NW_S0_WordFaith.nss]
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    A 30ft blast of divine energy rushs out from the
    Cleric blasting all enemies with varying effects
    depending on their HD.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Feb 5, 2001
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk, On: April 11, 2001
//:: Sep 2002: fixed the 'level 8' instantkill problem
//:: description is slightly inaccurate but I won't change it
//:: Georg: It's nerf time! oh yes. The spell now matches it's description.

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Range = RADIUS_SIZE_COLOSSAL;
    spell.SavingThrow = SAVING_THROW_NONE;
    spell.TargetType = SPELL_TARGET_SELECTIVEHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eBlind = EffectBlindness();
    effect eStun = EffectStunned();
    effect eConfuse = EffectConfused();
    effect eDeath = EffectDeath();
    effect eVis = EffectVisualEffect(VFX_IMP_DEATH);
    effect eSmite = EffectVisualEffect(VFX_FNF_WORD);
    effect eSonic = EffectVisualEffect(VFX_IMP_SONIC);
    effect eUnsummon =  EffectVisualEffect(VFX_IMP_UNSUMMON);
    effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eImmune = EffectVisualEffect(VFX_IMP_MAGIC_RESISTANCE_USE);
    effect eKill;
    effect eLink;
    int nHD;
    float fDelay;
    int nDuration = spell.Level/2;
    //Apply the FNF VFX impact to the target location
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eSmite, spell.Loc);
    //Get the first target in the spell area
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    while (GetIsObjectValid(oTarget))
    {
        //Make a faction check
        if (spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
            fDelay = GetRandomDelay(0.5, 2.0);
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            //Make SR check                                     //1.72: this will do nothing by default, but allows to dynamically enforce saving throw
            if(!MyResistSpell(spell.Caster, oTarget, fDelay) && !MySavingThrow(spell.SavingThrow, oTarget, spell.DC, SAVING_THROW_TYPE_DIVINE, spell.Caster))
            {
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eSonic, oTarget);
                //----------------------------------------------------------
                //Check if the target is an outsider
                //GZ: And do nothing anymore. This was not supposed to happen
                //----------------------------------------------------------
                /*if (GetRacialType(oTarget) == RACIAL_TYPE_OUTSIDER || GetRacialType(oTarget) == RACIAL_TYPE_ELEMENTAL)
                {
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eUnsummon, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget));
                }*/

                ///----------------------------------------------------------
                // And this is the part where the divine power smashes the
                // unholy summoned creature and makes it return to its homeplane
                //----------------------------------------------------------
                if (GetIsObjectValid(GetMaster(oTarget)))
                {
                    if (GetAssociateType(oTarget) == ASSOCIATE_TYPE_SUMMONED)
                    {
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eUnsummon, oTarget));
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, SupernaturalEffect(eDeath), oTarget));//simplified
                    }
                }
                else
                {
                    //Check the HD of the creature
                    nHD = GetHitDice(oTarget);
                    //Apply the appropriate effects based on HD
                    if (nHD >= 12)//no saving throw, very powerful
                    {
                        eLink = EffectLinkEffects(eBlind, eDur);
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBlind, oTarget, RoundsToSeconds(nDuration)));
                    }
                    else if (nHD >= 8 && nHD < 12)
                    {
                        eLink = EffectLinkEffects(eStun, eMind);
                        eLink = EffectLinkEffects(eLink, eDur);
                        eLink = EffectLinkEffects(eLink, eBlind);

                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nDuration)));
                    }
                    else if (nHD > 4 && nHD < 8)
                    {
                        eLink = EffectLinkEffects(eStun, eMind);
                        eLink = EffectLinkEffects(eLink, eDur);
                        eLink = EffectLinkEffects(eLink, eConfuse);
                        eLink = EffectLinkEffects(eLink, eBlind);

                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nDuration)));
                    }
                    else
                    {
                        if(!GetIsImmune(oTarget, IMMUNITY_TYPE_DEATH, spell.Caster))
                        {
                            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                        }
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget));
                    }
                }
            }
        }
        //Get the next target in the spell area
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    }
}
