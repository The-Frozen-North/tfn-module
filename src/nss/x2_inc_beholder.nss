//::///////////////////////////////////////////////
//:: Beholder AI and Attack Include
//:: x2_inc_beholder
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*

    Include file for several beholder functions

*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: August, 2003
//:://////////////////////////////////////////////
/*
Patch 1.71

- targetting routine rewritten from scratch to work better in multiplayer
- fear ray now gives fear not damage
- missed rays will be visible now
*/

#include "x0_i0_spells"

const int BEHOLDER_RAY_DEATH = 1;
const int BEHOLDER_RAY_TK = 2;
const int BEHOLDER_RAY_PETRI= 3;
const int BEHOLDER_RAY_CHARM = 4;
const int BEHOLDER_RAY_SLOW = 5;
const int BEHOLDER_RAY_WOUND = 6;
const int BEHOLDER_RAY_FEAR = 7;

struct beholder_target_struct
{
        object oTarget1;
        int nRating1;
        object oTarget2;
        int nRating2;
        object oTarget3;
        int nRating3;
        int nCount;
};



int   GetAntiMagicRayMakesSense ( object oTarget );
void  OpenAntiMagicEye          ( object oTarget );
void  CloseAntiMagicEye         ( object oTarget );
int   BehGetTargetThreatRating  ( object oTarget );
int   BehDetermineHasEffect     ( int nRay, object oCreature );
void  BehDoFireBeam             ( int nRay, object oTarget );

struct beholder_target_struct GetRayTargets ( object oTarget );

int GetAntiMagicRayMakesSense(object oTarget)
{
    // don't proceed if they don't have enough uses - pok
    if (GetHasSpell(727) < 1) return FALSE;

    int bRet = TRUE;
    int nType;

    effect eTest = GetFirstEffect(oTarget);

    if (!GetIsEffectValid(eTest))
    {
      int nMag = GetLevelByClass(CLASS_TYPE_WIZARD,oTarget) + GetLevelByClass(CLASS_TYPE_SORCERER,oTarget) + GetLevelByClass(CLASS_TYPE_BARD,oTarget) + GetLevelByClass(CLASS_TYPE_RANGER,oTarget) + GetLevelByClass(CLASS_TYPE_PALADIN,oTarget)+ GetLevelByClass(CLASS_TYPE_CLERIC,oTarget)+ GetLevelByClass(CLASS_TYPE_DRUID,oTarget);
      // at least 3 levels of magic user classes... we better use anti magic anyway
      if (nMag < 4)
      {
        bRet = FALSE;
      }
    }
    else
    {
        while (GetIsEffectValid(eTest) && bRet == TRUE )
        {
            nType = GetEffectType(eTest);
            if (nType == EFFECT_TYPE_STUNNED || nType == EFFECT_TYPE_PARALYZE  ||
                nType == EFFECT_TYPE_SLEEP || nType == EFFECT_TYPE_PETRIFY  ||
                nType == EFFECT_TYPE_CHARMED  || nType == EFFECT_TYPE_CONFUSED ||
                nType == EFFECT_TYPE_FRIGHTENED || nType == EFFECT_TYPE_SLOW )
            {
                bRet = FALSE;
            }

            eTest = GetNextEffect(oTarget);
        }
    }

    if (GetHasSpellEffect(727,oTarget)) // already antimagic
    {
        bRet = FALSE;
    }

    return bRet;
}


void OpenAntiMagicEye (object oTarget)
{
   if (GetAntiMagicRayMakesSense(oTarget))
   {
        ActionCastSpellAtObject(727 , GetSpellTargetObject(),METAMAGIC_ANY,FALSE,0, PROJECTILE_PATH_TYPE_DEFAULT,TRUE);
   }
}

// being a badass beholder, we close our antimagic eye only to attack with our eye rays
// and then reopen it...
void CloseAntiMagicEye(object oTarget)
{
    RemoveSpellEffects (727,OBJECT_SELF,oTarget);
}


// stacking protection
int BehDetermineHasEffect(int nRay, object oCreature)
{
  switch (nRay)
  {
      case BEHOLDER_RAY_FEAR :      if (GetHasEffect(EFFECT_TYPE_FRIGHTENED,oCreature))
                                        return TRUE;

      case BEHOLDER_RAY_DEATH :     if (GetIsDead(oCreature))
                                        return TRUE;

      case BEHOLDER_RAY_CHARM:      if (GetHasEffect(EFFECT_TYPE_CHARMED,oCreature))
                                        return TRUE;

      case BEHOLDER_RAY_SLOW:       if (GetHasEffect(EFFECT_TYPE_SLOW,oCreature))
                                        return TRUE;

      case BEHOLDER_RAY_PETRI:      if (GetHasEffect(EFFECT_TYPE_PETRIFY,oCreature))
                                        return TRUE;
  }
    return FALSE;
}


