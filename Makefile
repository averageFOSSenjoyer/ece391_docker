build: 
	docker build -t local/debian-xfce-vnc -f ./Dockerfile .

run: 
	docker run -it --rm -p 8080:8080 -p 6901:6901 -p 37391:37391 local/debian-xfce-vnc

run-release:
	docker run -p 8080:8080 -p 6901:6901 -p 37391:37391 local/debian-xfce-vnc