using System;
using System.Collections.Generic;
using System.Diagnostics.Contracts;
using System.Linq;
using System.Text;
using Godot;
using YACY.Legacy.Objects;

namespace YACY.Legacy
{
    public static class CYLevelParser
    {
        private static readonly string aMazerMagicValue = "[#name:";
            
        // Parses Adobe Shockwave Lingo's file structure for CY Levels
        // It consists of a dictionary where keys can be defined with either "" or starting with a #
        // Keys are case insensitive
        // Example: [#name: "Game Title, "Author": "ChallengeYou", ...]
        public static LegacyLevelData ParseCYLevel(string levelCode)
        {
            var levelHeaders = new Dictionary<string, string>();
            var levelData = new Dictionary<string, ICollection<string>>();
            var levelObjects = new Dictionary<string, ICollection<ICYObject>>();

            var strPtr = 0; // String index
            var depth = 0; // Depth inside arrays
            var objectCount = 0; // Keep track of object number

            var levelSize = levelCode.Length;

            while (strPtr != levelSize - 1)
            {
                var ch = levelCode[strPtr];
                switch (ch)
                {
                    // Array/Dictionary
                    case '[':
                        depth++;
                        break;
                    case ']':
                        depth--;
                        break;

                    // Key/Value extraction
                    case '"':
                    case '#':
                        strPtr++;

                        // Get key string
                        var keyEndChar = ch == '#' ? ':' : '"';
                        var keyEndIndex = levelCode.Find(keyEndChar, strPtr + 1);
                        var keyLength = keyEndIndex - strPtr;
                        var key = levelCode.Substring(strPtr, keyLength);
                        key = key.ToLower();

                        GD.Print($"Extracted {key}");

                        strPtr = keyEndIndex + 2 + (keyEndChar == '"' ? 1 : 0);

                        // Get Value
                        if (levelCode[strPtr] == '[')
                        {
                            var extractedData = ExtractLingoArray(levelCode, strPtr, levelSize, depth);

                            levelData.Add(key, extractedData.Objects);
                            objectCount += extractedData.Objects.Count;

                            strPtr = extractedData.FinalIndex;
                        }
                        else
                        {
                            // String/Variant value
                            var valueEndIndex = levelCode.Find(',', strPtr + 1);
                            var value = levelCode.Substring(strPtr, valueEndIndex - strPtr);

                            // If the value has speech marks, remove them
                            if (value.StartsWith("\"") && value.EndsWith("\""))
                                value = value.Substring(1, value.Length - 2);

                            levelHeaders.Add(key, value);
                            strPtr = valueEndIndex;
                        }

                        break;
                }

                if (depth == 0)
                {
                    break;
                }

                strPtr++;
            }

            // Check if there is metadata
            if (!levelHeaders.ContainsKey("name") || !levelHeaders.ContainsKey("creator"))
            {
                // Throw some sort of exception
                GD.PrintErr($"Level did not contain metadata");
            }

            //Print Boards
            /*if (levelData.ContainsKey("board"))
            {
                foreach (var board in levelData["board"])
                {
                    GD.Print($"Board: {board}");
                    var boardProperties = ExtractObjectProperties(board);
                    foreach (var prop in boardProperties)
                    {
                        GD.Print($" - {prop}");
                    }
                }
            }*/

            var rawLevelObjects = new Dictionary<string, ICollection<IList<string>>>();
            foreach (var data in levelData)
            {
                var rawObjectIndex = data.Key;
                var rawObjectList = new List<IList<string>>();
                foreach (var objectData in data.Value)
                {
                    var rawObject = ExtractObjectProperties(objectData);
                    rawObjectList.Add(rawObject);
                }
                
                rawLevelObjects.Add(rawObjectIndex, rawObjectList);
            }

            var legacyLevelData = new LegacyLevelData
            {
                Title = levelHeaders["name"],
                Author = levelHeaders["creator"],
                RawObjectData = rawLevelObjects,
            };
            return legacyLevelData;
        }

        private struct LingoArrayExtraction
        {
            public ICollection<string> Objects;
            public int FinalIndex;
        }

