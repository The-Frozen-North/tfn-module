void main()
{
     object oItem = GetItemActivated();

     ExecuteScript(GetResRef(oItem), GetItemActivator());
     ExecuteScript("is_" + GetTag(oItem), GetItemActivator());
}
