default:
	ruby make_html.rb ../database html

serve:
	ruby -run -e httpd html/ -p 8080
