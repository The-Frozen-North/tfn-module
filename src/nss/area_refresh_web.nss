void Webs(string sVar, int nVFX)
{        
    int nCount = GetLocalInt(OBJECT_SELF, sVar);
    int i;
    for (i=0; i<nCount; i++)
    {
        object oPetrified = GetLocalObject(OBJECT_SELF, sVar + IntToString(i) + "_plc");
        if (GetIsObjectValid(oPetrified))
        {
            DestroyObject(oPetrified);
        }
        location lLoc = GetLocalLocation(OBJECT_SELF, sVar + IntToString(i));
        oPetrified = CreateObject(OBJECT_TYPE_PLACEABLE, "invisibleobject", lLoc);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectVisualEffect(nVFX), oPetrified);
        SetLocalObject(OBJECT_SELF, sVar + IntToString(i) + "_plc", oPetrified);
    }
}

void main()
{
    Webs("largewebs", VFX_DUR_WEB_MASS);
    Webs("smallwebs", VFX_DUR_WEB);
}