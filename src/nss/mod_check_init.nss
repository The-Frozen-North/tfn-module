#include "nwnx_admin"
#include "nwnx_util"
#include "inc_webhook"

void main()
{
    SpeakString("Initializing...", TALKVOLUME_SHOUT);

    object oModule = GetModule();

    if (GetLocalInt(oModule, "treasure_ready") == 1)
    {
        NWNX_Util_SetInstructionLimit(-1);
        NWNX_Administration_ClearPlayerPassword();
        NWNX_Administration_SetDMPassword(Get2DAString("env", "Value", 3));
        SetEventScript(oModule, EVENT_SCRIPT_MODULE_ON_HEARTBEAT, "on_mod_heartb");
        ServerWebhook("The Frozen North is ready!", "The Frozen North server is ready for players to login.");
    }
}
