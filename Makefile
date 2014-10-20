default:
	ruby make_html.rb

server:
	ruby -run -e httpd html/ -p 8080