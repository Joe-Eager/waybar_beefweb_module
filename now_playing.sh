#!/bin/bash

# Beefweb API endpoint
URL="http://localhost:8880/api/query?player=true&trcolumns=%album%20artist%,%title%"

# Credentials
USERNAME="beefyDude"
PASSWORD="beefyPassword"

# Encode credentials to base64
CREDENTIALS=$(echo -n "$USERNAME:$PASSWORD" | base64)

# Function to truncate text and escape special characters for JSON
process_text() {
    local text="$1"
    local max_length=28 # Adjust this value as needed

    # Truncate the text if it exceeds the maximum length
    if [ ${#text} -gt $max_length ]; then
        text="${text:0:$max_length}..."
    fi

    # Escape special characters for JSON
    echo -n "$text" | jq -R -s -r -c '.'
}

# Function to get now playing information
get_now_playing() {
    # Make API request with authentication
    response=$(curl -s -H "Authorization: Basic $CREDENTIALS" "$URL")

    # Check if the request was successful
    if [ $? -ne 0 ] || [ -z "$response" ]; then
        echo '{"text": "Error: Unable to connect to foobar2000"}'
        exit 1
    fi

    # Parse playback state from JSON response
    playback_state=$(echo "$response" | jq -r '.player.playbackState')

    # Extract artist and title from the columns array in activeItem
    artist=$(echo "$response" | jq -r '.player.activeItem.columns[0]')
    title=$(echo "$response" | jq -r '.player.activeItem.columns[1]')

    # Escape special characters
    artist=$(process_text "$artist")
    title=$(process_text "$title")

    if [ "$playback_state" = "playing" ]; then

        # Check if artist and title are valid
        if [ -n "$artist" ] && [ -n "$title" ]; then
            colored_text="\u25B6 <span color='#9ccc00'>$title</span> - <span color='#628000'>$artist</span>"
            echo "{\"text\": \"$colored_text\"}"
        else
            echo '{"text": "Error: Unable to retrieve track information"}'
        fi
    elif [ "$playback_state" = "paused" ]; then
        colored_text=" \u23F8 <span color='#9ccc00'>$title</span> - <span color='#628000'>$artist</span>"
        echo "{\"text\": \"$colored_text\"}"
    elif [ "$playback_state" = "stopped" ]; then
        echo "{\"text\": \"\u23F9 - foobar2000\", \"class\": \"stopped\"}"
    else
        echo "{\"text\": \"No track is currently playing\", \"class\": \"not-playing\"}"
    fi
}

# Main execution
get_now_playing
