.PHONY: $(MAKECMDGOALS)

build:
	docker-compose build

clean:
	docker-compose down --volumes --remove-orphans

setup:
	docker-compose run --rm app mix setup

shell:
	docker-compose run --rm app ash

up:
	docker-compose up -d

down:
	docker-compose down --remove-orphans