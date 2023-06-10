//::///////////////////////////////////////////////
//:: Sunburst
//:: X0_S0_Sunburst
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
// Brilliant globe of heat
// All creatures in the globe are blinded and
// take 6d6 damage
// Undead creatures take 1d6 damage (max 25d6)
// The blindness is permanent unless cast to remove it
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: July 23 2002
//:://////////////////////////////////////////////
//:: Last Updated By: Andrew Nobbs May 14, 2003
//:: Notes: Changed damage to non-undead to 6d6
//:: 2003-10-09: GZ Added Subrace check for vampire special case, bugfix
/*
Patch 1.72
- fixed a minor 1.71 bug that didn't print kill feedback in case this spell slayed vampire
Patch 1.71
- fixed Arcane Defense feat not working against this spell
- was missing delay in few effect applications
- was missing VFXs in few cases
- killing method could fail in special case (magic damage immune/resistant vampire)
- removed second and third save - all effects are now tied with first save
- oozes and plants takes full damage as if they were undead
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 6;
    spell.DamageCap = 25;//max 25d6 damage
    spell.DamageType = DAMAGE_TYPE_MAGICAL;
    spell.Range = RADIUS_SIZE_COLOSSAL;
    spell.SaveType = SAVING_THROW_TYPE_NONE;
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.TargetType = SPELL_TARGET_SELECTIVEHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nCasterLvl = spell.Level;
    int nDamage;
    int nOrgDam;
    int nNumDice;
    float fDelay;
    effect eDeath = SupernaturalEffect(EffectDeath(FALSE,TRUE));
    effect eBlindness = EffectBlindness();
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink = EffectLinkEffects(eBlindness, eDur);
    effect eExplode = EffectVisualEffect(VFX_IMP_SUNSTRIKE);
    effect eVis = EffectVisualEffect(VFX_IMP_HEAD_HOLY);
    effect eHitVis = EffectVisualEffect(VFX_IMP_DIVINE_STRIKE_FIRE);
    effect eLOS = EffectVisualEffect(VFX_FNF_LOS_HOLY_30);
    effect eDam;
    //Limit Caster level for the purposes of damage
    if (nCasterLvl > spell.DamageCap)
    {
        nCasterLvl = spell.DamageCap;
    }
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Caster);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eLOS, spell.Loc);

    //Declare the spell shape, size and the location.  Capture the first target object in the shape.
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE);
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while (GetIsObjectValid(oTarget))
    {
        if (spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
        {
            fDelay = GetRandomDelay();//random delay so each target gets hit in different moment
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, spell.Id));
            //This visual effect is applied to the target object not the location as above.  This visual effect
            //represents the flame that erupts on the target not on the ground.
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eHitVis, oTarget);

            if (!MyResistSpell(spell.Caster, oTarget, fDelay))
            {
                //Check if the target is an undead, ooze or plant
                if(spellsIsRacialType(oTarget, RACIAL_TYPE_UNDEAD) || spellsIsRacialType(oTarget, RACIAL_TYPE_OOZE) || FindSubString(GetStringLowerCase(GetSubRace(oTarget)),"plant") > -1)
                {
                    nNumDice = nCasterLvl;
                }
                else if(spellsIsLightVulnerable(oTarget))
                {
                    nNumDice = 12;
                }
                else
                {
                    nNumDice = 6;
                }
                //Roll damage for each target
                nOrgDam = MaximizeOrEmpower(spell.Dice,nNumDice,spell.Meta);
                //Get the adjusted damage due to Reflex Save, Evasion or Improved Evasion
                nDamage = GetSavingThrowAdjustedDamage(nOrgDam, oTarget, spell.DC, spell.SavingThrow, spell.SaveType, spell.Caster);
                //saving throw wasn't successful
                if(nDamage > 0 && (nDamage == nOrgDam || GetHasFeat(FEAT_IMPROVED_EVASION,oTarget)))
                {
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget));
                    if(spellsIsRacialType(oTarget, RACIAL_TYPE_UNDEAD) && spellsIsLightVulnerable(oTarget))
                    {   //vampires are destroyed
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget));
                    }
                }
                if(nDamage > 0)
                {
                    //Set the damage effect
                    eDam = EffectDamage(nDamage, spell.DamageType);
                    // Apply effects to the currently selected target.
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eExplode, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                }
           }
       }
       //Select the next target within the spell shape.
       oTarget = GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE, OBJECT_TYPE_CREATURE);
    }
}
