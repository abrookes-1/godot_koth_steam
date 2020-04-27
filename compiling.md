
#### Install scoop (in Power Shell)
1. `Set-ExecutionPolicy RemoteSigned -scope CurrentUser`
2. `Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh/%27)`
3. delete or rename any existing `c:\mingw`
4. `scoop install gcc python scons`
#### Download and unpick Godot source and Godotsteam module source
5. download godot 3.1.2 from https://github.com/godotengine/godot/releases
- direct link: https://github.com/godotengine/godot/archive/3.1.2-stable.tar.gz
6. download godotsteam for 3.1 from https://gramps.github.io/GodotSteam/index.html
- direct link: https://github.com/Gramps/GodotSteam/zipball/master
7. move godotsteam into modules as in section "quick-howto" here https://github.com/Gramps/GodotSteam
8. open command prompt in godot source location and compile with `scons use_mingw=yes platform=windows`
9. wait a few hours
#### Final steps
10. copy `<godot_src>/modules/godotsteam/sdk/redistributable_bin/win64/steam_api64.dll` to `<godot_src>/bin` (next to the new godot exe)
11. make a `steam_appid.txt` file in the same location with your app id or 480