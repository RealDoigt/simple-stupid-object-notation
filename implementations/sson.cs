using System;
using static System.Console;
using System.Collections.Generic;

namespace sson
{
    public static class SSON
    {
        public static bool TrySetObjects(out Dictionary<string, Dictionary<string, string>> objects, string[] rawObjectData)
        {
            objects = new Dictionary<string, Dictionary<string, string>>();
            var defaultValues = new Dictionary<string, Dictionary<string, string>>();

            var readingObject = false; 
            var readingDefault = false;

            var lineCount = 0;
            var currentObject = "";

            foreach (var str in rawObjectData)
            {
                ++lineCount;

                if (str.StartsWith("#") || str.Length == 0) continue;

                if (str.StartsWith("."))
                {
                    if (!readingObject)
                    {
                        Error.WriteLine($"{str} at line {lineCount} is supposed to be a property, however it is cut off from its parent object, you probably misplaced a ; just before that line.");
                        return false;
                    }

                    var keyValuePair = str.Split('=');

                    if (keyValuePair.Length < 2)
                    {
                        Error.WriteLine($"expected a value after {str} at line {lineCount}; property cannot be empty");
                        return false;
                    }

                    // remove the dot at the beginning of the attribute
                    keyValuePair[0] = keyValuePair[0].Substring(1);

                    // removes the ; from the value if it's at the end of it
                    if (keyValuePair[1].EndsWith(";"))
                        keyValuePair[1] = keyValuePair[1].Remove(keyValuePair[1].Length - 1);

                    keyValuePair[0] = keyValuePair[0].Trim();
                    keyValuePair[1] = keyValuePair[1].Trim();

                    // put the value in the appropriate dictionary
                    if (readingDefault)
                    {
                        if (!defaultValues.ContainsKey(currentObject)) 
                            defaultValues.Add(currentObject, new Dictionary<string, string>());

                        if (!defaultValues[currentObject].ContainsKey(keyValuePair[0]))
                            defaultValues[currentObject].Add(keyValuePair[0], keyValuePair[1]);

                        else defaultValues[currentObject][keyValuePair[0]] = keyValuePair[1];
                    }

                    else
                    {
                        if (!objects.ContainsKey(currentObject))
                            objects.Add(currentObject, new Dictionary<string, string>());

                        if (!objects[currentObject].ContainsKey(keyValuePair[0]))
                            objects[currentObject].Add(keyValuePair[0], keyValuePair[1]);

                        else objects[currentObject][keyValuePair[0]] = keyValuePair[1];
                    }
                }

                else
                {
                    if (readingObject)
                    {
                        Error.WriteLine($"expect a ; before line {lineCount}");
                        return false;
                    }

                    if (str.StartsWith("default"))
                    {
                        readingObject = true;
                        readingDefault = true;

                        // removes the default part of the string.
                        currentObject = str.Substring(7).Trim();
                    }

                    else
                    {
                        var cleanStr = str.Trim();

                        currentObject = $"{cleanStr}_{lineCount}";
                        readingObject = true;

                        if (defaultValues.ContainsKey(cleanStr))
                        {
                            objects.Add(currentObject, new Dictionary<string, string>());

                            foreach (var property in defaultValues[cleanStr])
                                objects[currentObject].Add(property.Key, property.Value);
                        }
                    }
                }

                if (str.EndsWith(";"))
                {
                    if (!readingObject) 
                        Error.WriteLine($"redundant ; at line {lineCount}");

                    readingObject = false;
                    readingDefault = false;
                }
            }

            return true;
        }
    }
}
