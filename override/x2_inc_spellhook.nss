//::///////////////////////////////////////////////
//:: Spell Hook Include File
//:: x2_inc_spellhook
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
//:: Created By: Georg Zoeller
//:: Created On: 2003-06-04
//:: Updated On: 2003-10-25
//:://////////////////////////////////////////////
//:: Modified By: Deva Winblood
//:: Modified Date: January 15th-16th, 2008
//:://////////////////////////////////////////////
//:: Modified By: Community Patch 1.70, 17.9.2008
//:: Removed horse library, check for getishorsemounted rescripted by GetPhenoType
//:://////////////////////////////////////////////
/*
    Modified to insure no shapeshifting spells are castable upon
    mounted targets.  This prevents problems that can occur due
    to dismounting after shape shifting, or other issues that can
    occur due to preserved appearances getting out of synch.

    This can additional check can be disabled by setting the variable
    X3_NO_SHAPESHIFT_SPELL_CHECK to 1 on the module object.  If this
    variable is set then this script will function as it did prior to
    this modification.

*/

//#include "x2_inc_itemprop" - Inherited from x2_inc_craft
#include "70_inc_spellhook"
#include "70_inc_spells"
#include "x0_i0_match"
#include "x2_inc_craft"


const int X2_EVENT_CONCENTRATION_BROKEN = 12400;


// Use Magic Device Check.
// Returns TRUE if the Spell is allowed to be cast, either because the
// character is allowed to cast it or he has won the required UMD check
// Only active on spell scroll
int X2UseMagicDeviceCheck();


// This function holds all functions that are supposed to run before the actual
// spellscript gets run. If this functions returns FALSE, the spell is aborted
// and the spellscript will not run
int X2PreSpellCastCode();


// check if the spell is prohibited from being cast on items
// returns FALSE if the spell was cast on an item but is prevented
// from being cast there by its corresponding entry in des_crft_spells
// oItem - pass GetSpellTargetObject in here
int X2CastOnItemWasAllowed(object oItem);

// Sequencer Item Property Handling
// Returns TRUE (and charges the sequencer item) if the spell
// ... was cast on an item AND
// ... the item has the sequencer property
// ... the spell was non hostile
// ... the spell was not cast from an item
// in any other case, FALSE is returned an the normal spellscript will be run
// oItem - pass GetSpellTargetObject in here
int X2GetSpellCastOnSequencerItem(object oItem);

int X2RunUserDefinedSpellScript();



int X2UseMagicDeviceCheck()
{
    int nRet = ExecuteScriptAndReturnInt("x2_pc_umdcheck",OBJECT_SELF);
    return nRet;
}

//------------------------------------------------------------------------------
// GZ: This is a filter I added to prevent spells from firing their original spell
// script when they were cast on items and do not have special coding for that
// case. If you add spells that can be cast on items you need to put them into
// des_crft_spells.2da
//------------------------------------------------------------------------------
int X2CastOnItemWasAllowed(object oItem)
{
    int bAllow = (Get2DAString(X2_CI_CRAFTING_SP_2DA,"CastOnItems",GetSpellId()) == "1");
    if (!bAllow)
    {
        FloatingTextStrRefOnCreature(83453, OBJECT_SELF); // not cast spell on item
    }
    return bAllow;

}

//------------------------------------------------------------------------------
// Execute a user overridden spell script.
//------------------------------------------------------------------------------
int X2RunUserDefinedSpellScript()
{
    // See x2_inc_switches for details on this code
    string sScript =  GetModuleOverrideSpellscript();
    if (sScript != "")
    {
        ExecuteScript(sScript,OBJECT_SELF);
        if (GetModuleOverrideSpellScriptFinished() == TRUE)
        {
            return FALSE;
        }
    }
    return TRUE;
}



