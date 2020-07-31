void main()
{
     object oItem = GetItemActivated();

     ExecuteScript(GetResRef(oItem), GetItemActivator());

}
