//::///////////////////////////////////////////////
//:: Community Patch 1.70 Custom functions related to item properties and shifter
//:: 70_inc_itemprop
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
This include file contains new functions used for merging items and other item-based
stuff.

Most of these functions are private, meaning they don't appear in function list because
they are specific for one purpose and not expected to be used outside of that scope.

A short explanation how the new polymorph engine works:

1) When a polymorph spell is cast an engine placeable is created on the player's position.
2) All polymorph related informations are obtained and stored in local variables on player.
3) A pre-polymorph event fires on the creator object. In this event, all merged items are
searched for ability bonuses and these ability bonuses are then applied on character as an
effect. This is required in order to avoid losing spell slots from ability bonuses. Also
any additional polymorp effects are applied here. All these effects are applied permanently
because they will be removed after polymorph ends.
4) A polymorph effect is applied on character. If a CPP polymorph.2da is in use, then temporary
hitpoints are applied here as well. This is in order to fix the temp HP stackign and replenish.
5) OnPolymorph event fires on character. In this event additional item merging happens. All
merged item's properties are transfered to skin or weapon item.
6) A pseudo-heartbeat is established in order to correctly remove ability bonuses and additional
effects in modules where OnPolymorph event won't be 100% functional (because its dependant on
unmodified OnEquip and OnUnequip events). Also, if the polymorph is temporary, the function to
force end polymorph effect is started with delay equal to the expected duration of polymorph.
This workaround is important since any character saving while in polymorph (and this is something
that player can initialize by himself) restarts the polymorph duration.
7) When polymorph ends, the creator placeable object is destroyed.

Installation:
To get all advantages of this "engine" you need to do some extra steps:
1) Add this code into your module OnPlayerEquip script:
    //1.72: OnPolymorph scripted event handler
    if(!GetLocalInt(oPC,"Polymorphed") && GetHasEffect(EFFECT_TYPE_POLYMORPH,oPC))
    {
        SetLocalInt(oPC,"Polymorphed",1);
        SetLocalInt(oPC,"UnPolymorph",0);
        ExecuteScript("70_mod_polymorph",oPC);
    }
2) Add this code into your module OnPlayerUnEquip script:
    //1.72: OnPolymorph scripted event handler
    else if(!GetLocalInt(oPC,"UnPolymorph") && GetHasEffect(EFFECT_TYPE_POLYMORPH,oPC))
    {
        SetLocalInt(oPC,"UnPolymorph",1);
        SetLocalInt(oPC,"UnPolymorph_HP_Setup",TRUE);
        SetLocalInt(oPC,"UnPolymorph_HP",GetCurrentHitPoints(oPC));
        DelayCommand(0.0,ExecuteScript("70_mod_polymorph",oPC));
    }
3) In polymorph.2da rename column HPBONUS to TEMPHP or run auto 2da merger which will do it for you.
4) If you have any polymorph spells modified in your module, make sure your spells are calling ApplyPolymorph function from this include.

