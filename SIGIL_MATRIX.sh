#!/bin/bash

# Ensure cleanup on exit (restore cursor, reset colors, clear screen)
trap 'printf "\033[?25h\033[0m\033[2J"; exit 0' INT TERM

# Clear screen and hide cursor
printf "\033[2J\033[?25l"

# Get terminal dimensions
cols=$(tput cols)
rows=$(tput lines)
cols=${cols:-80}
rows=${rows:-24}

# 100 Unique Sigil Combinations
chars=(
    '!' '@' '#' '$' '%' '^' '&' '*' '(' '!'
    '!!' '!@' '!#' '!$' '!%' '!^' '!&' '!*' '!('
    '@)' '@!' '@@' '@#' '@$' '@%' '@^' '@&' '@*' '@('
    '#)' '#!' '#@' '##' '#$' '#%' '#^' '#&' '#*' '#('
    '$)' '$!' '$@' '$#' '$$' '$%' '$^' '$&' '$*' '$('
    '%)' '%!' '%@' '%#' '%$' '%%' '%^' '%&' '%*' '%('
    '%)' '^!' '^@' '^#' '^$' '^%' '^^' '^&' '^*' '^('
    '&)' '&!' '&@' '&#' '&$' '&%' '&^' '&&' '&*' '&('
    '*)' '*!' '*@' '*#' '*$' '*%' '*^' '*&' '**' '*('
    '()' '(!' '(@' '(#' '($' '(%' '(^' '(&' '(*' '(('
    '!))'
)
num_chars=${#chars[@]}

# Initialize drop positions and speeds for each column
for ((i=0; i<cols; i++)); do
    y_pos[i]=$((RANDOM % rows))
    speed[i]=$((RANDOM % 3 + 1))
done

# Main loop
while true; do
    for ((x=0; x<cols; x++)); do
        col=$((x + 1))
        
        # Print bright head
        char_idx=$((RANDOM % num_chars))
        char="${chars[$char_idx]}"
        printf "\033[%d;%dH\033[1;37m%s" "${y_pos[x]}" "$col" "$char"

        # Print trail
        trail_y=$((y_pos[x] - 4))
        if (( trail_y > 0 && trail_y <= rows )); then
            trail_char_idx=$((RANDOM % num_chars))
            trail_char="${chars[$trail_char_idx]}"
            printf "\033[%d;%dH\033[0;32m%s" "$trail_y" "$col" "$trail_char"
        fi

        # Clear tail
        end_y=$((y_pos[x] - 12))
        if (( end_y > 0 && end_y <= rows )); then
            printf "\033[%d;%dH " "$end_y" "$col"
        fi

        # Advance position
        y_pos[x]=$((y_pos[x] + speed[x]))
        if (( y_pos[x] > rows + 12 )); then
            y_pos[x]=$(( (RANDOM % 5) - 5 ))
            speed[x]=$((RANDOM % 3 + 1))
        fi
    done

    # Frame rate control (~33ms)
    read -t 0.033 -n 1 input 2>/dev/null
    if [[ $input == $'\x1b' ]]; then
        exit 0
    fi
done
