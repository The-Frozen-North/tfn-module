void main()
{
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectDisease(DISEASE_DREAD_BLISTERS), OBJECT_SELF);

    switch (d8())
    {
        case 1: PlayAnimation(ANIMATION_LOOPING_PAUSE_DRUNK, 1.0, IntToFloat(d3(3))); break;
        case 2: PlayAnimation(ANIMATION_LOOPING_PAUSE_TIRED, 1.0, IntToFloat(d3(3))); break;
        case 3: PlayAnimation(ANIMATION_FIREFORGET_DRINK); break;
        case 4:
        case 5: PlayAnimation(ANIMATION_LOOPING_SIT_CROSS, 1.0, IntToFloat(d10(5))); break;
    }

}
