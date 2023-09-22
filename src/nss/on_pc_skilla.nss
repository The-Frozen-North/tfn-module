#include "nwnx_events"
#include "nwnx_object"
#include "inc_horse"
#include "inc_general"
#include "inc_party"

void GiveSkillXP(object oTarget, object oPC, string sSkill)
{
    if (GetIsDead(oTarget)) return;
    if (GetIsPC(oTarget)) return;

    string sIdentifier = "skill_xp_"+GetName(oPC) + GetPCPublicCDKey(oPC);

    // this cannot be awarded again until reset
    if (GetLocalInt(oTarget, sIdentifier) == 1) return;


    SetLocalInt(oTarget, sIdentifier, 1);
    DelayCommand(1800.0, DeleteLocalInt(oTarget, sIdentifier)); // reset in 30 minutes

    // we use party data to award XP. That means to maximize XP value, you must be solo or far away enough from people. 
    // Does that seem odd? Yes. But this is the way to make sure that the correct XP is accounted for if they kill the creature with a party 
    // (players can get more potential XP if they use a skill in a party versus killing them without any successful skill uses)
    // another way to think about it, pickpocketing NPCs or using animal empathy with a party is less risky because you have a party to back you up in case shit hits the fan and they aggro

    int bAmbush = FALSE;
    if (GetLocalInt(oTarget, "ambush") == 1)
    {
        bAmbush = TRUE;
    }

    int bBoss = GetLocalInt(oTarget, "boss");
    int bSemiBoss = GetLocalInt(oTarget, "semiboss");
    int bRare = GetLocalInt(oTarget, "rare");
    float fMultiplier = 1.0;
    if (bBoss == 1)
    {
        fMultiplier = 3.0;
    }
    else if (bSemiBoss == 1 || bRare == 1)
    {
        fMultiplier = 2.0;
    }

    float fXP = GetPartyXPValue(oTarget, bAmbush, Party.AverageLevel, Party.TotalSize, fMultiplier) * SKILL_XP_PERCENTAGE;

    GiveXPToPC(oPC, fXP, FALSE, sSkill);
}

void main()
{
    if (StringToInt(NWNX_Events_GetEventData("SKILL_ID")) == SKILL_PICK_POCKET)
    {
        AssignCommand(OBJECT_SELF, ActionPlayAnimation(ANIMATION_FIREFORGET_STEAL));
        if (GetIsPC(OBJECT_SELF))
        {
            if (StringToInt(NWNX_Events_GetEventData("ACTION_RESULT")))
            {
                IncrementPlayerStatistic(OBJECT_SELF, "pickpockets_succeeded");

                object oTarget = StringToObject(NWNX_Events_GetEventData("TARGET_OBJECT_ID"));
                GiveSkillXP(oTarget, OBJECT_SELF, "Pick Pocketing");
            }
            else
            {
                IncrementPlayerStatistic(OBJECT_SELF, "pickpockets_failed");
            }
        }
    }
    else if (StringToInt(NWNX_Events_GetEventData("SKILL_ID")) == SKILL_ANIMAL_EMPATHY)
    {
        object oTarget = StringToObject(NWNX_Events_GetEventData("TARGET_OBJECT_ID"));

// do not get master from the script function - this may be the PC that successfully used animal empathy
// instead, use the stored master
        object oMaster = GetLocalObject(oTarget, "master");

        SetIsTemporaryEnemy(OBJECT_SELF, oMaster);

        if (GetIsPC(OBJECT_SELF) && StringToInt(NWNX_Events_GetEventData("ACTION_RESULT")))
        {
            GiveSkillXP(oTarget, OBJECT_SELF, "Animal Empathy");
        }
    }
    /* this doesnt seem to work :(
    else if (StringToInt(NWNX_Events_GetEventData("SKILL_ID")) == SKILL_OPEN_LOCK)
    {
        object oTarget = StringToObject(NWNX_Events_GetEventData("TARGET_OBJECT_ID"));

        if (GetIsPC(OBJECT_SELF) && StringToInt(NWNX_Events_GetEventData("ACTION_RESULT"))) //&& !GetLocked(oTarget))
        {
            float fXP = IntToFloat(GetLockUnlockDC(oTarget));

            if (fXP > 0.0)
            {
                fXP = fXP/4.0;
            }
            else
            {
                return;
            }

            if (fXP > 12.0) fXP = 12.0;
            
            GiveXPToPC(OBJECT_SELF, fXP, FALSE, "Lockpicking");
        }
    }
    */
}
