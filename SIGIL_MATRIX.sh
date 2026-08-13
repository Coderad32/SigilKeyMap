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
    '!' '@' '#' '$' '%' '^' '&' '*' '(' # 9
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

# Initialize drop positions, lengths, and speeds for each column across the full width
for ((i=0; i<cols; i++)); do
    y_pos[i]=$(( (RANDOM % rows) - rows ))
    length[i]=$((RANDOM % 8 + 6))
    speed[i]=$((RANDOM % 2 + 1))
done

# Main loop
while true; do
    # Re-check dimensions in case the window was resized
    cols=$(tput cols)
    rows=$(tput lines)

    for ((x=0; x<cols; x++)); do
        col=$((x + 1))
        head=${y_pos[x]}
        len=${length[x]}

        # Draw the falling trail for this column
        for ((j=0; j<len; j++)); do
            curr_y=$((head - j))
            
            if (( curr_y > 0 && curr_y <= rows )); then
                char_idx=$((RANDOM % num_chars))
                char="${chars[$char_idx]}"
                
                if (( j == 0 )); then
                    # Bright white leading head
                    printf "\033[%d;%dH\033[1;37m%s" "$curr_y" "$col" "$char"
                elif (( j < 3 )); then
                    # Bright green near the head
                    printf "\033[%d;%dH\033[1;32m%s" "$curr_y" "$col" "$char"
                else
                    # Dim green fading trail using original sigils
                    printf "\033[%d;%dH\033[0;32m%s" "$curr_y" "$col" "$char"
                fi
            fi
        done

        # Clear the space directly behind the tail
        tail_y=$((head - len))
        if (( tail_y > 0 && tail_y <= rows )); then
            printf "\033[%d;%dH " "$tail_y" "$col"
        fi

        # Advance position based on individual speed
        y_pos[x]=$((y_pos[x] + speed[x]))
        
        # Reset drop once it falls past the bottom
        if (( y_pos[x] - len > rows )); then
            y_pos[x]=$(( (RANDOM % 5) - 5 ))
            length[x]=$((RANDOM % 8 + 6))
            speed[x]=$((RANDOM % 2 + 1))
        fi
    done

    # Frame rate control (~33ms)
    read -t 0.033 -n 1 input 2>/dev/null
    if [[ $input == $'\x1b' ]]; then
        exit 0
    fi
done
