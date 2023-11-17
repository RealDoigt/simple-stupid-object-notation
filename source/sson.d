module sson;
import std.stdio;
import std.string;
import std.algorithm;

bool trySetObjects(out string[string][string] objects, string[] rawObjectData)
{
    auto readingDefault = false, 
         lineCount      = 0,
         currentObject  = "";

    string[string][string] defaultValues;
    
    foreach (str; rawObjectData)
    {
        ++lineCount;

        if (str.startsWith("#") || !str.length) continue;

        if (str.startsWith("."))
        {
            auto keyValuePair = str.split("=");

            if (keyValuePair.length < 2)
            {
                writefln("expected a value after %s at line %d; property cannot be empty.", str, lineCount);
                return false;
            }

            // this is a fix for when someone uses another = after the assign
            for (int i = 2; i < keyValuePair.length; ++i)
                keyValuePair[1] ~= "=" ~ keyValuePair[i];

            // remove the dot at the beginning of the attribute
            keyValuePair[0] = keyValuePair[0][1..$];

            keyValuePair[0] = keyValuePair[0].strip;
            keyValuePair[1] = keyValuePair[1].strip;

            // put the value in the appropriate hashmap.
            if (readingDefault) defaultValues[currentObject][keyValuePair[0]] = keyValuePair[1];
            else objects[currentObject][keyValuePair[0]] = keyValuePair[1];
        }

        else
        {
            if (str.startsWith("default"))
            {
                readingDefault = true;

                // removes the default part of the string.
                currentObject = str[7..$].strip;
            }
            
            else if (str.startsWith("alias"))
            {
                auto defaultValueToCopy = "";
                
                foreach (value; defaultValues.keys)
                    if (str.endsWith(value))
                    {
                        defaultValueToCopy = value;
                        break;
                    }
                    
                if (!defaultValueToCopy.length)
                {
                    writefln("couldn't match %s with an extant default object at line %d.", str, lineCount);
                    return false;
                }
                
                readingDefault = true;
                
                // removes the alias and aliased default parts of the string
                currentObject = str[5..$ - defaultValueToCopy.length].strip;
                
                foreach (attribute, value; defaultValues[defaultValueToCopy])
                    defaultValues[currentObject][attribute] = value;
            }
            
            else
            {
                auto cleanStr = str.strip;

                currentObject = format("%s_%d", cleanStr, lineCount);
                readingDefault = false;

                if (cleanStr in defaultValues)
                {
                    foreach (attribute, value; defaultValues[cleanStr])
                        objects[currentObject][attribute] = value;
                }
            }
        }
    }

    return true;
}
