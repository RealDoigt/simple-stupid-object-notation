#### SSON ####
SSON stands for either super simple object notation or simple stupid object notation, whatever you prefer.
SSON was made for the specific needs I had for helping me create game entities in one of my projects.
My specific needs were:
1. Convenient to use for manually typing data into a file.
2. Allow for default values to exist.
3. Easy to read and modify.
4. No tabulation required.
5. Easy to debug.

SSON is not a very powerful force of nature like JSON, CSON, YAML, XML and others. However, SSON does the things it was designed for well and it might appeal to certain use cases like scripting object values for a level in a game or services that are so small and simple in the data they use that more powerful features are not needed; SSON was created for simple cases.

#### Guide and Examples ####
Frankly I don't know what you're doing here, but if you've kept reading that means you might be interested in how it looks like.

First, to create an object, all you have to do is type out its name. Object names may contain anything as long as they don't start with `.` and `#`. However, you're free to include those characters elsewhere in the name. Then you may or may not add properties to that object by typing out their names in front of a `.` and using the `=` to initliaze that property's value. The name of the object and its properties are sperated by newlines. No value may be empty! If you want that value to be empty, don't type it. Don't forget this notation's goal is, in short, to avoid typing where unnecessary. Once you're done, you may either type a `;` on a new line or at the end of the last property to indicate the end of the object. It doesn't work for object names yet, but it's a future goal to make that possible.

Here's a couple of examples:
```sson
person
.name = john
.last name = doe
.age = 800;

pet
.species = cat
.annoying = very
;

food
;
```
You'll probably notice that the names of properties can have spaces in them. It's also technically possible for object names, but it is not recommended. At least, not now because the current implementation has a major oversight in that regard which limits the cases when you can use that feature for object names. Do note however that trailing white spaces will be removed. This is to allow a minimum of code style if the user wish to like these:
```sson
person
.name      = jane
.last name = doe
.age       = 25;

person
.name =   bob
.age =    30
.job =    construction worker
.salary = 123467;
```
Now you'll notice another thing is that both of these objects, while having the same name, don't have the same properties. This usage is correct, this is an example of using *implicit default values*. Those default values are expected to be initialized after the data has been interpreted and transformed.

However that's not all, there are also *explicit default values*. To define a default value, just type out `default` in front of the object name and all further objects of the same name will inherit those default values if they don't override them:
```
default player
.health = 20
.armor = 0
.ammo = 5;

# this player will have 20 health, 0 armor and 5 ammo
player
.x = 5
.y = 2;

# this player won't have 0 armour because it overrides the property
player
.y = 1
.x = 0
.armor = 10;

# it is also possible to change the default values midway
default player
.health = 10;

# this player won't have 20 health, but it'll have 0 armor and 5 ammo
player
.x = 6
.y = 12;
```
Finally with this example you'll understand that comments are also a thing in sson. However they're limited; they have to be on their own line. This is to allow as much freedom as possible in names and values. The good thing is they can still be pretty much anywhere; they could be in between two properties for example.

#### Important Implementation Details ####
Currently, the implementation transforms the values into a hashmap of string hashmaps where each object has its type name appended by the line number it was found on. In the below example, the first object will be called "player_1" and the second "npc_4":
```sson
player
.x = 8;

npc
.y = 10;
```
It is important to remember that those are line numbers! The reason those line numbers are appended is for easier debugging if you get unexpected values.

#### Conclusion ####
That's it! Thank you for reading. If you have comments or questions, open an issue. If you spotted a bug, want to offer an implementation in your favourite language or just want to improve this implementation, don't hesitate to make a pull request or place an issue.
