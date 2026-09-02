#!/bin/bash

# Ensure cleanup on exit (restore cursor, reset colors, clear screen)
trap 'printf "\033[?25h\033[0m\033[2J"; exit 0' INT TERM

# Clear screen and hide cursor
printf "\033[2J\033[?25l"

# Get terminal dimensions and define a smaller container box
term_cols=$(tput cols)
term_rows=$(tput lines)

box_width=60
box_height=20

# Center the container
start_col=$(( (term_cols - box_width) / 2 ))
start_row=$(( (term_rows - box_height) / 2 ))

(( start_col < 1 )) && start_col=1
(( start_row < 1 )) && start_row=1

inner_width=$((box_width - 2))
inner_height=$((box_height - 2))

# Draw container border once
printf "\033[36m"
printf "\033[%d;%dH┌" "$start_row" "$start_col"
for ((i=1; i<box_width-1; i++)); do printf "─"; done
printf "┐"
for ((r=1; r<box_height-1; r++)); do
    printf "\033[%d;%dH│" "$((start_row + r))" "$start_col"
    printf "\033[%d;%dH│" "$((start_row + r))" "$((start_col + box_width - 1))"
done
printf "\033[%d;%dH└" "$((start_row + box_height - 1))" "$start_col"
for ((i=1; i<box_width-1; i++)); do printf "─"; done
printf "┘"
printf "\033[0m"

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

# Initialize drop positions and slower speeds for each column inside the container
for ((i=0; i<inner_width; i++)); do
    y_pos[i]=$((RANDOM % inner_height))
    speed[i]=1
done

# Main loop
while true; do
    for ((x=0; x<inner_width; x++)); do
        col=$((start_col + 1 + x))
        abs_y=$((start_row + 1 + y_pos[x]))

        # Print bright head
        char_idx=$((RANDOM % num_chars))
        char="${chars[$char_idx]}"
        if (( y_pos[x] >= 0 && y_pos[x] < inner_height )); then
            printf "\033[%d;%dH\033[1;37m%s" "$abs_y" "$col" "$char"
        fi

        # Print trail
        trail_y=$((y_pos[x] - 3))
        abs_trail_y=$((start_row + 1 + trail_y))
        if (( trail_y >= 0 && trail_y < inner_height )); then
            trail_char_idx=$((RANDOM % num_chars))
            trail_char="${chars[$trail_char_idx]}"
            printf "\033[%d;%dH\033[0;32m%s" "$abs_trail_y" "$col" "$trail_char"
        fi

        # Clear tail
        end_y=$((y_pos[x] - 8))
        abs_end_y=$((start_row + 1 + end_y))
        if (( end_y >= 0 && end_y < inner_height )); then
            printf "\033[%d;%dH " "$abs_end_y" "$col"
        fi

        # Advance position
        y_pos[x]=$((y_pos[x] + speed[x]))
        if (( y_pos[x] >= inner_height + 8 )); then
            y_pos[x]=$(( - (RANDOM % 5) ))
        fi
    done

    # Slower frame rate control (~100ms)
    read -t 0.1 -n 1 input 2>/dev/null
    if [[ $input == $'\x1b' ]]; then
        exit 0
    fi
done
