#include "nw_inc_nui"

void main()
{
    string sWindow = NuiGetWindowId(NuiGetEventPlayer(), NuiGetEventWindow());
    ExecuteScript(sWindow + "_evt");
}