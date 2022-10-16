void main()
{
    string sParam = GetScriptParam("action");
    object oPC = StringToObject(GetScriptParam("pc"));
    if (sParam == "load")
    {
        // Corridor floors
        SetTextureOverride("tic01_halflr", "tic01_jailflr01", oPC);
        // Non-jail room walls
        SetTextureOverride("tic01_richwall", "tic01_jailwall", oPC);
        // Many pillars and supports
        SetTextureOverride("tic01_cbrddr02", "tic01_jailwall", oPC);
        // Some doorways and supports
        SetTextureOverride("tic01_stone20", "tic01_jailwall", oPC); 
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
    }
}