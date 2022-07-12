void main()
{
    ExecuteScript("remove_invis", GetLastOpenedBy());
    string sScript = GetLocalString(OBJECT_SELF, "onopen_script");
    if (sScript != "")
    {
        ExecuteScript(sScript, OBJECT_SELF);
    }
}