//------------------------------------------------------------------------------
// Created Brent Knowles, Georg Zoeller 2003-07-31
// Returns TRUE (and charges the sequencer item) if the spell
// ... was cast on an item AND
// ... the item has the sequencer property
// ... the spell was non hostile
// ... the spell was not cast from an item
// in any other case, FALSE is returned an the normal spellscript will be run
//------------------------------------------------------------------------------
int X2GetSpellCastOnSequencerItem(object oItem)
{

    if (!GetIsObjectValid(oItem))
    {
        return FALSE;
    }

    int nMaxSeqSpells = IPGetItemSequencerProperty(oItem); // get number of maximum spells that can be stored
    if (nMaxSeqSpells <1)
    {
        return FALSE;
    }

    if (GetIsObjectValid(GetSpellCastItem())) // spell cast from item?
    {
        // we allow scrolls
        int nBt = GetBaseItemType(GetSpellCastItem());
        if ( nBt !=BASE_ITEM_SPELLSCROLL && nBt != 105)
        {
            FloatingTextStrRefOnCreature(83373, OBJECT_SELF);
            return TRUE; // wasted!
        }
    }

    // Check if the spell is marked as hostile in spells.2da
    int nHostile = StringToInt(Get2DAString("spells","HostileSetting",GetSpellId()));
    if(nHostile ==1)
    {
        FloatingTextStrRefOnCreature(83885,OBJECT_SELF);
        return TRUE; // no hostile spells on sequencers, sorry ya munchkins :)
    }

    int nNumberOfTriggers = GetLocalInt(oItem, "X2_L_NUMTRIGGERS");
    // is there still space left on the sequencer?
    if (nNumberOfTriggers < nMaxSeqSpells)
    {
        // success visual and store spell-id on item.
        effect eVisual = EffectVisualEffect(VFX_IMP_BREACH);
        nNumberOfTriggers++;
        //NOTE: I add +1 to the SpellId to spell 0 can be used to trap failure
        int nSID = GetSpellId()+1;
        SetLocalInt(oItem, "X2_L_SPELLTRIGGER" + IntToString(nNumberOfTriggers), nSID);
        SetLocalInt(oItem, "X2_L_NUMTRIGGERS", nNumberOfTriggers);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, OBJECT_SELF);
        FloatingTextStrRefOnCreature(83884, OBJECT_SELF);
    }
    else
    {
        FloatingTextStrRefOnCreature(83859,OBJECT_SELF);
    }

    return TRUE; // in any case, spell is used up from here, so do not fire regular spellscript
}

//------------------------------------------------------------------------------
// * This is our little concentration system for black blade of disaster
// * if the mage tries to cast any kind of spell, the blade is signaled an event to die
//------------------------------------------------------------------------------
void X2BreakConcentrationSpells()
{
    // * At the moment we got only one concentration spell, black blade of disaster

    object oAssoc = GetAssociate(ASSOCIATE_TYPE_SUMMONED);
    if (GetIsObjectValid(oAssoc) && GetIsPC(OBJECT_SELF)) // only applies to PCS
    {
        if(GetTag(oAssoc) == "x2_s_bblade") // black blade of disaster
        {
            if (GetLocalInt(OBJECT_SELF,"X2_L_CREATURE_NEEDS_CONCENTRATION"))
            {
                SignalEvent(oAssoc,EventUserDefined(X2_EVENT_CONCENTRATION_BROKEN));
            }
        }
    }
}

//------------------------------------------------------------------------------
// being hit by any kind of negative effect affecting the caster's ability to concentrate
// will cause a break condition for concentration spells
//------------------------------------------------------------------------------
int X2GetBreakConcentrationCondition(object oPlayer)
{
     effect e1 = GetFirstEffect(oPlayer);
     int nType;
     int bRet = FALSE;
     while (GetIsEffectValid(e1) && !bRet)
     {
        nType = GetEffectType(e1);

        if (nType == EFFECT_TYPE_STUNNED || nType == EFFECT_TYPE_PARALYZE ||
            nType == EFFECT_TYPE_SLEEP || nType == EFFECT_TYPE_FRIGHTENED ||
            nType == EFFECT_TYPE_PETRIFY || nType == EFFECT_TYPE_CONFUSED ||
            nType == EFFECT_TYPE_DOMINATED || nType == EFFECT_TYPE_POLYMORPH)
         {
           bRet = TRUE;
         }
                    e1 = GetNextEffect(oPlayer);
     }
    return bRet;
}

