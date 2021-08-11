///Check if zesyyr is the new House Mother

int StartingConditional()
{
    int iResult;

    iResult = GetLocalInt(GetModule(),"Zesyyr_Rule")== TRUE;
    return iResult;
}
