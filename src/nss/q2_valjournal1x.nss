///Check if Valen journal given the players
///Initial Journal entries on Mirror and Maker plots

int StartingConditional()
{
    int iResult;

    iResult = GetLocalInt(GetModule(),"Valen_Journal")==1;
    return iResult;
}

