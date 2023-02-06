void RemoveAllEffects(object oObj)
{
    effect eTest = GetFirstEffect(oObj);
    while (GetIsEffectValid(eTest))
    {
        DelayCommand(0.0, RemoveEffect(oObj, eTest));
        eTest = GetNextEffect(oObj);
    }
}

object GetPentagramDummy(int nIndex)
{
    if (nIndex >= 1 && nIndex <= 5)
    {
        return GetObjectByTag("jhareg_pedestal_dummy" + IntToString(nIndex));
    }
    if (nIndex < 1)
    {
        return GetPentagramDummy(5);
    }
    // 5+ gets the first
    return GetPentagramDummy(1);
}


void main()
{
	string sAction = GetScriptParam("action");
	object oPC = GetPCSpeaker();
	if (sAction == "knock")
	{
		ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d6(2), DAMAGE_TYPE_FIRE), oPC);
	}
	else if (sAction == "water")
	{
		ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SMOKE_PUFF), OBJECT_SELF);
		location lSelf = GetLocation(OBJECT_SELF);
		object oTest = GetFirstObjectInShape(SHAPE_SPHERE, 3.0, lSelf);
		while (GetIsObjectValid(oTest))
		{
			if (GetObjectType(oTest) == OBJECT_TYPE_CREATURE && !GetIsDead(oTest))
			{
				if (ReflexSave(oTest, 14, SAVING_THROW_TYPE_FIRE, OBJECT_SELF))
				{
					ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_REFLEX_SAVE_THROW_USE), oTest);
				}
				else
				{
					ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d4(2), DAMAGE_TYPE_FIRE), oTest);
					ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectBlindness(), oTest, 6.0);
				}
			}
			oTest = GetNextObjectInShape(SHAPE_SPHERE, 3.0, lSelf);
		}
	}
	else if (sAction == "skull")
	{
		ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SUMMON_MONSTER_1), OBJECT_SELF);
		PlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE);
		SetPlaceableIllumination(OBJECT_SELF, 0);
		object oArea = GetArea(OBJECT_SELF);
		RecomputeStaticLighting(oArea);
		int i;
		for (i=1; i<=5; i++)
		{
			DelayCommand(IntToFloat(i)/2.0, RemoveAllEffects(GetPentagramDummy(i)));
		}
		object oBelial = GetLocalObject(oArea, "belial");
		DelayCommand(3.0, RemoveAllEffects(oBelial));
		DelayCommand(4.0, AssignCommand(oBelial, ActionStartConversation(oPC)));
		SetUseableFlag(OBJECT_SELF, FALSE);
        SetPlotFlag(oBelial, FALSE);
        SetLocalInt(oBelial, "area_cr", 15);
        SetLocalString(oBelial, "heartbeat_script", "hb_belial");
        SetLocalString(oBelial, "perception_script", "percep_belial");
	}
}