//::///////////////////////////////////////////////
//:: OnHitCastSpell Misc Effects
//:: x2_s3_misceffect
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
     Gelatinous cube paralzye
     DC 10 + CasterLevel

*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: 2003-09-18
//:://////////////////////////////////////////////
/*
Patch 1.72
- effects made undispellable (extraordinary)
*/

#include "x2_i0_spells"
#include "x2_inc_switches"

void main()
{

   object oItem;        // The item casting triggering this spellscript
   object oSpellTarget; // On a weapon: The one being hit. On an armor: The one hitting the armor
   object oSpellOrigin; // On a weapon: The one wielding the weapon. On an armor: The one wearing an armor

   // fill the variables
   oSpellOrigin = OBJECT_SELF;
   oSpellTarget = GetSpellTargetObject();
   oItem        =  GetSpellCastItem();

   if (GetIsObjectValid(oItem))
   {
      // you can not be deafened if you already can not hear.
      if (!GetHasSpellEffect(GetSpellId(),oSpellTarget))
      {
             int nDC = GetCasterLevel(oSpellOrigin)+10;
             if (DoCubeParalyze(oSpellTarget, oSpellOrigin,nDC))
             {
                if(!GetIsImmune(oSpellTarget,IMMUNITY_TYPE_PARALYSIS,oSpellOrigin) && !GetIsImmune(oSpellTarget,IMMUNITY_TYPE_MIND_SPELLS,oSpellOrigin))
                {
                    FloatingTextStrRefOnCreature(84609,oSpellTarget);
                }
             }
             return;
         }
    }
}
