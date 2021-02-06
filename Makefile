start:
	skaffold run -p local --port-forward -f k8s/skaffold.yml

start_dev:
	skaffold dev -p local --port-forward -f k8s/skaffold.yml

start_redis:
	kubectl apply -f k8s/manifest/redis/deployment.yml \
	&& kubectl apply -f k8s/manifest/redis/service.yml

stop_app:
	kubectl delete -f k8s/manifest/app

stop_redis:
	kubectl delete -f k8s/manifest/redis
