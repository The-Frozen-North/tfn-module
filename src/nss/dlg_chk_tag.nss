int StartingConditional()
{
    string sTest = GetScriptParam("tag");

    return GetTag(OBJECT_SELF) == sTest;
}
