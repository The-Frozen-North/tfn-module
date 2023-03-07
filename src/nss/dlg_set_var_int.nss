void main()
{
    string sVar = GetScriptParam("var");
    int nValue = StringToInt(GetScriptParam("val"));
    SetLocalInt(OBJECT_SELF, sVar, nValue);
}
