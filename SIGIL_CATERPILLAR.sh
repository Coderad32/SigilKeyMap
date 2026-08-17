#!/bin/bash

# Ensure cleanup on exit (restore cursor, reset colors, clear screen)
trap 'printf "\033[?25h\033[0m\033[2J"; exit 0' INT TERM

# Clear screen and hide cursor
printf "\033[2J\033[?25l"

# Get terminal dimensions dynamically for full screen
cols=$(tput cols)
rows=$(tput lines)
cols=${cols:-80}
rows=${rows:-24}

# 100 Unique Sigil Combinations
chars=(
    '!' '@' '#' '$' '%' '^' '&' '*' '(' '!)'# 10
    '!!' '!@' '!#' '!$' '!%' '!^' '!&' '!*' '!(' # 19
    '@)' '@!' '@@' '@#' '@$' '@%' '@^' '@&' '@*' '@(' # 29
    '#)' '#!' '#@' '##' '#$' '#%' '#^' '#&' '#*' '#(' # 39
    '$)' '$!' '$@' '$#' '$$' '$%' '$^' '$&' '$*' '$(' # 49
    '%)' '%!' '%@' '%#' '%$' '%%' '%^' '%&' '%*' '%(' # 59
    '%)' '^!' '^@' '^#' '^$' '^%' '^^' '^&' '^*' '^(' # 69
    '&)' '&!' '&@' '&#' '&$' '&%' '&^' '&&' '&*' '&(' # 79
    '*)' '*!' '*@' '*#' '*$' '*%' '*^' '*&' '**' '*(' # 89
    '()' '(!' '(@' '(#' '($' '(%' '(^' '(&' '(*' '((' # 99
    '!))' # 100
)
num_chars=${#chars[@]}

# Track previous positions so we can erase them cleanly without ghosting
for ((i=0; i<cols; i++)); do
    y_pos[i]=$((RANDOM % rows))
    prev_y[i]=0
    speed[i]=1
done

# Main loop
while true; do
    # Re-check dimensions in case the window was resized
    cols=$(tput cols)
    rows=$(tput lines)

    for ((x=0; x<cols; x++)); do
        col=$((x + 1))

        # Erase the exact previous position for this column if it was on screen
        if (( prev_y[x] > 0 && prev_y[x] <= rows )); then
            printf "\033[%d;%dH " "${prev_y[x]}" "$col"
        fi

        # Update previous position tracker
        prev_y[x]=${y_pos[x]}

        # Advance position
        y_pos[x]=$((y_pos[x] + speed[x]))
        if (( y_pos[x] > rows )); then
            y_pos[x]=1
            prev_y[x]=0
            speed[x]=$((RANDOM % 2 + 1))
        fi

        # Print character at the new position
        if (( y_pos[x] > 0 && y_pos[x] <= rows )); then
            char_idx=$((RANDOM % num_chars))
            char="${chars[$char_idx]}"
            printf "\033[%d;%dH\033[1;32m%s" "${y_pos[x]}" "$col" "$char"
        fi
    done

    # Frame rate control (~80ms delay)
    read -t 0.08 -n 1 input 2>/dev/null
    if [[ $input == $'\x1b' ]]; then
        exit 0
    fi
done
