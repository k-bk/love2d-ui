.PHONY: run
run: love
	./love .

love:
	curl -L -o love https://github.com/love2d/love/releases/download/11.3/love-11.3-x86_64.AppImage
	chmod +x love

