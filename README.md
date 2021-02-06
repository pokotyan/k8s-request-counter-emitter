## Requirement

### nginx ingress controller のインストール

参考：https://kubernetes.github.io/ingress-nginx/deploy/#docker-for-mac

```bash
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.43.0/deploy/static/provider/cloud/deploy.yaml
```

### skaffold のインストール

参考：https://skaffold.dev/docs/install/

```
brew install skaffold
```

### kustomize のインストール

参考：https://kubectl.docs.kubernetes.io/installation/kustomize/homebrew/

```
brew install kustomize
```

### ArgoCD のインストール

参考：https://argoproj.github.io/argo-cd/getting_started/

パスワード設定まで行う

```
username: admin
password: <設定したもの>
```

### ArgoCD のコンソール確認

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
# ポートフォワード実行後、https://localhost:8080 にアクセスし、設定したパスワードでログイン
```

### Argo Rollouts のインストール

参考：https://argoproj.github.io/argo-rollouts/installation/

コントローラと Kubectl Plugin をインストール

## Usage

### サーバー、redis の起動（skaffold）

```
make start_app
```

### サーバー、redis の停止（skaffold）

make start_app を Ctrl + C で止める

### サーバー、redis の起動（ArgoCD による監視）

```
argocd cluster add docker-desktop
```

ArgoCD のアプリケーションの作成は GUI 上でポチるか、 argocd app create コマンドを用いるか、マニフェストを登録するかで作れる

```bash
argocd app create k8s-request-counter-emitter \
--repo https://github.com/pokotyan/k8s-request-counter-emitter \
--path k8s/kustomize/overlays/local \
--dest-server https://kubernetes.default.svc \
--dest-namespace default \
--sync-policy automated \ # GitRepoを監視して変更があったら自動更新する
--auto-prune \
--self-heal
```

or 

```
kubectl apply -f k8s/manifest/argo
```

ArgoCD によるリポジトリの監視で、アプリを起動する場合は redis のポートフォワードがされてないので手動でする

```
kubectl port-forward svc/redis-service 6379:6379
```

### サーバー、redis の停止（ArgoCD による監視）

```
argocd app delete k8s-request-counter-emitter
```

### ArgoCD の アプリケーションの sync

※ArgoCD のコンソール上でポチる or リポジトリへの push でも sync される

```
argocd app sync k8s-request-counter-emitter
```

### ArgoCD の 状態確認

ロールアウトの観察

```
kubectl argo rollouts get rollout app --watch --cluster docker-desktop
```

アプリの確認

```
argocd app get k8s-request-counter-emitter
```

### フロントエンド、socket.io サーバーの起動

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

- pod の停止

```
make delete_pods
```
