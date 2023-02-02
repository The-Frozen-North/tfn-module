void main()
{
    string sParam = GetScriptParam("action");
    object oPC = StringToObject(GetScriptParam("pc"));
    if (sParam == "load")
    {
        // Fog
        SetTextureOverride("silm_fog_cloud", "fog05", oPC);
    }
    else
    {
        // Fog
        SetTextureOverride("silm_fog_cloud", "", oPC);
    }
}
