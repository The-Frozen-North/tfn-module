#include "nwnx_webhook"
#include "nwnx_creature"
#include "x2_inc_itemprop"
#include "inc_debug"

// Adds the HiPS feat at the first shadowdancer level,
// or the kobold commando skin
void GiveHiPSFeatSafely(object oCreature);

void GiveHiPSFeatSafely(object oCreature)
{
    object oSkin = GetItemInSlot(INVENTORY_SLOT_CARMOUR, oCreature);
    if (GetLevelByClass(CLASS_TYPE_SHADOWDANCER, oCreature) > 0)
    {
        int i;
        int nHitDice = GetHitDice(oCreature);
        for (i = 8; i <= nHitDice; i++)
        {
            if (NWNX_Creature_GetClassByLevel(oCreature, i) == CLASS_TYPE_SHADOWDANCER)
            {
                NWNX_Creature_AddFeatByLevel(oCreature, FEAT_HIDE_IN_PLAIN_SIGHT, i);
                break;
            }
        }
    }
    else if (GetLevelByClass(CLASS_TYPE_SHIFTER, oCreature) >= 7 && GetResRef(oSkin) == "x2_it_koboldcomm")
    {
        IPSafeAddItemProperty(oSkin, ItemPropertyBonusFeat(FEAT_HIDE_IN_PLAIN_SIGHT));
    }

    DeleteLocalInt(oCreature, "hips_cd");
}

void SendDiscordMessage(string sPath, string sMessage)
{
    NWNX_WebHook_SendWebHookHTTPS("discordapp.com", sPath, sMessage);
}

//void main() {}
