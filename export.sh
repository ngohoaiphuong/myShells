export_file(){
  files=(`find $1 -type f -name "*.$2"`)
  local dir_="$3"
  mkdir $dir_

  for (( i = 0; i < ${#files[@]}; i++ )); 
  do
    #statements
    if [[ ${files[$i]} =~ (\/YourGolf\.build\/) && ${files[$i]} =~ (\/i386\/) ]]; then
      #statements
      echo ".export ${files[$i]}"
      filename=$(basename "${files[$i]}")
      extension="${filename##*.}"
      # filename="${filename_%.*}"
      # echo $filename
      # echo "$dir_/$filename"
      # if [[ ! -d "$dir_/$filename" ]]; then
      #   osascript /Users/ngohoaiphuong/sources/tools/export.applescript ${files[$i]} "$dir_/$filename"
      # fi

      # if [[ -f "$dir_/index.html" ]]; then
      #   #statements
      #   rm "$dir_/index.html"
      # fi

      # if [[ -f "$dir_/coverstory.css" ]]; then
      #   #statements
      #   rm "$dir_/coverstory.css"
      # fi

      # if [[ -f "$dir_/coverstory.js" ]]; then
      #   #statements
      #   rm "$dir_/coverstory.js"
      # fi

      if [[ ! -d "$dir_/$filename" ]]; then
        osascript /Users/ngohoaiphuong/sources/tools/export.applescript ${files[$i]} "$dir_/$filename"
      fi
    fi
  done
}

dir_=$1
export_file $dir_ "gcno" "/Users/ngohoaiphuong/sources/reports"
# export_file $dir_ "gcda" "/Users/ngohoaiphuong/sources/reports"

# mkdir "/Users/ngohoaiphuong/sources/reports/gcno"

# for (( i = 0; i < ${#files[@]}; i++ )); 
# do
#   #statements
#   if [[ ${files[$i]} =~ (\/YourGolf\.build\/) ]]; then
#     #statements
#     echo ".export ${files[$i]}"
#     filename=$(basename "${files[$i]}")
#     extension="${filename##*.}"
#     # filename="${filename%.*}"
#     # echo $filename
#     echo "/Users/ngohoaiphuong/sources/reports/$filename"
#     osascript /Users/ngohoaiphuong/sources/tools/export.applescript ${files[$i]} "/Users/ngohoaiphuong/sources/reports/gcno/$filename"
#   fi
# done

# files=($gcda_files)

# mkdir "/Users/ngohoaiphuong/sources/reports/gcda"

# for (( i = 0; i < ${#files[@]}; i++ )); 
# do
#   #statements
#   if [[ ${files[$i]} =~ (\/YourGolf\.build\/) ]]; then
#     #statements
#     echo ".export ${files[$i]}"
#     filename=$(basename "${files[$i]}")
#     extension="${filename##*.}"
#     # filename="${filename%.*}"
#     # echo $filename
#     echo "/Users/ngohoaiphuong/sources/reports/$filename"
#     osascript /Users/ngohoaiphuong/sources/tools/export.applescript ${files[$i]} "/Users/ngohoaiphuong/sources/reports/gcda/$filename"
#   fi
# done