        // Extracts an array of objects in lingo format
        private static LingoArrayExtraction ExtractLingoArray(string levelCode, int strPtr, int levelSize, int depth)
        {
            // Array value
            var arrayStartIndex = strPtr + 1;
            var arrayDepth = depth;

            var objects = new List<string>();
            var objectStartIndex = strPtr;
            var objectDepth = depth + 1;

            depth++;
            strPtr++;

            var isInTextProperty = false; // Ignore control chars inside of text boxes

            // Objects inside an array typically have brackets inside them, objectDepth remembers
            while (depth > arrayDepth && strPtr != levelSize - 2)
            {
                var ch = levelCode[strPtr];
                switch (ch)
                {
                    case '[':
                        if (isInTextProperty) break;
                        depth++;

                        // If it's a new object array, set the object pointer to the start of it
                        if (depth == objectDepth + 1)
                        {
                            objectStartIndex = strPtr;
                        }

                        break;

                    case ']':
                        if (isInTextProperty) break;
                        depth--;

                        if (depth == objectDepth)
                        {
                            var objectStrLength = strPtr - objectStartIndex + 1;
                            var objectData = levelCode.Substring(objectStartIndex, objectStrLength);

                            objects.Add(objectData);
                        }

                        break;

                    case '"':
                        isInTextProperty = !isInTextProperty;
                        break;
                }

                strPtr++;
            }

            var returnData = new LingoArrayExtraction();
            returnData.Objects = objects;
            returnData.FinalIndex = strPtr;
            return returnData;
        }

        private static IList<string> ExtractObjectProperties(string objectArrayString)
        {
            var objectProperties = new List<string>();

            // Remove excess characters
            var cleanObjectStringBuilder = new StringBuilder();
            var maxLength = objectArrayString.Length - 1;
            var isInTextProperty = false;

            // Build clean string by removing all [ and ]
            for (var index = 0; index < maxLength; index++)
            {
                var ch = objectArrayString[index];

                if ((ch != '[' && ch != ']') || isInTextProperty)
                {
                    cleanObjectStringBuilder.Append(ch);
                }

                if (ch == '"')
                    isInTextProperty = !isInTextProperty;
            }

            var cleanObjectString = cleanObjectStringBuilder.ToString();
            var strPtr = 0;
            maxLength = cleanObjectString.Length;

            // Usually if there's more than 15 properties, it's a sign of an infinite loop
            while (strPtr < maxLength && objectProperties.Count < 15)
            {
                var ch = cleanObjectString[strPtr];

                // Check if numerical value
                string property;
                if (Char.IsDigit(ch) || ch == '-')
                {
                    var endIndex = cleanObjectString.Find(", ", strPtr);
                    if (endIndex != -1)
                    {
                        property = cleanObjectString.Substring(strPtr, endIndex - strPtr);
                        strPtr = endIndex;
                    }
                    else
                    {
                        property = cleanObjectString.Substring(strPtr, maxLength - strPtr);
                        strPtr = maxLength;
                    }
                    
                    objectProperties.Add(property);
                }
                
                // Check if colour value
                else if (ch == 'c')
                {
                    var endIndex = cleanObjectString.Find(')', strPtr);
                    property = cleanObjectString.Substring(strPtr, endIndex - strPtr + 1);

                    objectProperties.Add(property);
                    strPtr = endIndex;
                }
                
                // Check if text value
                else if (ch == '"')
                {
                    var endIndex = cleanObjectString.Find('"', strPtr + 1);
                    property = cleanObjectString.Substring(strPtr + 1, endIndex - strPtr - 1);

                    objectProperties.Add(property);
                    strPtr = endIndex;
                }

                strPtr++;
            }

            return objectProperties;
        }

        public static bool CheckMagicValue(byte[] levelData)
        {
			var magicValueBytes = Encoding.ASCII.GetBytes(aMazerMagicValue);
            if (levelData.Length < magicValueBytes.Length)
            {
                return false;
            }
        
            for (var i = 0; i < magicValueBytes.Length; i++)
            {
                if (levelData[i] != magicValueBytes[i])
                {
                    return false;
                }
            }
        
            return true;
        }
    }
}