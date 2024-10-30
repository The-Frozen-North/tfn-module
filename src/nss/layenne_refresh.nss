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
    // The four gem insert pedestals, and the four hint VFX around the tomb
    for (i=1; i<=4; i++)
    {
        object oPed = GetObjectByTag("LayennePedestal" + IntToString(i));
        object oVFX = GetLocalObject(oPed, "VFX1");
        if (GetIsObjectValid(oVFX))
        {
            SetPlotFlag(oVFX, 0);
            DestroyObject(oVFX);
        }
        oVFX = GetLocalObject(oPed, "VFX2");
        if (GetIsObjectValid(oVFX))
        {
            SetPlotFlag(oVFX, 0);
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



        oWP = GetWaypointByTag("LayenneHint" + IntToString(i));
        DestroyObject(GetLocalObject(oWP, "VFX1"));
        oVFX = CreateObject(OBJECT_TYPE_PLACEABLE, sPlaceableVFX, GetLocation(oWP));
        SetPlotFlag(oVFX, 1);
        SetLocalObject(oWP, "VFX1", oVFX);
    }

    // The four glyph generators for the iron golem fight
    for (i=1; i<=4; i++)
    {
        object oWP = GetWaypointByTag("LayenneGlyph" + IntToString(i));
        object oOldGlyph = GetLocalObject(oWP, "LayenneGlyphPlc");
        if (GetIsObjectValid(oOldGlyph))
        {
            DestroyObject(oOldGlyph);
        }
        object oGlyph = CreateObject(OBJECT_TYPE_PLACEABLE, "layenne_glyphgen", GetLocation(oWP));
        SetName(oGlyph, GetStringByStrRef(47501)); // "Glyph Generator"
        SetLocalObject(oWP, "LayenneGlyphPlc", oGlyph);
        SetEventScript(oGlyph, EVENT_SCRIPT_PLACEABLE_ON_DEATH, "layenne_glyph_d");
    }
}
