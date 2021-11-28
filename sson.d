module sson;
import std.stdio;
import std.string;
import std.algorithm;

bool trySetObjects(ref string[string][string] objects, string[] rawObjectData)
{
    auto readingObject = false, readingDefault = false;

    auto lineCount = 0;
    auto currentObject = "";

    string[string][string] defaultValues;

    // this puts all the attributes and values of an object in a hashmap
    // each object has a unique identifier that goes by its name and the
    // line # it was declared on, separated by an _ except for default values
    foreach (str; rawObjectData)
    {
        ++lineCount;

        if (str.startsWith("#") || !str.length) continue;

        if (str.startsWith("."))
        {
            if (!readingObject)
            {
                writeln("%s at line %d is supposed to be a property, however it is cut off from its parent object. You probably misplaced a ; just before that line.".format(str, lineCount));
                return false;
            }

            auto keyValuePair = str.split("=");

            if (keyValuePair.length < 2)
            {
                writeln("expected a value after %s at line %d; property cannot be empty.".format(str, lineCount));
                return false;
            }

            keyValuePair[0] = keyValuePair[0].strip;
            keyValuePair[1] = keyValuePair[1].strip;

            // remove the dot at the beginning of the attribute
            keyValuePair[0] = keyValuePair[0][1..keyValuePair[0].length];

            // removes the ; from the value if it's at the end of it
            if (keyValuePair[1].endsWith(";")) keyValuePair[1] = keyValuePair[1][0..keyValuePair[1].length - 1];

            // put the value in the appropriate hashmap.
            if (!readingDefault) objects[currentObject][keyValuePair[0]] = keyValuePair[1];
            else defaultValues[currentObject][keyValuePair[0]] = keyValuePair[1];
        }

        else
        {
            if (readingObject)
            {
                writeln("expected a ; before line %d".format(lineCount));
                return false;
            }

            if (str.startsWith("default"))
            {
                readingObject = true;
                readingDefault = true;

                // removes the default part of the string.
                currentObject = str[7..str.length].strip;
            }

            else
            {
                auto cleanStr = str.strip;

                currentObject = format("%s_%d", cleanStr, lineCount);
                readingObject = true;

                if (defaultValues.keys.canFind(cleanStr))
                {
                    auto attributes = defaultValues[cleanStr].keys;

                    foreach (attribute; attributes)
                        objects[currentObject][attribute] = defaultValues[cleanStr][attribute];
                }
            }
        }

        if (str.endsWith(";"))
        {
            if (!readingObject) writeln("redundant ; at line %d".format(lineCount));
            readingDefault = false;
            readingObject = false;
        }
    }

    return true;
}
