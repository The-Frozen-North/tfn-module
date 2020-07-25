void main()
{
     object oItem = GetItemActivated();

     ExecuteScript("5_"+GetResRef(oItem), GetItemActivator());

}
