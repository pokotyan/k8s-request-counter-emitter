## Requirement

### nginx ingress controller のインストール

参考：https://kubernetes.github.io/ingress-nginx/deploy/#docker-for-mac

```bash
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.43.0/deploy/static/provider/cloud/deploy.yaml
```

## Usage

### redis の起動

- 起動

```
make start_redis
```

- redis をローカルホストで LISTEN させる(socket.io サーバーからアクセスできるようにするため)

```
kubectl port-forward svc/redis-service 6379:6379
```

### サーバーの起動

```
make start_app
```

### socket.io サーバーの起動

https://github.com/pokotyan/k8s-request-counter/blob/main/README.md

## Reference

### ブラウザ側への push 通知

api の実行、もしくは pod の終了で redis のパブリッシュを実行し、socket.io サーバーへ通知を行う

- EXEC_API チャンネルの publish

```
curl http://localhost/publish
```

- SHUTDOWN チャンネルの publish

```
kubectl delete pod <pod_name>
```
