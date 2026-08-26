#!/bin/bash

cleanup() {
    printf '\033[0m\033[?25h\033[2J\033[H'
    exit 0
}

trap cleanup INT TERM EXIT

printf '\033[2J\033[?25l'

box_width=50
box_height=12
box_start_col=15
box_start_row=5

sigil_pool=(
    '!' '@' '#' '$' '%' '^' '&' '*' '(' ')'
    '!!' '!@' '!#' '!$' '!%' '!^' '!&' '!*' '!(' '!)'
    '@)' '@!' '@@' '@#' '@$' '@%' '@^' '@&' '@*' '@('
    '#)' '#!' '#@' '##' '#$' '#%' '#^' '#&' '#*' '#('
    '$)' '$!' '$@' '$#' '$$' '$%' '$^' '$&' '$*' '$('
    '%)' '%!' '%@' '%#' '%$' '%%' '%^' '%&' '%*' '%('
    '^)' '^!' '^@' '^#' '^$' '^%' '^^' '^&' '^*' '^('
    '&)' '&!' '&@' '&#' '&$' '&%' '&^' '&&' '&*' '&('
    '*)' '*!' '*@' '*#' '*$' '*%' '*^' '*&' '**' '*('
    '()' '(!' '(@' '(#' '($' '(%' '(^' '(&' '(*)' '(('
)

total_sigils=${#sigil_pool[@]}

x_position=()
trail_length=()
stream_speed=()

for ((i = 0; i < box_height; i++)); do
    x_position[i]=$(( (RANDOM % box_width) - box_width ))
    trail_length[i]=$(( RANDOM % 8 + 5 ))
    stream_speed[i]=1
done

draw_box_border() {
    local border=""
    local r
    local current_row
    local bottom_row

    border="+"
    for ((i = 0; i < box_width; i++)); do
        border+="-"
    done
    border+="+"

    printf '\033[%d;%dH\033[1;30m%s\033[0m' \
        "$box_start_row" \
        "$box_start_col" \
        "$border"

    for ((r = 1; r <= box_height; r++)); do
        current_row=$((box_start_row + r))

        printf '\033[%d;%dH\033[1;30m|\033[0m' \
            "$current_row" \
            "$box_start_col"

        printf '\033[%d;%dH\033[1;30m|\033[0m' \
            "$current_row" \
            "$((box_start_col + box_width + 1))"
    done

    bottom_row=$((box_start_row + box_height + 1))

    printf '\033[%d;%dH\033[1;30m%s\033[0m' \
        "$bottom_row" \
        "$box_start_col" \
        "$border"
}

draw_box_border

while true; do
    for ((y = 0; y < box_height; y++)); do
        relative_row=$((y + 1))
        absolute_row=$((box_start_row + relative_row))

        head_x=${x_position[y]}
        length=${trail_length[y]}

        for ((j = 0; j < length; j++)); do
            current_x=$((head_x - j))

            random_index=$((RANDOM % total_sigils))
            current_sigil=${sigil_pool[random_index]}
            sigil_width=${#current_sigil}

            if (( current_x >= 1 &&
                  current_x + sigil_width - 1 <= box_width )); then

                absolute_col=$((box_start_col + current_x))

                if (( j == 0 )); then
                    printf '\033[%d;%dH\033[1;37m%s\033[0m' \
                        "$absolute_row" \
                        "$absolute_col" \
                        "$current_sigil"
                elif (( j < 3 )); then
                    printf '\033[%d;%dH\033[1;32m%s\033[0m' \
                        "$absolute_row" \
                        "$absolute_col" \
                        "$current_sigil"
                else
                    printf '\033[%d;%dH\033[0;32m%s\033[0m' \
                        "$absolute_row" \
                        "$absolute_col" \
                        "$current_sigil"
                fi
            fi
        done

        tail_x=$((head_x - length))

        if (( tail_x >= 1 && tail_x <= box_width )); then
            absolute_tail_col=$((box_start_col + tail_x))

            printf '\033[%d;%dH ' \
                "$absolute_row" \
                "$absolute_tail_col"
        fi

        x_position[y]=$((x_position[y] + stream_speed[y]))

        if (( x_position[y] - length > box_width )); then
            x_position[y]=$(( (RANDOM % 8) - 8 ))
            trail_length[y]=$(( RANDOM % 8 + 5 ))
            stream_speed[y]=1
        fi
    done

    user_input=""

    if read -r -t 0.08 -n 1 user_input 2>/dev/null; then
        if [[ $user_input == $'\x1b' ]]; then
            exit 0
        fi
    fi
done