int BehGetTargetThreatRating(object oTarget)
{
    if (oTarget == OBJECT_INVALID)
    {
        return 0;
    }

    int nRet = 20;

    if (GetDistanceBetween(oTarget,OBJECT_SELF) <5.0f)
    {
        nRet += 3;
    }

    nRet += (GetHitDice(oTarget)-GetHitDice(OBJECT_SELF) /2);

    if (GetPlotFlag(oTarget)) //
    {
        nRet -= 6 ;
    }

    if (GetMaster(oTarget)!= OBJECT_INVALID)
    {
        nRet -= 4;
    }

    if (GetHasEffect(EFFECT_TYPE_PETRIFY,oTarget))
    {
        nRet -=10;
    }

    if (GetIsDead(oTarget))
    {
        nRet = 0;
    }

    return nRet;

}

struct beholder_target_struct GetRayTargets(object oTarget)
{
    struct beholder_target_struct stRet;
    int nTh = 1;

    object oEnemy = GetNearestCreature(CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY,OBJECT_SELF,1,CREATURE_TYPE_PERCEPTION,PERCEPTION_SEEN,CREATURE_TYPE_DOES_NOT_HAVE_SPELL_EFFECT,SPELL_ETHEREALNESS);
    while(GetIsObjectValid(oEnemy))
    {
        if(!GetIsDead(oEnemy))
        {
            stRet.nCount+= 1;
            switch(stRet.nCount)
            {
            case 1:
                stRet.oTarget1 = oEnemy;
                stRet.nRating1 = BehGetTargetThreatRating(oEnemy);
            break;
            case 2:
                stRet.oTarget2 = oEnemy;
                stRet.nRating2 = BehGetTargetThreatRating(oEnemy);
            break;
            case 3:
                stRet.oTarget3 = oEnemy;
                stRet.nRating3 = BehGetTargetThreatRating(oEnemy);
            break;
            }
        }
        oEnemy = GetNearestCreature(CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY,OBJECT_SELF,++nTh,CREATURE_TYPE_PERCEPTION,PERCEPTION_SEEN,CREATURE_TYPE_DOES_NOT_HAVE_SPELL_EFFECT,SPELL_ETHEREALNESS);
    }
    return stRet;
}


void BehDoFireBeam(int nRay, object oTarget)
{
    // don't use a ray if the target already has that effect
    if (BehDetermineHasEffect(nRay,oTarget))
    {
        return;
    }

    int bHit   = TouchAttackRanged(oTarget,TRUE)>0;
    int nProj;
    switch (nRay)
    {
        case BEHOLDER_RAY_DEATH: nProj = 776;
                            break;
        case BEHOLDER_RAY_TK:    nProj = 777;
                            break;
        case BEHOLDER_RAY_PETRI: nProj = 778;
                            break;
        case BEHOLDER_RAY_CHARM: nProj = 779;
                            break;
        case BEHOLDER_RAY_SLOW:  nProj = 780;
                            break;
        case BEHOLDER_RAY_WOUND: nProj = 783;
                            break;
        case BEHOLDER_RAY_FEAR:  nProj = 784;//1.71: spell constant corrected
                            break;
    }

    if (bHit)
    {
         ActionCastSpellAtObject(nProj,oTarget,METAMAGIC_ANY,TRUE,0,PROJECTILE_PATH_TYPE_DEFAULT,TRUE);
    }
    else
    {
        location lFail = GetLocation(oTarget);
        vector vFail = GetPositionFromLocation(lFail);

        if (GetDistanceBetween(OBJECT_SELF,oTarget) > 6.0f)
        {

           vFail.x += IntToFloat(Random(3)) - 1.5;
           vFail.y += IntToFloat(Random(3)) - 1.5;
           vFail.z += IntToFloat(Random(2));
           lFail = Location(GetArea(oTarget),vFail,0.0f);

        }
        //----------------------------------------------------------------------
        // if we are fairly near, calculating a location could cause us to
        // spin, so we use the same location all the time
        //----------------------------------------------------------------------
        else
        {
              vFail.z += 0.8;
              vFail.y += 0.2;
              vFail.x -= 0.2;
        }
        //1.71: changed to real spell as fake spells cannot be cast instantly
        ActionCastSpellAtLocation(nProj,lFail,METAMAGIC_ANY,TRUE,PROJECTILE_PATH_TYPE_DEFAULT,TRUE);
    }
}
