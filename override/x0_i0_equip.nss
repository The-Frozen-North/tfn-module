//:://////////////////////////////////////////////////
//:: X0_I0_EQUIP
/*
  Library that handles equipping weapons functions.
 */
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 01/21/2003
//:://////////////////////////////////////////////////

#include "x0_i0_assoc"
// #include "x0_i0_match" -- included in x0_i0_enemy
#include "x0_i0_enemy"

/**********************************************************************
 * CONSTANTS
 **********************************************************************/

/**********************************************************************
 * FUNCTION PROTOTYPES
 **********************************************************************/


// * checks to see if oUser has ambidexteriy and two weapon fighting
int WiseToDualWield(object oUser);

// Equip the weapon appropriate to enemy and position.
// This is now just a wrapper around bkEquipAppropriateWeapons.
void EquipAppropriateWeapons(object oTarget);

// * returns true if out of ammo of currently equipped weapons
int IsOutOfAmmo(int bIAmAHenc);
// Equip melee weapon(s) and a shield.
void bkEquipMelee(object oTarget = OBJECT_INVALID, int nClearActions=TRUE);
void bkEquipRanged(object oTarget=OBJECT_INVALID, int bIAmAHenc = FALSE, int bForceEquip = FALSE);

// Equip the appropriate weapons to face the target.
void bkEquipAppropriateWeapons(object oTarget, int nPrefersRanged=FALSE, int nClearActions=TRUE);

// * this is just a wrapper around ActionAttack
// * to make sure the creature equips weapons
void WrapperActionAttack(object oTarget);

/**********************************************************************
 * FUNCTION DEFINITIONS
 **********************************************************************/


//::///////////////////////////////////////////////
//:: Equip Appropriate Weapons
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Makes the user get his best weapons.  If the
    user is a Henchmen then he checks the player
    preference.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: April 2, 2002
//:://////////////////////////////////////////////
void EquipAppropriateWeapons(object oTarget)
{
    bkEquipAppropriateWeapons(oTarget,
                              GetAssociateState(NW_ASC_USE_RANGED_WEAPON));
}

// * stores the last Ranged weapons used for when the
// * henchmen switches from Ranged to melee in XP1
void StoreLastRanged()
{
    if (GetLocalObject(OBJECT_SELF, "X0_L_RIGHTHAND") == OBJECT_INVALID )
    {
        object oItem1 = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);
        if (GetIsObjectValid(oItem1) && GetWeaponRanged(oItem1))
            SetLocalObject(OBJECT_SELF, "X0_L_RIGHTHAND", oItem1);
    }
}

//::///////////////////////////////////////////////
//:: Equip Appropriate Weapons
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Makes the user get his best weapons.  If the
    user is a Henchmen then he checks the player
    preference.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: April 2, 2002
