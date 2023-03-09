#!/bin/bash

# -----------------------------------------------------------------------------
# Start Function Library
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# The month2num() function converts months by name to their number. It handles
# both full length names such as "November" as well as three letter code 
# abbriviations like "Nov". It also handles both upper and lower (and mixed) 
# cases. It can output the month number with an optional prepended zero as 
# appropriate such as "05" for months earlier than October.
# 
# Usage: month_num=$(month2num "$month_string" "--prepend_zero")
# -----------------------------------------------------------------------------
function month2num() {
  local month_input=""
  local month=0
  local leading=""

  if ! [ -z "$1" ]; then
    month_input=`echo "$1" | cut -b1-3 | tr "[:upper:]" "[:lower:]"`

    case $month_input in
      "jan") month="1"; ;;
      "feb") month="2"; ;;
      "mar") month="3"; ;;
      "apr") month="4"; ;;
      "may") month="5"; ;;
      "jun") month="6"; ;;
      "jul") month="7"; ;;
      "aug") month="8"; ;;
      "sep") month="9"; ;;
      "oct") month="10"; ;;
      "nov") month="11"; ;;
      "dec") month="12"; ;;
    esac
  fi

  if ! [ -z "$2" ]; then
    if [ "$2" == "--prepend_zero" ]; then
      leading="0"
    fi
  fi

  if [ $(( month < 10 )) == "1" ]; then
    month="$leading""$month"
  fi

  if [[ "$__resultvar" ]]; then
      eval $__resultvar="'$month'"
  else
      echo "$month"
  fi
}

# -----------------------------------------------------------------------------
# The read_x509() function reads and parses x509 certificate files. Pass the 
# full path and filename to the function. Output is a string list in the 
# following format.
# 
# $subject,$expiration_date,$will_expire_yes_no,$fqdn_list
# 
# Usage: cert_info=$(read_x509 "$cert")
# -----------------------------------------------------------------------------
function read_x509() {
  local secinday=86400
  local cert_file=""
  local cert_data=""

  if ! [ -z "$1" ]; then
    cert_file="$1"

    #local cert_subject=`openssl x509 -in "$cert_file" -nocert -subject | cut -d= -f2,3`
    local cert_subject_domain=`openssl x509 -in "$cert_file" -nocert -subject | cut -d= -f3 | cut -b2-`

    local cert_fqdn_list=`openssl x509 -in "$cert_file" -nocert -ext subjectAltName | echo -En | cut -z -c39- | cut -d, -f1- --output-delimiter=""`

    local cert_end_date=`openssl x509 -in "$cert_file" -nocert -enddate | cut -d"=" -f2`
    local cert_end_year=`echo "$cert_end_date" | rev | cut -d" " -f2 | rev`
    local cert_end_month_string=`echo "$cert_end_date" | cut -d" " -f1`
    local cert_end_month_num=$(month2num "$cert_end_month_string" "--prepend_zero")
    local cert_end_day=`echo "$cert_end_date" | rev | cut -d" " -f4 | rev`
    if [ $(( cert_end_day < 10 )) = 1 ]; then
      cert_end_day="0""$cert_end_day"
    fi
    local cert_end="$cert_end_year""-""$cert_end_month_num""-""$cert_end_day"

    local cert_will_expire=`openssl x509 -in "$cert_file" -nocert -checkend $(( 14 * $secinday )) | grep --color=no "will expire"`
    if ! [ -z "$cert_will_expire" ]; then
      cert_will_expire="true"
    else
      cert_will_expire="false"
    fi

    cert_data="$cert_subject_domain,$cert_end,$cert_will_expire,$cert_fqdn_list"
  fi

  if [[ "$__resultvar" ]]; then
      eval $__resultvar="'$cert_data'"
  else
      echo "$cert_data"
  fi
}

