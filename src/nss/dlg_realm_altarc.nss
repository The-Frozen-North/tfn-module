void main()
{
    object oPC = GetPCSpeaker();

    ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectVisualEffect(VFX_FNF_GAS_EXPLOSION_NATURE),oPC);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT,EffectDisease(DISEASE_BLINDING_SICKNESS),oPC);
}
