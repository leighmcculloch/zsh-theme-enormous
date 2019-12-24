git_untracked_count() {
  local stat="$1"
  local count=$(echo $stat | grep "^??" | wc -l)
  if [ $count -eq 0 ]; then return; fi
  echo "%{$fg_no_bold[yellow]%}? %{$fg_bold[yellow]%}$count %{$reset_color%}"
}

git_modified_count() {
  local stat="$1"
  local count=$(echo $stat | grep "^.[MD]" | wc -l)
  if [ $count -eq 0 ]; then return; fi
  echo "%{$fg_no_bold[red]%}M %{$fg_bold[red]%}$count %{$reset_color%}"
}

git_index_count() {
  local stat="$1"
  local count=$(echo $stat | grep "^[AMRD]." | wc -l)
  if [ $count -eq 0 ]; then return; fi
  echo "%{$fg_no_bold[green]%}S %{$fg_bold[green]%}$count %{$reset_color%}"
}

git_status_count() {
  local stat=$(git status --porcelain 2>/dev/null)
  echo "$(git_untracked_count $stat)$(git_modified_count $stat)$(git_index_count $stat)"
}

git_behind_ahead_count() {
  branch_info=$(git --no-pager branch '--format=%(if)%(HEAD)%(then)%(upstream:track)%(end)' 2>/dev/null)

  behind_count=$(echo $branch_info | grep -o 'behind [0-9]\+' | grep -o '[0-9]\+')
  ahead_count=$(echo $branch_info | grep -o 'ahead [0-9]\+' | grep -o '[0-9]\+')

  if ! [ $behind_count ] && ! [ $ahead_count ]; then return; fi

  behind=""
  if [ ! -z $behind_count ] && [ $behind_count -gt 0 ]; then
    behind="%{$fg_bold[white]%}↓$behind_count"
  fi

  ahead=""
  if [ ! -z $ahead_count ] && [ $ahead_count -gt 0 ]; then
    ahead="%{$fg_bold[white]%}↑$ahead_count"
  fi

  echo "$behind$ahead %{$reset_color%}"
}

git_branch() {
  branch_name=$(git branch 2>/dev/null | grep "^* " | cut -d' ' -f 2)
  if ! [ $branch_name ]; then return; fi
  echo "%{$fg[magenta]%}$branch_name "
}

current_directory() {
  echo "%{$fg[green]%}%~ "
}

PROMPT='
$(current_directory)$(git_branch)$(git_status_count)$(git_behind_ahead_count)
%{$fg[white]%}ΙΧΘΥΣ %{$reset_color%}'
