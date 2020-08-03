void main()
{
    string sResRef = GetResRef(OBJECT_SELF);
    if (GetStringLeft(sResRef, 3) != "hen") return;

    int i;
    for (i = 1; i < 30; i++)
    {
        DeleteLocalString(OBJECT_SELF, "banter"+IntToString(i));
        DeleteLocalString(OBJECT_SELF, "banter_sound"+IntToString(i));
    }

    int nCount = 0;
    object oArea = GetArea(OBJECT_SELF);
    string sAreaResRef = GetResRef(oArea);

    int bTrapped = GetLocalInt(oArea, "trapped");
    int bAmbush = GetLocalInt(oArea, "ambush");

    int bDanger, bInjured, bBadlyWounded, bPoison, bDisease, bSick, bGoblin, nEffectType;

    if (GetStringLeft(sAreaResRef, 6) == "goblin") bGoblin = TRUE;

    if (bTrapped || bAmbush) bDanger = TRUE;

    float fHealthPercentage = IntToFloat(GetCurrentHitPoints(OBJECT_SELF)) / IntToFloat(GetMaxHitPoints(OBJECT_SELF));

    if (fHealthPercentage <= 0.75) bInjured = TRUE;

    if (fHealthPercentage <= 0.50) bBadlyWounded = TRUE;

    effect eEffect = GetFirstEffect(OBJECT_SELF);

    while (GetIsEffectValid(eEffect))
    {
        nEffectType =GetEffectType(eEffect);
        if (nEffectType == EFFECT_TYPE_POISON) bPoison = TRUE;
        if (nEffectType == EFFECT_TYPE_DISEASE) bDisease = TRUE;
        if (nEffectType == EFFECT_TYPE_DAZED || nEffectType == EFFECT_TYPE_CONFUSED) bSick = TRUE;

        eEffect = GetNextEffect(OBJECT_SELF);
    }

// ====================================
// DAELAN
// ====================================
   if (sResRef == "hen_daelan")
   {

        if (!bDanger)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "It is good to see you again. Everything is going well, I hope?");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2daelm_65");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "For adventurers, we seem to be doing little adventuring.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2daelm_bore");
        }

        if (bInjured)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Perhaps we can rest now.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2daelm_rest");
        }

        if (bBadlyWounded)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "My injuries are grave... I need healing, quickly!");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2daelm_dyin");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Quickly, I need healing!");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2daelm_heal");
        }

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Are you certain?");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2daelm_bad");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Let's move quietly, now.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2daelm_hide");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "An excellent idea.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2daelm_good");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Do you feel that? Eyes, watching us from the shadows.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2daelm_89");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "My axe is ready to take down any who dare stand against us.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2daelm_90");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Listen! Something is following us... no, it's gone now.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2daelm_94");

        if (GetIsAreaAboveGround(oArea) == AREA_UNDERGROUND)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "The air here is heavy and stale. I miss the feel of a stiff wind against my face.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2daelm_96");

            if (bDanger)
            {
                nCount++;
                SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "How much deeper can this dungeon go? We must be miles underground already.");
                SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2daelm_98");
            }
        }

        if (bDanger)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Stay vigilant. Let your guard down here and you will soon be very dead.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2daelm_95");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "We should search this place.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2daelm_srch");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Our adventure here will make a fine tale for my tribe's storyteller... assuming we survive.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2daelm_102");
        }

        if (GetIsAreaInterior(oArea) && bDanger)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "I hear the scurrying of rats and insects fleeing before our torches... and other things, as well.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2daelm_97");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "There's something unsettling about this place. You can taste the madness of its creator.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2daelm_92");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Imagine how many bodies lie buried in here; adventurers who have entered but never come out.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2daelm_99");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "What could possess someone - even a madman - to build a place like this?");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2daelm_100");
        }


        if (bGoblin)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "This place bears the marks of goblin craftsmen... and the only thing goblins craft is traps.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2daelm_84");
        }

        if (bTrapped)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "I prefer battle to the uncertainty of walking these trap filled halls.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2daelm_103");
        }

        if (GetTilesetResRef(oArea) == TILESET_RESREF_CRYPT)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "The stench of evil hangs upon this place. I have a bad feeling about that sarcophagus.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2daelm_80");
        }

        if (GetStringLeft(sAreaResRef, 4) == "maze")
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Though they attack us, I feel sorry for the creatures trapped in this maze.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2daelm_101");
        }

        if (bPoison)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Poisoned?! I feel... unwell.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2daelm_sick");
        }

    }

