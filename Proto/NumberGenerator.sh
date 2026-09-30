#!/usr/bin/env bash

cols=$(tput cols)
rows=$(tput lines)

cleanup() {
    printf '\e[0m\e[?25h\e[2J\e[H'
    exit
}

trap cleanup INT TERM EXIT

printf '\e[2J\e[?25l'

while true; do
    x=$((RANDOM % cols))
    y=$((RANDOM % rows))

    # Pick a random Matrix-like character
    chars='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ@#$%&*()_+=-'
    char=${chars:RANDOM % ${#chars}:1}

    # Move cursor and print character
    printf '\e[%d;%dH\e[32m%s' "$y" "$x" "$char"

    # Randomly create a brighter character
    if (( RANDOM % 5 == 0 )); then
        printf '\e[1;97m'
    fi

    sleep 0.01
done
