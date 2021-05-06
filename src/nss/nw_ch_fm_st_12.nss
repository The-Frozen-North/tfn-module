void main()
{
    //int nHeal = GetMaxHitPoints();
    //effect eHeal = EffectHeal(nHeal);
    //ApplyEffectToObject(DURATION_TYPE_INSTANT,eHeal,OBJECT_SELF);

    SetLocalInt(OBJECT_SELF, "fed", 1);
    DelayCommand(300.0, DeleteLocalInt(OBJECT_SELF, "fed"));
}
