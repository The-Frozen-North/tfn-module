#include "nwnx_events"
#include "nwnx_object"

void main()
{
    int nPrice = StringToInt(NWNX_Events_GetEventData("PRICE"));
    if (GetIsPC(OBJECT_SELF) && GetGold(OBJECT_SELF) >= nPrice)
    {
        object oItem = NWNX_Object_StringToObject(NWNX_Events_GetEventData("ITEM"));
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
                        case 1: sOneLiner = "What a steal!";
                        case 2: sOneLiner = "Whoa, that's nice! Can I have it back?";
                        case 3: sOneLiner = "Fate smiles on you today.";
                        case 4: sOneLiner = "Such a brave soul!";
                        case 5: sOneLiner = "What a steal!";
                        case 6: sOneLiner = "What?! I never even knew I had that thing!";
                    }
                }
                else
                {
                    switch (d6())
                    {
                        case 1: sOneLiner = "A good paperweight.";
                        case 2: sOneLiner = "I've seen better.";
                        case 3: sOneLiner = "Fortune favors the bold.";
                        case 4: sOneLiner = "Do come back again.";
                        case 5: sOneLiner = "Let's see what happens, shall we?";
                        case 6: sOneLiner = "Don't forget - luck always changes.";
                    }
                }
                AssignCommand(oKhadala, SpeakString(sOneLiner));
            }
        }
    }
}
