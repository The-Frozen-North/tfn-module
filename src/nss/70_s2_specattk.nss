//::///////////////////////////////////////////////
//:: Custom Special Attack
//:: 70_s2_specattk
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
This script will run for all default special attack + any custom you create. To create
custom special attack, create new useable feat with no spellID. Such feat will trigger
this script where you can code almost everything you can think of.

It can fire 4 times for each special attack each time in different event with different
posibilities.

Event SPECIAL_ATTACK_EVENTTYPE_USE_FEAT:
Runs when player and only player uses feat that has no spell ID set. This is the case
of all vanilla special attacks.
Only nType and oTarget variables are functional here.
In this event you either add special attack action or not depending whether player
uses the special attack with correct weapon etc.
NPCs will not trigger it and use vanilla special attack limitations. (at least for now)

Event SPECIAL_ATTACK_EVENTTYPE_ATTACK_BONUS_CALCULATION:
Runs when attack roll is going to be calculated. Runs for both PCs and NPCs.
Only nType and oTarget variables are functional here.
In this event you can code possible bonuses or penalties to the attack roll.
Variable SPECIAL_ATTACK_RESULT will pass the attack modifier into the engine. This
will apply only to 'to hit modifier', but its possible to use function NWNXPatch_SetAttackRoll
and modify attack roll too.

Event SPECIAL_ATTACK_EVENTTYPE_DAMAGE_BONUS_CALCULATION:
Runs when attack damage is going to be calculated. Runs for both PCs and NPCs.
Only nType and oTarget variables are functional here.
In this event you can code possible bonuses or penalties to final damage.
Variable SPECIAL_ATTACK_RESULT will pass the damage modifier into the engine. This
will apply only to base weapon damage, but its possible to use functions NWNXPatch_Get/SetTotalDamageDealtByType
and modify any other damage type too.
Note: runs regardless of whether special attack hit or miss. (at least for now)

Event SPECIAL_ATTACK_EVENTTYPE_EFFECTS_CALCULATION:
Runs when everything was calculated already and special attack didn't miss. Runs for both PCs and NPCs.
All variables are functional here, DATA1 refers to total damage, DATA2 to attack roll.
In this event you can code special OnHit effects, penalties or bonuses to self/target.
It is still possible to modify damage dealt in this even using NWNXPatch_Get/SetTotalDamageDealtByType
but its not recommend to do (will not be count for defensive roll purposes and won't apply
the usual damage visual effects either).
Variable SPECIAL_ATTACK_RESULT will pass the special attack result (-2 failure -1 resisted)
into the engine.

Notes:
Called shot is recognized by constants SPECIAL_ATTACK_CALLED_SHOT_LEGS and SPECIAL_ATTACK_CALLED_SHOT_ARMS
not FEAT_CALLED_SHOT.

Ki Damage is special. The damage is calculated in different event and in different
manner than other special attacks. So while the script runs for Ki Damage, it does
nothing by default because there is no attack bonus and no damage bonus and no effects.
However it should be possible to recalculate the base damage in the 4th event.

Custom feat id must not exceed 65000.

Fires also for:
FEAT_CLEAVE
FEAT_GREAT_CLEAVE
FEAT_WHIRLWIND_ATTACK
FEAT_IMPROVED_WHIRLWIND
FEAT_CIRCLE_KICK
and runs events 2-4 but by default no change is done for these feats.

Fires also for attack of opportunity (65002) and riposte attack (65003).
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow
//:: Created On: 12-6-2017
//:://////////////////////////////////////////////

#include "70_inc_nwnx"
#include "nw_i0_spells"

void PerformStunFist(object oTarget, effect eStun, float fDuration)
{
    //overrides mind spell immunity to force stun to ignore it
    NWNXPatch_SetImmunityOverride(oTarget,IMMUNITY_TYPE_MIND_SPELLS,FALSE);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eStun,oTarget,fDuration);
    //restores immunity behavior
    NWNXPatch_RemoveImmunityOverride(oTarget,IMMUNITY_TYPE_MIND_SPELLS);
}

