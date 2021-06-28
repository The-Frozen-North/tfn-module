#include "NW_I0_PLOT"

int StartingConditional()
{
    object oReturn = GetLocalObject(GetModule(),"NW_G_M1Q2Returnee");
//    return GetIsObjectValid(oReturn) &&
//           oReturn == GetPCSpeaker();
    if (GetIsObjectValid(oReturn) && oReturn == GetPCSpeaker())
    {
        return TRUE;
    }
    return FALSE;
}

