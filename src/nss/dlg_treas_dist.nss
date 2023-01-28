#include "inc_debug"
#include "inc_treasure"

void main()
{
    object oPC = GetPCSpeaker();

    if (GetIsDeveloper(oPC))
    {
        SendDiscordLogMessage(GetName(OBJECT_SELF)+" viewed the treasure distribution store.");
        OpenStore(GetObjectByTag(TREASURE_DISTRIBUTION), oPC);
    }
}
