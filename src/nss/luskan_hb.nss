void main()
{
    object oPC = GetFirstPC();

    while (GetIsObjectValid(oPC))
    {
        if (GetArea(oPC) == OBJECT_SELF)
        {
            SetLocalInt(oPC, "luskan_interrogate", GetLocalInt(oPC, "luskan_interrogate") + 1);
        }
        
        oPC = GetNextPC();
    }
}

