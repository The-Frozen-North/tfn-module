void main()
{
    int nDoOnce = GetLocalInt(OBJECT_SELF, "DO_ONCE");
    if(nDoOnce == 1)
        return;
    SetLocalInt(OBJECT_SELF, "DO_ONCE", 1);
    DelayCommand(10.0, SetLocalInt(OBJECT_SELF, "DO_ONCE", 0)); // to allow player to use also
    object oWP = GetNearestObjectByTag("q5_wp_grease");
    effect eGrease = EffectAreaOfEffect(AOE_PER_GREASE, "q5_s0_greasea", "q5_s0_greasec", "q5_s0_greaseb");
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eGrease, GetLocation(oWP), RoundsToSeconds(10));
}
