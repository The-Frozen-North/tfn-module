#include "1_inc_persist"
#include "1_inc_debug"

void main()
{
    object oPC = GetFirstPC();

    //ExportAllCharacters();

    while(GetIsObjectValid(oPC))
    {
        if (GetIsDead(oPC))
        {
            SendDebugMessage(GetName(oPC)+" is dead, start revive loop");
            int bEnemy = FALSE;
            int bFriend = FALSE;

            location lLocation = GetLocation(oPC);

            float fSize = 50.0;

            object oCreature = GetFirstObjectInShape(SHAPE_SPHERE, fSize, lLocation, TRUE, OBJECT_TYPE_CREATURE);

            while (GetIsObjectValid(oCreature))
            {
// do not count self and count only if alive
                if (!GetIsDead(oCreature) && (oCreature != oPC))
                {
                    if (GetIsEnemy(oCreature, oPC))
                    {
                        bEnemy = TRUE;
                        SendDebugMessage("Enemy detected, breaking from revive loop: "+GetName(oCreature));
                        break;
                    }
                    else if (!bFriend && GetIsFriend(oCreature, oPC))
                    {
                        bFriend = TRUE;
                        SendDebugMessage("Friend detected: "+GetName(oCreature));
                    }

                }

                oCreature = GetNextObjectInShape(SHAPE_SPHERE, fSize, lLocation, TRUE, OBJECT_TYPE_CREATURE);
            }

            if (!bEnemy && bFriend)
            {
                NWNX_Object_DeleteInt(oPC, "DEAD");
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), oPC);
                WriteTimestampedLogEntry(PlayerDetailedName(oPC)+" was revived by friendly "+GetName(oCreature)+".");
            }
        }

        SavePCInfo(oPC);

        oPC = GetNextPC();
    }
}
