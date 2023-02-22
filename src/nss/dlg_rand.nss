// param "chance" -> % chance of this being valid

int StartingConditional()
{
    int nChance = StringToInt(GetScriptParam("chance"));
    if (Random(100) < nChance)
    {
        return 1;
    }
    return 0;
}
