# Shigger
A simple shitty digger in CC Tweaked using Advanced Peripherals Geo scanner to mine all ores from surface to bedrock, designed especially for All the Mods 10 modpack.

It was coded in around 5 days while I didn't have access to Minecraft and then tested and debugged in one day. It still has some bugs and I will have to make some improvements, so this is NOT the final version and should be used on your own risk.

All the code was written by myself and the only AI help I got, was at the very beginning to understand, how to make it structurally correct, as it was my first project in CC Tweaked and Lua, and I didn't want to write everything in one file (it just teached me to use file = {} as a table to save all public functions inside and then use require() to use them). If anything doesn't work, it's 100% my fault (and some things still doesn't work, but I will be updating it in the near future)

# HOW TO USE IT
The program is quite simple although it needs some things correctly prepared. Maybe in the future I will create second version that will be much better and more independet of user error, but this was my first real code I have created in Lua and CC Tweaked.

Instruction:
1) Place the robotg facing NORTH
2) equip him with pickaxe and geo scanner (he doesn't care if he has it, so it will break if you don't do it)
3) place a chest behind the robot. It can be a double chest, modded chest, doesn't matter
4) robot must be placed on surface, and if not, make sure there is no ore at the same level as chest in 8 block radius from the turtle, because he might break the chest xd
5) type "main" in the robot and hit enter and follow instructions (the fuel SHOULD be coal, because it can stack with the coal he digs, but if you give him enough of a different fuel, it should work fine)
6) wait for him to finish the job of digging all resources in 8x8 radius
7) profit

If robot ever encounters an error, it will go into an emergency mode, which will make him dig to surface, empty his inventory to chest and wait there for you to use your pickaxe to beat the shi... I mean, to pick him up gently with your pickaxe.

things you can change:
1) if you type "edit config.lua" you can expand the white_ and thrash_list. White list is all the targets he will dig (you can use part of the name like "ore" or whole names like "minecraft:ancient_debris"). Thrash list allows you to list items, you DON'T want to collect. Robot will throw them away during mining to save on trips to the chest on surface (this option is still not tested. I once again don't have access to Minecraft, but I want to preapre all the files on github already so it's easier to install it for me later)
2) max_fuel - is just the limit the turtle will use while refueling. It's in place to save some of that precious black gold people call coal.
3) max_movement_retry_amount - it's used in code. After that many failed attmepts in movement (f. ex. there is unbreakable block in front, or way too much gravel) the robot will go into emergency mode
4) empty_thrash - this option allows you to enable/disable (currently experimental) option to thorw the thrash away while digging to save the trips to chest

So yeah, that's it. I have created this project, because in two weeks my friends and I start an ATM 10 server and I wanted to somehow prepare for a quick start (while I will be building home, the robots will dig ^^)

I have only tested it on advanced turtle

TODO:
1) at bedrock layer, the robot will just perform the scan and generate a file with ores and their positions. It's too much work to dig around bedrock
2) sometimes robot doesn't detect the bedrock and gets stuck. It will use the emergency return at that point so no worries, but I need to fix it
3) I am preparing this for ATM 10, so it will also detect allthemodium ore and avoid it + print you location of it (turtles cannot mine allthemodium, even if you give them netherite pickaxe using datapacks :C )
4) make better UI

# INSTALATION
Just use this command in your turtle:
wget https://raw.githubusercontent.com/Irecco1/Shigger/refs/heads/main/install.lua install.lua install

Okay, I guess that's everything, I am not sorry for wasteing your time here, and if you use this project, I hope it will give you enough resources to compensate the headache you probably got while reading it

I am also still learning the github, so pardon me for not making it easily accessible at the moment ^^"

Bye, and have a nice day! :3