// ====================================
// LINU
// ====================================
   else if (sResRef == "hen_linu")
   {

        if (!bDanger)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Blessed be.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_hi");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Well, this is certainly one way of not getting anywhere, isn't it?");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_bore");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "It is good to see you again.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_104");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Blessed be, my friend.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_106");
        }

        if (bBadlyWounded)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "With my... last breath... I...");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_dyin");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "I will need healing, quickly!");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_heal");
        }

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "I am NOT clumsy! ...well, all right, I am not THAT clumsy.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_78");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Oops! I think I knocked something over!");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_82");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Oh my! Did you hear that? Oh... maybe it was nothing.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_84");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "I would never have pictured myself doing this back at the temple in Evereska.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_92");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Oh dear. There went my heel. Sigh...");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_93");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "I would never have pictured myself doing this back at the temple in Evereska.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_92");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Oops! I spilled something on my armor...");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_98");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Where did my symbol go? Did I drop it again?");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_99");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "*stubs toe* Tekashi! Oh, please do excuse my elven.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_cuss");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "I do not think that is such a good idea.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_bad");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "We should work together!");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_grup");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Now what would that be?");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_look");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "On a journey there must always be time to rest.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_rest");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Your will?");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_slct");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "I'll keep my eyes open.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_srch");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "By Sehanine, I should say so.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_yes");

        if (bDanger)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "I... don't have the senses of some damnable thief, but I do think there is danger here.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_75");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "There seem to be bodies everywhere. What poor souls met their fates here?");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_88");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Sehanine give me courage to walk into the shadows...");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_94");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Let us move unseen, then.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_hide");
        }

        if (GetIsAreaInterior(oArea) && bDanger)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Sehanine guide us through this terrible place.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_86");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "This dungeon smells of... old death. I can't imagine anyone actually living here.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_87");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "How many heroes have met ignoble ends in these halls? It is sad to think about.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_89");
        }

        if (bTrapped)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "I don't want to step into any traps. I seem to do that too often.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_83");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Just be careful where you step, dear. I can heal you, but I'd rather you just didn't get hurt.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_91");
        }

        if (bPoison || bSick || bDisease)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Why is everything spinning?");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2linuf_sick");
        }
   }

// ====================================
// SHARWYN
// ====================================
   else if (sResRef == "hen_sharwyn")
   {
        if (!bDanger)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Good to see you again!");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_61");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Some excitement would be welcome...");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_bore");
        }

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "This shall make a grand tale!");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_64");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Hello, there. A rather enjoyable adventure this is, isn't it?");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_69");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "So be it!");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_76");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Did someone write graffiti here? Hmmm... ahhhh... no, I guess that would be just a stain. Huh.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_93");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Now *this* should be interesting.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_77");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Hmph. I should have picked up some new boots.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_95");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Wait... did I mark this on the map right? Damn it!");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_101");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "You know, I began adventuring to be famous. Yet I always seem to end up traveling with someone who takes the credit.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_102");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Hmmm... is this off-tune? I can't decide.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_109");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Can you imagine if we actually receive the reward? All that gold... what would one do with it?");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_111");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Hmm, I don't know.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_bad");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "*slight tear on cloak* Oh bugger!");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_cuss");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "I am not a packmule, you know. Notice the lack of long ears and hooves.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_encm");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Sounds fine to me.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_good");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Let's stay together now.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_grup");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Let's look around a bit.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_srch");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "I'll see what I can do.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_pick");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "What's that?");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_look");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Time to fade into the background, hmm?");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_hide");

        if (GetIsNight() || GetIsAreaInterior(oArea))
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Have you ever tried drawing a map by torchlight? This is so frustrating...");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_96");
        }

        if (bGoblin)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Can you see the traces? It looks like goblins in this area. We'd best be careful... for goblins to survive here, they'd have to be very cunning.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_89");
        }

        if (bDanger)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Just watch. I'm going to write some great song down here and then die horribly just so it can be found by some talentless bard years from now and *he'll* become famous.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_103");
        }

        if (bInjured)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "I need to sit down. J-just for a bit.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_rest");
        }

        if (bBadlyWounded)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "I cannot keep up with this!");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_help");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Damn! I need some healing.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_heal");
        }

        if (bPoison)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Bloody poison!");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_sick");
        }

        if (GetIsAreaInterior(oArea) && bDanger)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Why do dungeons always have to be so blasted cold? I'm freezing.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_92");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "You know what? This dungeon seems very clean to me.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_104");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Dried blood. More dried blood. Bones. Yick.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2sharf_108");
        }
   }

