---
apiVersion: v1
kind: Namespace
metadata:
  name: cert-manager
---
apiVersion: v1
kind: Secret
metadata:
  name: housefam-casa-tls
  namespace: cert-manager
  annotations:
    cert-manager.io/alt-names: '*.housefam.casa,housefam.casa'
    cert-manager.io/certificate-name: housefam-casa
    cert-manager.io/common-name: housefam.casa
    cert-manager.io/ip-sans: ""
    cert-manager.io/issuer-group: ""
    cert-manager.io/issuer-kind: ClusterIssuer
    cert-manager.io/issuer-name: letsencrypt-production
    cert-manager.io/uri-sans: ""
  labels:
    controller.cert-manager.io/fao: "true"
type: kubernetes.io/tls
data:
  tls.crt: op://$VAULT/housefam-casa-tls/tls.crt
  tls.key: op://$VAULT/housefam-casa-tls/tls.key
---
apiVersion: v1
kind: Namespace
metadata:
  name: external-secrets
---
apiVersion: v1
kind: Secret
metadata:
  name: onepassword-secret
  namespace: external-secrets
stringData:
  1password-credentials.json: op://$VAULT/1password/OP_CREDENTIALS_JSON
  token: op://$VAULT/1password/OP_CONNECT_TOKEN
