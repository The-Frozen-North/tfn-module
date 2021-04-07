//::///////////////////////////////////////////////
//:: Undeath to Death
//:: X2_S0_Undeath
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*

  This spell slays 1d4 HD worth of undead creatures
  per caster level (maximum 20d4). Creatures with
  the fewest HD are affected first;

*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On:  August 13,2003
//:://////////////////////////////////////////////
/*
Patch 1.72
- fixed a minor 1.71 bug that didn't print kill feedback on destroyed undeads
Patch 1.70
- line of sight wasn't checked, spell now doesn't affect creatures behind walls
- saving throw check occured before SR check
- maximized version of this spell wasn't properly capped
- spell affected the most distant creatures first instead of nearest
- killing method could fail in special case (divine damage immune/resistant undead)
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_toollib"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Range = 20.0;
    spell.DamageCap = 20;
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    // Impact VFX
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_STRIKE_HOLY), spell.Loc);
    TLVFXPillar(VFX_FNF_LOS_HOLY_20, spell.Loc, 3, 0.0);
    effect eDeath = SupernaturalEffect(EffectDeath(FALSE,TRUE));
    effect eVis = EffectVisualEffect(VFX_IMP_DEATH);

    // calculation
    int nLevel = spell.Level;
    if (nLevel > spell.DamageCap)
    {
        nLevel = spell.DamageCap;
    }

    int nLow = 9999;
    object oLow;
    // calculate number of hitdice affected with proper metamagic bonuses
    int nHDLeft = MaximizeOrEmpower(4,nLevel,spell.Meta);
    float fDelay;
    int nCurHD;
    object oFirst = FIX_GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);

    // Only start loop if there is a creature in the area of effect
    if(GetIsObjectValid(oFirst))
    {
        object oTarget = oFirst;
        while (GetIsObjectValid(oTarget) && nHDLeft > 0)
        {
            if (spellsIsRacialType(oTarget, RACIAL_TYPE_UNDEAD))
            {
                nCurHD = GetHitDice(oTarget);
                if (nCurHD <= nHDLeft)
                {
                    // ignore creatures already affected
                    if(GetLocalInt(oTarget,"X2_EBLIGHT_I_AM_DEAD") == 0 && !GetPlotFlag(oTarget) && !GetIsDead(oTarget))
                    {
                        if(spellsIsTarget(oTarget, spell.TargetType, spell.Caster))
                        {
                            // store the creature with the lowest HD
                            if (GetHitDice(oTarget) < nLow)//remove <= in order to affect nearest first
                            {
                                nLow = GetHitDice(oTarget);
                                oLow = oTarget;
                            }
                        }
                    }
                }
            }

            // Get next target
            oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);

            // End of cycle, time to kill the lowest creature
            if (!GetIsObjectValid(oTarget))
            {
                // we have a valid lowest creature we can affect with the remaining HD
                if (GetIsObjectValid(oLow) && nHDLeft >= nLow)
                {
                    SignalEvent(oLow, EventSpellCastAt(spell.Caster, spell.Id));
                    SetLocalInt(oLow, "X2_EBLIGHT_I_AM_DEAD", TRUE);
                    //scale delay by distance from epicenter
                    fDelay = GetDelayByRange(0.2,1.4,GetDistanceBetweenLocations(spell.Loc, GetLocation(oLow)),spell.Range);
                    if(!MyResistSpell(spell.Caster, oLow, fDelay))
                    {
                       if(!MySavingThrow(spell.SavingThrow,oLow,spell.DC,SAVING_THROW_TYPE_NONE,spell.Caster,fDelay))
                       {
                           DelayCommand(fDelay+0.5,ApplyEffectToObject(DURATION_TYPE_INSTANT,eDeath,oLow));
                           DelayCommand(fDelay,ApplyEffectToObject(DURATION_TYPE_INSTANT,eVis,oLow));
                       }
                       else
                       {
                           DelayCommand(0.1,DeleteLocalInt(oLow,"X2_EBLIGHT_I_AM_DEAD"));
                       }
                    }
                    else
                    {//1.0 was too long, if there would be two casters casting in the same moment, it could cause errors
                          DelayCommand(0.1,DeleteLocalInt(oLow,"X2_EBLIGHT_I_AM_DEAD"));
                    }
                    // decrement remaining HD
                    nHDLeft -= nLow;
                    // restart the loop
                    oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc, TRUE);
                }
                // reset counters
                oLow = OBJECT_INVALID;
                nLow = 9999;
            }
        }
    }
}
