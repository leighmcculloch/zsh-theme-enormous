git_untracked_count() {
  count=$(git status --porcelain 2>/dev/null | grep "^??" | wc -l)
  if [ $count -eq 0 ]; then return; fi
  echo "%{$fg_no_bold[yellow]%}? %{$fg_bold[yellow]%}$count %{$reset_color%}"
}

git_modified_count() {
  count=$(git status --porcelain 2>/dev/null | grep "^.[MD]" | wc -l)
  if [ $count -eq 0 ]; then return; fi
  echo "%{$fg_no_bold[red]%}M %{$fg_bold[red]%}$count %{$reset_color%}"
}

git_index_count() {
  count=$(git status --porcelain 2>/dev/null | grep "^[AMRD]." | wc -l)
  if [ $count -eq 0 ]; then return; fi
  echo "%{$fg_no_bold[green]%}S %{$fg_bold[green]%}$count %{$reset_color%}"
}

git_behind_ahead_count() {
  branch_info=$(git --no-pager branch '--format=%(upstream:track)')

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

GIT_BRANCH_MAX_LENGTH=20

git_branch() {
  branch_name=$(git branch 2>/dev/null | grep "^* " | cut -d' ' -f 2)
  if ! [ $branch_name ]; then return; fi
  branch_name=$(truncate_string $branch_name $GIT_BRANCH_MAX_LENGTH)
  echo "%{$fg[magenta]%}$branch_name "
}

CURRENT_DIRECTORY_MAX_LENGTH=90

current_directory() {
  dir=${PWD/$HOME/\~}
  dir=$(truncate_string $dir $CURRENT_DIRECTORY_MAX_LENGTH)
  echo "%{$fg[green]%}$dir "
}

CURRENT_USER_MAX_LENGTH=5

current_user() {
  user=$USER
  user=$(truncate_string $user $CURRENT_USER_MAX_LENGTH)
  echo "%{$fg[cyan]%}$user%{$reset_color%}"
}

current_hostname() {
  echo "%{$fg[cyan]%}$(hostname)%{$reset_color%}"
}

TRUNCATION_STRING_MAX_LENGTH=20
TRUNCATION_STRING_FILLER=..

truncate_string() {
  string=$1
  max_length=${2:=$TRUNCATION_STRING_MAX_LENGTH}
  filler=${3:=$TRUNCATION_STRING_FILLER}
  string_len=${#string}
  if [ $string_len -gt $max_length ]; then
    filler_len=${#GIT_PROMPT_BRANCH_NAME_TRUNCATION_FILLER}
    remaining_len=$(expr $max_length - $filler_len)
    prefix_len=$(expr $remaining_len / 2)
    prefix=${string:0:$prefix_len}
    suffix_len=$(expr $(expr $remaining_len + 1) / 2)
    suffix_start=$(expr $string_len - $suffix_len)
    suffix=${string:$suffix_start:$suffix_len}
    string=`echo $(echo ${prefix}${filler}${suffix})`
  fi
  echo "$string"
}

precmd() {
  print "";
  print -rP "$(current_user)@$(current_hostname):$(current_directory)$(git_branch)$(git_untracked_count)$(git_modified_count)$(git_index_count)$(git_behind_ahead_count)%{$reset_color%}"
}

PROMPT='%{$reset_color%}$ '
