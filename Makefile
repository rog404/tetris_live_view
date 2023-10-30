APP = tetris

build:
	docker build -t $(APP) .

run:
	docker run --rm --name $(APP) -p 4000:4000 $(APP)

stop:
	docker stop $(APP)

rm:
	docker image rm $(APP)