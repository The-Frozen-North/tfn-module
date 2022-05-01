//::///////////////////////////////////////////////
//:: x2_s1_beholdatt
//:: Beholder Attack Spell Logic
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*

    This spellscript is the core of the beholder's
    attack logic.

*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: 2003-08-28
//:://////////////////////////////////////////////
/*
Patch 1.71

- added G'Zhorb appearance to the list of appearances that can use antimagic eye (dispell)
- any custom creature with beholder antimagic cone will be also able to use antimagic eye
- targetting improved, script now handles multiple targets properly and ignore dead players
- randomization fixed, in some cases the script was trying to randomize rays fired on targets,
due to the bug this however never happened
*/

#include "x2_inc_beholder"

//1.71 private function
object GetNthRayTarget(object oEmergencyTarget, int nTh)
{
int n = 1;
int nEnemy;
object oEnemy = GetNearestCreature(CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY,OBJECT_SELF,1,CREATURE_TYPE_PERCEPTION,PERCEPTION_SEEN,CREATURE_TYPE_DOES_NOT_HAVE_SPELL_EFFECT,SPELL_ETHEREALNESS);
 while(GetIsObjectValid(oEnemy))
 {
  if(!GetIsDead(oEnemy))
  {
   if(++nEnemy >= nTh)
   {
   return oEnemy;
   }
  }
 oEnemy = GetNearestCreature(CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY,OBJECT_SELF,++n,CREATURE_TYPE_PERCEPTION,PERCEPTION_SEEN,CREATURE_TYPE_DOES_NOT_HAVE_SPELL_EFFECT,SPELL_ETHEREALNESS);
 }
return oEmergencyTarget;
}

