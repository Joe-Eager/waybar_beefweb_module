# waybar_beefweb_module
a now playing beefweb interface for waybar

## Instructions
This is a script that displays now playing in the waybar. You need a music player that runs a BeefWeb server.
This code also includes credentials you can change as needed:
```
# Credentials
USERNAME="beefyDude"
PASSWORD="beefyPassword"

# Encode credentials to base64
CREDENTIALS=$(echo -n "$USERNAME:$PASSWORD" | base64)
```
To add it to the waybar you need to make a UserModules, e.x.:
```
"custom/foobar2000": {
  "exec": "$HOME/.config/waybar/now_playing.sh",
  "return-type": "json",
  "interval": 5
}
```
Then add that to whatever config you want, e.x.:
```
"modules-left": [
  "custom/foobar2000"
]
```
