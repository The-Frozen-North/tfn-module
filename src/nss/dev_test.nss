// This is a script file intended to be compiled into /development for testing.
// It IS useful because it means you can change includes and get a full recompile of all dependencies
// and know that they are being called
// The NWScript debug window, as nice as it is, can't do that!
// It also seems like there's a limit on the amount of stuff you can copy in at a time.
// (and there's no batch file to put .nss into development at the moment, that seems messy anyway as the whole include tree would probably have to go in)
#include "inc_webhook"

void CheckNPC()
{
    object oPC = GetPCSpeaker();
    if (!GetIsObjectValid(oPC) || GetArea(oPC) != GetArea(OBJECT_SELF))
    {
        WriteTimestampedLogEntry(GetName(OBJECT_SELF) + "(oid " + ObjectToString(OBJECT_SELF) + ") is in invalid conversation");
        WriteTimestampedLogEntry("   current action=" + IntToString(GetCurrentAction(OBJECT_SELF)));
        WriteTimestampedLogEntry("   invalid pc=" + GetName(oPC) + ", oid=" + ObjectToString(oPC));
        object oLastSpeaker = GetLastSpeaker();
        WriteTimestampedLogEntry("   last speaker=" + GetName(oLastSpeaker) + ", oid=" + ObjectToString(oLastSpeaker));
        SendDiscordLogMessage(GetName(OBJECT_SELF) + " in " + GetName(GetArea(OBJECT_SELF)) + " is bugged. Last speaker=" + GetName(oLastSpeaker) + ", oid=" + ObjectToString(oLastSpeaker));
    }
}

void CheckAreaNPCs(object oArea)
{
    WriteTimestampedLogEntry("Check area: " + GetName(oArea));
    object oTest = GetFirstObjectInArea(oArea);
    int nCount = 0;
    while (GetIsObjectValid(oTest))
    {
        if (GetObjectType(oTest) == OBJECT_TYPE_CREATURE)
        {
            if (!GetIsDead(oTest) && !GetIsPC(oTest))
            {
                nCount++;
                if (IsInConversation(oTest))
                {
                    AssignCommand(oTest, CheckNPC());
                }
            }
        }
        oTest = GetNextObjectInArea(oArea);
    }
    WriteTimestampedLogEntry("Finished checking " + IntToString(nCount) + " NPCs in " + GetName(oArea) + ", tag=" + GetTag(oArea));
}

void main()
{
    float fDelay;
    object oTest = GetFirstArea();
    while (GetIsObjectValid(oTest))
    {
        DelayCommand(fDelay, CheckAreaNPCs(oTest));
        fDelay += 2.0;
        oTest = GetNextArea();
    }
    DelayCommand(fDelay, SendMessageToPC(OBJECT_SELF, "Done!"));
    DelayCommand(fDelay, SendDiscordLogMessage("Finished checking for broken NPCs."));
}