void X2DoBreakConcentrationCheck()
{
    object oMaster = GetMaster();
    if (GetLocalInt(OBJECT_SELF,"X2_L_CREATURE_NEEDS_CONCENTRATION"))
    {
         if (GetIsObjectValid(oMaster))
         {
            // master doing anything that requires attention and breaks concentration
            switch(GetCurrentAction(oMaster))
            {
                case ACTION_DISABLETRAP:
                case ACTION_TAUNT:
                case ACTION_PICKPOCKET:
                case ACTION_ATTACKOBJECT:
                case ACTION_COUNTERSPELL:
                case ACTION_FLAGTRAP:
                case ACTION_CASTSPELL:
                case ACTION_ITEMCASTSPELL:
                case ACTION_EXAMINETRAP: //added in 1.70
                case ACTION_LOCK:        //added in 1.70
                case ACTION_OPENLOCK:    //added in 1.70
                case ACTION_RECOVERTRAP: //added in 1.70
                case ACTION_SETTRAP:     //added in 1.70
                SignalEvent(OBJECT_SELF,EventUserDefined(X2_EVENT_CONCENTRATION_BROKEN));
                return;
            }
            if (X2GetBreakConcentrationCondition(oMaster))
            {
                SignalEvent(OBJECT_SELF,EventUserDefined(X2_EVENT_CONCENTRATION_BROKEN));
            }
         }
    }
}


//------------------------------------------------------------------------------
// This function will return TRUE if the spell that is cast is a shape shifting
// spell.
//------------------------------------------------------------------------------
int X3ShapeShiftSpell(object oTarget)
{ // PURPOSE: Return TRUE if a shape shifting spell was cast at oTarget
    int nSpellID=GetSpellId();
    string sUp=GetStringUpperCase(Get2DAString("x3restrict","SHAPESHIFT", nSpellID));
    if (sUp=="YES") return TRUE;
    return FALSE;
} // X3ShapeShiftSpell()

//duplicate code from 70_spellhook to provide forwards compatibility
void _X2PreSpellCastCode()
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
//end of duplicate code from 70_spellhook

//------------------------------------------------------------------------------
// Community Patch 1.71: function changed in order to allow modify internal spellhook
// need to recompile all spellscripts. New internal spellhook is in 70_spelllhook script
// this library is however still used as include file for new spellhook internal and many
// old spellscripts
//------------------------------------------------------------------------------
int X2PreSpellCastCode()
{
    SetLocalInt(OBJECT_SELF,"70_SPELLHOOK_DURATION",spell.DurationType);
    SetLocalInt(OBJECT_SELF,"70_SPELLHOOK_DAMAGECAP",spell.DamageCap);
    SetLocalInt(OBJECT_SELF,"70_SPELLHOOK_DAMAGETYPE",spell.DamageType);
    SetLocalInt(OBJECT_SELF,"70_SPELLHOOK_LIMIT",spell.Limit);
    SetLocalInt(OBJECT_SELF,"70_SPELLHOOK_SAVINGTHROW",spell.SavingThrow);
    SetLocalInt(OBJECT_SELF,"70_SPELLHOOK_TARGETTYPE",spell.TargetType);
    SetLocalFloat(OBJECT_SELF,"70_SPELLHOOK_RANGE",spell.Range);
    SetLocalInt(OBJECT_SELF,"X2_L_LAST_RETVAR",-1);
    ExecuteScript("70_spellhook",OBJECT_SELF);
    int nRet = GetLocalInt(OBJECT_SELF,"X2_L_LAST_RETVAR");
    if(nRet == -1)//support for forwards compatibility
    {
        _X2PreSpellCastCode();
        nRet = GetLocalInt(OBJECT_SELF,"X2_L_LAST_RETVAR");
    }
    DeleteLocalInt(OBJECT_SELF,"X2_L_LAST_RETVAR");
    DeleteLocalInt(OBJECT_SELF,"70_SPELLHOOK_DURATION");
    DeleteLocalFloat(OBJECT_SELF,"70_SPELLHOOK_RANGE");
    DeleteLocalInt(OBJECT_SELF,"70_SPELLHOOK_DAMAGECAP");
    DeleteLocalInt(OBJECT_SELF,"70_SPELLHOOK_DAMAGETYPE");
    DeleteLocalInt(OBJECT_SELF,"70_SPELLHOOK_LIMIT");
    DeleteLocalInt(OBJECT_SELF,"70_SPELLHOOK_SAVINGTHROW");
    DeleteLocalInt(OBJECT_SELF,"70_SPELLHOOK_TARGETTYPE");
    return !nRet;
}
