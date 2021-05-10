/*/////////////////////// [On Heartbeat - Animations] //////////////////////////
    Filename: J_AI_Heart_aimat
///////////////////////// [On Heartbeat - Animations] //////////////////////////
    To keep the heartbeat small, I've divided all the bits that MIGHT fire
    into other scripts. This makes it smaller, and faster.

    I've also shortened the perception script too - and along with the heartbeat
    is the largest, Out-Of-Combat script. It isn't divided up by execute scripts,
    but should be leaner.
///////////////////////// [History] ////////////////////////////////////////////
    1.3 - Added to speed up heartbeat and keep filesize down on un-used parts.
    1.4 - Changed to nw_i0_generic, as to include all animations, whatever NwN version.
///////////////////////// [Workings] ///////////////////////////////////////////
    This is executed as file HEARTBEAT_ANIMATIONS_FILE, from the heartbeat
    script (Default1, or onheartbeat). It can run by itself, using the SoU
    animations - better then me changing and making my own, as they are vastly
    improved from NwN!
///////////////////////// [Arguments] //////////////////////////////////////////
    Arguments: N/A
///////////////////////// [On Heartbeat - Animations] ////////////////////////*/

// Generic Include File. This contains animations whatever NwN version it is.
#include "NW_I0_GENERIC"

void main()
{
    if(GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS))
    {
        PlayMobileAmbientAnimations_NonAvian();
    }
    else if(GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS_AVIAN))
    {
        PlayMobileAmbientAnimations_Avian();
    }
    else if(GetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS))
    {
        PlayImmobileAmbientAnimations();
    }
}

