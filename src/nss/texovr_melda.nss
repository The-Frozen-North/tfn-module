void main()
{
    string sParam = GetScriptParam("action");
    object oPC = StringToObject(GetScriptParam("pc"));
    if (sParam == "load")
    {
        // Corridor floors
        SetTextureOverride("tic01_halflr", "tni02_halflr", oPC);
        // Non-jail room walls
        SetTextureOverride("tic01_richwall", "tic01_librwall", oPC);
        // Many pillars and supports
        SetTextureOverride("tic01_cbrddr02", "tic01_librwall", oPC);
        // Some doorways and supports
        SetTextureOverride("tic01_stone20", "tni02_floor01", oPC); 
        // The pesky "edge" texture that is in every room and is really hard to replace
        SetTextureOverride("tic01_floor01", "tni02_floor01", oPC); 
        // The "swirly mosaic"
		SetTextureOverride("tic01_floor00", "tdt01_floor03", oPC); 
    }
    else
    {
        // Corridor floors
        SetTextureOverride("tic01_halflr", "", oPC);
        // Non-jail room walls
        SetTextureOverride("tic01_richwall", "", oPC);
        // Many pillars and supports
        SetTextureOverride("tic01_cbrddr02", "", oPC);
        // Some doorways and supports
        SetTextureOverride("tic01_stone20", "", oPC); 
        // The pesky "edge" texture that is in every room and is really hard to replace
        SetTextureOverride("tic01_floor01", "", oPC); 
        // The "swirly mosaic"
		SetTextureOverride("tic01_floor00", "", oPC); 
    }
}