Changes to the shapeshifting:
1.72:
- disabled casting spells in polymorph that player normally doesn't have access to
- fixed polymorph temp hitpoints stacking and replenish (dependant on polymorph.2da change)
- fixed losing all merged item properties when "repolymorph" happens (dependant on OnPolymorph event)
- fixed losing bonus spell slots from ability bonuses (but only up to the ability bonus that was
merged into shape)
- fixed losing spell slots from both ability bonuses and itemproperties, instead the spells in slots
will be "consumed" (dependant on NWNX_Patch)
- merged ability decreases now ignores immunity to ability decrease from shape or from other merged
items (without NWNX, that is - if NWNX_Patch is in use this will be handled in engine and pass
through even negative energy immunity spell - which this solution can't)
- fixed dying after unpolymorph (which happened due to the fact that all constitution bonuses
were lost for a short while)
- skill bonuses and saving throw bonuses are now stacked as well, if ability bonuses are
1.71:
- allowed to merge any custom non-weapon in left hand slot such as flags or
musical instruments
- added optional feature to stack ability bonuses from multiple items together
- added optional feature to merge bracers (when items are allowed to merge)
- added benefits of being incorporeal to the spectre shape (50% concealment and
the ability to walk through other creatures)
1.70
- fixed dying when unpolymorphed as an result of sudden constitution bonus drop
which also could result to the server crash
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow
//:: Created On: ?-11-2010
//:://////////////////////////////////////////////

#include "x2_inc_itemprop"
#include "70_inc_itemprop"
#include "70_inc_spells"

const int POLYMORPH_DEBUG = FALSE;

const int POLYMORPH_EVENTTYPE_POLYMORPH_INVALID = -1;
const int POLYMORPH_EVENTTYPE_POLYMORPH_ONPOLYMORPH = 1;
const int POLYMORPH_EVENTTYPE_POLYMORPH_UNPOLYMORPH = 0;
const int POLYMORPH_EVENTTYPE_POLYMORPH_REPOLYMORPH = 2;
const int POLYMORPH_EVENTTYPE_POLYMORPH_PREPOLYMORPH = 3;

struct abilities
{
int Con,Str,Wis,Dex,Cha,Int;
};

// Determine the type (POLYMORPH_EVENTTYPE_POLYMORPH_*) of the last polymorph
// event (as returned from the OnPolymorph special event).
int GetLastPolymorphEventType();

//nPolymorph: POLYMORPH_TYPE_*
//nSubType: SUBTYPE_*
//for permanent duration, keep fDuration in its default value (0.0)
//fDelay will delay a polymorph effect application if needed
void ApplyPolymorph(object oTarget, int nPolymorph, int nSubType=SUBTYPE_EXTRAORDINARY, float fDuration=0.0, int bLocked=FALSE, float fDelay=0.0);

//Use in OnPrePolymorph event to cancel polymorph from happening
void CancelPolymorph();

void CancelPolymorph()
{
DestroyObject(OBJECT_SELF);
}

int GetLastPolymorphEventType()
{
    if(GetTag(OBJECT_SELF) == "70_EC_POLYMORPH") return POLYMORPH_EVENTTYPE_POLYMORPH_PREPOLYMORPH;
    effect eSearch = GetFirstEffect(OBJECT_SELF);
    while(GetIsEffectValid(eSearch))
    {
        if(GetEffectType(eSearch) == EFFECT_TYPE_POLYMORPH)
        {
            return GetLocalInt(OBJECT_SELF,"UnPolymorph") ? POLYMORPH_EVENTTYPE_POLYMORPH_REPOLYMORPH : POLYMORPH_EVENTTYPE_POLYMORPH_ONPOLYMORPH;
        }
        eSearch = GetNextEffect(OBJECT_SELF);
    }
    return GetLocalInt(OBJECT_SELF,"UnPolymorph") ? POLYMORPH_EVENTTYPE_POLYMORPH_UNPOLYMORPH : POLYMORPH_EVENTTYPE_POLYMORPH_INVALID;
}

//1.70 by Shadooow, private function for shifter polymorp and con bonus issue
struct abilities IPGetAbilityBonuses(struct abilities abil, object oItem)
{
    if(!GetIsObjectValid(oItem)) return abil;//sanity check
    object oOwner = GetItemPossessor(oItem);
    int nValue, bStack = oItem == GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,oOwner) || GetLocalInt(oOwner,"71_POLYMORPH_STACK_ABILITY_BONUSES") || GetModuleSwitchValue("71_POLYMORPH_STACK_ABILITY_BONUSES");
    int STRbonus,CHAbonus,INTbonus,DEXbonus,CONbonus,WISbonus;
    //first calculate the highest bonus on given item since multiple bonuses of same ability on one item doesn't stack
    itemproperty ip = GetFirstItemProperty(oItem);
    while (GetIsItemPropertyValid(ip))
    {
        if(GetItemPropertyType(ip) == ITEM_PROPERTY_ABILITY_BONUS)
        {
            nValue = GetItemPropertyCostTableValue(ip);
            switch(GetItemPropertySubType(ip))
            {
            case IP_CONST_ABILITY_CON:
                if(nValue > CONbonus)
                CONbonus = nValue;
            break;
            case IP_CONST_ABILITY_DEX:
                if(nValue > DEXbonus)
                DEXbonus = nValue;
            break;
            case IP_CONST_ABILITY_CHA:
                if(nValue > CHAbonus)
                CHAbonus = nValue;
            break;
            case IP_CONST_ABILITY_INT:
                if(nValue > INTbonus)
                INTbonus = nValue;
            break;
            case IP_CONST_ABILITY_STR:
                if(nValue > STRbonus)
                STRbonus = nValue;
            break;
            case IP_CONST_ABILITY_WIS:
                if(nValue > WISbonus)
                WISbonus = nValue;
            break;
            }
        }
        ip = GetNextItemProperty(oItem);
    }
    //now, stack or replace the highest bonuses into structure and send it back into calling script
    if(bStack)
    {
        abil.Con+= CONbonus;
        abil.Dex+= DEXbonus;
        abil.Cha+= CHAbonus;
        abil.Int+= INTbonus;
        abil.Str+= STRbonus;
        abil.Wis+= WISbonus;
    }
    else
    {
        if(CONbonus > abil.Con) abil.Con = CONbonus;
        if(DEXbonus > abil.Dex) abil.Dex = DEXbonus;
        if(CHAbonus > abil.Cha) abil.Cha = CHAbonus;
        if(INTbonus > abil.Int) abil.Int = INTbonus;
        if(STRbonus > abil.Str) abil.Str = STRbonus;
        if(WISbonus > abil.Wis) abil.Wis = WISbonus;
    }
    return abil;
}

