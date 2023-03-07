// Maker sanctum mithral golems don't chase players
// probably also stops ranged doorway cheese

void main()
{
    object oEnter = GetEnteringObject();

    if(GetResRef(oEnter) == "mithralgolem")
    {
        effect eVis = EffectVisualEffect(VFX_IMP_UNSUMMON);
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, GetLocation(oEnter));
        location lJump = GetLocalLocation(oEnter, "spawn");
        AssignCommand(oEnter, ClearAllActions(TRUE));
        AssignCommand(oEnter, JumpToLocation(lJump));
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(d6(4)), oEnter);
    }
}
