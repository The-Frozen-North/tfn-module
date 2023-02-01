#include "NW_I0_PLOT"

int StartingConditional()
{
    int l_iResult;

    //l_iResult = CheckIntelligenceNormal() && CheckWisdomHigh();
    l_iResult = CheckWisdomHigh();
    return l_iResult;
}
