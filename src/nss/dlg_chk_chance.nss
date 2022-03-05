int StartingConditional()
{
    if (StringToInt(GetScriptParam("chance")) >= d100()) return TRUE;

    return FALSE;
}
