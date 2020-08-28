const float MORALE_RADIUS = 30.0;

// Makes the killer play a voice sometimes. Won't work if the killer is a PC or if the killer was not hostile.
void KillTaunt(object oKiller, object oKilled);

// Copies the item to an existing object's inventory. Does not copy if target does not exist.
// Will copy vars, and return the new item.
object CopyItemToExistingTarget(object oItem, object oTarget);

object CopyItemToExistingTarget(object oItem, object oTarget)
{
    if (GetIsObjectValid(oTarget))
    {
        return CopyItem(oItem, oTarget, TRUE);
    }
    else
    {
        return OBJECT_INVALID;
    }
}

void KillTaunt(object oKiller, object oKilled)
{
    if (GetIsPC(oKiller)) return;

    if (!GetIsReactionTypeHostile(oKilled, oKiller)) return;

    int nRandom = d4();

    float fDelay = 1.25;

    switch (nRandom)
    {
       case 1: DelayCommand(fDelay, PlayVoiceChat(VOICE_CHAT_THREATEN, oKiller)); break;
       case 2: DelayCommand(fDelay, PlayVoiceChat(VOICE_CHAT_LAUGH, oKiller)); break;
       case 3: DelayCommand(fDelay, PlayVoiceChat(VOICE_CHAT_CHEER, oKiller)); break;
    }
}

void SendMessageToAllPCs(string sMessage)
{
    object oPC = GetFirstPC();

    while (GetIsObjectValid(oPC))
    {
        SendMessageToPC(oPC, sMessage);
        oPC = GetNextPC();
    }
}

void DoMoraleCry(object oCreature)
{
     if (GetIsDead(oCreature)) return;
     if (GetLocalInt(oCreature, "morale_cried") == 1) return;

     SetLocalInt(oCreature, "morale_cried", 1);

     switch (d6())
     {
         case 1: PlayVoiceChat(VOICE_CHAT_HELP, oCreature); break;
         case 2: PlayVoiceChat(VOICE_CHAT_FLEE, oCreature); break;
         case 3: PlayVoiceChat(VOICE_CHAT_NEARDEATH, oCreature); break;
         case 4:
            if (GetCurrentHitPoints(oCreature) <= GetMaxHitPoints(oCreature)/2)
                PlayVoiceChat(VOICE_CHAT_HEALME, oCreature);
         break;
     }

     DelayCommand(30.0, DeleteLocalInt(oCreature, "morale_cried"));
}

void DoMoraleCheck(object oCreature, int nDC = 10)
{
    if (GetIsDead(oCreature)) return;
    if (GetIsPC(oCreature)) return;
    if (GetLocalInt(oCreature, "morale_checked") == 1) return;

    switch (GetRacialType(oCreature))
    {
        case RACIAL_TYPE_UNDEAD:
        case RACIAL_TYPE_CONSTRUCT:
        case RACIAL_TYPE_OOZE:
            return;
        break;
    }

    SetLocalInt(oCreature, "morale_checked", 1);

    location lLocation = GetLocation(oCreature);
    int nFriendlies = 0;
    int nEnemies = 0;
    float fRadius = MORALE_RADIUS;

    object oNearbyCreature = GetFirstObjectInShape(SHAPE_SPHERE, fRadius, lLocation, TRUE, OBJECT_TYPE_CREATURE);
    while (GetIsObjectValid(oNearbyCreature))
    {
        if (oNearbyCreature != oCreature && !GetIsDead(oCreature))
        {
            if (GetIsFriend(oNearbyCreature, oCreature))
            {
                nFriendlies = nFriendlies + 2;
            }
            else if (GetIsEnemy(oNearbyCreature, oCreature))
            {
                nEnemies = nEnemies + 2;
            }
        }
        oNearbyCreature = GetNextObjectInShape(SHAPE_SPHERE, fRadius, lLocation, TRUE, OBJECT_TYPE_CREATURE);
    }

    int nDifference = nEnemies - nFriendlies;

// if they have at least 3 allies over the player, never run
    if (nDifference <= -6) return;

    nDC = nDC + nDifference - GetHitDice(oCreature);

    if (nDC < 1) nDC = 1;

    if (WillSave(oCreature, nDC, SAVING_THROW_TYPE_FEAR) == 0)
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectFrightened(), oCreature, IntToFloat(d3(2)));
        DelayCommand(IntToFloat(d10())/10.0, DoMoraleCry(oCreature));
    }

    DelayCommand(5.0, DeleteLocalInt(oCreature, "morale_checked"));
}

void DoMoraleCheckSphere(object oCreature, int nDC = 10, float fRadius = MORALE_RADIUS)
{
    location lLocation = GetLocation(oCreature);

    object oNearbyCreature = GetFirstObjectInShape(SHAPE_SPHERE, fRadius, lLocation, TRUE, OBJECT_TYPE_CREATURE);
    while (GetIsObjectValid(oNearbyCreature))
    {
        if (oNearbyCreature != oCreature && !GetIsDead(oNearbyCreature) && GetIsFriend(oCreature, oNearbyCreature)) DoMoraleCheck(oNearbyCreature, nDC);

        oNearbyCreature = GetNextObjectInShape(SHAPE_SPHERE, fRadius, lLocation, TRUE, OBJECT_TYPE_CREATURE);
    }
}

void PlayNonMeleePainSound(object oDamager)
{
    if (GetIsDead(OBJECT_SELF)) return;

    int nWeaponDamage = GetDamageDealtByType(DAMAGE_TYPE_BASE_WEAPON);

    int bRanged = GetWeaponRanged(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oDamager));

    if (bRanged || nWeaponDamage == -1)
    {
        switch (d6())
        {
            case 1: PlayVoiceChat(VOICE_CHAT_PAIN1); break;
            case 2: PlayVoiceChat(VOICE_CHAT_PAIN2); break;
            case 3: PlayVoiceChat(VOICE_CHAT_PAIN3); break;
        }
    }
}

int Gibs(object oCreature)
{
    int nHP = GetCurrentHitPoints(oCreature);

    if (!(nHP <= -11 && nHP <= -(GetMaxHitPoints(oCreature)/2))) return FALSE;
    if (GetLocalInt(OBJECT_SELF, "gibbed") == 1) return FALSE;

    int nAppearanceType = GetAppearanceType(oCreature);

    string sBlood = Get2DAString("appearance", "BLOODCOLR", GetAppearanceType(oCreature));

    int nGib;
    if (sBlood == "R")
    {
        nGib = VFX_COM_CHUNK_RED_MEDIUM;
        PlaySound("bf_med_insect");
    }
    else if (sBlood == "Y")
    {
        nGib = VFX_COM_CHUNK_YELLOW_MEDIUM;
        PlaySound("bf_med_insect");
    }
    else if (sBlood == "G")
    {
        nGib = VFX_COM_CHUNK_GREEN_MEDIUM;
        PlaySound("bf_med_insect");
    }
    else if (sBlood == "W")
    {
        nGib = VFX_COM_CHUNK_BONE_MEDIUM;
        PlaySound("bf_med_bone");
    }
    else
    {
        return FALSE;
    }

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(nGib), GetLocation(oCreature));
    return TRUE;
}

int GibsNPC(object oCreature)
{
    if (Gibs(oCreature))
    {
// Prevent gibs from happening more than once in the case of many APR.
        SetLocalInt(OBJECT_SELF, "gibbed", 1);
// Some sort of delay must be used, otherwise the sound won't play.
        DestroyObject(oCreature, 0.1);
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

//void main(){}