void CheckPolymorphEnd(object oTarget, effect ePolymorph, effect eHP, object oCreator)
{
    if(POLYMORPH_DEBUG) SendMessageToPC(oTarget,"CheckPolymorphEnd start");
    effect eSearch = GetFirstEffect(oTarget);
    while(GetIsEffectValid(eSearch))
    {
        if(eSearch == ePolymorph)//original polymorph found
        {
            if(POLYMORPH_DEBUG) SendMessageToPC(oTarget,"still in polymorph nothing happens!");
            DelayCommand(3.0,CheckPolymorphEnd(oTarget,ePolymorph,eHP,oCreator));
            return;
        }
        else if(GetEffectType(eSearch) == EFFECT_TYPE_POLYMORPH && oCreator == GetLocalObject(oTarget,"Polymorph_Creator"))//this happens when player repolymorphs
        {
            if(POLYMORPH_DEBUG) SendMessageToPC(oTarget,"still in same polymorph though ID changed!");
            DelayCommand(3.0,CheckPolymorphEnd(oTarget,eSearch,eHP,oCreator));
            return;
        }
        eSearch = GetNextEffect(oTarget);
    }
    if(POLYMORPH_DEBUG) SendMessageToPC(oTarget,"no polymorph effect found!");
    //polymorph ended, clean all additional effects, if any
    eSearch = GetFirstEffect(oTarget);
    while(GetIsEffectValid(eSearch))
    {
        if(oCreator != OBJECT_INVALID && GetEffectCreator(eSearch) == oCreator)
        {
            RemoveEffect(oTarget,eSearch);
        }
        eSearch = GetNextEffect(oTarget);
    }
    RemoveEffect(oTarget,eHP);
    DestroyObject(oCreator);
}

