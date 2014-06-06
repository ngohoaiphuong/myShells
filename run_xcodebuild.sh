APPNAME="YourGolf"
APPNAME_PUMA="YourGolf Puma"
APPNAME_PUMA="YourGolf Puma"

chmod +x /Users/admin/Projects/YGO-iOS2/scripts/travis/add-key.sh

/Users/admin/Projects/YGO-iOS2/scripts/travis/add-key.sh 

pod install

echo "xcodebuild -workspace \"$APPNAME.xcworkspace\" -scheme \"$APPNAME\" -sdk iphonesimulator -configuration Adhoc clean test"
xcodebuild -workspace "$APPNAME.xcworkspace" -scheme "$APPNAME" -sdk iphonesimulator -configuration Adhoc clean test | perl -ne '$message = $_; print $_ if($message =~ /((failed\s+with\s+exit\s+code\s+1)|(FAILED)|(SUCCEEDED)|(error\:)|(Failures\:)|(Executed)|(Test\s+Case))/i);if($message =~ /((failed\s+with\s+exit\s+code\s+1) | (\*\*\s+test\s+failed\s+\*\*))/i){print "exit by my program\n"; exit(1);}'

echo "xctool -workspace \"$APPNAME.xcworkspace\" -scheme \"$APPNAME\" -sdk iphoneos -configuration Adhoc clean build archive"
# xctool -workspace "$APPNAME.xcworkspace" -scheme "$APPNAME" -sdk iphoneos -configuration Adhoc clean build archive | perl filter_log.pl

echo "xctool -workspace \"$APPNAME.xcworkspace\" -scheme \"$APPNAME_PUMA\" -sdk iphoneos -configuration Adhoc clean build archive"
# xctool -workspace "$APPNAME.xcworkspace" -scheme "$APPNAME_PUMA" -sdk iphoneos -configuration Adhoc clean build archive | perl filter_log.pl