//:://////////////////////////////////////////////
//:: BK: Incorporated Pausanias' changes
//:: and moved to x0_inc_generic
//:: left EquipAppropriateWeapons in nw_i0_generic as a wrapper
//:: function passing in whether this creature
//:: prefers RANGED or MELEE attacks
void bkEquipAppropriateWeapons(object oTarget, int nPrefersRanged=FALSE, int nClearActions=TRUE)
{
    // * Associates never try to switch weapons on their own
    // * but original campaign henchmen have to be able to do this.
    int bIAmAHench = GetIsObjectValid(GetMaster());
 //   if (bIAmAHench == TRUE
 //       && GetLocalInt(OBJECT_SELF, "X0_L_NOTALLOWEDTOHAVEINVENTORY") == 0) return;

     int bEmptyHanded = FALSE;

//    SpawnScriptDebugger();
    object oRightHand = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);
    int bIsWieldingRanged = FALSE;
    object oEnemy = GetNearestPerceivedEnemy();

    // * determine if I am wielding a ranged weapon
    bIsWieldingRanged = GetWeaponRanged(oRightHand) && (IsOutOfAmmo(bIAmAHench) == FALSE);

    if (GetIsObjectValid(oRightHand) == FALSE)
    {
        bEmptyHanded = TRUE;
    }


    // * anytime there is no enemy around, try  a ranged weapon
    if (GetIsObjectValid(oEnemy) == FALSE) {
        if (nClearActions)
            ClearActions(CLEAR_X0_I0_EQUIP_EquipAppropriateWeapons1);


        // MODIFIED Feb 11 2003
        // henchmen should not equip ranged weapons here because its outside
        // of the weapon preference code (OC)
        if (bIAmAHench == FALSE || nPrefersRanged == TRUE) //1.71: ignore this if ranged is preferred
        {
            bkEquipRanged(OBJECT_INVALID, bIAmAHench);
            return;
        }
        //1.71: we are henchman outside of combat, not prefered ranged, equip melee
        bkEquipMelee(oTarget, nClearActions);
        return;
    }

    float fDistance = GetDistanceBetween(OBJECT_SELF, oEnemy);

    // * Equip the appropriate weapon for the distance of the enemy.
    // * If enemy is too close AND I do not have The Point Blank feat

    // * Point blank is only useful in Normal or less however (Oct 1 2003 BK)
    int bPointBlankShotMatters = FALSE;
    if (GetHasFeat(FEAT_POINT_BLANK_SHOT) == TRUE)
    {
        bPointBlankShotMatters = TRUE;
    }
    if (GetGameDifficulty()== GAME_DIFFICULTY_CORE_RULES || GetGameDifficulty()== GAME_DIFFICULTY_DIFFICULT)
    {
        bPointBlankShotMatters = FALSE;
    }

    if ((fDistance < MELEE_DISTANCE) && bPointBlankShotMatters == FALSE)
    {
        // If I'm using a ranged weapon, and I'm in close range,
        // AND I haven't already switched to melee, do so now.
        if (bIsWieldingRanged || bEmptyHanded)
        {
            // xp1 henchmen store ranged weapon so I can switch back to it later
            if (bIAmAHench == TRUE && GetLocalInt(OBJECT_SELF, "X0_L_NOTALLOWEDTOHAVEINVENTORY") == 0)
                StoreLastRanged();
            //SpawnScriptDebugger();
            bkEquipMelee(oTarget, nClearActions);
        }
    }
    else
    {
        // If I'm not at close range, AND I was told to use a ranged
        // weapon, BUT I switched to melee, switch back to missile.
        if ( ! bIsWieldingRanged && (!bIAmAHench || nPrefersRanged)) //1.71: non-henchman will always try to equip ranged
        {
            if (nClearActions)
                ClearActions(CLEAR_X0_I0_EQUIP_EquipAppropriateWeapons2);
            bkEquipRanged(oTarget, bIAmAHench);
        }
        // * If I am at Ranged distance and I am equipped with a ranged weapon
        // * I might as well stay at range and continue shooting.
        else if (bIsWieldingRanged == TRUE)//1.71: else if, so the AI doesn't try equip ranged and melee at the same time
        {
            return;
        }
        else//not wielding ranged, not preffering ranged
        {
            // xp1 henchmen store ranged weapon so I can switch back to it later
            //if (bIAmAHench == TRUE && GetLocalInt(OBJECT_SELF, "X0_L_NOTALLOWEDTOHAVEINVENTORY") == 0)
                //StoreLastRanged(); - 1.71: this is not ranged weapon!
            bkEquipMelee(oTarget, nClearActions);
        }
    }
}


// * New function February 28 2003. Need a wrapper for ranged
// * so I have quick access to exiting from it for OC henchmen
// * equipping
void bkEquipRanged(object oTarget=OBJECT_INVALID, int bIAmAHenc = FALSE, int bForceEquip = FALSE)
{  // SpawnScriptDebugger();
    int bOldHench = FALSE;

    // * old OC henchmen have different equipping rules.
    if (GetLocalInt(OBJECT_SELF, "X0_L_NOTALLOWEDTOHAVEINVENTORY") ==  10)
    {
        bOldHench = TRUE;
    }

    // * If I am an XP1 henchmen and I have not been explicitly
    // * told to re-equip a ranged weapon
    // * than don't EVER equip ranged weapons (i.e., if I never
    // * started out with one in my hand then I shouldn't start
    // * using one unless I have no other weapons.
    if (bForceEquip == FALSE && bOldHench == FALSE && bIAmAHenc == TRUE)
    {
        return;
    }

    // * if I am a henchmen and been told to use only melee, I should obey
    if (bIAmAHenc = TRUE && bOldHench == TRUE && GetAssociateState(NW_ASC_USE_RANGED_WEAPON) == FALSE) { return;}
    //SpawnScriptDebugger();

    ActionEquipMostDamagingRanged(oTarget);
}

// * returns true if out of ammo of currently equipped weapons
int IsOutOfAmmo(int bIAmAHenc)
{
    // * If I am out of ammo, go to melee
    // * don't do this for henchmen
    if (bIAmAHenc == FALSE)
    {
        int nWeaponType = GetBaseItemType(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND));
        object oAmmo = OBJECT_INVALID;
        if (nWeaponType == BASE_ITEM_LONGBOW || nWeaponType == BASE_ITEM_SHORTBOW)
        {
            oAmmo = GetItemInSlot(INVENTORY_SLOT_ARROWS);
        }
        else
        if (nWeaponType == BASE_ITEM_LIGHTCROSSBOW || nWeaponType == BASE_ITEM_HEAVYCROSSBOW)
        {
            oAmmo = GetItemInSlot(INVENTORY_SLOT_BOLTS);
        }
        else
        if (nWeaponType == BASE_ITEM_SLING)
        {
            oAmmo = GetItemInSlot(INVENTORY_SLOT_BULLETS);
        }
        else//1.70: fix in AI for using throwing weapons
        if (nWeaponType == BASE_ITEM_DART || nWeaponType == BASE_ITEM_THROWINGAXE || nWeaponType == BASE_ITEM_SHURIKEN)
        {
            return FALSE;
        }
        if (GetIsObjectValid(oAmmo) == FALSE)
        {
            //ActionEquipMostDamagingMelee(oTarget);
            //PrintString("***out of ammo switching weapons***");
            return TRUE;
        }
    }
        return FALSE;
}

