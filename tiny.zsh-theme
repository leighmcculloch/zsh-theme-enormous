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
  count=`echo $(git status --porcelain 2>/dev/null | grep "^[AMRD]." | wc -l)`
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

GIT_BRANCH_MAX_LENGTH=20

git_branch() {
  branch_name=`echo $(git branch 2>/dev/null | grep "^* " | cut -d' ' -f 2)`
  if ! [ $branch_name ]; then return; fi
  branch_name=$(truncate_string $branch_name $GIT_BRANCH_MAX_LENGTH)
  echo "%{$fg[magenta]%}$branch_name"
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

PROMPT='%{$fg[magenta]%}$ %{$reset_color%}'
RPROMPT='$(git_untracked_count)$(git_modified_count)$(git_index_count)$(git_behind_ahead_count)$(git_branch)%{$reset_color%}'
