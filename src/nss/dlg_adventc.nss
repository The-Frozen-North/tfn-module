#include "inc_adventurer"
#include "inc_ctoken"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    RevealTrueNameToPlayer(OBJECT_SELF, oPC);
    
    SetCustomToken(CTOKEN_ADVENTURER_DIALOGUE, "It's good to see a friendly soul in these parts. I'm " + GetAdventurerTrueName(OBJECT_SELF) + " - what do you think about teaming up? You can keep any treasures we find - I'm already at capacity, haha.");
    
    return 1;
}