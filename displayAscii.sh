#!/bin/bash
# Name: Phat Tran Tien Nguyen
# StudentID: 649653
# Description: This script to generate character-based ("ASCII art") versions of famous images and also raise errors if input files are invalid.

# implementation note - you may only use syntax and commands discussed in practical classes.
# unusual syntax/commands will be indicative of potential academic misconduct
# (for example, scripts developed by external parties)

# ********************************
# Some predefined values to use..
NL="\n"         # useful to include a newline character in output
BLINK='\033[5m' # makes output text blink
REDF='\033[1;31m' # makes red foreground text
YELLOWB='\033[43m' # makes yellow background text
NC='\033[0m' # clear colour etc and makes output text normal again
BINERR="${BLINK}${REDF}${YELLOWB}X${NC}" # used to display a red blinking X on a yellow background
# The main variable used to display different characters based on image intensity value - note there are 80 chars, 0 to 79
SHADECHAR='$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\|()1{}[]?-_+~<>i!lI;:,"^`\'"'"'.          '
# ********************************


# ********************************
# the rest of your code goes here..
img_dir=$1
img_name=$2
completed_dir="$img_dir/$img_name"
error_log=""
final_result=""

if [ $# -ne 2 ]; then
   echo "Two arguments are required to generate image!"
   exit
fi

if [ ! -d $img_dir ]; then
   echo "Directory $img_dir not found!"
   exit
fi

if [ ! -f "${completed_dir}_000_000" ]; then
   echo "Directory $img_dir does not contain any images starting with $img_name"
   exit
fi

# Get column value function
cut_fn_column() {
    completed_filename=$1
    echo ${completed_filename:$(( ${#completed_dir} + 5)):3}
}

# calculate binary -> decimal
# access each single number character and handle by times 1 2 4 8...
calculate_decimal() {
    binary_number=$1
    decimal=0

    index_value=${binary_number:0:1}
    tmp=$(( $index_value * 128 ))
    decimal=$(( $decimal + $tmp ))

    index_value=${binary_number:1:1}
    tmp=$(( $index_value * 64 ))
    decimal=$(( $decimal + $tmp ))

    index_value=${binary_number:2:1}
    tmp=$(( $index_value * 32 ))
    decimal=$(( $decimal + $tmp ))

    index_value=${binary_number:3:1}
    tmp=$(( $index_value * 16 ))
    decimal=$(( $decimal + $tmp ))

    index_value=${binary_number:4:1}
    tmp=$(( $index_value * 8 ))
    decimal=$(( $decimal + $tmp ))

    index_value=${binary_number:5:1}
    tmp=$(( $index_value * 4 ))
    decimal=$(( $decimal + $tmp ))

    index_value=${binary_number:6:1}
    tmp=$(( $index_value * 2 ))
    decimal=$(( $decimal + $tmp ))

    index_value=${binary_number:7:1}
    tmp=$(( $index_value * 1 ))
    decimal=$(( $decimal + $tmp ))

    echo $decimal
}

# Check binary number validation and print converted SHADECHAR on console if valid or save error msg if invalid
handle_binary_number() {
    item=$1
    col_number=$(cut_fn_column $item)

    while read -r line
    do
        binary_error_flag="false" # set binary number inside file is valid
        
        if [[ "${line}" = *[!01]* ]]; then
            error_log+="BINARYERROR1: Non-binary digit(s):$line found in $filename$NL"
            binary_error_flag="true" # turn the checker into true (mean binary number invalid)
        elif [ ${#line} -lt 8 ]; then
            error_log+="BINARYERROR2: Less than 8 binary digits: $line in $filename$NL"
            binary_error_flag="true"
        elif [ ${#line} -gt 8 ]; then
            error_log+="BINARYERROR3: More than 8 binary digits: $line in $filename$NL"
            binary_error_flag="true"
        elif [ $(calculate_decimal "$line") -gt 79 ]; then
            error_log+="BINARYERROR4: binary value: $line found in $filename is too large$NL"
            binary_error_flag="true"
        fi

        # print converted result if binary number is valid
        if [ $binary_error_flag = "false" ]; then
            if [ $col_number = "000" ]; then # Handle for the newline of image
                echo -n -e "$NL"
            fi
            # calculate binary to decimal and convert to special character (SHADECHAR)
            converted_value=$(calculate_decimal "$line") 
            echo -n -e "${SHADECHAR:$converted_value:1}"
        else
            echo -n -e "${BINERR}" # print X with red color, yellow and blink in background with the invalid binary value case
        fi
    done < $item
}

validate_filename() {
    filename=${1:$(( ${#img_dir} + 1 )):$(( ${#1} - ${#img_dir} ))}

    # Get number at the back of filename (eg: marylin_000_000 -> _000_000)
    extended_img_name=${1:${#completed_dir}:$(( ${#1} - ${#completed_dir} ))}

    # Check cases matched with required error pattern
    case "$extended_img_name" in
        _[0-9][0-9][0-9]_[0-9][0-9][0-9]) handle_binary_number "$1" ;;
        _*[!0-9]*_[0-9][0-9][0-9]) error_log+="ROWERROR1: File $filename has an invalid row value$NL" ;;
        _[0-9][0-9][0-9]_*[!0-9]*) error_log+="COLERROR1: File $filename has an invalid column value$NL" ;;
        _[0-9][0-9][0-9]_[0-9] | _[0-9][0-9][0-9]_[0-9][0-9]) error_log+="COLERROR2: File $filename does not have enough column digits$NL" ;;
        _[0-9]_[0-9][0-9][0-9] | _[0-9][0-9]_[0-9][0-9][0-9]) error_log+="ROWERROR2: File $filename does not have enough row digits$NL" ;;
        *) error_log+="GENERALERR: File $filename has an invalid name$NL"
            fname_error_flag="true" ;;
    esac
}

# Go through all files have the image name in directory
for item in `ls $completed_dir*`; do
    validate_filename $item
done

# check and print all errors if error_log is not null
if [ ! -z "$error_log" ]; then
    echo -e -n $NL$error_log
fi
# ********************************