void ForcePolymorphEnd(object oTarget, effect ePolymorph, effect eHP, object oCreator)
{
    if(POLYMORPH_DEBUG) SendMessageToPC(oTarget,"ForcePolymorphEnd start");
    effect eSearch = GetFirstEffect(oTarget);
    int bFound;
    while(GetIsEffectValid(eSearch))
    {
        if(eSearch == ePolymorph)//original polymorph found
        {
            RemoveEffect(oTarget,eSearch);
            bFound = TRUE;
            break;
        }
        else if(GetEffectType(eSearch) == EFFECT_TYPE_POLYMORPH && oCreator == GetLocalObject(oTarget,"Polymorph_Creator"))//this happens when player repolymorphs
        {
            if(POLYMORPH_DEBUG) SendMessageToPC(oTarget,"not exactly old polymorph, but correct!");
            RemoveEffect(oTarget,eSearch);
            bFound = TRUE;
            break;
        }
        eSearch = GetNextEffect(oTarget);
    }
    int nSpellId = GetEffectSpellId(ePolymorph);
    //clean all additional effects, if any
    eSearch = GetFirstEffect(oTarget);
    while(GetIsEffectValid(eSearch))
    {
        if((oCreator != OBJECT_INVALID && GetEffectCreator(eSearch) == oCreator) || (bFound && GetEffectSpellId(eSearch) == nSpellId))
        {
            RemoveEffect(oTarget,eSearch);
        }
        eSearch = GetNextEffect(oTarget);
    }
    RemoveEffect(oTarget,eHP);
    DestroyObject(oCreator);
}

void ApplyPolymorph_Polymorph(object oTarget, effect ePolymorph, float fDuration=0.0)
{
    ApplyEffectToObject(fDuration > 0.0 ? DURATION_TYPE_TEMPORARY : DURATION_TYPE_PERMANENT,ePolymorph,oTarget,fDuration);

    AssignCommand(oTarget,ClearAllActions());// cancels any spells in action queve to avoid exploit

    //1.72: item merging is now done in 70_mod_polymorph to allow customization of the process without need to recompile all polymorph scripts
    SetLocalInt(oTarget,"Polymorphed",1);

    ExecuteScript("70_mod_polymorph",oTarget);
}

