import sson;
import std.stdio;
import std.file;
import std.array;

void main()
{
    string[string][string] objects;
    
    if (objects.trySetObjects("test.sson".readText.split("\n")[0..$]))
        foreach(key, object; objects) writefln("%s: %s", key, object);
}