// ====================================
// TOMI
// ====================================
   else if (sResRef == "hen_tomi")
   {
        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Ha! I knew you'd come around eventually! You hear that, world?! Tomi's back on the road!!");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_69");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Ya might want to rethink that...");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_bad");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "So are we off, aye?");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_76");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Bloody hell...");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_81");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "I wonder where me old friend Sammy has gotten off to. I sure do miss 'im.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_94");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "You reminds me of someone I met in Neverwinter. I ever tells ya that?");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_95");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Just another adventure to round out me fulfilling career, I always say.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_96");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Oy now! Don't get too far ahead! I can only run so bleedin' fast, ya know.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_97");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Where's me damn picks... oh, there. Why'd I put 'em there?");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_101");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Ya think we'll be going down t' the Underdark? I been there before, ya know.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_112");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "*yawns*");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_bore");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Wish I thought of that.");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_good");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Oh... maybe we should organize ourselves a bit?");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_grup");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "'Ey! What's this?");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_look");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "I am sooo bushed. You have no idea!");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_rest");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "There's gotta be something here...");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_srch");

        nCount++;
        SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Sooo....");
        SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_say");

        if (bDanger)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Mehh... might want t' hold on, here. I gots a bad feelin' about this place.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_87");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "So-oooo... hmmm... I wonder how much a map o' this place would go for...");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_98");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Alright. Update the map... this thing'll be worth a fortune...");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_104");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Crimeny... where the bloody hell are we?");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_103");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Monster blood. There ain't nothin' that stinks quite like it.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_111");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "This isn't working out like I thought!");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_flee");
        }

        if (bGoblin)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Can ya smell that? That's goblin turds, that is. Bloody smart buggers, sometimes, though they're probably no match fer you.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_91");
        }

        if (bGoblin || sAreaResRef == "begg" || GetTilesetResRef(oArea) == TILESET_RESREF_SEWERS)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Brandobaris's bloody feet! Does it ever smell in here, phaugh!");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_99");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Oh. lovely... what'd I step in now?");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_102");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "What in bleedin' blazes is on me shoe? Gahhh! It's a right squishy one.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_113");
        }

        if (GetIsAreaInterior(oArea) && bDanger)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Hmph. Every dungeon looks the same.");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_100");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Ya ever wonder why they don't just get an army and invade this place?");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_107");
        }

        if (GetIsAreaAboveGround(oArea) == AREA_UNDERGROUND)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Oy! I hate it when there's miles o' rock over me bloody head, don't you?");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_105");
        }

        if (bBadlyWounded)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "'Ey! Bleedin' over here...");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_heal");

            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Oh shoot... and we were doing so well...");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_dyin");
        }

        if (GetIsAreaAboveGround(oArea) == AREA_UNDERGROUND)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Oy! I hate it when there's miles o' rock over me bloody head, don't you?");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_105");
        }

        if (bPoison)
        {
            nCount++;
            SetLocalString(OBJECT_SELF, "banter"+IntToString(nCount), "Poison?! Why didn't I think of that...");
            SetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nCount), "vs_nx2tomim_sick");
        }
   }

    int nRandom = Random(nCount)+1;

    SpeakString(GetLocalString(OBJECT_SELF, "banter"+IntToString(nRandom)));
    ClearAllActions();
    PlaySound(GetLocalString(OBJECT_SELF, "banter_sound"+IntToString(nRandom)));
}
