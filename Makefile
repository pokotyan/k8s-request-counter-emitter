start_app:
	skaffold dev -p local --port-forward -f k8s/skaffold.yml

delete_pods:
	kubectl get pods -o json | jq -r '.items[] | select(.metadata.name | test("app-")) | .metadata.name' | while read line; do kubectl delete po $$line; done