// * checks to see if oUser has ambidexteriy and two weapon fighting
int WiseToDualWield(object oUser)
{
    //1.71: ranger dual wield also qualify
    if (GetHasFeat(374,oUser) || (GetHasFeat(FEAT_AMBIDEXTERITY, oUser) && GetHasFeat(FEAT_TWO_WEAPON_FIGHTING, oUser)))
    {
        return TRUE;
    }
    return FALSE;
}

//::///////////////////////////////////////////////
//:: GetIsWeaponLarge
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Returns true if this is a large weapon.
    initial purpose: to prevent people from
    swapping between shields and their
    preferred weapon (XP1 Henchmen were doing)

    For now just going with the 12 pound rule


    Ended up not being used...
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: May 2, 2003
//:://////////////////////////////////////////////

int GetIsWeaponLarge(object oItem)
{
    if (GetWeight(oItem) > 12)
    {
        return TRUE;
    }
    return FALSE;
}
//::///////////////////////////////////////////////
//:: bkEquipMelee
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
// Equip melee weapon AND check for shield.
    nClearActions: If this is False, it won't ever clear actions
                   The henchmen requipping rules require this (BKNOV2002)
*/
void bkEquipMelee(object oTarget = OBJECT_INVALID, int nClearActions=TRUE)
{
    // * BK Feb 2003: If I am an associate and have been ordered to use ranged
    // * weapons never try to equip my shield
    if (GetAssociateState(NW_ASC_USE_RANGED_WEAPON) == TRUE) { return;}
    //SpawnScriptDebugger();

    if(GetLevelByClass(CLASS_TYPE_MONK) > 0)//1.71: fix for monks trying to equip inappropriate weapons
    {
        ActionEquipMostDamagingMelee(oTarget);
        return;
    }

    int bHasMaster = GetIsObjectValid(GetMaster());
    int bOldHench = FALSE;
    if (GetLocalInt(OBJECT_SELF, "X0_L_NOTALLOWEDTOHAVEINVENTORY") ==  10)
    {
        bOldHench = TRUE;
    }

    object oRightHand = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND); // What I have in my right hand current
    // * May 2003: If already holding a weapon and I am an XP1 henchmen
    // * do not try to equip another weapon melee weapon.
    // * XP1 henchmen should only switch weapons if going from ranged to melee.
    if (bHasMaster && !bOldHench
        // * valid weapon in hand that is NOT a ranged weapon
        && (GetIsObjectValid(oRightHand) == TRUE && GetWeaponRanged(oRightHand) == FALSE) )
    {
        return; //shadooow: why are OC henchmans trying to dualwield?
    }

    object oLeftHand = GetItemInSlot(INVENTORY_SLOT_LEFTHAND);
    // Are we already dual-wielding? Don't do anything.
    if (MatchSingleHandedWeapon(oRightHand) &&
        MatchSingleHandedWeapon(oLeftHand))
        return;

    object oShield=OBJECT_INVALID;
    object oLeft=OBJECT_INVALID;
    object oRight=OBJECT_INVALID;

    // Check for the presence of a shield and the number of
    // single-handed weapons.
    object oSelf = OBJECT_SELF;
    object oItem = GetFirstItemInInventory(oSelf);

    int iHaveShield = FALSE;
    int nSingle = 0;
    int nWeaponType, nMelee = 0;

    while (GetIsObjectValid(oItem))
    {
        if(bHasMaster && !GetIdentified(oItem))
        {
            //1.71: only try to equip identified items if we are in player's party
            oItem = GetNextItemInInventory(oSelf);
            continue;
        }
        nWeaponType = GetLocalInt(oItem,"WeaponType");
        if(!nWeaponType)
        {
            if(GetWeaponRanged(oItem))
            {
                nWeaponType = -1;
            }
            else
            {
                nWeaponType = StringToInt(Get2DAString("baseitems","WeaponType",GetBaseItemType(oItem)));
            }
            SetLocalInt(oItem,"WeaponType",nWeaponType);
        }
        if(nWeaponType > 0)
        {
            nMelee++;
        }
        if (MatchSingleHandedWeapon(oItem))
        {
            nSingle++;
            if (nSingle == 1)
                oRight = oItem;
            else if (nSingle == 2)
                oLeft = oItem;
            else {//Shadooow: AI might still try to use weapon that creature cannot use due to the restrictions or missing proficiency
                // see if the one we just found is better?
            }                            //1.71: do not consiser tower shield if we are small creature
        } else if (MatchShield(oItem) && (GetBaseItemType(oItem) != BASE_ITEM_TOWERSHIELD || GetCreatureSize(OBJECT_SELF) > CREATURE_SIZE_SMALL)) {
            iHaveShield = TRUE;
            oShield = oItem;
        }
        oItem = GetNextItemInInventory(oSelf);
   }

   int bAlreadyClearedActions = FALSE;

   // SpawnScriptDebugger();
    // * May 2003 -- Only equip if found a singlehanded weapon that I will equip                //1.71: fixed right for left
    if (GetIsObjectValid(oRight) && iHaveShield && GetHasFeat(FEAT_SHIELD_PROFICIENCY,oSelf) && (MatchShield(oLeftHand) == FALSE)  )
    {
        if (nClearActions == TRUE)
        {
            ClearActions(CLEAR_X0_I0_EQUIP_EquipMelee1);
        }
        /* HACK HACK HACK
           Need to do this three times to get the shield to actually equip in certain circumstances
        *  HACK HACK HACK */
      //  SpeakString("*******************************************SHIELD");

        // * March 2003 : redundant code, but didn't want to break existing behavior
        if (GetIsObjectValid(oLeft) == TRUE || GetIsObjectValid(oRight))
        {
           // SpeakString("equip melee");
            //ActionEquipMostDamagingMelee(oTarget);
            ActionEquipItem(oRight,INVENTORY_SLOT_RIGHTHAND);
            ActionEquipItem(oRight,INVENTORY_SLOT_RIGHTHAND);
            ActionEquipItem(oRight,INVENTORY_SLOT_RIGHTHAND);
        }
        ActionEquipItem(oShield,INVENTORY_SLOT_LEFTHAND);
        ActionEquipItem(oShield,INVENTORY_SLOT_LEFTHAND);
        ActionEquipItem(oShield,INVENTORY_SLOT_LEFTHAND);
        return;
    }
    else if (nSingle >= 2 && WiseToDualWield(OBJECT_SELF))
    {
        // SpeakString("dual-wielding");
        if (nClearActions == TRUE )
            ClearActions(CLEAR_X0_I0_EQUIP_EquipMelee2);
        ActionEquipItem(oRight,INVENTORY_SLOT_RIGHTHAND);
        ActionEquipItem(oLeft,INVENTORY_SLOT_LEFTHAND);
        return;
    }


    // * don't switch to bare hands - 1.71: disabled, equip most damaging melee seems consistent and smarter
    /*if (GetIsObjectValid(oRight) == TRUE || GetIsObjectValid(oLeft))
    {
        if (nClearActions == TRUE && bAlreadyClearedActions == FALSE)
            ClearActions(CLEAR_X0_I0_EQUIP_EquipMelee3);
        // * It would be better to use ActionEquipMostDamaging here, but it is inconsistent
        if (GetIsObjectValid(oRight) == TRUE)
            ActionEquipItem(oRight,INVENTORY_SLOT_RIGHTHAND);
        else
        if (GetIsObjectValid(oLeft) == TRUE)
            ActionEquipItem(oLeft,INVENTORY_SLOT_RIGHTHAND);

        return;
    }*/

    // Fallback: If I'm still here, try ActionEquipMostDamagingMelee
    if(nMelee > 0)//1.72: do not try equip melee if there is no weapon in inventory (causes creature to re-equip ranged weapon and it look weird)
    ActionEquipMostDamagingMelee(oTarget);

    // * if not melee weapon found then try ranged
    // * April 2003 removed this beccause henchmen sometimes fall down into this
   // bkEquipRanged(oTarget);
}



// * this is just a wrapper around ActionAttack
// * to make sure the creature equips weapons
void WrapperActionAttack(object oTarget)
{
    //AssignCommand(oTarget, SpeakString("eek. They want to kill ME!"));
    // * last minute check to make sure weapons are being used (BKNOV2002)

//    if (GetIsObjectValid(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND)) == FALSE || GetIsObjectValid(GetItemInSlot(INVENTORY_SLOT_LEFTHAND)) == FALSE) {
        // SpeakString("trying to equip");
   //    SpawnScriptDebugger();
        // Feb 28: Always try to equip weapons at this point
    bkEquipAppropriateWeapons(oTarget,GetAssociateState(NW_ASC_USE_RANGED_WEAPON));
    SetLocalObject(OBJECT_SELF,"NW_GENERIC_LAST_ATTACK_TARGET",oTarget);//1.71: stored attacked target for custom content purposes
    ActionAttack(oTarget);
}


/* void main() {} /* */
