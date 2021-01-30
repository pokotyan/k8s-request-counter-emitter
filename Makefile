#start:
#	docker-compose -p test -f docker-compose_redis.yml up -d \
#	&& docker-compose -p test -f docker-compose_app.yml up --build

start_app:
	skaffold dev --port-forward -f k8s/skaffold.yml

start_redis:
	kubectl apply -f k8s/redis/deployment.yml \
	&& kubectl apply -f k8s/redis/service.yml

stop_app:
	kubectl delete -f k8s/app

stop_redis:
	kubectl delete -f k8s/redis
