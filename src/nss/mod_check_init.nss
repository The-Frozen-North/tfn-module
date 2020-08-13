#include "nwnx_admin"
#include "nwnx_util"
#include "inc_nwnx"

void main()
{
    SpeakString("Initializing...", TALKVOLUME_SHOUT);

    object oModule = GetModule();

    if (GetLocalInt(oModule, "treasure_ready") == 1)
    {
        NWNX_Util_SetInstructionLimit(-1);
        NWNX_Administration_ClearPlayerPassword();
        SetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_HEARTBEAT, "on_mod_heartb");
        SendDiscordLogMessage("The server is now online.");
    }
}
