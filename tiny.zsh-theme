GIT_PROMPT_BRANCH_NAME_MAX_LENGTH=20
GIT_PROMPT_BRANCH_NAME_TRUNCATION_FILLER=..

PROMPT='%{$fg[magenta]%}$ %{$reset_color%}'

git_untracked_count() {
  count=`echo $(git status --porcelain 2>/dev/null | grep "^??" | wc -l)`
  if [ $count -eq 0 ]; then return; fi
  echo "%{$fg_no_bold[yellow]%}? %{$fg_bold[yellow]%}$count %{$reset_color%}"
}

git_modified_count() {
  count=`echo $(git status --porcelain 2>/dev/null | grep "^.[MD]" | wc -l)`
  if [ $count -eq 0 ]; then return; fi
  echo "%{$fg_no_bold[red]%}M %{$fg_bold[red]%}$count %{$reset_color%}"
}

git_index_count() {
  count=`echo $(git status --porcelain 2>/dev/null | grep "^[AMD]." | wc -l)`
  if [ $count -eq 0 ]; then return; fi
  echo "%{$fg_no_bold[green]%}S %{$fg_bold[green]%}$count %{$reset_color%}"
}

git_behind_ahead_count() {
  branch_info=`echo $(git branch -v 2>/dev/null | grep "^*")`

  behind_count=`echo $(echo $branch_info | grep -o "behind \d\d*" | grep -o "\d\d*")`
  ahead_count=`echo $(echo $branch_info | grep -o "ahead \d\d*" | grep -o "\d\d*")`

  if ! [ $behind_count ] && ! [ $ahead_count ]; then return; fi

  behind=""
  if [ $behind_count ]; then
    behind=$(echo "%{$fg_bold[white]%}↓$behind_count")
  fi

  ahead=""
  if [ $ahead_count ]; then
    ahead=$(echo "%{$fg_bold[white]%}↑$ahead_count")
  fi

  echo "$behind$ahead %{$reset_color%}"
}

git_branch() {
  branch_name=`echo $(git branch 2>/dev/null | grep "^* " | cut -d' ' -f 2)`
  if ! [ $branch_name ]; then return; fi

  len=${#branch_name}
  max=$GIT_PROMPT_BRANCH_NAME_MAX_LENGTH
  if [ $len -gt $max ]; then
    filler=$GIT_PROMPT_BRANCH_NAME_TRUNCATION_FILLER
    filler_len=${#GIT_PROMPT_BRANCH_NAME_TRUNCATION_FILLER}
    remaining_len=$(expr $max - $filler_len)
    prefix_len=$(expr $remaining_len / 2)
    prefix=${branch_name:0:$prefix_len}
    suffix_len=$(expr $(expr $remaining_len + 1) / 2)
    suffix_start=$(expr $len - $suffix_len)
    suffix=${branch_name:$suffix_start:$suffix_len}
    branch_name=`echo $(echo ${prefix}${filler}${suffix})`
  fi
  echo "%{$fg[magenta]%}$branch_name"
}

RPROMPT='$(git_untracked_count)$(git_modified_count)$(git_index_count)$(git_behind_ahead_count)$(git_branch)%{$reset_color%}'
