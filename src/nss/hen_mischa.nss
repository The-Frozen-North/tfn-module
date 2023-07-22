void main()
{
    // we suspect this may be causing Mischa to do nothing in combat
    // we will see if this does anything
    DecrementRemainingFeatUses(OBJECT_SELF, FEAT_PALADIN_SUMMON_MOUNT);
    ExecuteScript("hen_scale");
}
