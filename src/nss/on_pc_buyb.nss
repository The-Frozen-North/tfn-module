#include "nwnx_events"

void main()
{
    int nPrice = StringToInt(NWNX_Events_GetEventData("PRICE"));
    if (GetIsPC(OBJECT_SELF) && GetGold(OBJECT_SELF) >= nPrice)
    {
        object oItem = StringToObject(NWNX_Events_GetEventData("ITEM"));
        object oKhadala = GetObjectByTag("khadala");
        if (GetTag(oItem) == "gamble")
        {
            NWNX_Events_SkipEvent();
            object oNewItem = CopyItem(GetLocalObject(oItem, "item"), OBJECT_SELF, TRUE);
            DestroyObject(oItem);

            TakeGoldFromCreature(nPrice, OBJECT_SELF, TRUE);

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
    }
}
