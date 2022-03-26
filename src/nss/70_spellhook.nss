//::///////////////////////////////////////////////
//:: Community Patch 1.71: Improve Spell Hook Include File
//:: 70_spellhook
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*

    This file acts as a hub for all code that
    is hooked into the nwn spellscripts'

    If you want to implement material components
    into spells or add restrictions to certain
    spells, this is the place to do it.

*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow
//:: Created On: 2012-01-17
//:://////////////////////////////////////////////
/*
Patch 1.72
- improved exploit fix to prevent casting in polymorph
- improved musical instruments to combine both bard song and perform skill restriction
*/

#include "70_inc_spellhook"
#include "x2_inc_spellhook"
#include "x0_i0_match"

//------------------------------------------------------------------------------
// if X2_EXECUTE_SCRIPT_END is set by this script, the original spell will not be cast
// the order in which the functions are called here DOES MATTER, changing it
// WILL break the crafting subsystems
//------------------------------------------------------------------------------
void main()
{
   object oTarget = GetSpellTargetObject();
   object oItem = GetSpellCastItem();

   if(oItem != OBJECT_INVALID)
   {
       int spellOverride = GetLocalInt(oItem,"ITEM_SPELL_OVERRIDE");
       if(spellOverride != 0 && !GetLocalInt(GetModule(),"SPELL_OVERRIDE_FINISHED"))
       {
           SetLocalInt(GetModule(),"SPELL_OVERRIDE_FINISHED",TRUE);
           ExecuteScript(Get2DAString("spells","ImpactScript",spellOverride < 0 ? 0 : spellOverride),OBJECT_SELF);
           SetLocalInt(GetModule(),"SPELL_OVERRIDE_FINISHED",FALSE);
           SetExecutedScriptReturnValue(X2_EXECUTE_SCRIPT_END);
           return;
       }
   }
   else if(GetIsPC(OBJECT_SELF))
   {
       //1.72: polymorph exploit handling
       int bPoly;
       effect eSearch = GetFirstEffect(OBJECT_SELF);
       while(GetIsEffectValid(eSearch))
       {
           if(GetEffectType(eSearch) == EFFECT_TYPE_POLYMORPH)
           {
               int spell = GetSpellId();
               if(spell > 0 && GetLocalInt(oTarget,"Polymorph_ID") > 0 && Get2DAString("spells","Innate",spell) != "10" && GetHasSpell(spell) && spell != GetLocalInt(oTarget,"Poly_SPELL1") && spell != GetLocalInt(oTarget,"Poly_SPELL2") && spell != GetLocalInt(oTarget,"Poly_SPELL3"))
               {
                   //block the spell for exploit abuse
                   FloatingTextStrRefOnCreature(3734,OBJECT_SELF,FALSE);//prints "Spell failed!"
                   SetExecutedScriptReturnValue(X2_EXECUTE_SCRIPT_END);
                   return;
               }
               if(oTarget != OBJECT_SELF && GetIsObjectValid(oTarget))
               {   //1.72: targetting engine bug handling, polymorph spells can be cast to anything no matter their target type
                   string sHex = GetStringLowerCase(Get2DAString("spells","TargetType",spell));
                   //converts hex value into integer
                   if(GetStringLeft(sHex, 2) == "0x") sHex = GetStringRight(sHex, GetStringLength(sHex) - 2);
                   int allowedTarget, nVal, nLoop = GetStringLength(sHex) - 1;
                   string sConv = "0123456789abcdef";
                   while(sHex != "")
                   {
                       nVal = FindSubString(sConv, GetStringLeft(sHex, 1));
                       nVal = nVal * FloatToInt(pow(16.0, IntToFloat(nLoop)));
                       allowedTarget+= nVal;
                       sHex = GetStringRight(sHex, nLoop--);
                   }
                   if(allowedTarget > 0)
                   {
                       switch(GetObjectType(oTarget))
                       {
                           case OBJECT_TYPE_ITEM:
                               if(allowedTarget & 8) break;
                           case OBJECT_TYPE_CREATURE:
                               if(allowedTarget & 2) break;
                           case OBJECT_TYPE_PLACEABLE:
                               if(allowedTarget & 32) break;
                           case OBJECT_TYPE_DOOR:
                               if(allowedTarget & 16) break;
                           default:
                               //force replace current target with caster
                               SetLocalObject(OBJECT_SELF,"SPELL_TARGET_OVERRIDE",OBJECT_SELF);
                           break;
                       }
                   }
               }
               bPoly = TRUE;
               break;
           }
           eSearch = GetNextEffect(OBJECT_SELF);
       }
       //metamagic exploit handling
       int nMeta = GetMetaMagicFeat();
       if((nMeta == METAMAGIC_EMPOWER && !GetHasFeat(FEAT_EMPOWER_SPELL)) || (nMeta == METAMAGIC_MAXIMIZE && !GetHasFeat(FEAT_MAXIMIZE_SPELL)))
       {
           nMeta = bPoly-1;//if used in polymorph nothing happens, CP fixes this exploit in engine and simply remove the metamagic flag
       }
       else if((nMeta == METAMAGIC_EXTEND && !GetHasFeat(FEAT_EXTEND_SPELL)) || (nMeta == METAMAGIC_QUICKEN && !GetHasFeat(FEAT_QUICKEN_SPELL)) ||
              (nMeta == METAMAGIC_SILENT && !GetHasFeat(FEAT_SILENCE_SPELL)) || (nMeta == METAMAGIC_STILL && !GetHasFeat(FEAT_STILL_SPELL)))
       {
               nMeta = -1;
       }
       if(nMeta < 0)
       {
           //block the spell for exploit abuse
           FloatingTextStrRefOnCreature(3734,OBJECT_SELF,FALSE);//prints "Spell failed!"
           SetExecutedScriptReturnValue(X2_EXECUTE_SCRIPT_END);
           return;
       }
   }
   //---------------------------------------------------------------------------
   // This small addition will check to see if the target is mounted and the
   // spell is therefor one that should not be permitted.
   //---------------------------------------------------------------------------
   if(!GetLocalInt(GetModule(),"X3_NO_SHAPESHIFT_SPELL_CHECK"))
   { // do check for abort due to being mounted check
       switch(GetPhenoType(oTarget))
       {// shape shifting not allowed while mounted
       case 3:
       case 5:
       case 6:
       case 8:
        if(X3ShapeShiftSpell(oTarget))
        {
           if(GetIsPC(oTarget))
           {
           FloatingTextStrRefOnCreature(111982,oTarget,FALSE);
           }
        SetExecutedScriptReturnValue(X2_EXECUTE_SCRIPT_END);
        return;
        }// shape shifting not allowed while mounted
       break;
       }
   } // do check for abort due to being mounted check


   //---------------------------------------------------------------------------
   // This stuff is only interesting for player characters we assume that use
   // magic device always works and NPCs don't use the crafting feats or
   // sequencers anyway. Thus, any NON PC spellcaster always exits this script
   // with TRUE (unless they are DM possessed or in the Wild Magic Area in
   // Chapter 2 of Hordes of the Underdark.
   //---------------------------------------------------------------------------
   if (!GetIsPC(OBJECT_SELF))
   {
       if( !GetIsDMPossessed(OBJECT_SELF) && !GetLocalInt(GetArea(OBJECT_SELF), "X2_L_WILD_MAGIC"))
       {
           SetExecutedScriptReturnValue(X2_EXECUTE_SCRIPT_CONTINUE);
           return;
       }
   }

   //---------------------------------------------------------------------------
   // Break any spell require maintaining concentration (only black blade of
   // disaster)
   // /*REM*/ X2BreakConcentrationSpells();
   //---------------------------------------------------------------------------

   //---------------------------------------------------------------------------
   // 1.72: no scroll reading under blindness/darkness
   //---------------------------------------------------------------------------
   if(oItem != OBJECT_INVALID && GetBaseItemType(oItem) == BASE_ITEM_SPELLSCROLL && GetGameDifficulty() >= GAME_DIFFICULTY_CORE_RULES)
   {
       int bTS = GetHasSpellEffect(SPELL_TRUE_SEEING) || GetHasEffect(EFFECT_TYPE_TRUESEEING) || GetItemHasItemProperty(GetItemInSlot(INVENTORY_SLOT_CARMOUR),ITEM_PROPERTY_TRUE_SEEING) || IPGetHasItemPropertyOnCharacter(OBJECT_SELF,ITEM_PROPERTY_TRUE_SEEING);
       int bUV = GetHasSpellEffect(SPELL_DARKVISION) || GetHasEffect(EFFECT_TYPE_ULTRAVISION);
       effect eSearch = GetFirstEffect(OBJECT_SELF);
       while(GetIsEffectValid(eSearch))
       {
           switch(GetEffectType(eSearch))
           {
               case EFFECT_TYPE_BLINDNESS:
                   if(!bTS)
                   {
                       FloatingTextStrRefOnCreature(3734,OBJECT_SELF,FALSE);//prints "Spell failed!"
                       SetExecutedScriptReturnValue(X2_EXECUTE_SCRIPT_END);
                       return;
                   }
               break;
               case EFFECT_TYPE_DARKNESS:
                   if(!bTS && !bUV)
                   {
                       FloatingTextStrRefOnCreature(3734,OBJECT_SELF,FALSE);//prints "Spell failed!"
                       SetExecutedScriptReturnValue(X2_EXECUTE_SCRIPT_END);
                       return;
                   }
               break;
           }
           eSearch = GetNextEffect(OBJECT_SELF);
       }
   }
   //---------------------------------------------------------------------------
   // Run use magic device skill check
   //---------------------------------------------------------------------------
   int nContinue = X2UseMagicDeviceCheck();

   if (nContinue)
   {
       //-----------------------------------------------------------------------
       // run any user defined spellscript here
       //-----------------------------------------------------------------------
       nContinue = X2RunUserDefinedSpellScript();
   }

   //---------------------------------------------------------------------------
   // The following code is only of interest if an item was targeted
   //---------------------------------------------------------------------------
   if (GetIsObjectValid(oTarget) && GetObjectType(oTarget) == OBJECT_TYPE_ITEM)
   {
       //-----------------------------------------------------------------------
       // Check if spell was used to trigger item creation feat
       //-----------------------------------------------------------------------
       if (nContinue)
       {
           nContinue = !ExecuteScriptAndReturnInt("x2_pc_craft",OBJECT_SELF);
       }

       //-----------------------------------------------------------------------
       // Check if spell was used for on a sequencer item
       //-----------------------------------------------------------------------
       if (nContinue)
       {
           nContinue = !X2GetSpellCastOnSequencerItem(oTarget);
       }

       //-----------------------------------------------------------------------
       // * Execute item OnSpellCast At routing script if activated
       //-----------------------------------------------------------------------
       if (GetModuleSwitchValue(MODULE_SWITCH_ENABLE_TAGBASED_SCRIPTS))
       {
           SetUserDefinedItemEventNumber(X2_ITEM_EVENT_SPELLCAST_AT);
           int nRet = ExecuteScriptAndReturnInt(GetUserDefinedItemEventScriptName(oTarget),OBJECT_SELF);
           if (nRet == X2_EXECUTE_SCRIPT_END)
           {
               SetExecutedScriptReturnValue(X2_EXECUTE_SCRIPT_END);
               return;
           }
       }

       //-----------------------------------------------------------------------
       // Prevent any spell that has no special coding to handle targetting of items
       // from being cast on items. We do this because we can not predict how
       // all the hundreds spells in NWN will react when cast on items
       //-----------------------------------------------------------------------
       if (nContinue)
       {
           nContinue = X2CastOnItemWasAllowed(oTarget);
       }
   }

   if(GetLocalInt(oItem,"MUSICAL_INSTRUMENT"))//variable indicating musical instrument
   {
       nContinue = MusicalInstrumentsCheck(oItem);
   }


   SetExecutedScriptReturnValue(!nContinue);
}
