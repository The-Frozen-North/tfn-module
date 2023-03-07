void main()
{
	object oDestination = GetObjectByTag("q4b_portal");
	object oPC = GetLastUsedBy();
	if (GetIsPC(oPC))
	{
		AssignCommand(oPC, JumpToLocation(GetLocation(oDestination)));
	}
}