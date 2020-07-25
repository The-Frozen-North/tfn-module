void ApplyDiseaseAbilityDecrease(object oTarget, int nDiseaseID)
{
SetLocalInt(oTarget,"DISEASE_ID",nDiseaseID);
//roll, immunity check and vfx is handled by game engine
effect eDisease;
string s2DA,sn;
int n, nAbility, nDice, nDam, nDamage;
 for(n=1;n<4;n++)
 {
 sn = IntToString(n);
 s2DA = Get2DAString("disease","Type"+sn,nDiseaseID);
  if(s2DA == "****" || s2DA == "") break;
 nAbility = StringToInt(s2DA);
 nDice = StringToInt(Get2DAString("disease","Dice"+sn,nDiseaseID));
 nDam = StringToInt(Get2DAString("disease","Dam"+sn,nDiseaseID));
 nDamage = 0;
  while(nDam-- > 0)
  {
  nDamage+= Random(nDice)+1;
  }
  if(nDamage > 0)
  {
  eDisease = EffectLinkEffects(eDisease,EffectAbilityDecrease(nAbility,nDamage));
  }
 }
 if(n > 1)
 {
 ApplyEffectToObject(DURATION_TYPE_PERMANENT,SupernaturalEffect(eDisease),oTarget);
 }
}

object GetDiseaseEffectCreator(object oTarget)
{
object oCreator = GetObjectByTag("70_EC_DISEASE");
 if(!GetIsObjectValid(oCreator))
 {
 oCreator = CreateObject(OBJECT_TYPE_PLACEABLE,"plc_invisobj",GetLocation(oTarget),FALSE,"70_EC_DISEASE");
 ApplyEffectToObject(DURATION_TYPE_PERMANENT,ExtraordinaryEffect(EffectVisualEffect(VFX_DUR_CUTSCENE_INVISIBILITY)),oCreator);
 SetPlotFlag(oCreator,TRUE);
  if(oCreator == OBJECT_INVALID)
  {
  WriteTimestampedLogEntry("ERROR: Disease Effect Creator not found, some features might not work properly!");
  oCreator = oTarget;
  }
 }
return oCreator;
}

void Disease(int nDiseaseID)
{
object oTarget = OBJECT_SELF;
object oCreator = GetDiseaseEffectCreator(oTarget);
AssignCommand(oCreator,ApplyDiseaseAbilityDecrease(oTarget,nDiseaseID));
}
