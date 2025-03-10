#!/bin/bash

set -euo pipefail

in="$1"
out="$2"

function corner_variant()
{
    local corner="$1"
    local side_v="$2"
    local side_h="$3"
    local name_v="$4"
    local name_h="$5"

    if ((side_v == 1))
    then
        if ((side_h == 1))
        then
            if ((corner == 1))
            then
                echo "$in/$name_v-$name_h-fill.png"
            else
                echo "$in/$name_v-$name_h-out.png"
            fi
        else
            echo "$in/$name_v-$name_h-vertical.png"
        fi
    elif ((side_h == 1))
    then
        echo "$in/$name_v-$name_h-horizontal.png"
    else
        echo "$in/$name_v-$name_h-in.png"
    fi
}

function generate()
{
    local up_left="$1"
    local up="$2"
    local up_right="$3"
    local left="$4"
    local right="$5"
    local down_left="$6"
    local down="$7"
    local down_right="$8"

    local layers=(
        "$(corner_variant "$up_left" "$up" "$left" up left)"
        "$(corner_variant "$up_right" "$up" "$right" up right)"
        "$(corner_variant "$down_left" "$down" "$left" down left)"
        "$(corner_variant "$down_right" "$down" "$right" down right)"
    )

    local layer_args=()

    for layer in "${layers[@]}"
    do
        layer_args+=('(' '-page' '+0+0' "$layer" ')')
    done

    local name="$out/$down_right$down_left$up_right$up_left$down$up$right$left.png"
    echo "$name" "${layers[@]}"
    convert -background none \
            "${layer_args[@]}" \
            -layers flatten \
            -scale 128x128 \
            "$name"

}

for left in 0 1
do
    for right in 0 1
    do (
        for up in 0 1
        do (
            for down in 0 1
            do (
                for up_left in 0 1
                do (
                    if ((up_left == 1))
                    then
                        if ((up == 0)) || ((left == 0))
                        then
                            exit 0
                        fi
                    fi

                    for up_right in 0 1
                    do (
                        if ((up_right == 1))
                        then
                            if ((up == 0)) || ((right == 0))
                            then
                                exit 0
                            fi
                        fi

                        for down_left in 0 1
                        do (
                            if ((down_left == 1))
                            then
                                if ((down == 0)) || ((left == 0))
                                then
                                    exit 0
                                fi
                            fi

                            for down_right in 0 1
                            do (
                                if ((down_right == 1))
                                then
                                    if ((down == 0)) || ((right == 0))
                                    then
                                        exit 0
                                    fi
                                fi

                                generate $up_left \
                                         $up \
                                         $up_right \
                                         $left \
                                         $right \
                                         $down_left \
                                         $down \
                                         $down_right
                            ) done
                        ) done
                    ) done
                ) done
            ) done
        ) done
    ) done
done