# -----------------------------------------------------------------------------
# The build_cert_line() function generates a colorful readout making 
# certificate expiration date and status easy to identify. Pass the full path 
# and filename of the certificate to the function.
# 
# Useage: one_line=$(build_cert_line "$new_cert")
# -----------------------------------------------------------------------------
function build_cert_line() {
  local domain_maxlength=0;
  local secinday=86400

  if ! [ -z "$1" ]; then
    if ! [ -z "$2" ]; then
      domain_maxlength="$2";
    fi
    local one_cert="$1"

    one_domain=`echo "$one_cert" | cut -d/ -f5`;

    after_domain_space="";
    for (( i=0; i<$(( $domain_maxlength - ${#one_domain} )); i++ )); do
      after_domain_space="$after_domain_space ";
    done

    local cert_info=$(read_x509 "$one_cert")

    local cert_name=`echo "$cert_info" | cut -d, -f1`
    local cert_end=`echo "$cert_info" | cut -d, -f2`
    local cert_will_expire=`echo "$cert_info" | cut -d, -f3`
    local cert_ext_domains=`echo "$cert_info" | cut -d, -f4`

    local cert_end_stripped=`echo "$cert_end" | cut -c5,8 --complement`
    local cert_end_as_sec=`date +%s -d "$cert_end_stripped"`

    local today=`date +%Y-%m-%d`
    local today_stripped=`echo "$today" | cut -c5,8 --complement`
    local today_as_sec=`date +%s -d "$today_stripped"`

    local difference_as_days=$(( ($cert_end_as_sec - $today_as_sec) / $secinday ))

    # defaults
      # endcaps are actually a text/foreground item
      # endcap_color use highlight_color
      # icon_color use highlight_text_color (already set)
      # icon_background use highlight_background (already set)
      # middle area with domain text ... same for everyone
      # domain_text do not set, use default
      # domain_background do not set, use default
      # date_text_color use highlight_text (already set)
      # date_background_color use highlight_background (already set)
    local icon="$warning"
    local domain_text="$c_bold_white"
    local domain_background="$c_back_grey_234"
    local highlight_color="$c_yellow"
    local highlight_background="$c_back_yellow"
    local highlight_text="$c_bold_black"

    if [ $(( $difference_as_days > 13 )) == 1 ]; then
      icon="$good"
      highlight_color="$c_green"
      highlight_background="$c_back_green"
      highlight_text="$c_black"
    elif [ $(( $difference_as_days > 0 )) == 1 ]; then
      icon="$warning"
      highlight_color="$c_yellow"
      highlight_background="$c_back_yellow"
      highlight_text="$c_bold_black"
    else
      icon="$bad"
      highlight_color="$c_red"
      highlight_background="$c_back_red"
      highlight_text="$c_bold_white"
    fi

    local build="  "
    build+="$highlight_color""$outter_left_end"
    build+="$highlight_background""$highlight_text"" ""$icon"" "
    build+="$domain_background""$highlight_color""$inner_right_end"

    build+="$domain_background""$domain_text""  ""$cert_name""  ""$after_domain_space"

    build+="$domain_background""$highlight_color""$inner_left_end"
    build+="$highlight_background""$highlight_text"" ""$cert_end"" "
    build+="$c_reset""$highlight_color""$outter_right_end"
    build+="$c_reset"
  fi

  if [[ "$__resultvar" ]]; then
      eval $__resultvar="'$build'"
  else
      echo "$build"
  fi
}

# ----------------------------------------------------
# BlueKnight's Bash Color Library v1.1 - 2023-01-13
# Function color - overyly simple color library but it's a start at one.
# ----------------------------------------------------
function color() {
  local esc="\e["
  local m="m";
  local reset="0;39";
  local c256f="38;5;";
  local c256b="48;5;";

  local bold=";1";

  local black="16";
  local red="124";
  local green="35";
  local yellow="226";
  local blue="33";
  local pink="134";
  local cyan="51";
  local white="255";
  local gray="243";
  local silver="248";
  local gold="136";
  local dkgray="232";
  local dkgreen="22";
  local dkyellow="58";
  local dkred="52";

  local error="";
  local request="";
  local answer="";

  if ! [ -z "$1" ]; then
    request="$1";
  fi

  case $request in
    "reset") answer="$esc$reset$m"; ;;
    "black") answer="$esc$c256f$black$m"; ;;
    "red") answer="$esc$c256f$red$m"; ;;
    "green") answer="$esc$c256f$green$m"; ;;
    "yellow") answer="$esc$c256f$yellow$m"; ;;
    "blue") answer="$esc$c256f$blue$m"; ;;
    "pink") answer="$esc$c256f$pink$m"; ;;
    "cyan") answer="$esc$c256f$cyan$m"; ;;
    "white") answer="$esc$c256f$white$m"; ;;
    "gray"|"grey") answer="$esc$c256f$gray$m"; ;;
    "silver") answer="$esc$c256f$silver$m"; ;;
    "gold") answer="$esc$c256f$gold$m"; ;;
    "dkgray") answer="$esc$c256f$dkgray$m"; ;;
    "dkgreen") answer="$esc$c256f$dkgreen$m"; ;;
    "dkyellow") answer="$esc$c256f$dkyellow$m"; ;;
    "dkred") answer="$esc$c256f$dkred$m"; ;;

    "boldwhite") answer="$esc$c256f$white$bold$m"; ;;
    "boldgold") answer="$esc$c256f$gold$bold$m"; ;;
    "boldgreen") answer="$esc$c256f$green$bold$m"; ;;
    "boldblack") answer="$esc$c256f$black$bold$m"; ;;

    "backblack") answer="$esc$c256b$black$bold$m"; ;;
    "backgreen") answer="$esc$c256b$green$bold$m"; ;;
    "backyellow") answer="$esc$c256b$yellow$bold$m"; ;;
    "backred") answer="$esc$c256b$red$bold$m"; ;;
    "backdkgray") answer="$esc$c256b$dkgray$bold$m"; ;;
    "backdkgreen") answer="$esc$c256b$dkgreen$m"; ;;
    "backdkyellow") answer="$esc$c256b$dkyellow$m"; ;;
    "backdkred") answer="$esc$c256b$dkred$m"; ;;

    "grey-"*) answer="$esc$c256f"`echo "$request" | cut -d- -f2`"$m"; ;;
    "backgrey-"*) answer="$esc$c256b"`echo "$request" | cut -d- -f2`"$m"; ;;

    *) error="++unexpected request++"; ;;
  esac

  local myresult="";
  if ! [ "$error" == "" ]; then
    myresult="$error"
  else
    myresult="$answer"
  fi

  if [[ "$__resultvar" ]]; then
      eval $__resultvar="'$myresult'"
  else
      echo "$myresult"
  fi
  return 0
}
# --- End Function Library ----------------------------------------------------

