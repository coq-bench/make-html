default:
	ruby make_html.rb

serve:
	ruby -run -e httpd html/ -p 8080
