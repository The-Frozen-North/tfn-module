#include "lcs_inc_general"

const int FILTER_2DA_RANGE_HIGH = 0xFFFF;
const int FILTER_2DA_RANGE_LOW = 0xFFFF0000;
const int BITLEN_2DA_RANGE = 16;

const string UI_CHAR_UNDERSCORE = "_";

//==========================================/
void read_2da_apart(string s2da)
//==========================================/
    {
    //PrintString(s2da);

    int i = 0;

    int block = 0;
    int appr_range = GetLocalInt(OBJECT_SELF, s2da + UI_CHAR_UNDERSCORE + "0");

    while(appr_range > 0)
        {
        int appr_endrow = FILTER_2DA_RANGE_HIGH & appr_range;
        int appr_row = appr_range >>> BITLEN_2DA_RANGE;

        while(appr_row <= appr_endrow)
            {
            string appr_acbonus = Get2DAString(s2da, "ACBONUS", appr_row);
            if(appr_acbonus != "")
                {
                i++;

                set_apart_2da_row(s2da, i, appr_row);

                //PrintString(IntToString(appr_row));
                }
            appr_row++;
            }
        block++;
        appr_range = GetLocalInt(OBJECT_SELF, s2da + UI_CHAR_UNDERSCORE + IntToString(block));
        }

    set_apart_max_index(s2da, i);
    }

