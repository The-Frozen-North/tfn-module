/// ----------------------------------------------------------------------------
/// @file   util_i_csvlists.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Functions for manipulating comma-separated value (CSV) lists.
/// @details
///
/// ## Usage:
///
/// ```nwscript
/// string sKnight, sKnights = "Lancelot, Galahad, Robin";
/// int i, nCount = CountList(sKnights);
/// for (i = 0; i < nCount; i++)
/// {
///     sKnight = GetListItem(sKnights, i);
///     SpeakString("Sir " + sKnight);
/// }
///
/// int bBedivere = HasListItem(sKnights, "Bedivere");
/// SpeakString("Bedivere " + (bBedivere ? "is" : "is not") + " in the party.");
///
/// sKnights = AddListItem(sKnights, "Bedivere");
/// bBedivere = HasListItem(sKnights, "Bedivere");
/// SpeakString("Bedivere " + (bBedivere ? "is" : "is not") + " in the party.");
///
/// int nRobin = FindListItem(sKnights, "Robin");
/// SpeakString("Robin is knight " + IntToString(nRobin) + " in the party.");
/// ```
/// ----------------------------------------------------------------------------

#include "x3_inc_string"
#include "util_i_math"
#include "util_i_strings"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Return the number of items in a CSV list.
/// @param sList The CSV list to count.
int CountList(string sList);

/// @brief Add an item to a CSV list.
/// @param sList The CSV list to add the item to.
/// @param sListItem The item to add to sList.
/// @param bAddUnique If TRUE, will only add the item to the list if it is not
///     already there.
/// @returns A modified copy of sList with sListItem added.
string AddListItem(string sList, string sListItem, int bAddUnique = FALSE);

/// @brief Return the item at an index in a CSV list.
/// @param sList The CSV list to get the item from.
/// @param nIndex The index of the item to get (0-based).
string GetListItem(string sList, int nIndex = 0);

/// @brief Return the index of a value in a CSV list.
/// @param sList The CSV list to search.
/// @param sListItem The value to search for.
/// @returns -1 if the item was not found in the list.
int FindListItem(string sList, string sListItem);

/// @brief Return whether a CSV list contains a value.
/// @param sList The CSV list to search.
/// @param sListItem The value to search for.
/// @returns TRUE if the item is in the list, otherwise FALSE.
int HasListItem(string sList, string sListItem);

/// @brief Delete the item at an index in a CSV list.
/// @param sList The CSV list to delete the item from.
/// @param nIndex The index of the item to delete (0-based).
/// @returns A modified copy of sList with the item deleted.
string DeleteListItem(string sList, int nIndex = 0);

/// @brief Delete the first occurrence of an item in a CSV list.
/// @param sList The CSV list to remove the item from.
/// @param sListItem The value to remove from the list.
/// @returns A modified copy of sList with the item removed.
string RemoveListItem(string sList, string sListItem);

/// @brief Copy items from one CSV list to another.
/// @param sSource The CSV list to copy items from.
/// @param sTarget The CSV list to copy items to.
/// @param nIndex The index to begin copying from.
/// @param nRange The number of items to copy.
/// @param bAddUnique If TRUE, will only copy items to sTarget if they are not
///     already there.
/// @returns A modified copy of sTarget with the items added to the end.
string CopyListItem(string sSource, string sTarget, int nIndex, int nRange = 1, int bAddUnique = FALSE);

/// @brief Merge the contents of two CSV lists.
/// @param sList1 The first CSV list.
/// @param sList2 The second CSV list.
/// @param bAddUnique If TRUE, will only put items in the returned list if they
///     are not already there.
/// @returns A CSV list containing the items from each list.
string MergeLists(string sList1, string sList2, int bAddUnique = FALSE);

/// @brief Add an item to a CSV list saved as a local variable on an object.
/// @param oObject The object on which the local variable is saved.
/// @param sListName The varname for the local variable.
/// @param sListItem The item to add to the list.
/// @param bAddUnique If TRUE, will only add the item to the list if it is not
///     already there.
/// @returns The updated copy of the list with sListItem added.
string AddLocalListItem(object oObject, string sListName, string sListItem, int bAddUnique = FALSE);

/// @brief Delete an item in a CSV list saved as a local variable on an object.
/// @param oObject The object on which the local variable is saved.
/// @param sListName The varname for the local variable.
/// @param nIndex The index of the item to delete (0-based).
/// @returns The updated copy of the list with the item at nIndex deleted.
string DeleteLocalListItem(object oObject, string sListName, int nNth = 0);

/// @brief Remove an item in a CSV list saved as a local variable on an object.
/// @param oObject The object on which the local variable is saved.
/// @param sListName The varname for the local variable.
/// @param sListItem The value to remove from the list.
/// @returns The updated copy of the list with the first instance of sListItem
///     removed.
string RemoveLocalListItem(object oObject, string sListName, string sListItem);

/// @brief Merge the contents of a CSV list with those of a CSV list stored as a
///     local variable on an object.
/// @param oObject The object on which the local variable is saved.
/// @param sListName The varname for the local variable.
/// @param sListToMerge The CSV list to merge into the saved list.
/// @param bAddUnique If TRUE, will only put items in the returned list if they
///     are not already there.
/// @returns The updated copy of the list with all items from sListToMerge
///     added.
string MergeLocalList(object oObject, string sListName, string sListToMerge, int bAddUnique = FALSE);

/// @brief Convert a comma-separated value list to a JSON array.
/// @param sList Source CSV list.
/// @returns JSON array representation of CSV list.
json ListToJson(string sList);

