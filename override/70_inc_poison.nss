#include "x2_inc_switches"
#include "70_inc_nwnx"

void SecondaryDamage(object oTarget, int nPoisonID, effect eTrack)
{
 if(GetIsObjectValid(oTarget))
 {
 int bCured = TRUE;
 effect e = GetFirstEffect(oTarget);
  while(GetIsEffectValid(e))
  {
   if(e == eTrack)
   {
   bCured = FALSE;
   break;
   }
  e = GetNextEffect(oTarget);
  }
  if(bCured)
  {
  return;
  }
 int nDC = StringToInt(Get2DAString("poison","Save_DC",nPoisonID));
  if(!FortitudeSave(oTarget,nDC,SAVING_THROW_TYPE_POISON,OBJECT_INVALID))
  {
  SendMessageToPCByStrRef(oTarget,66947);
  int nVFX = VFX_IMP_POISON_S;
   if(Get2DAString("poison","VFX_Impact",nPoisonID) == "VFX_IMP_POISON_L")
   {
   nVFX = VFX_IMP_POISON_L;
   }
  ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(nVFX),oTarget);
  string s2DA = Get2DAString("poison","Default2",nPoisonID);
   if(s2DA == "" || s2DA == "****")
   {
   s2DA = Get2DAString("poison","Script_2",nPoisonID);
   ExecuteScript(s2DA,oTarget);
   return;
   }
  int nAbility = ABILITY_CONSTITUTION;
   if(s2DA == "DEX") nAbility = ABILITY_DEXTERITY;
   else if(s2DA == "STR") nAbility = ABILITY_STRENGTH;
   else if(s2DA == "WIS") nAbility = ABILITY_WISDOM;
   else if(s2DA == "INT") nAbility = ABILITY_INTELLIGENCE;
   else if(s2DA == "CHA") nAbility = ABILITY_CHARISMA;
  int nDice = StringToInt(Get2DAString("poison","Dice2",nPoisonID));
  int nDamage, nDam = StringToInt(Get2DAString("poison","Dam2",nPoisonID));
   do
   {
   nDamage+= Random(nDice)+1;
   }while(--nDam > 0);
   if(nDamage < 1) nDamage = 0;//sanity check
  ApplyEffectToObject(DURATION_TYPE_PERMANENT,ExtraordinaryEffect(EffectAbilityDecrease(nAbility,nDamage)),oTarget);
  }
 }
 else
 {
 DelayCommand(60.0,SecondaryDamage(oTarget,nPoisonID,eTrack));
 }
}

void Apply1stPoison(object oTarget, int nPoisonID)
{
effect e = GetFirstEffect(oTarget);
 while(GetIsEffectValid(e))
 {
  if(GetEffectType(e) == EFFECT_TYPE_POISON)
  {
  int bPoisonCanStack = GetModuleSwitchValue("71_ALLOW_POISON_STACKING");
  SetLocalInt(oTarget,"POISON_ID",nPoisonID);
  effect ePoison = EffectVisualEffect(VFX_DUR_CESSATE_NEUTRAL);
  string s2DA = Get2DAString("poison","Default1",nPoisonID);
   if(s2DA != "" && s2DA != "****")
   {
   int nAbility = ABILITY_CONSTITUTION;
    if(s2DA == "DEX") nAbility = ABILITY_DEXTERITY;
    else if(s2DA == "STR") nAbility = ABILITY_STRENGTH;
    else if(s2DA == "WIS") nAbility = ABILITY_WISDOM;
    else if(s2DA == "INT") nAbility = ABILITY_INTELLIGENCE;
    else if(s2DA == "CHA") nAbility = ABILITY_CHARISMA;
   int nDice = StringToInt(Get2DAString("poison","Dice1",nPoisonID));
   int nDamage, nDam = StringToInt(Get2DAString("poison","Dam1",nPoisonID));
    do
    {
    nDamage+= Random(nDice)+1;
    }while(--nDam > 0);
    if(nDamage < 1) nDamage = 0;//sanity check
   ePoison = EffectLinkEffects(ePoison,EffectAbilityDecrease(nAbility,nDamage));
    if(bPoisonCanStack)//1.72: with nwnx, poison icon and hp bar color is restored with stacked poisons!
    {
    effect eTemp = EffectPoison(20);
    effect eIcon = NWNXPatch_SetEffectTrueType(eTemp,EFFECT_TRUETYPE_ICON);
     if(GetEffectType(eIcon) == EFFECT_TYPE_INVALIDEFFECT)
     {
     ePoison = EffectLinkEffects(eIcon,ePoison);
     }
    }
   ePoison = ExtraordinaryEffect(ePoison);
   }
  DelayCommand(0.1,ApplyEffectToObject(DURATION_TYPE_PERMANENT,ePoison,oTarget));
   if(bPoisonCanStack || GetGameDifficulty() == GAME_DIFFICULTY_DIFFICULT)
   {
   RemoveEffect(oTarget,e);
   DelayCommand(60.0,SecondaryDamage(oTarget,nPoisonID,ePoison));
   }
  return;
  }
 e = GetNextEffect(oTarget);
 }
}

