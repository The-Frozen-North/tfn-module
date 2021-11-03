#include "inc_henchman"
#include "inc_general"

void main()
{
    SpeakString("PARTY_I_WAS_ATTACKED", TALKVOLUME_SILENT_TALK);

    SetLocalInt(OBJECT_SELF, "times_died", GetLocalInt(OBJECT_SELF, "times_died")+1);

    string sText = "*Your henchman has died*";

    if (!IsCreatureRevivable(OBJECT_SELF))
        sText = "*Your henchman has died, and can only be revived by Raise Dead*";


    FloatingTextStringOnCreature(sText, GetMaster(OBJECT_SELF), FALSE);

    KillTaunt(GetLastHostileActor(OBJECT_SELF), OBJECT_SELF);
}
