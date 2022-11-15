# Browser based Terminal

## Build and push Docker Image

```
# regular on amd64
docker build -t thinkportgmbh/workshops:vscode -f Dockerfile.vscode
docker push -t thinkportgmbh/workshops:vscode

# crossbuild on mac m1 arm64
docker buildx build --push --platform linux/amd64 --tag thinkportgmbh/workshops:vscode  -f Dockerfile.vscode .
```
