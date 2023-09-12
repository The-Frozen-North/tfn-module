#include "nw_o2_coninclude"
#include "nw_i0_generic"

void VoidBeginConversation(string sResRef, object oConversationTarget)
{
    BeginConversation(sResRef, oConversationTarget);
}

void ScanTarget(object oTarget, object oScanner)
{
    effect eVis = EffectVisualEffect(VFX_IMP_MAGIC_RESISTANCE_USE);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);

    if (GetIsDead(oTarget)) return;

    if (GetLocalInt(oTarget, "warden_interrogate") < 2) return;

// don't interrogate while in conversation
    if (IsInConversation(oScanner)) return;


// don't interrupt invisibility purge
    if (GetCurrentAction() == ACTION_CASTSPELL) return;

// never saw the guy, do nothing
    if (!GetObjectSeen(oTarget, oScanner)) return;

// if already bluffed, do nothing
    if (GetLocalInt(OBJECT_SELF, "bluffed_"+GetPCPublicCDKey(oTarget)+GetName(oTarget))) return;

// if currently interrogated by another warden, do nothing
    if (IsInConversation(oTarget))
    {
        object oLastConversationObject = GetLocalObject(oTarget, "last_conversation_object");

        if (GetResRef(oLastConversationObject) == "luskan_warden")
            return;

        // otherwise, if the PC is in a conversation with someone that's NOT a warden, do this to force the conversation to end
        AssignCommand(oTarget, ActionStartConversation(oTarget, "non_existant_dialogue"));
        return;
    }

    PlayVoiceChat(VOICE_CHAT_STOP, OBJECT_SELF);

    AssignCommand(oScanner, ClearAllActions());
    AssignCommand(oScanner, VoidBeginConversation("", oTarget));
}

int DispelInvis() {
    float fRadius = 20.0;
    location lLocation = GetLocation(OBJECT_SELF);

    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fRadius, lLocation);
    //Get first target in spell area
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != OBJECT_SELF)
        {
            // Trigger if PC
            if (GetIsPC(oTarget) && GetHasEffect(EFFECT_TYPE_INVISIBILITY, oTarget))
            {
                AssignCommand(OBJECT_SELF, ClearAllActions());
                AssignCommand(OBJECT_SELF, SpeakString("An illusion? What are you hiding?!"));
                AssignCommand(OBJECT_SELF, ActionCastSpellAtObject(SPELL_INVISIBILITY_PURGE, OBJECT_SELF, METAMAGIC_ANY, TRUE));

                return TRUE;
            }
        }
        //Get next target in area
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, fRadius, lLocation);
    }

    return FALSE;
}

void main()
{
// don't scan in combat
    if (GetIsInCombat()) return;

// don't scan while resting
    if (GetIsResting()) return;

// don't scan while in conversation
    if (IsInConversation(OBJECT_SELF)) return;

// don't scan while casting a spell
    if (GetCurrentAction() == ACTION_CASTSPELL) return;

// make sure we always have see invis on
    if (!GetHasEffect(EFFECT_TYPE_SEEINVISIBLE))
    {
        effect eEffect = EffectSeeInvisible();
        eEffect = EffectLinkEffects(eEffect, EffectVisualEffect(VFX_DUR_MAGICAL_SIGHT));

        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eEffect, OBJECT_SELF);
    }

// if currently dispelling, return
    if (DispelInvis()) return;

    effect eImpact = EffectVisualEffect(VFX_FNF_HOWL_ODD, FALSE, 1.0, Vector(0.0, 0.0, 2.0));
    float fDelay;
    float fRadius = 15.0;

    location lLocation = GetLocation(OBJECT_SELF);

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, GetLocation(OBJECT_SELF));

    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fRadius, lLocation);
    //Get first target in spell area
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != OBJECT_SELF)
        {
            fDelay = GetDistanceToObject(oTarget)/10;

            // Trigger if PC
            if(GetIsPC(oTarget))
            {
                //Apply the VFX impact and effects
                DelayCommand(fDelay, ScanTarget(oTarget, OBJECT_SELF));
            }
        }
        //Get next target in area
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, fRadius, lLocation);
    }
}
