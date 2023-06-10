//::///////////////////////////////////////////////
//:: Sunbeam
//:: s_Sunbeam.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
//:: All creatures in the beam are struck blind and suffer 4d6 points of damage. (A successful
//:: Reflex save negates the blindness and reduces the damage by half.) Creatures to whom sunlight
//:: is harmful or unnatural suffer double damage.
//::
//:: Undead creatures caught within the ray are dealt 1d6 points of damage per caster level
//:: (maximum 20d6), or half damage if a Reflex save is successful. In addition, the ray results in
//:: the total destruction of undead creatures specifically affected by sunlight if they fail their saves.
//:://////////////////////////////////////////////
//:: Created By: Keith Soleski
//:: Created On: Feb 22, 2001
//:://////////////////////////////////////////////
//:: Last Modified By: Keith Soleski, On: March 21, 2001
//:: VFX Pass By: Preston W, On: June 25, 2001
/*
Patch 1.71

- second save at DC 0 removed
- damage wasn't properly calculated in case that there would be both undead and
non-undead creatures in AoE
- oozes and plants takes full damage as if they were undead
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DamageCap = 20;
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_DIVINE;
    spell.Range = RADIUS_SIZE_COLOSSAL;
    spell.SaveType = SAVING_THROW_TYPE_DIVINE;
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis = EffectVisualEffect(VFX_IMP_DEATH);
    effect eVis2 = EffectVisualEffect(VFX_IMP_SUNSTRIKE);
    effect eStrike = EffectVisualEffect(VFX_FNF_SUNBEAM);
    effect eDam;
    effect eBlind = EffectBlindness();
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink = EffectLinkEffects(eBlind, eDur);

    int nCasterLevel = spell.Level;
    int nDamage;
    int nOrgDam;
    int nNumDice;
    float fDelay;
    int nBlindLength = 3;
    //Limit caster level
    if (nCasterLevel > spell.DamageCap)
    {
        nCasterLevel = spell.DamageCap;
    }
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eStrike, spell.Loc);
    //Get the first target in the spell area
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    while(GetIsObjectValid(oTarget))
    {
        // Make a faction check
        if (spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
            fDelay = GetRandomDelay(1.0, 2.0);
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            //Make an SR check
            if (!MyResistSpell(spell.Caster, oTarget, fDelay))
            {
                //Check if the target is an undead, ooze or plant
                if(spellsIsRacialType(oTarget, RACIAL_TYPE_UNDEAD) || spellsIsRacialType(oTarget, RACIAL_TYPE_OOZE) || FindSubString(GetStringLowerCase(GetSubRace(oTarget)),"plant") > -1)
                {
                    nNumDice = nCasterLevel;
                }
                else if(spellsIsLightVulnerable(oTarget))
                {
                    nNumDice = 6;
                }
                else
                {
                    nNumDice = 3;
                }
                //Do metamagic checks
                nOrgDam = MaximizeOrEmpower(spell.Dice,nNumDice,spell.Meta);

                //Get the adjusted damage due to Reflex Save, Evasion or Improved Evasion
                nDamage = GetSavingThrowAdjustedDamage(nOrgDam, oTarget, spell.DC, spell.SavingThrow, spell.SaveType, spell.Caster);
                //saving throw wasn't successful
                if(nDamage > 0 && (nDamage == nOrgDam || GetHasFeat(FEAT_IMPROVED_EVASION,oTarget)))
                {
                    DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nBlindLength)));
                }
                if(nDamage > 0)
                {
                    //Set damage effect
                    eDam = EffectDamage(nDamage, spell.DamageType);
                    //Apply the damage effect and VFX impact
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                }
            }
        }
        //Get the next target in the spell area
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
    }
}
