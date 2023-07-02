void main()
{
    ExecuteScript("luskan_cityfac");

    // 1 out of 4 NPCs will be asleep permanently until damaged.
    if (d4() == 1)
    {
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectSleep(), OBJECT_SELF);
    }
}
