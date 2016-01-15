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
  branch=`echo $(git branch 2>/dev/null | grep "^* " | cut -d' ' -f 2)`
  if ! [ $branch ]; then return; fi
  echo "%{$fg[magenta]%}$branch"
}

RPROMPT='$(git_untracked_count)$(git_modified_count)$(git_index_count)$(git_behind_ahead_count)$(git_branch)%{$reset_color%}'
