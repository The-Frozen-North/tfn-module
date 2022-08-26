
void main()
{
    object oPC = GetExitingObject();
	effect eTest = GetFirstEffect(oPC);
	while (GetIsEffectValid(eTest))
	{
		if (GetEffectCreator(eTest) == OBJECT_SELF && GetEffectType(eTest) == EFFECT_TYPE_SPELL_FAILURE && GetEffectTag(eTest) == "obelisk_spellfail")
		{
			RemoveEffect(oPC, eTest);
			break;
		}
		eTest = GetNextEffect(oPC);
	}
}