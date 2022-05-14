#include "nwnx_events"

void main()
{
    object oItem = StringToObject(NWNX_Events_GetEventData("ITEM_OBJECT_ID"));
    object oTarget = StringToObject(NWNX_Events_GetEventData("TARGET_OBJECT_ID"));
    object oOwner = GetItemPossessor(oItem);
    int nBaseItemType = GetBaseItemType(oItem);

    if ((nBaseItemType == BASE_ITEM_POTIONS || nBaseItemType == BASE_ITEM_ENCHANTED_POTION) && !GetIsPC(oTarget) && GetIsPC(oOwner) && GetMaster(oTarget) == oOwner)
    {
        PlayVoiceChat(VOICE_CHAT_THANKS, oTarget);
    }

    ExecuteScript("remove_invis", OBJECT_SELF);
}