# -----------------------------------------------------------------------------
# Begin Colors Declaration
# -----------------------------------------------------------------------------
c_reset=$(color "reset");
c_black=$(color "black");
c_red=$(color "red");
c_green=$(color "green");
c_yellow=$(color "yellow");
c_blue=$(color "blue");
c_pink=$(color "pink");
c_cyan=$(color "cyan");
c_white=$(color "white");
c_dkgray=$(color "dkgray");
c_gray=$(color "gray");
c_silver=$(color "silver");
c_gold=$(color "gold");
c_bold_white=$(color "boldwhite");
c_bold_gold=$(color "boldgold");
c_bold_green=$(color "boldgreen");
c_bold_black=$(color "boldblack");
c_back_black=$(color "backblack");
c_back_green=$(color "backgreen");
c_back_yellow=$(color "backyellow");
c_back_red=$(color "backred");
c_back_dkgray=$(color "backdkgray");
c_back_dkgreen=$(color "backdkgreen");
c_back_dkyellow=$(color "backdkyellow");
c_back_dkred=$(color "backdkred");
c_back_grey_232=$(color "backgrey-232");
c_back_grey_233=$(color "backgrey-233");
c_back_grey_234=$(color "backgrey-234");
c_back_grey_235=$(color "backgrey-235");
c_back_grey_236=$(color "backgrey-236");
c_back_grey_237=$(color "backgrey-237");
c_back_grey_238=$(color "backgrey-238");
c_back_grey_239=$(color "backgrey-239");
c_back_grey_240=$(color "backgrey-240");
c_back_grey_241=$(color "backgrey-241");
c_back_grey_242=$(color "backgrey-242");
c_back_grey_243=$(color "backgrey-243");
c_back_grey_244=$(color "backgrey-244");
c_back_grey_245=$(color "backgrey-245");
c_back_grey_246=$(color "backgrey-246");
c_back_grey_247=$(color "backgrey-247");
c_back_grey_248=$(color "backgrey-248");
c_back_grey_249=$(color "backgrey-249");
c_back_grey_250=$(color "backgrey-250");
c_back_grey_251=$(color "backgrey-251");
c_back_grey_252=$(color "backgrey-252");
c_back_grey_253=$(color "backgrey-253");
c_back_grey_254=$(color "backgrey-254");
# --- End Colors Declaration --------------------------------------------------

# -----------------------------------------------------------------------------
# Declare constants
# -----------------------------------------------------------------------------
secinday=86400;
triangle_right="\uE0B0"
triangle_left="\uE0B2"
circle_right="\uE0B4"
circle_left="\uE0B6"
good="✓"
warning="◬"
bad="⬣"
# --- End Constants -----------------------------------------------------------

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
outter_left_end="$circle_left"
outter_right_end="$circle_right"
inner_left_end="$circle_left"
inner_right_end="$circle_right"
certpath="/etc/letsencrypt/live"
# --- End Configuration -------------------------------------------------------

# -----------------------------------------------------------------------------
# Main Script Body - slim version, only check/display status of cert
# -----------------------------------------------------------------------------
cert_list=$(find $certpath -name cert.pem | sort -f )
filename_array=();
domain_from_filename_array=();
cert_name_array=()
cert_end_array=();
domain_maxlength=0;
if ! [ -z "$cert_list" ]; then
  for one_cert in $cert_list; do
    filename_array+=("$one_cert");
    domain_from_filename=`echo "$one_cert" | cut -d/ -f5`;
    domain_from_filename_array+=("$one_domain");
    cert_info=$(read_x509 "$one_cert")
    cert_name=`echo "$cert_info" | cut -d, -f1`
    cert_name_array+=("$cert_name");
    cert_end=`echo "$cert_info" | cut -d, -f2`
    cert_end_array+=("$cert_end");
    if (( domain_maxlength < ${#domain_from_filename} )); then
      domain_maxlength="${#domain_from_filename}";
    fi
  done
fi

echo ""
echo -en "$c_bold_white""Checking LetsEncrypt SSL Certificate";
if (( ${#filename_array[@]} > 1 )); then
  echo -en "s";
fi
echo -e "$c_reset"

if (( ${#filename_array[@]} == 0 )); then
  echo -e "  ${c_red}No Certificate Files Found.${c_reset}"
else
  # add sorting here
  for one_cert in ${filename_array[@]}; do
    one_line=$(build_cert_line "$one_cert" "$domain_maxlength")
    echo -e "$one_line"
  done
fi

echo ""
# sleep 1

# exit 0