const int SPECIAL_ATTACK_EVENTTYPE_USE_FEAT = 1;
const int SPECIAL_ATTACK_EVENTTYPE_ATTACK_BONUS_CALCULATION = 2;
const int SPECIAL_ATTACK_EVENTTYPE_DAMAGE_BONUS_CALCULATION = 3;
const int SPECIAL_ATTACK_EVENTTYPE_EFFECTS_CALCULATION = 4;
const int SPECIAL_ATTACK_CALLED_SHOT_LEGS = 65000;
const int SPECIAL_ATTACK_CALLED_SHOT_ARMS = 65001;
const int SPECIAL_ATTACK_ATTACK_OF_OPPORTUNITY = 65002;
const int SPECIAL_ATTACK_RIPOSTE = 65003;

void main()
{
    //Declare major variables
    int nWis = GetAbilityModifier(ABILITY_WISDOM);
    int nLevel = GetHitDice(OBJECT_SELF);
    int nEvent = GetLocalInt(OBJECT_SELF,"SPECIAL_ATTACK_EVENT");
    int nType = GetLocalInt(OBJECT_SELF,"SPECIAL_ATTACK_TYPE");
    int nDamage = GetLocalInt(OBJECT_SELF,"SPECIAL_ATTACK_DATA1");
    int nAB = GetLocalInt(OBJECT_SELF,"SPECIAL_ATTACK_DATA2");
    object oTarget = GetLocalObject(OBJECT_SELF,"SPECIAL_ATTACK_TARGET");
    object oWeaponTarget = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,oTarget);
    object oWeaponAttacker = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);
    if(nEvent == SPECIAL_ATTACK_EVENTTYPE_USE_FEAT)
    {
        if(nType == FEAT_STUNNING_FIST || nType == FEAT_QUIVERING_PALM)
        {
            if(!GetIsObjectValid(oWeaponAttacker))
            {
                NWNXPatch_ActionUseSpecialAttack(OBJECT_SELF,oTarget,nType);
            }
            else
            {
                ActionAttack(oTarget);
                SendMessageToPCByStrRef(OBJECT_SELF,66780);
            }
        }
        else if(nType == SPECIAL_ATTACK_CALLED_SHOT_LEGS || nType == SPECIAL_ATTACK_CALLED_SHOT_ARMS)
        {
            NWNXPatch_ActionUseSpecialAttack(OBJECT_SELF,oTarget,nType);
        }
        else if(nType == FEAT_DISARM || nType == FEAT_IMPROVED_DISARM || nType == FEAT_KNOCKDOWN || nType == FEAT_IMPROVED_KNOCKDOWN ||
        nType == FEAT_SMITE_EVIL  || nType == FEAT_SMITE_GOOD || nType == FEAT_SAP)
        {
            if(!GetIsObjectValid(oWeaponAttacker) || !GetWeaponRanged(oWeaponAttacker))
            {
                NWNXPatch_ActionUseSpecialAttack(OBJECT_SELF,oTarget,nType);
            }
            else
            {
                ActionAttack(oTarget);
            }
        }
        else if(nType == FEAT_KI_DAMAGE)
        {
            if(GetIsObjectValid(oWeaponAttacker) && !GetWeaponRanged(oWeaponAttacker))
            {
                int nFeat = -1;
                switch(GetBaseItemType(oWeaponAttacker))
                {
                case BASE_ITEM_BASTARDSWORD: nFeat = FEAT_WEAPON_OF_CHOICE_BASTARDSWORD; break;
                case BASE_ITEM_BATTLEAXE: nFeat = FEAT_WEAPON_OF_CHOICE_BATTLEAXE; break;
                case BASE_ITEM_CLUB: nFeat = FEAT_WEAPON_OF_CHOICE_CLUB; break;
                case BASE_ITEM_DAGGER: nFeat = FEAT_WEAPON_OF_CHOICE_DAGGER; break;
                case BASE_ITEM_DIREMACE: nFeat = FEAT_WEAPON_OF_CHOICE_DIREMACE; break;
                case BASE_ITEM_DOUBLEAXE: nFeat = FEAT_WEAPON_OF_CHOICE_DOUBLEAXE; break;
                case BASE_ITEM_DWARVENWARAXE: nFeat = FEAT_WEAPON_OF_CHOICE_DWAXE; break;
                case BASE_ITEM_GREATAXE: nFeat = FEAT_WEAPON_OF_CHOICE_GREATAXE; break;
                case BASE_ITEM_GREATSWORD: nFeat = FEAT_WEAPON_OF_CHOICE_GREATSWORD; break;
                case BASE_ITEM_HALBERD: nFeat = FEAT_WEAPON_OF_CHOICE_HALBERD; break;
                case BASE_ITEM_HANDAXE: nFeat = FEAT_WEAPON_OF_CHOICE_HANDAXE; break;
                case BASE_ITEM_HEAVYFLAIL: nFeat = FEAT_WEAPON_OF_CHOICE_HEAVYFLAIL; break;
                case BASE_ITEM_KAMA: nFeat = FEAT_WEAPON_OF_CHOICE_KAMA; break;
                case BASE_ITEM_KATANA: nFeat = FEAT_WEAPON_OF_CHOICE_KATANA; break;
                case BASE_ITEM_KUKRI: nFeat = FEAT_WEAPON_OF_CHOICE_KUKRI; break;
                case BASE_ITEM_LIGHTFLAIL: nFeat = FEAT_WEAPON_OF_CHOICE_LIGHTFLAIL; break;
                case BASE_ITEM_LIGHTHAMMER: nFeat = FEAT_WEAPON_OF_CHOICE_LIGHTHAMMER; break;
                case BASE_ITEM_LIGHTMACE: nFeat = FEAT_WEAPON_OF_CHOICE_LIGHTMACE; break;
                case BASE_ITEM_LONGSWORD: nFeat = FEAT_WEAPON_OF_CHOICE_LONGSWORD; break;
                case BASE_ITEM_MORNINGSTAR: nFeat = FEAT_WEAPON_OF_CHOICE_MORNINGSTAR; break;
                case BASE_ITEM_QUARTERSTAFF: nFeat = FEAT_WEAPON_OF_CHOICE_QUARTERSTAFF; break;
                case BASE_ITEM_RAPIER: nFeat = FEAT_WEAPON_OF_CHOICE_RAPIER; break;
                case BASE_ITEM_SCIMITAR: nFeat = FEAT_WEAPON_OF_CHOICE_SCIMITAR; break;
                case BASE_ITEM_SCYTHE: nFeat = FEAT_WEAPON_OF_CHOICE_SCYTHE; break;
                case BASE_ITEM_SHORTSPEAR: nFeat = FEAT_WEAPON_OF_CHOICE_SHORTSPEAR; break;
                case BASE_ITEM_SHORTSWORD: nFeat = FEAT_WEAPON_OF_CHOICE_SHORTSWORD; break;
                case BASE_ITEM_SICKLE: nFeat = FEAT_WEAPON_OF_CHOICE_SICKLE; break;
                case BASE_ITEM_TRIDENT: nFeat = FEAT_WEAPON_OF_CHOICE_TRIDENT; break;
                case BASE_ITEM_TWOBLADEDSWORD: nFeat = FEAT_WEAPON_OF_CHOICE_TWOBLADEDSWORD; break;
                case BASE_ITEM_WARHAMMER: nFeat = FEAT_WEAPON_OF_CHOICE_WARHAMMER; break;
                case BASE_ITEM_WHIP: nFeat = FEAT_WEAPON_OF_CHOICE_WHIP; break;
                }
                if(nFeat > -1 && GetHasFeat(nFeat))
                {
                    NWNXPatch_ActionUseSpecialAttack(OBJECT_SELF,oTarget,nType);
                    return;
                }
            }
            ActionAttack(oTarget);
            SendMessageToPCByStrRef(OBJECT_SELF,3951);
        }
    }
    else if(nEvent == SPECIAL_ATTACK_EVENTTYPE_ATTACK_BONUS_CALCULATION)
    {
        int nBonus = 0;
        if(nType == FEAT_SAP || nType == FEAT_KNOCKDOWN  || nType == FEAT_IMPROVED_KNOCKDOWN)
        {
            nBonus = -4;
        }
        else if(nType == FEAT_STUNNING_FIST)
        {
            if(GetLevelByClass(CLASS_TYPE_MONK) < 1) nBonus = -4;
        }
        else if(nType == FEAT_DISARM || nType == FEAT_IMPROVED_DISARM)
        {
            int mod = 0;
            object wpn_target = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,oTarget);
            object wpn_attacker = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);
            if(GetIsObjectValid(wpn_target) && GetIsObjectValid(wpn_attacker))
            {
                int size_attacker = StringToInt(Get2DAString("baseitems","WeaponSize",GetBaseItemType(wpn_attacker)));
                int size_target = StringToInt(Get2DAString("baseitems","WeaponSize",GetBaseItemType(wpn_target)));
                mod = 4 * (size_attacker - size_target);
            }
            nBonus = nType == 16 ? mod-4 : mod-6;
        }
        else if(nType == FEAT_SMITE_EVIL || nType == FEAT_SMITE_GOOD)
        {
            if((nType == FEAT_SMITE_EVIL && GetAlignmentGoodEvil(oTarget) == ALIGNMENT_EVIL) || (nType == FEAT_SMITE_GOOD && GetAlignmentGoodEvil(oTarget) == ALIGNMENT_GOOD))
            {
                nBonus = GetAbilityModifier(ABILITY_CHARISMA);
            }
        }
        else if(nType == SPECIAL_ATTACK_CALLED_SHOT_LEGS || nType == SPECIAL_ATTACK_CALLED_SHOT_ARMS)
        {
            nBonus = -4;
        }
        else if(nType == SPECIAL_ATTACK_ATTACK_OF_OPPORTUNITY)//attack of opportunity
        {
            if(GetHasFeat(FEAT_OPPORTUNIST)) nBonus = 4;
            if(GetLocalInt(OBJECT_SELF,"AOO_SNEAK") != 0)
            {
                NWNXPatch_SetAttackSneak(OBJECT_SELF,GetLocalInt(OBJECT_SELF,"AOO_SNEAK"));
            }
        }
        //system variable that pushes the attack roll bonus to engine
        SetLocalInt(OBJECT_SELF,"SPECIAL_ATTACK_RESULT",nBonus);
        return;
    }
    else if(nEvent == SPECIAL_ATTACK_EVENTTYPE_DAMAGE_BONUS_CALCULATION)
    {
        int nBonus = 0;
        if(nType == FEAT_STUNNING_FIST)
        {
            //non-monks gets a -4damage penalty when using stunning fist
            if(GetLevelByClass(CLASS_TYPE_MONK) < 1) nBonus = -4;
        }
        else if(nType == FEAT_SMITE_EVIL  || nType == FEAT_SMITE_GOOD)
        {
            //damage modification test
            int damage_bonus, damage_multiplier = 1;

            //no effect on dead target
            if(!GetIsObjectValid(oTarget) || GetIsDead(oTarget) || GetObjectType(oTarget) != OBJECT_TYPE_CREATURE)
            {
                return;
            }
            if((nType == FEAT_SMITE_EVIL && GetAlignmentGoodEvil(oTarget) == ALIGNMENT_EVIL) || (nType == FEAT_SMITE_GOOD && GetAlignmentGoodEvil(oTarget) == ALIGNMENT_GOOD))
            {
                int nClass,nTh=1;
                while(nTh < 4)
                {
                    nClass = GetClassByPosition(nTh);
                    if(nClass != CLASS_TYPE_INVALID && NWNXPatch_GetIsFeatGranted(nClass,nType))
                    {
                        damage_bonus+= GetLevelByPosition(nTh);
                    }
                    nTh++;
                }
                if(damage_bonus > 0)
                {
                    nTh = 10;
                    while(nTh > 0)
                    {
                        if(GetHasFeat(823+nTh))
                        {
                            damage_multiplier = nTh;
                            break;
                        }
                        nTh--;
                    }
                    nBonus = damage_bonus*damage_multiplier;
                }
            }
        }
        //system variable that pushes the damage bonus to engine
        SetLocalInt(OBJECT_SELF,"SPECIAL_ATTACK_RESULT",nBonus);
        return;
    }
    else if(nEvent == SPECIAL_ATTACK_EVENTTYPE_EFFECTS_CALCULATION)
    {
        if(nType == FEAT_STUNNING_FIST)
        {
            //lets not forget to decrement feat uses
            DecrementRemainingFeatUses(OBJECT_SELF,nType);
            if(GetWeaponRanged(oWeaponAttacker)) return;//sanity check

            //no effect on dead target, when total damage is 0 or when target has immunity to critical hits/stun
            if(!GetIsObjectValid(oTarget) || nDamage < 1 || GetIsDead(oTarget) || GetIsImmune(oTarget,IMMUNITY_TYPE_CRITICAL_HIT,OBJECT_SELF) || GetIsImmune(oTarget,IMMUNITY_TYPE_STUN,OBJECT_SELF))
            {
                //system variable that shows "failed" in the combat log
                SetLocalInt(OBJECT_SELF,"SPECIAL_ATTACK_RESULT",-2);
                return;
            }

            int nDC = 10+GetHitDice(OBJECT_SELF)/2+GetAbilityModifier(ABILITY_WISDOM);
            if(GetHasFeat(FEAT_EPIC_IMPROVED_STUNNING_FIST_1)) nDC+= 2;
            if(GetHasFeat(FEAT_EPIC_IMPROVED_STUNNING_FIST_2)) nDC+= 2;
            if(GetHasFeat(FEAT_EPIC_IMPROVED_STUNNING_FIST_3)) nDC+= 2;
            if(GetHasFeat(FEAT_EPIC_IMPROVED_STUNNING_FIST_4)) nDC+= 2;
            if(GetHasFeat(FEAT_EPIC_IMPROVED_STUNNING_FIST_5)) nDC+= 2;
            if(GetHasFeat(FEAT_EPIC_IMPROVED_STUNNING_FIST_6)) nDC+= 2;
            if(GetHasFeat(FEAT_EPIC_IMPROVED_STUNNING_FIST_7)) nDC+= 2;
            if(GetHasFeat(FEAT_EPIC_IMPROVED_STUNNING_FIST_8)) nDC+= 2;
            if(GetHasFeat(FEAT_EPIC_IMPROVED_STUNNING_FIST_9)) nDC+= 2;
            if(GetHasFeat(FEAT_EPIC_IMPROVED_STUNNING_FIST_10)) nDC+= 2;

            //fortitude save
            if(!FortitudeSave(oTarget,nDC,SAVING_THROW_TYPE_NONE))
            {
                effect eStun = ExtraordinaryEffect(EffectStunned());
                int nDuration = GetScaledDuration(3,oTarget);
                DelayCommand(0.5,PerformStunFist(oTarget,eStun,RoundsToSeconds(nDuration)));
            }
            else
            {
                //system variable that shows "resisted" in the combat log
                SetLocalInt(OBJECT_SELF,"SPECIAL_ATTACK_RESULT",-1);
            }
        }
        else if(nType == FEAT_KNOCKDOWN || nType == FEAT_IMPROVED_KNOCKDOWN)
        {
            if(GetWeaponRanged(oWeaponAttacker)) return;//sanity check
            //no effect on dead target
            if(!GetIsObjectValid(oTarget) || GetIsDead(oTarget))
            {
                //system variable that shows "failed" in the combat log
                SetLocalInt(OBJECT_SELF,"SPECIAL_ATTACK_RESULT",-2);
                return;
            }

            int size_attacker = GetCreatureSize(OBJECT_SELF)+(nType == FEAT_IMPROVED_KNOCKDOWN);
            int size_target = GetCreatureSize(oTarget);

            if(size_target-size_attacker > 1)
            {
                if(GetIsPC(OBJECT_SELF))
                {
                    SendMessageToPCByStrRef(OBJECT_SELF,7949+(nType == FEAT_IMPROVED_KNOCKDOWN));
                }
                //system variable that shows "failed" in the combat log
                SetLocalInt(OBJECT_SELF,"SPECIAL_ATTACK_RESULT",-2);
                return;
            }

            int nRoll = d20()+GetSkillRank(SKILL_DISCIPLINE,oTarget);

            if(size_target > size_attacker)
            {
                nRoll+= 4*(size_target-size_attacker);
            }
            else if(size_target < size_attacker)
            {
                nRoll-= 4*(size_attacker-size_target);
            }

            //discipline skill check
            if(nRoll < nAB)
            {
                effect eKnockdown = ExtraordinaryEffect(EffectKnockdown());
                DelayCommand(0.5,ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eKnockdown,oTarget,6.0));
            }
            else
            {
                //system variable that shows "resisted" in the combat log
                SetLocalInt(OBJECT_SELF,"SPECIAL_ATTACK_RESULT",-1);
            }
        }
        else if(nType == FEAT_DISARM || nType == FEAT_IMPROVED_DISARM)
        {
            if(GetWeaponRanged(oWeaponAttacker)) return;//sanity check

            int bDisarmable = GetIsCreatureDisarmable(oTarget);
            if(!GetDroppableFlag(oWeaponTarget))//workaround for a bug in GetIsCreatureDisarmable function
            {
                SetDroppableFlag(oWeaponTarget,TRUE);
                bDisarmable = GetIsCreatureDisarmable(oTarget);
                SetDroppableFlag(oWeaponTarget,FALSE);
            }
            //no effect on dead target, unarmed targets, targets with cursed weapon + immune ones
            if(!GetIsObjectValid(oTarget) || GetIsDead(oTarget) || !GetIsObjectValid(oWeaponTarget) || !bDisarmable || GetItemCursedFlag(oWeaponTarget) || GetLocalInt(oTarget,"IMMUNITY_DISARM"))
            {
                //system variable that shows "failed" in the combat log
                SetLocalInt(OBJECT_SELF,"SPECIAL_ATTACK_RESULT",-2);
                return;
            }

            effect eSearch = GetFirstEffect(oTarget);
            while(GetIsEffectValid(eSearch))
            {
                if(GetEffectType(eSearch) == EFFECT_TYPE_POLYMORPH)
                {
                    //also no effect on polymorphed targets
                    SetLocalInt(OBJECT_SELF,"SPECIAL_ATTACK_RESULT",-2);
                    return;
                }
                eSearch = GetNextEffect(oTarget);
            }

            if(d20()+GetSkillRank(SKILL_DISCIPLINE,oTarget) < nAB)
            {
                effect eDisarm = EffectBlindness();
                eDisarm = NWNXPatch_SetEffectTrueType(eDisarm,EFFECT_TRUETYPE_DISARM);
                ApplyEffectToObject(DURATION_TYPE_INSTANT,eDisarm,oTarget);
            }
            else
            {
                //system variable that shows "resisted" in the combat log
                SetLocalInt(OBJECT_SELF,"SPECIAL_ATTACK_RESULT",-1);
            }
        }
        else if(nType == FEAT_SMITE_EVIL || nType == FEAT_SMITE_GOOD)
        {
            //lets not forget to decrement feat uses
            DecrementRemainingFeatUses(OBJECT_SELF,nType);
            if(GetWeaponRanged(oWeaponAttacker)) return;//sanity check

            //no effect on dead target
            if(!GetIsObjectValid(oTarget) || GetIsDead(oTarget) || GetObjectType(oTarget) != OBJECT_TYPE_CREATURE)
            {
                //system variable that shows "failed" in the combat log
                SetLocalInt(OBJECT_SELF,"SPECIAL_ATTACK_RESULT",-2);
                return;
            }

            if(nType == FEAT_SMITE_EVIL)
            {
                if(GetAlignmentGoodEvil(oTarget) != ALIGNMENT_EVIL)
                {
                    if(GetIsPC(OBJECT_SELF))
                    {
                        SendMessageToPCByStrRef(OBJECT_SELF,10490);
                    }
                    //system variable that shows "failed" in the combat log
                    SetLocalInt(OBJECT_SELF,"SPECIAL_ATTACK_RESULT",-2);
                    return;
                }
            }
            else if(nType == FEAT_SMITE_GOOD)
            {
                if(GetAlignmentGoodEvil(oTarget) != ALIGNMENT_GOOD)
                {
                    if(GetIsPC(OBJECT_SELF))
                    {
                        SendMessageToPCByStrRef(OBJECT_SELF,3777);
                    }
                    //system variable that shows "failed" in the combat log
                    SetLocalInt(OBJECT_SELF,"SPECIAL_ATTACK_RESULT",-2);
                    return;
                }
            }

            //and that's all folks! damage is calculated above
        }
        else if(nType == FEAT_SAP)
        {
            if(GetWeaponRanged(oWeaponAttacker)) return;//sanity check
            //no effect on dead target
            if(!GetIsObjectValid(oTarget) || GetIsDead(oTarget) || nDamage < 1)
            {
                //system variable that shows "failed" in the combat log
                SetLocalInt(OBJECT_SELF,"SPECIAL_ATTACK_RESULT",-2);
                return;
            }
            if(GetCreatureSize(oTarget) != CREATURE_SIZE_SMALL && GetCreatureSize(oTarget) != CREATURE_SIZE_LARGE)
            {
                if(GetIsPC(OBJECT_SELF))
                {
                    SendMessageToPCByStrRef(OBJECT_SELF,7948);
                }
                //system variable that shows "failed" in the combat log
                SetLocalInt(OBJECT_SELF,"SPECIAL_ATTACK_RESULT",-2);
                return;
            }

            //discipline check
            if(d20()+GetSkillRank(SKILL_DISCIPLINE,oTarget) < nAB)
            {
                effect eDaze = ExtraordinaryEffect(EffectDazed());
                DelayCommand(0.5,ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eDaze,oTarget,12.0));
            }
            else
            {
                //system variable that shows "resisted" in the combat log
                SetLocalInt(OBJECT_SELF,"SPECIAL_ATTACK_RESULT",-1);
            }
        }
        else if(nType == FEAT_QUIVERING_PALM)
        {
            //lets not forget to decrement feat uses
            DecrementRemainingFeatUses(OBJECT_SELF,nType);
            if(GetWeaponRanged(oWeaponAttacker)) return;//sanity check

            //no effect on dead target, unarmed targets, targets with cursed weapon + immune ones
            if(!GetIsObjectValid(oTarget) || nDamage < 1 || GetIsDead(oTarget) || GetIsImmune(oTarget,IMMUNITY_TYPE_CRITICAL_HIT,OBJECT_SELF))
            {
                //system variable that shows "failed" in the combat log
                SetLocalInt(OBJECT_SELF,"SPECIAL_ATTACK_RESULT",-2);
                return;
            }
            if(GetHitDice(OBJECT_SELF) <= GetHitDice(oTarget))
            {
                if(GetIsPC(OBJECT_SELF))
                {
                    SendMessageToPCByStrRef(OBJECT_SELF,53240);
                }
                //system variable that shows "failed" in the combat log
                SetLocalInt(OBJECT_SELF,"SPECIAL_ATTACK_RESULT",-2);
                return;
            }

            int nDC = 10+GetLevelByClass(CLASS_TYPE_MONK)/2+GetAbilityModifier(ABILITY_WISDOM);

            //fortitude save
            if(!FortitudeSave(oTarget,nDC,SAVING_THROW_TYPE_NONE))
            {
                NWNXPatch_SetAttackKillingBlow(OBJECT_SELF,TRUE);
                effect eDeath = SupernaturalEffect(EffectDeath(TRUE));
                DelayCommand(0.5,ApplyEffectToObject(DURATION_TYPE_INSTANT,eDeath,oTarget));
            }
            else
            {
                //system variable that shows "resisted" in the combat log
                SetLocalInt(OBJECT_SELF,"SPECIAL_ATTACK_RESULT",-1);
            }
        }
        else if(nType == SPECIAL_ATTACK_CALLED_SHOT_LEGS || nType == SPECIAL_ATTACK_CALLED_SHOT_ARMS)
        {
            //no effect on dead target or targets without legs/arms
            if(!GetIsObjectValid(oTarget) || GetIsDead(oTarget))
            {
                //system variable that shows "failed" in the combat log
                SetLocalInt(OBJECT_SELF,"SPECIAL_ATTACK_RESULT",-2);
                return;
            }
            if(nType == SPECIAL_ATTACK_CALLED_SHOT_LEGS && StringToInt(Get2DAString("appearance","HASLEGS",GetAppearanceType(oTarget))) < 1)
            {
                if(GetIsPC(OBJECT_SELF))
                {
                    SendMessageToPCByStrRef(OBJECT_SELF,7946);
                }
                //system variable that shows "failed" in the combat log
                SetLocalInt(OBJECT_SELF,"SPECIAL_ATTACK_RESULT",-2);
                return;
            }
            else if(nType == SPECIAL_ATTACK_CALLED_SHOT_ARMS && StringToInt(Get2DAString("appearance","HASARMS",GetAppearanceType(oTarget))) < 1)
            {
                if(GetIsPC(OBJECT_SELF))
                {
                    SendMessageToPCByStrRef(OBJECT_SELF,7947);
                }
                //system variable that shows "failed" in the combat log
                SetLocalInt(OBJECT_SELF,"SPECIAL_ATTACK_RESULT",-2);
                return;
            }

            //discipline check
            if(d20()+GetSkillRank(SKILL_DISCIPLINE,oTarget) < nAB)
            {
                effect eShot;
                if(nType == SPECIAL_ATTACK_CALLED_SHOT_LEGS)
                {
                    eShot = EffectAbilityDecrease(ABILITY_DEXTERITY,2);
                    eShot = EffectLinkEffects(eShot,EffectMovementSpeedDecrease(20));
                }
                else
                {
                    eShot = EffectAttackDecrease(2);
                }
                eShot = ExtraordinaryEffect(eShot);
                DelayCommand(0.5,ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eShot,oTarget,24.0));
            }
            else
            {
                //system variable that shows "resisted" in the combat log
                SetLocalInt(OBJECT_SELF,"SPECIAL_ATTACK_RESULT",-1);
            }
        }
        else if(nType == FEAT_KI_DAMAGE)
        {
            //int base_dmg_original = NWNXPatch_GetTotalDamageDealtByType(OBJECT_SELF,DAMAGE_TYPE_BASE_WEAPON);

        }
        /*custom special attack example code
        else if(nType == 1115)//*FEAT_BLINDING_FIST
        {
            //no effect on dead target
            if(!GetIsObjectValid(oTarget) || GetIsDead(oTarget) )
            {
                //system variable that shows "failed" in the combat log
                SetLocalInt(OBJECT_SELF,"SPECIAL_ATTACK_RESULT",-2);
                return;
            }

            int nDC = GetHitDice(OBJECT_SELF)/2+GetAbilityModifier(ABILITY_DEXTERITY);
            //check
            if(!FortitudeSave(oTarget,nDC,SAVING_THROW_TYPE_NONE))
            {
                effect eBlind = ExtraordinaryEffect(EffectBlindness());
                DelayCommand(0.5,ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eBlind,oTarget,12.0));
            }
            else
            {
                //system variable that shows "resisted" in the combat log
                SetLocalInt(OBJECT_SELF,"SPECIAL_ATTACK_RESULT",-1);
            }
        }
        */
    }
}
