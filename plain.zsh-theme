# The time the last command started
unset PLAIN_COMMAND_START

# The time it took the last command to execute
unset PLAIN_COMMAND_TIME

function {
    local dir="%F{10}%2~%f"
    local arrow="%(?.%F{8}.%F{1})>%f"

    PROMPT="$dir"'$(plain_git)'$'\n'"$arrow "

    local jobs="%(1j. %F{8}[%F{3}%j%F{8}]%f.)"
    local time="%F{6}%T%f"

    RPROMPT='$(plain_execution_time)'"$time$jobs"
}

precmd() {
    if [[ $PLAIN_COMMAND_START ]]; then
        local now=$(date +%s)
        local elapsed=$(($now - $PLAIN_COMMAND_START))

        if [[ $elapsed -lt ${PLAIN_REPORT_TIME_ABOVE:-60} ]]; then
            unset PLAIN_COMMAND_TIME
        else
            PLAIN_COMMAND_TIME=$elapsed
        fi
    fi
}

preexec() {
    PLAIN_COMMAND_START=$(date +%s)
}

plain_git() {
    [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) ]] || return

    plain_git_repo
    plain_git_branch
    plain_git_status
}

plain_git_repo() {
    local repo_name="$(basename $(git rev-parse --show-toplevel))"
    printf " %%F{8}in%%f %%F{11}$repo_name%%f"

    local ahead="$(git log --oneline @{upstream}.. 2> /dev/null)"
    local behind="$(git log --oneline ..@{upstream} 2> /dev/null)"

    if [[ -n "$ahead" && -n "$behind" ]]; then
        printf " %%F{1}N%%f"
    elif [[ -n "$ahead" ]]; then
        printf " %%F{2}^%%f"
    elif [[ -n "$behind" ]]; then
        printf " %%F{5}v%%f"
    fi
}

plain_git_branch() {
    if [[ ! $(git symbolic-ref -q HEAD) ]]; then
        local short_hash="$(git rev-parse --short HEAD)"
        printf " %%F{8}at%%f %%F{5}$short_hash%%f"

        return
    else
        local branch_name="$(git rev-parse --abbrev-ref HEAD 2> /dev/null)"
        printf " %%F{8}on%%f %%F{4}$branch_name%%f"
    fi
}

plain_git_status() {
    local status_symbols

    [[ -n "$(git stash list)" ]] && status_symbols+="@"
    [[ $(git rev-parse --verify MERGE_HEAD 2> /dev/null) ]] && status_symbols+=">"
    [[ $(git rev-parse --verify REBASE_HEAD 2> /dev/null) ]] && status_symbols+="<"
    [[ $(git rev-parse --verify CHERRY_PICK_HEAD 2> /dev/null) ]] && status_symbols+="%%"
    [[ $(git rev-parse --verify REVERT_HEAD 2> /dev/null) ]] && status_symbols+="^"

    [[ -n "$status_symbols" ]] && status_symbols="%%F{13}$status_symbols%%f"

    local color_all_staged="10"
    local color_mixed="3"
    local color_all_tree="14"

    local git_status="$(git status --porcelain 2> /dev/null)"

    local staged_modified="$(echo "$git_status" | grep "^[MR]")"
    local tree_modified="$(echo "$git_status" | grep "^.[MR]")"
    local staged_added="$(echo "$git_status" | grep "^A")"
    local staged_deleted="$(echo "$git_status" | grep "^D")"
    local tree_deleted="$(echo "$git_status" | grep "^.D")"
    local tree_untracked="$(echo "$git_status" | grep "^??")"
    local tree_unmerged="$(echo "$git_status" | grep "^UU")"

    if [[ -n "$staged_modified" && -n "$tree_modified" ]]; then
        status_symbols+="%%F{$color_mixed}~%%f"
    elif [[ -n "$staged_modified" ]]; then
        status_symbols+="%%F{$color_all_staged}~%%f"
    elif [[ -n "$tree_modified" ]]; then
        status_symbols+="%%F{$color_all_tree}~%%f"
    fi

    [[ -n "$staged_added" ]] && status_symbols+="%%F{$color_all_staged}+%%f"

    if [[ -n "$staged_deleted" && -n "$tree_deleted" ]]; then
        status_symbols+="%%F{$color_mixed}-%%f"
    elif [[ -n "$staged_deleted" ]]; then
        status_symbols+="%%F{$color_all_staged}-%%f"
    elif [[ -n "$tree_deleted" ]]; then
        status_symbols+="%%F{$color_all_tree}-%%f"
    fi

    [[ -n "$tree_untracked" ]] && status_symbols+="%%F{$color_all_tree}?%%f"
    [[ -n "$tree_unmerged" ]] && status_symbols+="%%F{$color_all_tree}!%%f"

    [[ -n "$status_symbols" ]] && printf " $status_symbols"
}

plain_execution_time() {
    [[ -z "$PLAIN_COMMAND_TIME" ]] && return

    # Assumes that commands don't run longer than 24 hours
    # Would be good to get an unbounded replacement for %H
    local time="$(date -d@$PLAIN_COMMAND_TIME -u +%H:%M:%S | sed -e "s/^[0:]\+//")"

    printf "%%F{11}$time%%f %%F{8}>%%f "
}

