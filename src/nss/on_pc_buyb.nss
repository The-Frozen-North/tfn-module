#include "nwnx_events"
#include "inc_webhook"

void main()
{
    int nPrice = StringToInt(NWNX_Events_GetEventData("PRICE"));
    if (GetIsPC(OBJECT_SELF) && GetGold(OBJECT_SELF) >= nPrice)
    {
        object oItem = StringToObject(NWNX_Events_GetEventData("ITEM"));

        if (GetTag(oItem) == "gamble")
        {
            object oKhadala = GetObjectByTag("khadala");
            
            NWNX_Events_SkipEvent();
            object oNewItem = CopyItem(GetLocalObject(oItem, "item"), OBJECT_SELF, TRUE);
            DestroyObject(oItem);

            TakeGoldFromCreature(nPrice, OBJECT_SELF, TRUE);
            // The random items should never be valuable enough to trigger this
            // in the _AFTER of the same event!
            ValuableItemWebhook(OBJECT_SELF, oNewItem, TRUE);

            if (d4() == 1)
            {
                string sOneLiner = "";
                if (GetGoldPieceValue(oNewItem) > 6000)
                {
                    switch (d6())
                    {
                        case 1: sOneLiner = "What a steal!"; break;
                        case 2: sOneLiner = "Whoa, that's nice! Can I have it back?"; break;
                        case 3: sOneLiner = "Fate smiles on you today."; break;
                        case 4: sOneLiner = "Such a brave soul!"; break;
                        case 5: sOneLiner = "What a steal!"; break;
                        case 6: sOneLiner = "What?! I never even knew I had that thing!"; break;
                    }
                }
                else
                {
                    switch (d6())
                    {
                        case 1: sOneLiner = "A good paperweight."; break;
                        case 2: sOneLiner = "I've seen better."; break;
                        case 3: sOneLiner = "Fortune favors the bold."; break;
                        case 4: sOneLiner = "Do come back again."; break;
                        case 5: sOneLiner = "Let's see what happens, shall we?"; break;
                        case 6: sOneLiner = "Don't forget - luck always changes."; break;
                    }
                }
                AssignCommand(oKhadala, SpeakString(sOneLiner));
            }
        }
        else if (IsAmmoInfinite(oItem))
        {
            int nBaseItem = GetBaseItemType(oItem);

            if (nBaseItem == BASE_ITEM_DART || 
                nBaseItem == BASE_ITEM_THROWINGAXE || 
                nBaseItem == BASE_ITEM_SHURIKEN || 
                nBaseItem == BASE_ITEM_ARROW || 
                nBaseItem == BASE_ITEM_BOLT || 
                nBaseItem == BASE_ITEM_BULLET)
            {
                SetLocalString(oItem, "buy_uuid", GetRandomUUID());    
            }
        }
    }
}
