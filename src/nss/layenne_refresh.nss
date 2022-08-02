// Layenne's tomb refresh


void main()
{
    int bAmethyst = 0;
    int bEmerald = 0;
    int bDiamond = 0;
    int bSapphire = 0;

    // If someone spawned the middle one, delete it
    object oCentral = GetObjectByTag("LayenneCentralPedestalPlc");
    if (GetIsObjectValid(oCentral))
    {
        DestroyObject(oCentral);
    }
    int i;
    for (i=1; i<=4; i++)
    {
        object oPed = GetObjectByTag("LayennePedestal" + IntToString(i));
        object oVFX = GetLocalObject(oPed, "VFX1");
        if (GetIsObjectValid(oVFX))
        {
            DestroyObject(oVFX);
        }
        oVFX = GetLocalObject(oPed, "VFX2");
        if (GetIsObjectValid(oVFX))
        {
            DestroyObject(oVFX);
        }
        DestroyObject(oPed);
        object oWP = GetWaypointByTag("LayenneSparkle" + IntToString(i));
        oPed = CreateObject(OBJECT_TYPE_PLACEABLE, "layenne_ped_plc", GetLocation(oWP), FALSE, "LayennePedestal" + IntToString(i));
        int nRoll = Random(4);
        while (1)
        {
            if (nRoll == 0 && !bAmethyst) { break; }
            else if (nRoll == 0 && bAmethyst) { nRoll++; }
            if (nRoll == 1 && !bEmerald) { break; }
            else if (nRoll == 1 && bEmerald) { nRoll++; }
            if (nRoll == 2 && !bDiamond) { break; }
            else if (nRoll == 2 && bDiamond) { nRoll++; }
            if (nRoll == 3 && !bSapphire) { break; }
            else if (nRoll == 3 && bSapphire) { nRoll = 0; }
        }
        int nVFX;
        string sPlaceableVFX;
        
        if (nRoll == 0)
        {
            SetLocalString(oPed, "layenne_gem", "amethyst");
            nVFX = VFX_DUR_LIGHT_PURPLE_15;
            sPlaceableVFX = "plc_solpurple";
            bAmethyst = 1;
        }
        else if (nRoll == 1) 
        {
            SetLocalString(oPed, "layenne_gem", "emerald");
            nVFX = 179;
            sPlaceableVFX = "plc_solgreen";
            bEmerald = 1;
        }
        else if (nRoll == 2)
        {
            SetLocalString(oPed, "layenne_gem", "diamond");
            nVFX = VFX_DUR_LIGHT_WHITE_15;
            sPlaceableVFX = "plc_solwhite";
            bDiamond = 1;
        }
        else if (nRoll == 3)
        {
            SetLocalString(oPed, "layenne_gem", "sapphire");
            nVFX = VFX_DUR_LIGHT_BLUE_15;
            sPlaceableVFX = "plc_solblue";
            bSapphire = 1;
        }
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectVisualEffect(nVFX), oPed);
        oVFX = CreateObject(OBJECT_TYPE_PLACEABLE, sPlaceableVFX, GetLocation(oWP));
        SetLocalObject(oPed, "VFX1", oVFX);
    }
}
