void DoPassOut(object oPC)
{
    ClearAllActions();
    AssignCommand(oPC,ClearAllActions());
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectKnockdown(),oPC,10.0);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,EffectAbilityDecrease(ABILITY_INTELLIGENCE,6),oPC,HoursToSeconds(1));
    ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_IMP_SLEEP),oPC);
    ActionResumeConversation();
}

int StartingConditional()
{
    ActionPauseConversation();
    object oPC = GetPCSpeaker();
    AssignCommand(oPC, ActionPlayAnimation(ANIMATION_FIREFORGET_DRINK));

    if (GetAbilityScore(oPC, ABILITY_CONSTITUTION) >= StringToInt(GetScriptParam("constitution")))
    {
        ActionResumeConversation();
        return TRUE;
    }
    else
    {
        DelayCommand(1.0, DoPassOut(oPC));
        return FALSE;
    }
}
