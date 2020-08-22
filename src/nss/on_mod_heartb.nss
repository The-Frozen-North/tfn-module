#include "inc_persist"
#include "inc_debug"
#include "inc_henchman"
#include "nwnx_util"

void DoRevive(object oDead)
{
        if (GetIsDead(oDead))
        {
            SendDebugMessage(GetName(oDead)+" is dead, start revive loop");
            int bEnemy = FALSE;
            int bFriend = FALSE;
            int bMasterFound = FALSE;

            object oMaster = GetMasterByUUID(oDead);
            int bMasterDead = GetIsDead(oMaster);

            location lLocation = GetLocation(oDead);

            float fSize = 45.0;

            float fMasterDistance = GetDistanceBetween(oDead, oMaster);
            if (fMasterDistance > 0.0 && fMasterDistance <= 100.0) bMasterFound = TRUE;

            object oCreature = GetFirstObjectInShape(SHAPE_SPHERE, fSize, lLocation, TRUE, OBJECT_TYPE_CREATURE);

            while (GetIsObjectValid(oCreature))
            {
// do not count self and count only if alive
                if (!GetIsDead(oCreature) && (oCreature != oDead))
                {
                    if (GetIsEnemy(oCreature, oDead))
                    {
                        bEnemy = TRUE;
                        SendDebugMessage("Enemy detected, breaking from revive loop: "+GetName(oCreature));
                        break;
                    }
                    else if (!bFriend && GetIsFriend(oCreature, oDead))
                    {
                        bFriend = TRUE;
                        SendDebugMessage("Friend detected: "+GetName(oCreature));
                    }

                }

                oCreature = GetNextObjectInShape(SHAPE_SPHERE, fSize, lLocation, TRUE, OBJECT_TYPE_CREATURE);
            }

            if (GetStringLeft(GetResRef(oDead), 3) == "hen" && bMasterFound && !bMasterDead) bFriend = TRUE;

            if (!bEnemy && bFriend)
            {
                NWNX_Object_DeleteInt(oDead, "DEAD");
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), oDead);
                if (GetStringLeft(GetResRef(oDead), 3) == "hen" && bMasterFound) SetMaster(oDead, oMaster);
                WriteTimestampedLogEntry(GetName(oDead)+" was revived by friendly "+GetName(oCreature)+".");
            }

// destroy henchman if still not alive and master isn't found
            if (!GetIsPC(oDead) && GetIsDead(oDead) && GetStringLeft(GetResRef(oDead), 3) == "hen" && !bMasterFound)
            {
                 ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_RESTORATION), lLocation);
                 ClearMaster(oDead);
                 DestroyObject(oDead);
            }
        }
}


void main()
{
    object oPC = GetFirstPC();

    ExportAllCharacters();

    if (GetIsObjectValid(oPC))
    {
        int nTickCount = NWNX_Util_GetServerTicksPerSecond();
        if (nTickCount <= 50) SendDebugMessage("Low tick count detected: "+IntToString(nTickCount), TRUE);
    }

    //ExportAllCharacters();

    while(GetIsObjectValid(oPC))
    {
        DoRevive(oPC);

        SavePCInfo(oPC);

        oPC = GetNextPC();
    }

    DoRevive(GetObjectByTag("hen_tomi"));
    DoRevive(GetObjectByTag("hen_daelan"));
    DoRevive(GetObjectByTag("hen_sharwyn"));
    DoRevive(GetObjectByTag("hen_linu"));
}
