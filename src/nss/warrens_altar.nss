void DestroyUndead(object oCreature, effect eBeam)
{
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(100), oCreature);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBeam, oCreature, 1.0);
}

void DestroyUndeadByArea(object oPedestal, string sAreaTag)
{
    object oArea = GetObjectByTag(sAreaTag);
    object oCreature = GetFirstObjectInArea(oArea);

    //DeleteLocalInt(oArea, "ambush");

    string sResRef;
    effect eBeam = EffectBeam(VFX_BEAM_EVIL, oPedestal, BODY_NODE_CHEST);

    while (GetIsObjectValid(oCreature))
    {
        sResRef = GetResRef(oCreature);

        if ((sResRef == "weakzombie" || sResRef == "shadow" || sResRef == "zombie" || sResRef == "zombwar" || sResRef == "zombietyrant" || sResRef == "skeleton"))
        {
            DelayCommand(0.1+(IntToFloat(d4())/10.0), DestroyUndead(oCreature, eBeam));
        }

        oCreature = GetNextObjectInArea(oArea);
    }
}

void main()
{
    object oPedestal = OBJECT_SELF;

    DestroyUndeadByArea(oPedestal, "beg_grave");
    DestroyUndeadByArea(oPedestal, "beg_crypts");
    DestroyUndeadByArea(oPedestal, "beg_warrens");

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_HARM), GetLocation(oPedestal));

    DestroyObject(GetNearestObjectByTag("pedestal_light"));
}
