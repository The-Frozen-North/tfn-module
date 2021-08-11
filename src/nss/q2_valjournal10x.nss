///Check if Cavallas journal given the players
///Follow up journal entries on Mirror and Maker plots
///Opens up boat for player travel

int StartingConditional()
{
    int iResult;

    iResult = GetLocalInt(GetModule(),"Valen_Journal")>=10;
    return iResult;
}


