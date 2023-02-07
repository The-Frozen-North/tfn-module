// For some reason the pentagram in Jhareg doesn't draw very reliably
// when you aren't near it when it was made.


void RemoveAllEffects(object oObj)
{
    effect eTest = GetFirstEffect(oObj);
    while (GetIsEffectValid(eTest))
    {
        DelayCommand(0.0, RemoveEffect(oObj, eTest));
        eTest = GetNextEffect(oObj);
    }
}

object GetPentagramDummy(int nIndex)
{
    if (nIndex >= 1 && nIndex <= 5)
    {
        return GetObjectByTag("jhareg_pedestal_dummy" + IntToString(nIndex));
    }
    if (nIndex < 1)
    {
        return GetPentagramDummy(5);
    }
    // 5+ gets the first
    return GetPentagramDummy(1);
}

void main()
{
    if (GetIsPC(GetEnteringObject())) { return; }
    object oBelial = GetLocalObject(GetArea(OBJECT_SELF), "belial");
    // Belial is freed, don't redo the pentagram
    if (!GetPlotFlag(oBelial))
    {
        return;
    }
    int i;
    for (i=1; i<=5; i++)
    {
        object oThis = GetPentagramDummy(i);
        RemoveAllEffects(oThis);
    }
    for (i=1; i<=5; i++)
    {
        object oThis = GetPentagramDummy(i);
        //AssignCommand(oThis, SpeakString(IntToString(i)));
        object oNext = GetPentagramDummy(i+1);
        DelayCommand(IntToFloat(i)/30.0, ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(VFX_BEAM_SILENT_EVIL, oThis, BODY_NODE_CHEST, FALSE, 1.0), oNext));
        //SendMessageToPC(GetFirstPC(), "Beam between " + ObjectToString(oThis) + " " + IntToString(i) + " and " + ObjectToString(oNext) + " " + IntToString(i+1));
    }
}
