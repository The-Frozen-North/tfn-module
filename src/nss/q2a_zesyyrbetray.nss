///Check if Zesyyr has been exposed by the player

int StartingConditional()
{
    int iResult;

    iResult = GetLocalInt(GetModule(),"Zesyyr_Betray")== TRUE;
    return iResult;
}

