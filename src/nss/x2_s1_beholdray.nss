//::///////////////////////////////////////////////
//:: Beholder Ray Attacks
//:: x2_s2_beholdray
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Implementation for the new version of the
    beholder rays, using projectiles instead of
    rays
*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: 2003-09-16
//:://////////////////////////////////////////////
/*
Patch 1.71

- added proper saving throw type into death, charm and fear bolt
- protected against action cancel
*/

#include "x0_i0_spells"
#include "inc_quest"

void main()
{
    int     nSpell = GetSpellId();
    object  oTarget = GetSpellTargetObject();
    //if(!GetIsObjectValid(oTarget))
    //{
    //    return;//ray missed
    //}
    int     nSave, bSave, nSaveType = SAVING_THROW_TYPE_NONE;
    int     nSaveDC = 15;
    float   fDelay  = 0.0;  //old -- GetSpellEffectDelay(GetLocation(oTarget),OBJECT_SELF);
    effect  e1, eLink, eVis, eDur;
    
    int bHasQuestProtection = 0;
    if (!GetIsPC(oTarget))
    {
        bHasQuestProtection = GetQuestEntry(GetMaster(oTarget), "q_beholder_prot");
    }
    else
    {
        bHasQuestProtection = GetQuestEntry(oTarget, "q_beholder_prot");
        if (bHasQuestProtection == 3)
        {
            FloatingTextStringOnCreature("The obelisk's orb absorbs some of the beholder's power!", oTarget);
            SetQuestEntry(oTarget, "q_beholder_prot", 4);
        }
    }
    if (bHasQuestProtection < 3)
    {
        bHasQuestProtection = 0;
    }

    switch (nSpell)
    {
        case 776:
                                  nSave = SAVING_THROW_FORT;      //BEHOLDER_RAY_DEATH
                                  nSaveType = SAVING_THROW_TYPE_DEATH;
                                  break;
        case 777:
                                  nSave = SAVING_THROW_WILL;     //BEHOLDER_RAY_TK
                                  break;
        case 778:                                              //BEHOLDER_RAY_PETRI
                                  nSave = SAVING_THROW_FORT;
                                  break;
        case 779:                                                   // BEHOLDER_RAY_CHARM
                                  nSave = SAVING_THROW_WILL;
                                  nSaveType = SAVING_THROW_TYPE_MIND_SPELLS;
                                  break;
        case 780:                                                   //BEHOLDER_RAY_SLOW
                                  nSave = SAVING_THROW_WILL;
                                  break;
        case 783:
                                  nSave = SAVING_THROW_FORT;        //BEHOLDER_RAY_WOUND
                                  break;
        case 784:                                                   // BEHOLDER_RAY_FEAR
                                  nSave = SAVING_THROW_WILL;
                                  nSaveType = SAVING_THROW_TYPE_FEAR;
                                  break;
        case 785:
        case 786:
        case 787:
    }

    SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, nSpell, TRUE));

    if(!MySavingThrow(nSave, oTarget, nSaveDC, nSaveType, OBJECT_SELF, fDelay))
    {
      if (bHasQuestProtection)
      {
          ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_GLOBE_USE), oTarget);
      }

      switch (nSpell)
      {
          case 776:                
          {
            if (!bHasQuestProtection)
            {
                e1 = EffectDeath(TRUE);
            }
            else
            {
                e1 = EffectDamage(d6(8));
            }
            eVis = EffectVisualEffect(VFX_IMP_DEATH);
            eLink = EffectLinkEffects(e1,eVis);
            ApplyEffectToObject(DURATION_TYPE_INSTANT,eLink,oTarget);
            break;
          }
          case 777:                e1 = ExtraordinaryEffect(EffectKnockdown());
                                   eVis = EffectVisualEffect(VFX_IMP_STUN);
                                   ApplyEffectToObject(DURATION_TYPE_INSTANT,eVis,oTarget);
                                   ApplyEffectToObject(DURATION_TYPE_TEMPORARY,e1,oTarget,6.0);
                                   break;
          // Petrify for one round per SaveDC
          case 778:                      
          {
            eVis = EffectVisualEffect(VFX_IMP_POLYMORPH);
            if (!bHasQuestProtection)
            {
               ApplyEffectToObject(DURATION_TYPE_INSTANT,eVis,oTarget);
               DoPetrification(nSaveDC,OBJECT_SELF,oTarget,nSpell, 0, TRUE);
            }
            else
            {
               
               e1 = EffectPetrify();
               ApplyEffectToObject(DURATION_TYPE_INSTANT,eVis,oTarget);
               ApplyEffectToObject(DURATION_TYPE_TEMPORARY,e1,oTarget, RoundsToSeconds(d4(2)));
            }
            break;
          }
          case 779: 
          {
            e1 = EffectCharmed();
            eVis = EffectVisualEffect(VFX_IMP_CHARM);
            ApplyEffectToObject(DURATION_TYPE_INSTANT,eVis,oTarget);
            if (!bHasQuestProtection)
            {
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY,e1,oTarget,24.0);
            }
            else
            {
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY,e1,oTarget,18.0);
            }
            break;
          }    
          case 780:
          {
            e1 = EffectSlow();
            eVis = EffectVisualEffect(VFX_IMP_SLOW);
            ApplyEffectToObject(DURATION_TYPE_INSTANT,eVis,oTarget);
            if (!bHasQuestProtection)
            {
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY,e1,oTarget,RoundsToSeconds(6));
            }
            else
            {
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY,e1,oTarget,RoundsToSeconds(4));
            }
            break;
          }   
          case 783:                e1 = EffectDamage(d8(2)+10);
                                   eVis = EffectVisualEffect(VFX_COM_BLOOD_REG_RED);
                                   ApplyEffectToObject(DURATION_TYPE_INSTANT,eVis,oTarget);
                                   ApplyEffectToObject(DURATION_TYPE_INSTANT,e1,oTarget);
                                   break;
          case 784:
           {
            e1 = EffectFrightened();
            eDur = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);
            e1 = EffectLinkEffects(eDur, e1);
            ApplyEffectToObject(DURATION_TYPE_INSTANT,eVis,oTarget);
            if (!bHasQuestProtection)
            {
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY,e1,oTarget,RoundsToSeconds(1+d4()));
            }
            else
            {
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY,e1,oTarget,RoundsToSeconds(1+d2()));
            }
            break;
          }  
       }

    }
}
