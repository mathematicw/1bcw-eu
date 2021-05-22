#! /bin/bash
# NOTES:
# 1)  locating the logfile to extract data from
# 2)  searching needed lines and save them into a new file



echo "Now is"; date

#VARIABLES RESET
Choose=""               #utility var
Mmf="0"                 #for searching files modified from 0 minutes ago
Mmt="100000000"         #for searching files modified untill 100 000 000 minutes ago
Default_Path="/var/log" #default searching path
Path="$Default_Path"    #
P="*"                   #some pattern to narrow searching
Nfn=""                  #the name of a new file to save lines
Fnp="*"                 #part of the file name, to be sought
Sp="*"                  #the begin-pattern (in searching by range of patterns)
Tp="*"                  #the end-pattern (in searching by range of patterns) 
C=""                    #utility variable
H=""                    #utility variable
Seacolor=" \033[36m %s \n\033[0m"
Magenta=" \033[35m %s \n\033[0m"
Blue=" \033[34m %s \n\033[0m"
Green=" \033[32m %s \n\033[0m"
Yellow=" \033[33m %s \n\033[0m"
Red=" \033[31m %s \n\033[0m"

#   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍    ◍   ◍   ◍   ◍

search_set () {
while true; do
printf "
Set parameters for searching logfile:   [0]> > > > The file has been found. Proceed lines extracting > > > > 
[1]- searching path (default /var/log)  [2]- range of <modifyed minutes ago>    
[3]- filename (or *part*)               [4]- sample of the file content                [5]- Perform searching
"
read -s -n1 Choose

    case $Choose in
    [1]) printf "$Yellow" "<path> = (Enter to use default path) "; read Path ; [[ -z "$Path" ]] && Path="$Default_Path"; printf "$Blue" "Path has been set to $Path";;
    [2]) Minutes_mod; printf "$Blue" "Minutes modif range has been set to: ($Mmf - $Mmt)" ;;
    [3]) printf "$Yellow" "file name (may use any util symbols, wildcards,^ etc)"; read Fnp && printf "$Blue" "Filename=$Fnp" ;;
    [4]) printf "$Yellow" "Type the <part of pattern> (Format is: 'Mar  1 hh:mm', use 2 spaces before !):" ; read P && printf "$Blue" "Sample=$P";;
    [0]) happy; [ $? -eq 0 ] && return ;;
    [5]) searching ;;
     *) printf "$Red" "Must choose from [1] to [5]" ;;
    esac
done
}

Minutes_mod () {
printf "$Yellow" "Format: <modified minutes ago minimum> <Space> <modified minutes ago maximum> (For ex.: 0 5):"; 
while true; do
read -r Mmf Mmt
if [[ -n $Mmf && $Mmf != *[!0123456789]* ]] && [[ -n $Mmt && $Mmt != *[!0123456789]* ]]; #must be nonempty string and not consist of non-digit
then Mmf=$((10#$Mmf)) ; Mmt=$((10#$Mmt));

    if [[ ${Mmt} -ge ${Mmf} ]]; then return 0;
    else printf "$Yellow" "First value must be LESSER or EQUAL second one"
    fi

else 
    printf "$Red" "Values must be integer. 
    Default values will be assigned: 0 - 100000000";
    Mmf=0;
    Mmt=100000000; return 1
fi # >&2
done
}

happy () {
prompt_confirm "To exctract lines there Must Be Only ONE logfile here! Ok? (Y/n):" "please use "Y,y,Enter,Space" or "N,n""
}

prompt_confirm() {
  while true; do
#    printf "$Red" "→"
    printf "$Yellow" "${1}"
    read -r -n 1 REPLY
    case $REPLY in
      [yY]) echo; return 0 ;;
      "") echo; return 0 ;;
      [nN]) return 1 ;;
      *) printf "$Red" "${2}" ;;
    esac 
  done  
}

searching () {
prompt_confirm "Is it correct: Path:$Path; Range of minutes-modified-ago:($Mmf-$Mmt); Filename:$Fnp; ContentSample:$P ? (Y/n)" "please use "Y,y,Enter,Space" or "N,n""
[[ $? -eq 0 ]] && sudo find $Path -type f -readable -mmin +$Mmf -mmin -$Mmt -name "*$Fnp*" -print0 | xargs -0 sudo grep -l --color -E "$P"
printf "$Yellow" "YOUR SET: Path=$Path ; Range of minutes modified ago ($Mmf - $Mmt) ; Filename=$Fnp ; ContentSample=$P
to proceed extracting there must be only ONE FILE in the search result."
}

searching_patterns_range () {
printf "$Green" "Now set <start-pattern> and <end-pattern> to find needed logs in this logfile"
while true;
do
printf "$Yellow" "type <"START"PATTERN> in format <Mar  1 12:10> (Use 2 spaces before 1-9, CASE SENSITIVE): "
read Sp
printf "$Yellow" "type <"END"PATTERN> ... : "
read Tp 
sudo find "$Path" -type f -readable -mmin +$Mmf -mmin -$Mmt -name "*$Fnp*" -print0 | xargs -0 sudo sed -n "/^$Sp/,/^$Tp/p"
prompt_confirm "is it correct? [Y/n]" "please use "Y,y,Enter,Space" or "N,n""
[[ $? -eq 0 ]] && return
done
}

saving_lines () {
while true ; do
printf "$Green" "Save these lines to another file? (Y/n): "
read -n1 -s S
if [[ -z "$S" ]] || [ "$S" == "y" ] || [ "$S" == "Y" ]; then 
    printf "$Green" "Specify <NEW FILE NAME> , located in your HOME dir.(~):"
    read Nfn
    sudo find "$Path" -type f -readable -mmin +$Mmf -mmin -$Mmt -name "*$Fnp*" -print0 | xargs -0 sudo sed -n "/^$Sp/,/^$Tp/p" > ~/$Nfn
    cat -n ~/$Nfn && printf "$Green" "the lines have been saved into ~/$Nfn"
    return 0
elif [ "$S" == "n" ] || [ "$S" == "N" ]; then
    return 0
else 
    printf "wrong input"
fi
done
}
ty () {
printf "\nThank you for testing my script\n"
echo
}

# END OF FUNCTIONS ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍    ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍

search_set
searching_patterns_range
saving_lines
ty

# End  ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍   ◍ 
