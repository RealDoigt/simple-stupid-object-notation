# SSON
SSON stands for either **S**imple **S**tupid **O**bject **N**otation. SSON was made for the specific needs I had for helping me create game entities in one of my projects. I have since kept it evolving according to my needs.

My specific needs are:
1. Type less.
2. Data polymorphism.
3. Data generation.
4. Easy to read and modify.
5. Easy to debug.

SSON is designed for certain use cases like scripting object values for a level in a game or services that are so small and simple in the data they use that more powerful features are not needed; SSON was created for simple cases. My goal with SSON is to have a data format that takes less time to write data manually. It cannot be compared to JSON nor XML for it seeks to achieve different goals. If you're here for an alternative to those, check out CSON, YAML, SDLang and KDL instead. 

## Guide and Examples
Frankly I don't know what you're doing here, but if you've kept reading that means you might be interested in how it looks like.

First, to create an object, all you have to do is type out its name. Object names may contain anything as long as they don't start with `default`, `.` and `#`. However, you're free to include those elsewhere in the name. Then you may or may not add properties to that object by typing out their names in front of a `.` and using the `=` to initialize that property's value. The name of the object and its properties are sperated by newlines. No value may be empty! If you want that value to be empty, don't type it. Don't forget this notation's goal is, in short, to avoid typing where unnecessary. Once you're done, you may either type a `;` on a new line or at the end of the last property to indicate the end of the object. It doesn't work for object names.

Here's a couple of examples:
```sson
person
.name = john
.last name = doe
.age = 800

pet
.species = cat
.annoying = very
```
You'll probably notice that the names of properties can have spaces in them. It's also possible for object names. Do note however that trailing white spaces will be removed. This is to allow a minimum of code style if the user wishes to have one like these examples show:
```sson
person
.name      = jane
.last name = doe
.age       = 25

person
.name =   bob
.age =    30
.job =    construction worker
.salary = 123467

  person
. name = bobby
. age  = 60
. job  = who knows?
```
Now you'll notice that these objects, while having the same name, don't have the same properties. This usage is correct, it is an example of using *implicit default values*. Those default values are expected to be initialized after the data has been interpreted and transformed. To be clear, it is the responsibility of the service which receives the transformed values to initialize them and not the interpreter itself.

However that's not all, there are also *explicit default values*. To define a default value, just type out `default` in front of the object name and all further objects of the same name will inherit those default values if they don't override them:
```sson
default player
.health = 20
.armor = 0
.ammo = 5

# this player will have 20 health, 0 armor and 5 ammo
player
.x = 5
.y = 2

# this player won't have 0 armour because it overrides the property
player
.y = 1
.x = 0
.armor = 10

# it is also possible to change the default values midway
default player
.health = 10

# this player won't have 20 health, but it'll have 0 armor and 5 ammo
player
.x = 6
.y = 12
```
Finally with this example you'll understand that comments are also a thing in sson. However they're limited; they have to be on their own line. This is to allow as much freedom as possible in names and values. The good thing is they can still be pretty much anywhere; they could be in between two properties for example.

Now, that's not all there is to default values. There are also default values that come from an alias. An alias is something which creates, under a different name, a default profile from another already existing one like so:
```sson
default potion
.recover = 20
.price = 10
.name = Potion
.description = A basic remedy

alias poison potion
.recover = -5
.name = Poison
.description = This one does't help you get better
```
This has the advantage of being able to carry over the potion default values without overriding them for the poison objects. It also makes the configuration code easier to understand
## Important Implementation Details
The official implementation transforms the values into a hashmap of string hashmaps where each object has its type name appended by the line number it was found on. In the below example, the first object will be called `player_1` and the second  `npc_4`:
```sson
player
.x = 8

npc
.y = 10
```
It is important to remember that those are line numbers! The reason the data is structured like that is for easier debugging.

## Conclusion
That's it! Thank you for reading. If you have comments or questions, open an issue. If you spotted a bug, want to offer an implementation in your favourite language or just want to improve this implementation, don't hesitate to make a pull request or place an issue.
