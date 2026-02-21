# Shigger
A simple shitty digger in CC Tweaked using Advanced Peripherals Geo scanner to mine all ores from surface to bedrock, designed especially for All the Mods 10 modpack.

It was coded in around ~~5 days~~ 8 days (I hate debugging my stupid mistakes and typos). I will be honest, that I have not tested it fully yet, but everything should work. I hope.

I haven't used artificual intelligence while writing this code and instead I used no intelligence at all

# HOW TO USE IT
The program is quite simple although it needs some things correctly prepared. It was my first project in CC Tweaked and Lua and I don't really care about it being flawless.

Instruction:
1) Place the robotg facing NORTH
2) equip him with pickaxe and geo scanner (there is no check for that, it will just crash if you don't give it to him)
3) place a chest behind the robot. It can be a double chest, modded chest, doesn't matter
4) robot must be placed on surface, and if not, make sure there is no ore at the same level as chest in 8 block radius from the turtle, because he might break the chest while going for that ore
5) type "main" in the robot and hit enter and follow instructions (the fuel SHOULD be coal, because it can stack with the coal he digs, but if you give him enough of a different high energy fuel, it should work fine)
6) wait for him to finish the job of digging all resources in 8x8 radius
7) profit

If robot ever encounters an error, it will go into an emergency mode, which will make him dig to surface, empty his inventory to chest and wait there for you to use your pickaxe to beat the shi... I mean, to pick him up gently with your pickaxe.

About the ATM 10 compatibility:

If the turtle finds allthemodium, vibranium or unobtanium it will log it's relative coordinates and save them in umined.txt which you can open with command `edit unmined.txt`. This file will also have all ores that were too close to bedrock to safely mine

things you can change:
1) if you type "edit config.lua" you can expand the white_list. White list is all the targets he will dig (you can use part of the name like "ore" or whole names like "minecraft:ancient_debris").
2) max_fuel - is just the limit the turtle will use while refueling. It's in place to save some of that precious black gold people call coal.
3) max_movement_retry_amount - it's used in code. After that many failed attmepts in movement (f. ex. there is unbreakable block in front, or way too much gravel) the robot will go into emergency mode
4) ~~empty_thrash - this option allows you to enable/disable option to thorw the thrash away while digging to save the trips to chest~~ this is currently not used. If you don't want the robot to throw blocks away while digging, empty the thrash list
5) debug_logger - currently doesn't change anything, it was used during development to log some errors

So yeah, that's it. I have created this project, because in two weeks my friends and I start an ATM 10 server and I wanted to somehow prepare for a quick start (while I will be building home, the robots will dig ^^)


# INSTALATION
Just use this command in your turtle:

`wget https://raw.githubusercontent.com/Irecco1/Shigger/refs/heads/main/install.lua install.lua`

next you run the program `install`
and everything should be done!
(if it doesn't work, blame whoever you want, just not me)


Okay, I guess that's everything, I am not sorry for wasting your time here, and if you use this project, I hope it will give you enough resources to compensate the headache you probably got while reading it

I am also still learning the github, so pardon me for not making it easily accessible at the moment

Bye, and have a nice day! :3