/// @brief Convert a JSON array to a comma-separate value list.
/// @param jArray JSON array list.
/// @returns CSV list of JSON array values.
string JsonToList(json jArray);

// -----------------------------------------------------------------------------
//                           Function Implementations
// -----------------------------------------------------------------------------

int CountList(string sList)
{
    if (sList == "")
        return 0;

    return GetSubStringCount(sList, ",") + 1;
}

string AddListItem(string sList, string sListItem, int bAddUnique = FALSE)
{
    if (bAddUnique && HasListItem(sList, sListItem))
        return sList;

    if (sList != "")
        return sList + ", " + sListItem;

    return sListItem;
}

string GetListItem(string sList, int nIndex = 0)
{
    if (nIndex < 0 || sList == "")
        return "";

    // Loop through the elements until we find the one we want.
    int nCount, nLeft, nRight = FindSubString(sList, ",");
    while (nRight != -1 && nCount < nIndex)
    {
        nCount++;
        nLeft = nRight + 1;
        nRight = FindSubString(sList, ",", nLeft);
    }

    // If there were not enough elements, return a null string.
    if (nCount < nIndex)
        return "";

    // Get the element
    return TrimString(GetStringSlice(sList, nLeft, nRight));
}

int FindListItem(string sList, string sListItem)
{
    sList = TrimString(sList);
    sListItem = TrimString(sListItem);
    if (sList == "")
        return -1;

    int nItem, nStart, nEnd;
    do
    {
        nEnd = FindSubString(sList, ",", nStart);
        if (TrimString(GetStringSlice(sList, nStart, nEnd)) == sListItem)
            return nItem;
        nItem++;
        nStart = nEnd + 1;
    }
    while (nEnd >= 0);
    return -1;
}

int HasListItem(string sList, string sListItem)
{
    return (FindListItem(sList, sListItem) > -1);
}

string DeleteListItem(string sList, int nIndex = 0)
{
    if (nIndex < 0 || sList == "")
        return sList;

    int nPos = FindSubStringN(sList, ",", nIndex);
    if (nPos < 0)
    {
        if (nIndex)
        {
            nPos = FindSubStringN(sList, ",", nIndex - 1);
            return TrimStringRight(GetStringSlice(sList, 0, nPos));
        }

        return "";
    }

    string sRight = GetStringSlice(sList, nPos + 1);
    nPos = FindSubStringN(sList, ",", nIndex - 1);
    sRight = nPos < 0 ? TrimStringLeft(sRight) : sRight;
    return GetStringSlice(sList, 0, nPos + 1) + sRight;
}

string RemoveListItem(string sList, string sListItem)
{
    return DeleteListItem(sList, FindListItem(sList, sListItem));
}

string CopyListItem(string sSource, string sTarget, int nIndex, int nRange = 1, int bAddUnique = FALSE)
{
    string sValue;
    int i, nCount = CountList(sSource);

    if (nIndex < 0 || nIndex >= nCount || !nCount)
        return sSource;

    nRange = clamp(nRange, 1, nCount - nIndex);

    for (i = 0; i < nRange; i++)
    {
        sValue = GetListItem(sSource, nIndex + i);
        sTarget = AddListItem(sTarget, sValue, bAddUnique);
    }

    return sTarget;
}

string MergeLists(string sList1, string sList2, int bAddUnique = FALSE)
{
    int i, nCount = CountList(sList2);
    for (i = 0; i < nCount; i++)
        sList1 = AddListItem(sList1, GetListItem(sList2, i), bAddUnique);

    return sList1;
}

string AddLocalListItem(object oObject, string sListName, string sListItem, int bAddUnique = FALSE)
{
    string sList = GetLocalString(oObject, sListName);
    sList = AddListItem(sList, sListItem, bAddUnique);
    SetLocalString(oObject, sListName, sList);
    return sList;
}

string DeleteLocalListItem(object oObject, string sListName, int nNth = 0)
{
    string sList = GetLocalString(oObject, sListName);
    sList = DeleteListItem(sList, nNth);
    SetLocalString(oObject, sListName, sList);
    return sList;
}

string RemoveLocalListItem(object oObject, string sListName, string sListItem)
{
    string sList = GetLocalString(oObject, sListName);
    sList = RemoveListItem(sList, sListItem);
    SetLocalString(oObject, sListName, sList);
    return sList;
}

string MergeLocalList(object oObject, string sListName, string sListToMerge, int bAddUnique = FALSE)
{
    string sList = GetLocalString(oObject, sListName);
    sList = MergeLists(sList, sListToMerge, bAddUnique);
    SetLocalString(oObject, sListName, sList);
    return sList;
}

json ListToJson(string sList)
{
    json jRet = JsonArray();
    if (sList == "")
        return jRet;

    string sItem;
    int nStart, nEnd;

    do
    {
        nEnd = FindSubString(sList, ",", nStart);
        sItem = TrimString(GetStringSlice(sList, nStart, nEnd));
        jRet = JsonArrayInsert(jRet, JsonString(sItem));
        nStart = nEnd + 1;
    } while (nEnd != -1);

    return jRet;
}

string JsonToList(json jArray)
{
    if (JsonGetType(jArray) != JSON_TYPE_ARRAY)
        return "";

    string sList;
    int i, nCount = JsonGetLength(jArray);
    for (i; i < nCount; i++)
    {
        if (i > 0)
            sList += ", ";
        sList += JsonGetString(JsonArrayGet(jArray, i));
    }

    return sList;
}
