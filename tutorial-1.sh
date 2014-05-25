foo(){
  echo 'data'
  data=$1
  echo '----------------'
  echo $data
}

trim() {
    local var=$@

    result=''

    var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters

    result=$var
}

getRepository(){
  pattern=$1
  repository=$2

  result=''

  if [[ $repository =~ ^($pattern)(.*)$ ]]; then
    result=${BASH_REMATCH[2]}
    return 1
  fi

  return 0
}

parseToken(){
  str=$1
  key=''
  value=''

  OIFS=$IFS
  IFS=$2

  local arr=($str)

  if [[ ${#arr[@]} == 2 ]]; then
    #statements
    key=${arr[0]}
    trim $key
    key=$result

    value=${arr[1]}
    trim $value
    value=$result
  fi

  IFS=$OIFS
}

getValueFromKey(){
  str=$2
  pattern=$1
  result=''

  if [[ $str =~ ^($pattern)(.*)$ ]]; then
    #statements
    result=${BASH_REMATCH[2]}
    return 1
  fi

  return 0
}

getCurrentPullRequest(){
  url_api=$1

  response=`curl -s $url_api | sed -e 's/\[/\(/g' -e 's/\]/\)/g' | awk -F: '/(\"html_url\"\:)|(\"state\"\:)|(\"ref\"\:)/ {print}'`
  
  OIFS=$IFS
  IFS=','

  tokens=($response)
  for (( i = 0; i < ${#tokens[@]}; i++ )); 
  do
    #statements
    tokens[$i]=`echo ${tokens[$i]} | tr -d ' ' | sed -e 's/\"//g'`
    trim ${tokens[$i]}
    tokens[$i]=$result

    if [[ ${tokens[$i]} =~ (ref\:) ]]; then
      getValueFromKey 'state:' ${tokens[$i-2]}
      local status=$result

      getValueFromKey 'html_url:' ${tokens[$i-3]}
      local repository=$result

      getValueFromKey 'ref:' ${tokens[$i]}
      if [[ $? == 1 && $result == $branch && $status == 'open' ]]; then
        #statements
        result=$repository
        return 1
      fi
    fi
  done    

  IFS=$OIFS

  return 0
}

path='/Users/travis/build/ngohoaiphuong/Coveralls-iOS'
branch='feature/coveralls'
url_api='https://api.github.com/repos/'

# response=`curl https://api.github.com/users\?callback\=foo`
# echo "$response"

getValueFromKey '/Users/travis/build/' $path

if [[ $? == 1 ]]; then
  #statements
  url_api="${url_api}${result}/pulls"

  getCurrentPullRequest $url_api
  if [[ $? == 1 ]]; then
    #statements
    echo "repository=$result"
  fi
fi

