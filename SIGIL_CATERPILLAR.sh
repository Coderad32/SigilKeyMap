#!/bin/bash

# Configuration: Set your desired window dimensions here
WIN_WIDTH=60
WIN_HEIGHT=20

# Ensure cleanup on exit (restore cursor, reset colors, clear screen)
trap 'printf "\033[?25h\033[0m\033[2J"; exit 0' INT TERM

# Clear screen and hide cursor
printf "\033[2J\033[?25l"

# Get terminal dimensions to center the window
term_cols=$(tput cols)
term_rows=$(tput lines)

# Calculate starting coordinates to center the box
start_x=$(( (term_cols - WIN_WIDTH) / 2 ))
start_y=$(( (term_rows - WIN_HEIGHT) / 2 ))
if (( start_x < 0 )); then start_x=0; fi
if (( start_y < 0 )); then start_y=0; fi

# Inner grid dimensions (accounting for borders)
grid_width=$((WIN_WIDTH - 2))
grid_height=$((WIN_HEIGHT - 2))

# 100 Unique Sigil Combinations
chars=(
    '!' '@' '#' '$' '%' '^' '&' '*' '(' '!)'
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

# Track previous positions for the inner grid columns
for ((i=0; i<grid_width; i++)); do
    y_pos[i]=$((RANDOM % grid_height))
    prev_y[i]=0
    speed[i]=1
done

# Function to draw the static border window
draw_border() {
    # Top border
    printf "\033[%d;%dH\033[1;34m+" "$start_y" "$start_x"
    for ((i=0; i<grid_width; i++)); do
        printf "-"
    done
    printf "+"

    # Side borders
    for ((r=1; r<=grid_height; r++)); do
        curr_y=$((start_y + r))
        printf "\033[%d;%dH|" "$curr_y" "$start_x"
        printf "\033[%d;%dH|" "$curr_y" "$((start_x + WIN_WIDTH - 1))"
    done

    # Bottom border
    bottom_y=$((start_y + WIN_HEIGHT - 1))
    printf "\033[%d;%dH+" "$bottom_y" "$start_x"
    for ((i=0; i<grid_width; i++)); do
        printf "-"
    done
    printf "+\033[0m"
}

# Initial window paint
draw_border

# Main loop
while true; do
    for ((x=0; x<grid_width; x++)); do
        col=$((start_x + 1 + x))

        # Erase the exact previous position for this column if inside the box
        if (( prev_y[x] > 0 && prev_y[x] <= grid_height )); then
            prev_row=$((start_y + prev_y[x]))
            printf "\033[%d;%dH " "$prev_row" "$col"
        fi

        # Update previous position tracker
        prev_y[x]=${y_pos[x]}

        # Advance position
        y_pos[x]=$((y_pos[x] + speed[x]))
        if (( y_pos[x] > grid_height )); then
            y_pos[x]=1
            prev_y[x]=0
            speed[x]=$((RANDOM % 2 + 1))
        fi

        # Print character at the new position inside the box
        if (( y_pos[x] > 0 && y_pos[x] <= grid_height )); then
            curr_row=$((start_y + y_pos[x]))
            char_idx=$((RANDOM % num_chars))
            char="${chars[$char_idx]}"
            printf "\033[%d;%dH\033[1;32m%s" "$curr_row" "$col" "$char"
        fi
    done

    # Frame rate control (~80ms delay) with exit check
    read -t 0.08 -n 1 input 2>/dev/null
    if [[ $input == $'\x1b' ]]; then
        exit 0
    fi
done