//==========================================/
void main()
//==========================================/
{
    SetLocalInt(OBJECT_SELF, "parts_belt_0", 21);
    SetLocalInt(OBJECT_SELF, "parts_belt_1", 110 << BITLEN_2DA_RANGE | 115);
    SetLocalInt(OBJECT_SELF, "parts_belt_2", 150 << BITLEN_2DA_RANGE | 156);

    SetLocalInt(OBJECT_SELF, "parts_bicep_0", 15);
    SetLocalInt(OBJECT_SELF, "parts_bicep_1", 110 << BITLEN_2DA_RANGE | 134);
    SetLocalInt(OBJECT_SELF, "parts_bicep_2", 150 << BITLEN_2DA_RANGE | 163);
    SetLocalInt(OBJECT_SELF, "parts_bicep_3", 180 << BITLEN_2DA_RANGE | 181);

    SetLocalInt(OBJECT_SELF, "parts_chest_0", 53);
    SetLocalInt(OBJECT_SELF, "parts_chest_1", 110 << BITLEN_2DA_RANGE | 129);
    SetLocalInt(OBJECT_SELF, "parts_chest_2", 150 << BITLEN_2DA_RANGE | 177);
    SetLocalInt(OBJECT_SELF, "parts_chest_3", 210 << BITLEN_2DA_RANGE | 210);

    SetLocalInt(OBJECT_SELF, "parts_foot_0", 16);
    SetLocalInt(OBJECT_SELF, "parts_foot_1", 80 << BITLEN_2DA_RANGE | 83);
    SetLocalInt(OBJECT_SELF, "parts_foot_2", 110 << BITLEN_2DA_RANGE | 122);
    SetLocalInt(OBJECT_SELF, "parts_foot_3", 150 << BITLEN_2DA_RANGE | 160);
    SetLocalInt(OBJECT_SELF, "parts_foot_4", 180 << BITLEN_2DA_RANGE | 181);

    SetLocalInt(OBJECT_SELF, "parts_forearm_0", 23);
    SetLocalInt(OBJECT_SELF, "parts_forearm_1", 110 << BITLEN_2DA_RANGE | 112);
    SetLocalInt(OBJECT_SELF, "parts_forearm_2", 120 << BITLEN_2DA_RANGE | 128);
    SetLocalInt(OBJECT_SELF, "parts_forearm_3", 150 << BITLEN_2DA_RANGE | 167);
    SetLocalInt(OBJECT_SELF, "parts_forearm_4", 181 << BITLEN_2DA_RANGE | 181);

    SetLocalInt(OBJECT_SELF, "parts_hand_0", 9);
    SetLocalInt(OBJECT_SELF, "parts_hand_1", 109 << BITLEN_2DA_RANGE | 113);
    SetLocalInt(OBJECT_SELF, "parts_hand_2", 121 << BITLEN_2DA_RANGE | 122);
    SetLocalInt(OBJECT_SELF, "parts_hand_3", 150 << BITLEN_2DA_RANGE | 155);
    SetLocalInt(OBJECT_SELF, "parts_hand_4", 181 << BITLEN_2DA_RANGE | 181);

    SetLocalInt(OBJECT_SELF, "parts_legs_0", 16);
    SetLocalInt(OBJECT_SELF, "parts_legs_1", 80 << BITLEN_2DA_RANGE | 94);
    SetLocalInt(OBJECT_SELF, "parts_legs_2", 112 << BITLEN_2DA_RANGE | 122);
    SetLocalInt(OBJECT_SELF, "parts_legs_3", 150 << BITLEN_2DA_RANGE | 162);
    SetLocalInt(OBJECT_SELF, "parts_legs_4", 181 << BITLEN_2DA_RANGE | 182);

    SetLocalInt(OBJECT_SELF, "parts_neck_0", 6);
    SetLocalInt(OBJECT_SELF, "parts_neck_1", 108 << BITLEN_2DA_RANGE | 113);
    SetLocalInt(OBJECT_SELF, "parts_neck_2", 120 << BITLEN_2DA_RANGE | 127);
    SetLocalInt(OBJECT_SELF, "parts_neck_3", 150 << BITLEN_2DA_RANGE | 160);
    SetLocalInt(OBJECT_SELF, "parts_neck_4", 181 << BITLEN_2DA_RANGE | 181);

    SetLocalInt(OBJECT_SELF, "parts_pelvis_0", 37);
    SetLocalInt(OBJECT_SELF, "parts_pelvis_1", 112 << BITLEN_2DA_RANGE | 122);
    SetLocalInt(OBJECT_SELF, "parts_pelvis_2", 150 << BITLEN_2DA_RANGE | 161);

    SetLocalInt(OBJECT_SELF, "parts_robe_0", 6);
    SetLocalInt(OBJECT_SELF, "parts_robe_1", 110 << BITLEN_2DA_RANGE | 173);
    SetLocalInt(OBJECT_SELF, "parts_robe_2", 180 << BITLEN_2DA_RANGE | 187);

    SetLocalInt(OBJECT_SELF, "parts_shin_0", 21);
    SetLocalInt(OBJECT_SELF, "parts_shin_1", 80 << BITLEN_2DA_RANGE | 93);
    SetLocalInt(OBJECT_SELF, "parts_shin_2", 110 << BITLEN_2DA_RANGE | 120);
    SetLocalInt(OBJECT_SELF, "parts_shin_3", 128 << BITLEN_2DA_RANGE | 132);
    SetLocalInt(OBJECT_SELF, "parts_shin_4", 150 << BITLEN_2DA_RANGE | 164);
    SetLocalInt(OBJECT_SELF, "parts_shin_5", 181 << BITLEN_2DA_RANGE | 181);

    SetLocalInt(OBJECT_SELF, "parts_shoulder_0", 25);
    SetLocalInt(OBJECT_SELF, "parts_shoulder_1", 120 << BITLEN_2DA_RANGE | 122);

    read_2da_apart("parts_belt");
    read_2da_apart("parts_bicep");
    read_2da_apart("parts_chest");
    read_2da_apart("parts_foot");
    read_2da_apart("parts_forearm");
    read_2da_apart("parts_hand");
    read_2da_apart("parts_legs");
    read_2da_apart("parts_neck");
    read_2da_apart("parts_pelvis");
    read_2da_apart("parts_robe");
    read_2da_apart("parts_shin");
    read_2da_apart("parts_shoulder");

    SetEventScript(OBJECT_SELF, EVENT_SCRIPT_PLACEABLE_ON_HEARTBEAT, "");
}
