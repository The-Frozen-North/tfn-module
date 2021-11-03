void main()
{
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectDisease(DISEASE_DREAD_BLISTERS), OBJECT_SELF);

    switch (d8())
    {
        case 1: PlayAnimation(ANIMATION_LOOPING_PAUSE_DRUNK, 0.7, IntToFloat(d3(3))); break;
        case 2: PlayAnimation(ANIMATION_LOOPING_PAUSE_TIRED, 0.7, IntToFloat(d3(3))); break;
        case 3: PlayAnimation(ANIMATION_LOOPING_SIT_CROSS, 0.7, IntToFloat(d8(4))); break;
    }

}
