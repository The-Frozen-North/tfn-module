void main()
{

// stop if talking to another player
    if (IsInConversation(OBJECT_SELF)) return;

    int nCount = GetLocalInt(OBJECT_SELF, "count");
    SetLocalInt(OBJECT_SELF, "count", nCount+1);

    if (d10() == 1)
    {
        ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectVisualEffect(VFX_FNF_SMOKE_PUFF), GetLocation(OBJECT_SELF));
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectEthereal(), OBJECT_SELF, 5.0);

        return;
    }

    if (nCount < 4) return;

    DeleteLocalInt(OBJECT_SELF, "count");

    float fSize = 15.0;

    string sTalktomeSound = GetLocalString(OBJECT_SELF, "talktome_sound");
    AssignCommand(OBJECT_SELF, ClearAllActions());

    DelayCommand(0.05, AssignCommand(OBJECT_SELF, PlaySound(sTalktomeSound)));

    string sTalktomeText = GetLocalString(OBJECT_SELF, "talktome_text");

    DelayCommand(0.06, AssignCommand(OBJECT_SELF, SpeakString(sTalktomeText)));
    DelayCommand(0.08, AssignCommand(OBJECT_SELF, PlayAnimation(ANIMATION_LOOPING_TALK_FORCEFUL, 1.0, 6.0)));
}
