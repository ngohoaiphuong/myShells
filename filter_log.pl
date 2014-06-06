$message = $_

print $_ if($message =~ /((failed\s+with\s+exit\s+code\s+1)|(FAILED)|(SUCCEEDED)|(error\:)|(Failures\:)|(Executed)|(Test\s+Case))/i);

if($message =~ /((failed\s+with\s+exit\s+code\s+1) | (\*\*\s+test\s+failed\s+\*\*))/i){
	print 'exit by my program filter_log';
	exit(1);
}