void main()
{
    object oPC = GetLastUsedBy();
	location lTarget = GetLocation(GetWaypointByTag("MeldanenPortalTarget"));
	
	ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_IMP_UNSUMMON), GetLocation(oPC));
    ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_IMP_UNSUMMON), lTarget);
	
	AssignCommand(oPC, DelayCommand(0.5, JumpToLocation(lTarget)));
}