void main()
{
    int nApp = GetAppearanceType(OBJECT_SELF);
    object oTarget = GetSpellTargetObject();
    // Only if we are beholders and not beholder mages
 /*
    //* GZ: cut whole immunity thing because it was causing too much trouble
     if (nApp == 472 ||nApp == 401 || nApp == 403)
    {
        CloseAntiMagicEye(oTarget);
    }
  */

    // need that to make them not drop out of combat
    SignalEvent(oTarget,EventSpellCastAt(OBJECT_SELF,GetSpellId()));

    struct beholder_target_struct stTargets = GetRayTargets(oTarget);
    int nRay;
    if (stTargets.nCount ==0)
    {
        //emergency fallback
            BehDoFireBeam(BEHOLDER_RAY_SLOW,oTarget);
            BehDoFireBeam(BEHOLDER_RAY_DEATH,oTarget);
            BehDoFireBeam(BEHOLDER_RAY_FEAR,oTarget);
            BehDoFireBeam(BEHOLDER_RAY_TK,oTarget);
    }
    else if (stTargets.nCount ==1) // AI for only one target
    {
        if (d2()==1)
        {
            BehDoFireBeam(BEHOLDER_RAY_SLOW,stTargets.oTarget1);
            BehDoFireBeam(BEHOLDER_RAY_FEAR,stTargets.oTarget1);
            if (d2()==1)
                BehDoFireBeam(BEHOLDER_RAY_DEATH,stTargets.oTarget1);
        }
        else
        {
            BehDoFireBeam(BEHOLDER_RAY_WOUND,stTargets.oTarget1);
            BehDoFireBeam(BEHOLDER_RAY_TK,stTargets.oTarget1);
            if (d2()==1)
                BehDoFireBeam(BEHOLDER_RAY_PETRI,stTargets.oTarget1);
        }
        if (d3()==1)
        {
            BehDoFireBeam(BEHOLDER_RAY_CHARM,stTargets.oTarget2);
        }
    }
    else if (stTargets.nCount ==2)
    {
        if (d2()==1)
        {
            BehDoFireBeam(BEHOLDER_RAY_SLOW,stTargets.oTarget1);
            if (d2()==1)
                BehDoFireBeam(BEHOLDER_RAY_DEATH,stTargets.oTarget1);
            BehDoFireBeam(BEHOLDER_RAY_FEAR,stTargets.oTarget1);
            BehDoFireBeam(BEHOLDER_RAY_WOUND,stTargets.oTarget2);
            BehDoFireBeam(BEHOLDER_RAY_TK,stTargets.oTarget2);
            if (d2()==1)
                BehDoFireBeam(BEHOLDER_RAY_PETRI,stTargets.oTarget2);
            BehDoFireBeam(BEHOLDER_RAY_CHARM,stTargets.oTarget2);
        }
        else
        {
            BehDoFireBeam(BEHOLDER_RAY_WOUND,stTargets.oTarget1);
            BehDoFireBeam(BEHOLDER_RAY_TK,stTargets.oTarget1);
            if (d2()==1)
                BehDoFireBeam(BEHOLDER_RAY_PETRI,stTargets.oTarget1);
            BehDoFireBeam(BEHOLDER_RAY_SLOW,stTargets.oTarget2);
            if (d2()==1)
                BehDoFireBeam(BEHOLDER_RAY_DEATH,stTargets.oTarget2);
            BehDoFireBeam(BEHOLDER_RAY_FEAR,stTargets.oTarget2);
        }
    }
    else if (stTargets.nCount ==3)
    {
       if (d2()==1)
       {
            if (d2()==1)
                BehDoFireBeam(BEHOLDER_RAY_DEATH,stTargets.oTarget1);
            BehDoFireBeam(BEHOLDER_RAY_SLOW,stTargets.oTarget1);
            if (d2()==1)
                BehDoFireBeam(BEHOLDER_RAY_FEAR,stTargets.oTarget2);
            BehDoFireBeam(BEHOLDER_RAY_WOUND,stTargets.oTarget2);
            BehDoFireBeam(BEHOLDER_RAY_TK,stTargets.oTarget3);
            BehDoFireBeam(BEHOLDER_RAY_PETRI,stTargets.oTarget3);
            BehDoFireBeam(BEHOLDER_RAY_CHARM,stTargets.oTarget2);
       }
       else
       {
            if (d2()==1)
                BehDoFireBeam(BEHOLDER_RAY_DEATH,stTargets.oTarget2);
            BehDoFireBeam(BEHOLDER_RAY_SLOW,stTargets.oTarget3);
            BehDoFireBeam(BEHOLDER_RAY_FEAR,stTargets.oTarget1);
            if (d2()==1)
                BehDoFireBeam(BEHOLDER_RAY_WOUND,stTargets.oTarget2);
            BehDoFireBeam(BEHOLDER_RAY_TK,stTargets.oTarget1);
            BehDoFireBeam(BEHOLDER_RAY_PETRI,stTargets.oTarget3);
            BehDoFireBeam(BEHOLDER_RAY_CHARM,stTargets.oTarget1);
       }
    }
    else
    {
        if (d2()==1)
            BehDoFireBeam(BEHOLDER_RAY_DEATH,GetNthRayTarget(oTarget,Random(stTargets.nCount)+1));
        BehDoFireBeam(BEHOLDER_RAY_SLOW,GetNthRayTarget(oTarget,Random(stTargets.nCount)+1));
        BehDoFireBeam(BEHOLDER_RAY_FEAR,GetNthRayTarget(oTarget,Random(stTargets.nCount)+1));
        BehDoFireBeam(BEHOLDER_RAY_WOUND,GetNthRayTarget(oTarget,Random(stTargets.nCount)+1));
        BehDoFireBeam(BEHOLDER_RAY_TK,GetNthRayTarget(oTarget,Random(stTargets.nCount)+1));
        if (d2()==1)
            BehDoFireBeam(BEHOLDER_RAY_PETRI,GetNthRayTarget(oTarget,Random(stTargets.nCount)+1));
        BehDoFireBeam(BEHOLDER_RAY_CHARM,GetNthRayTarget(oTarget,Random(stTargets.nCount)+1));
        BehDoFireBeam(BEHOLDER_RAY_WOUND,GetNthRayTarget(oTarget,Random(stTargets.nCount)+1));
    }

    // Only if we are beholders and not beholder mages
    if (nApp == 472 || nApp == 401 || nApp == 403 || nApp == 299 || GetHasSpell(727))
    {                                              //GZhorb or any custom beholder with antimagic cone
        OpenAntiMagicEye(oTarget);
    }
}
