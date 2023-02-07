void main()
{
    int nAmount = StringToInt(GetScriptParam("amount"));
    TakeGoldFromCreature(nAmount, GetPCSpeaker(), TRUE);
}
