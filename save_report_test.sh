trim() {
    local var=$@

    result=''

    var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters

    result=$var
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
  local url_api=$1

  echo "curl -i https://api.github.com/users/whatever"
  curl -i 'https://api.github.com/users/whatever?client_id=d7f5c6567b209db57c67&client_secret=ba7ee1cd4879f8aad1c241723bf052cc058295d2'
  response=`curl -s $url_api | sed -e 's/\[/\(/g' -e 's/\]/\)/g' | awk -F: '/(\"html_url\"\:)|(\"state\"\:)|(\"ref\"\:)|(\"comments_url\")/ {print}'`
  
  OIFS=$IFS
  IFS=','
  comments_url=''
  tokens=($response)

  for (( i = 0; i < ${#tokens[@]}; i++ )); 
  do
    #statements
    tokens[$i]=`echo ${tokens[$i]} | tr -d ' ' | sed -e 's/\"//g'`
    trim ${tokens[$i]}
    tokens[$i]=$result

    if [[ ${tokens[$i]} =~ (ref\:)(.*) ]]; then
      getValueFromKey 'state:' ${tokens[$i-3]}
      local status=$result

      getValueFromKey 'html_url:' ${tokens[$i-4]}
      local repository=$result

      getValueFromKey 'comments_url:' ${tokens[$i-1]}
      local comments=$result

      getValueFromKey 'ref:' ${tokens[$i]}
      if [[ "$result" == "$branch" && "$status" == 'open' ]]; then
        #statements
        result=$repository
        comments_url=$comments
        return 1
      fi
    fi
  done    

  IFS=$OIFS

  return 0
}

generate_report(){
  echo "osascript .utility/coverstory.scpt $TRAVIS_BUILD_DIR/coverage_report $HOME/coverage"
  osascript .utility/coverstory.scpt $TRAVIS_BUILD_DIR/coverage_report $HOME/coverage
}

push_2_report(){
  local dir_html=$1
  local name_branch=$2

  echo "dir_html=$dir_html"
  echo "name_branch=$name_branch"
  echo "------------------------"

  cp -R $dir_html $HOME/report_$name_branch
  rm -rf $dir_html

  cd ${HOME}/build_${TRAVIS_BUILD_NUMBER}

  # git remote add my_origin https://${report_token}@github.com/${report_repository}.git

  if [[ "$name_branch" == "analyzer" ]]; then
    #statements
    echo "copy all file of branch $name_branch"
    cp -R $HOME/report_$name_branch/*/ code-metrics/$name_branch
  else
    cp -R $HOME/report_$name_branch/ code-metrics/$name_branch
  fi
}

commit_new_report(){
  cd ${HOME}/build_${TRAVIS_BUILD_NUMBER}

  git add .
  git commit -m "generate report from Travis CI [skip ci]"
  git push -q origin $TRAVIS_BRANCH

  #remove all data
  # cd $HOME
  # rm -rf ${HOME}/build_${TRAVIS_BUILD_NUMBER}  
}

set_git_info(){
  git config --global user.email "ngohoai.phuong@gmail.com"
  git config --global user.name "Travis"
}

push_comment_2_pullrequest(){
  # message_str="[Analyzer completed]($2) [Run coverage completed]($1)"
  # curl -X POST -d "{\"body\":\"${message_str}\"}" -H "Authorization: token ${GH_TOKEN}" $comments_url
  message_html="<html><div><a href='$1' target='_blank'>Measure Coverage Result</a></div><div><a href='$2' target='_blank'>Analyzer Result</a></div></html>"
  curl -X POST -d "{\"body\":\"${message_html}\"}" -H "Authorization: token ${GH_TOKEN}" $comments_url
}

push_comment_2_slack(){
  echo "s3=${path_s3}"
  local coverage_link="https://s3.amazonaws.com/ygo-development/artifacts/${path_s3}/coverage/index.html"

  local analyzer_link="https://s3.amazonaws.com/ygo-development/artifacts/${path_s3}/analyzer/index.html"

  # payload="{\"channel\":\"#${slack_channel}\", \"username\": \"Travis CI\", \"text\":\"Coverage and Analyzer code completed\""
  # payload="${payload},\"attachments\":[{\"pretext\":\"You can get coverage build directory ${coverage_repository}\",\"fields\":[{\"title\":\"Notes\",\"value\":\"You can view result online at ${coverage_link}\"}]}, {\"pretext\":\"You can get analyzer build directory ${analyzer_repository}\",\"fields\":[{\"title\":\"Notes\",\"value\":\"You can view result online at ${analyzer_link}\"}]}]"
  # payload="${payload},\"icon_url\":\"https://s3-us-west-2.amazonaws.com/slack-files2/bot_icons/2014-05-22/2351865235_48.png\"}"

  payload="{\"channel\":\"#${slack_channel}\", \"username\": \"Travis CI\", \"text\":\"Coverage and Analyzer code completed\""
  payload="${payload},\"attachments\":[{\"pretext\":\"You can view coverage report at ${coverage_link}\"}, {\"pretext\":\"You can view analyzer report at ${analyzer_link}\"}]"
  payload="${payload},\"icon_url\":\"https://s3-us-west-2.amazonaws.com/slack-files2/bot_icons/2014-05-22/2351865235_48.png\"}"

  cmd="curl -X POST --data-urlencode 'payload=${payload}' https://ygo.slack.com/services/hooks/incoming-webhook\?token\=lz25ioqy6NTAUO4BshDh2yWb"
  echo $cmd
  # eval $cmd
}

save_report(){
  local which_branch=$1
  if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
    if [[ "$which_branch" == 'coverage' ]]; then
      #statements
      generate_report
    fi

    set_git_info

    if [[ -d $HOME/coverage && "$which_branch" == 'coverage' ]]; then
      #statements
      push_2_report $HOME/coverage "coverage"
    fi

    if [[ -d $TRAVIS_BUILD_DIR/analyzer_report  && "$which_branch" == 'analyzer' ]]; then
      #statements
      push_2_report $TRAVIS_BUILD_DIR/analyzer_report "analyzer"
    fi
  fi
}

create_s3_dir(){
  cd ${HOME}/build_${TRAVIS_BUILD_NUMBER}
  local branch=`echo $TRAVIS_BRANCH | sed -e 's/.*\///g'`
  mv code-metrics $TRAVIS_BUILD_NUMBER
  mkdir -p s3/YGO-iOS2/$branch
  echo "mv $TRAVIS_BUILD_NUMBER s3/YGO-iOS2/$branch"
  mv $TRAVIS_BUILD_NUMBER s3/YGO-iOS2/$branch
  path_s3="YGO-iOS2/${branch}/${TRAVIS_BUILD_NUMBER}"

  s3cmd sync s3/YGO-iOS2 s3://ygo-development/artifacts/
}

export REPO="$(pwd | sed s,^/home/travis/build/,,g)"
url_api='https://api.github.com/repos/'
branch=$TRAVIS_BRANCH
slack_channel=$SLACK_CHANNEL

echo '-----------------------------'
echo "REPOSITORY=$REPO"
echo "TRAVIS_BUILD_DIR=$TRAVIS_BUILD_DIR"
echo "TRAVIS_REPO_SLUG=$TRAVIS_REPO_SLUG"
echo "BRANCH=$branch"
echo "GH_TOKEN=${GH_TOKEN}"
echo "TRAVIS_TOKEN=${report_token}"
echo "coverage_branch=${coverage_branch}"
echo "analyzer_branch=${analyzer_branch}"
echo '-----------------------------'

export TRAVIS_BUILD_NUMBER=179
export TRAVIS_BRANCH="feature/8139-8076_run_coverage_analyze"
# travis encrypt 'asw=AKIAIW6RCACCAER7DFQQ secr=BNv5ETBDGO8A+n9kzl3EBpBfH84OXs65jFXUH4Ad'


if [[ "$1" == "send_message" ]]; then
  #statements
  push_comment_2_slack 
elif [[ "$1" == "commit" ]]; then
  commit_new_report
elif [[ "$1" == "s3" ]]; then
  # echo "s3://ygo-development/artifacts/YGO-iOS2/css_link.html" | sed -e 's/s3\:\//https\:\/\/s3.amazonaws.com/g'
  create_s3_dir
  push_comment_2_slack 
else
  #statements
  save_report $1
fi

# push_comment_2_slack $coverage_branch $analyzer_branch