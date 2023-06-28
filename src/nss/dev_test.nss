#include "inc_nui_config"

void main()
{
    AssignCommand(GetFirstPC(), SpeakString("dev_test"));
    ExecuteScript("pc_xpbar", GetFirstPC());
    DisplayUIMasterConfigurationInterface(GetFirstPC());
}