//::///////////////////////////////////////////////
//:: Gedlee's Electric Loop
//:: X2_S0_ElecLoop
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    You create a small stroke of lightning that
    cycles through all creatures in the area of effect.
    The spell deals 1d6 points of damage per 2 caster
    levels (maximum 5d6). Those who fail their Reflex
    saves must succeed at a Will save or be stunned
    for 1 round.

    Spell is standard hostile, so if you use it
    in hardcore mode, it will zap yourself!

*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: Oct 19 2003
//:://////////////////////////////////////////////
/*
Patch 1.72

- in the rare case when 1 damage was rolled, spell tried to stun creature with
improved evasion who suceeded in first save
*/


#include "70_inc_spells"
#include "x2_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 6;
    spell.DamageCap = 5;
    spell.DamageType = DAMAGE_TYPE_ELECTRICAL;
    spell.Range = RADIUS_SIZE_SMALL;
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect   eStrike    = EffectVisualEffect(spell.DmgVfxS);
    float    fDelay;
    effect   eBeam;
    int      nDamage;
    int      nPotential;
    effect   eDam;
    object   oLastValid;
    effect   eStun = EffectLinkEffects(EffectVisualEffect(VFX_IMP_STUN),EffectStunned());

    //--------------------------------------------------------------------------
    // Calculate Damage Dice. 1d per 2 caster levels, max 5d
    //--------------------------------------------------------------------------
    int nNumDice = spell.Level/2;
    if (nNumDice<1)
    {
        nNumDice = 1;
    }
    else if (nNumDice > spell.DamageCap)
    {
        nNumDice = spell.DamageCap;
    }

    //--------------------------------------------------------------------------
    // Loop through all targets
    //--------------------------------------------------------------------------

    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE);
    while (GetIsObjectValid(oTarget))
    {
        if (spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
            spell.SavingThrow = SAVING_THROW_REFLEX;
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));

            //------------------------------------------------------------------
            // Calculate delay until spell hits current target. If we are the
            // first target, the delay is the time until the spell hits us
            //------------------------------------------------------------------
            if (GetIsObjectValid(oLastValid))
            {
                   fDelay += 0.2;
                   fDelay += GetDistanceBetweenLocations(GetLocation(oLastValid), GetLocation(oTarget))/20;
            }
            else
            {
                fDelay = GetDistanceBetweenLocations(spell.Loc, GetLocation(oTarget))/20;
            }

            //------------------------------------------------------------------
            // If there was a previous target, draw a lightning beam between us
            // and iterate delay so it appears that the beam is jumping from
            // target to target
            //------------------------------------------------------------------
            if (GetIsObjectValid(oLastValid))
            {
                 eBeam = EffectBeam(VFX_BEAM_LIGHTNING, oLastValid, BODY_NODE_CHEST);
                 DelayCommand(fDelay,ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBeam,oTarget,1.5));
            }

            if (!MyResistSpell(spell.Caster, oTarget, fDelay))
            {

                nPotential = MaximizeOrEmpower(spell.Dice, nNumDice, spell.Meta)+2;//workaround for the 1dmg issue
                nDamage    = GetSavingThrowAdjustedDamage(nPotential, oTarget, spell.DC, spell.SavingThrow, spell.SaveType, spell.Caster);

                //--------------------------------------------------------------
                // If we failed the reflex save, we save vs will or are stunned
                // for one round
                //--------------------------------------------------------------
                if (nDamage > 0 && (nDamage == nPotential || GetHasFeat(FEAT_IMPROVED_EVASION,oTarget)))
                {
                    spell.SavingThrow = SAVING_THROW_WILL;
                    if(!MySavingThrow(spell.SavingThrow, oTarget, spell.DC, SAVING_THROW_TYPE_MIND_SPELLS, spell.Caster, fDelay))
                    {
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eStun,oTarget, RoundsToSeconds(1)));
                    }

                }

                nDamage = nDamage == nPotential ? nDamage-2 : nDamage-1;//workaround for the 1dmg issue

                if (nDamage > 0)
                {
                    eDam = EffectDamage(nDamage, spell.DamageType);
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eStrike, oTarget));
                }
            }
            //------------------------------------------------------------------
            // Store Target to make it appear that the lightning bolt is jumping
            // from target to target
            //------------------------------------------------------------------
            oLastValid = oTarget;
        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE);
    }
}
