#include "inc_follower"

int StartingConditional()
{
    int iResult;

    iResult = CheckFollowerMaster(OBJECT_SELF, GetPCSpeaker());
    return iResult;
}
