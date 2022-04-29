#include "inc_henchman"
#include "inc_general"

void main()
{
     if (GetLocalInt(OBJECT_SELF, "PETRIFIED") == 1)
    {
        location lLocation = GetLocation(OBJECT_SELF);
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_COM_CHUNK_STONE_MEDIUM), lLocation);
        ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_RESTORATION), lLocation);

        DestroyObject(OBJECT_SELF);

        // don't do the rest of the script
        return;
    }


    SpeakString("PARTY_I_WAS_ATTACKED", TALKVOLUME_SILENT_TALK);

    SetLocalInt(OBJECT_SELF, "times_died", GetLocalInt(OBJECT_SELF, "times_died")+1);

    string sText = "*Your henchman has died*";

    if (!IsCreatureRevivable(OBJECT_SELF))
        sText = "*Your henchman has died, and can only be revived by Raise Dead*";


    FloatingTextStringOnCreature(sText, GetMaster(OBJECT_SELF), FALSE);

    KillTaunt(GetLastHostileActor(OBJECT_SELF), OBJECT_SELF);

    if (GibsNPC(OBJECT_SELF))
    {
        DoMoraleCheckSphere(OBJECT_SELF, MORALE_PANIC_GIB_DC);
    }
    else
    {
        DoMoraleCheckSphere(OBJECT_SELF, MORALE_PANIC_DEATH_DC);
    }
}
