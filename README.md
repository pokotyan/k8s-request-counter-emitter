## Requirement

### git hooks

```
git config core.hooksPath .githooks
chmod a+x .githooks/pre-push
```

### nginx ingress controller のインストール

参考：https://kubernetes.github.io/ingress-nginx/deploy/#docker-for-mac

```bash
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.43.0/deploy/static/provider/cloud/deploy.yaml
```

### ArgoCD のインストール

参考：https://argoproj.github.io/argo-cd/getting_started/

パスワード設定まで行う

### Argo Rollouts のインストール

参考：https://argoproj.github.io/argo-rollouts/installation/

コントローラと Kubectl Plugin をインストール

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

### ArgoCD のコンソール起動

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
# ポートフォワード実行後、https://localhost:8080 にアクセス
```

### ArgoCD の sync

```
argocd cluster add docker-desktop
```

```bash
argocd app create k8s-request-counter-emitter \
--repo https://github.com/pokotyan/k8s-request-counter-emitter \
--path k8s/app \
--dest-server https://kubernetes.default.svc \
--dest-namespace default \
--sync-policy automated \ # GitRepoを監視して変更があったら自動更新する設定
--auto-prune \
--self-heal
```

```
argocd app sync k8s-request-counter-emitter
```

ロールアウトの観察

```
kubectl argo rollouts get rollout app --watch --cluster docker-desktop
```

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