void Apply2stPoison(object oTarget, int nPoisonID)
{
effect e = GetFirstEffect(oTarget);
 while(GetIsEffectValid(e))
 {
  if(GetEffectType(e) == EFFECT_TYPE_POISON)
  {
  string s2DA = Get2DAString("poison","Default2",nPoisonID);
   if(s2DA == "" || s2DA == "****")
   {
   return;
   }
  int nAbility = ABILITY_CONSTITUTION;
   if(s2DA == "DEX") nAbility = ABILITY_DEXTERITY;
   else if(s2DA == "STR") nAbility = ABILITY_STRENGTH;
   else if(s2DA == "WIS") nAbility = ABILITY_WISDOM;
   else if(s2DA == "INT") nAbility = ABILITY_INTELLIGENCE;
   else if(s2DA == "CHA") nAbility = ABILITY_CHARISMA;
  int nDice = StringToInt(Get2DAString("poison","Dice2",nPoisonID));
  int nDamage, nDam = StringToInt(Get2DAString("poison","Dam2",nPoisonID));
   do
   {
   nDamage+= Random(nDice)+1;
   }while(--nDam > 0);
   if(nDamage < 1) nDamage = 0;//sanity check
  ApplyEffectToObject(DURATION_TYPE_PERMANENT,ExtraordinaryEffect(EffectAbilityDecrease(nAbility,nDamage)),oTarget);
  break;
  }
 e = GetNextEffect(oTarget);
 }
}

object GetPoisonEffectCreator(object oTarget)
{
object oCreator = GetObjectByTag("70_EC_POISON");
 if(!GetIsObjectValid(oCreator))
 {
 oCreator = CreateObject(OBJECT_TYPE_PLACEABLE,"plc_invisobj",GetLocation(oTarget),FALSE,"70_EC_POISON");
 ApplyEffectToObject(DURATION_TYPE_PERMANENT,ExtraordinaryEffect(EffectVisualEffect(VFX_DUR_CUTSCENE_INVISIBILITY)),oCreator);
 SetPlotFlag(oCreator,TRUE);
  if(oCreator == OBJECT_INVALID)
  {
  WriteTimestampedLogEntry("ERROR: Poison Effect Creator not found, some features might not work properly!");
  oCreator = oTarget;
  }
 }
return oCreator;
}

void Poison(int nPoisonID, int bSecondary = FALSE)
{
object oTarget = OBJECT_SELF;
object oCreator = GetPoisonEffectCreator(oTarget);
 if(!bSecondary)
 {
 AssignCommand(oCreator,Apply1stPoison(oTarget,nPoisonID));
 }
 else
 {
 AssignCommand(oCreator,Apply2stPoison(oTarget,nPoisonID));
 }
}