void ApplyPolymorph(object oTarget, int nPolymorph, int nSubType=SUBTYPE_EXTRAORDINARY, float fDuration=0.0, int bLocked=FALSE, float fDelay=0.0)
{
    if(oTarget != OBJECT_SELF)//polymorphing someone else, not in vanilla, support for custom content
    {
        if(spellsIsImmuneToPolymorph(oTarget))//oozes, plants, incorporeal creatures and few others are immune to polymorph
        {
            //engine workaround for immunity feedback
            string sFeedback = GetStringByStrRef(8342);
            sFeedback = GetStringLeft(sFeedback,GetStringLength(sFeedback)-10);
            sFeedback = GetStringRight(sFeedback,GetStringLength(sFeedback)-10);
            sFeedback = "<c›þþ>"+GetName(oTarget)+"</c> <cÍþ>"+sFeedback+" "+GetStringByStrRef(8344)+"</c>";
            SendMessageToPC(oTarget,sFeedback);
            SendMessageToPC(OBJECT_SELF,sFeedback);
            ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_IMP_GLOBE_USE),oTarget);
            return;
        }
        else if(GetRacialType(oTarget) == RACIAL_TYPE_SHAPECHANGER || GetLevelByClass(CLASS_TYPE_SHIFTER,oTarget) > 0)
        {
            bLocked = FALSE;//shapechangers are not immune to the polymorph but are allowed to unpolymorph at will
        }
    }
    //determine temporary hitpoints
    int nHP = StringToInt(Get2DAString("polymorph","TEMPHP",nPolymorph));

    //determine all polymorph qualities from 2DA
    string s2DA = Get2DAString("polymorph","SPELL1",nPolymorph);
    int spell1 = s2DA == "" ? -1 : StringToInt(s2DA);
    s2DA = Get2DAString("polymorph","SPELL2",nPolymorph);
    int spell2 = s2DA == "" ? -1 : StringToInt(s2DA);
    s2DA = Get2DAString("polymorph","SPELL3",nPolymorph);
    int spell3 = s2DA == "" ? -1 : StringToInt(s2DA);

    int bWeapon = Get2DAString("polymorph","MergeW",nPolymorph) == "1";
    int bArmor  = Get2DAString("polymorph","MergeA",nPolymorph) == "1";
    int bItems  = Get2DAString("polymorph","MergeI",nPolymorph) == "1";

    //make a polymorph creator object
    object oCreator = CreateObject(OBJECT_TYPE_PLACEABLE,"plc_invisobj",GetLocation(oTarget),FALSE,"70_EC_POLYMORPH");
    SetPlotFlag(oCreator,TRUE);

    //store polymorph informations to retrieve from OnPolymorph event later
    SetLocalInt(oTarget,"Polymorph_ID",nPolymorph+1);//+1 to determine errors (0 = error)
    SetLocalInt(oTarget,"Polymorph_SpellID",GetEffectSpellId(EffectDazed()));
    SetLocalInt(oTarget,"Polymorph_Locked",bLocked);
    SetLocalInt(oTarget,"Polymorph_HP",nHP);
    SetLocalInt(oTarget,"Polymorph_SPELL1",spell1);
    SetLocalInt(oTarget,"Polymorph_SPELL2",spell2);
    SetLocalInt(oTarget,"Polymorph_SPELL3",spell3);
    SetLocalInt(oTarget,"Polymorph_MergeI",bItems);
    SetLocalInt(oTarget,"Polymorph_MergeA",bArmor);
    SetLocalInt(oTarget,"Polymorph_MergeW",bWeapon);
    SetLocalObject(oTarget,"Polymorph_Creator",oCreator);
    SetLocalObject(oCreator,"Polymorph_Target",oTarget);

    //1.72: the code for apply ability bonuses and polymorph-specific effects moved into 70_mod_polymorph to allow easy modifying
    ExecuteScript("70_mod_polymorph",oCreator);

    if(!GetIsObjectValid(oCreator)) return; //polymorph was canceled in OnPrePolymorph script

    nPolymorph = GetLocalInt(oTarget,"Polymorph_ID")-1;//support for custom content, this will allow to change polymorph and hitpoints from OnPrePolymorph event
    bLocked = GetLocalInt(oTarget,"Polymorph_Locked");
    nHP = GetLocalInt(oTarget,"Polymorph_HP");

    //prepare polymorph and temp HP effects - this is done now so it gets spellID from current spellscript
    effect eHP, ePolymorph = EffectPolymorph(nPolymorph,bLocked);
    if(nHP > 0)
    {
        eHP = EffectTemporaryHitpoints(nHP);
    }
    if(nSubType == SUBTYPE_EXTRAORDINARY)
    {
        ePolymorph = ExtraordinaryEffect(ePolymorph);
        if(nHP > 0) eHP = ExtraordinaryEffect(eHP);
    }
    else if(nSubType == SUBTYPE_SUPERNATURAL)
    {
        ePolymorph = SupernaturalEffect(ePolymorph);
        if(nHP > 0) eHP = SupernaturalEffect(eHP);
    }

    SetLocalInt(oTarget,"UnPolymorph",0);//system variable to correctly determine engine repolymorph

    //finally lets apply polymorph
    if(fDelay > 0.0)
        DelayCommand(fDelay, ApplyPolymorph_Polymorph(oTarget,ePolymorph,fDuration));
    else
        ApplyPolymorph_Polymorph(oTarget,ePolymorph,fDuration);


    //if a new polymorph 2DA is used, temporary hitpoints are applied separately
    if(nHP > 0)
    {
        if(fDelay > 0.0)
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_PERMANENT,eHP,oTarget,fDuration));
        else
            ApplyEffectToObject(DURATION_TYPE_PERMANENT,eHP,oTarget,fDuration);
    }

    //sanity pseudo HB to remove all polymorph related effects (HP, abilities, addition) in case the OnPolymorph event didn't fire
    if(!GetLocalInt(GetModule(),"72_POLYMORPH_DISABLE_POLYMORPH_END_CHECK"))
    {
        DelayCommand(6.0+fDelay,CheckPolymorphEnd(oTarget,ePolymorph,eHP,oCreator));
    }
}
