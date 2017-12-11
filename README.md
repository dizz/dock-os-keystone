## Hello

This container will run up keystone against a mysql backend. Keystone provides AuthN and AuthZ.

## Using

* Build the image: `docker build -t dizz/dock-os-keystone .`
* Run docker compose to bring up the stack: `docker-compose up`

## Environment Variables

See the bootstrap.sh script

## Quick Test

The admin credentials to the keystone service instance will be shown when the keystone container starts.

Use the user credentials shown when the following is executed...

### Get a Token
```
curl -si -X POST $OS_AUTH_URL/auth/tokens\?nocatalog -H "Content-Type: application/json" -d '{ "auth": { "identity": { "methods": ["password"],"password": {"user": {"domain": {"name": "'"$OS_USER_DOMAIN_NAME"'"},"name": "'"$OS_USERNAME"'", "password": "'"$OS_PASSWORD"'"} } }, "scope": { "project": { "domain": { "name": "'"$OS_PROJECT_DOMAIN_NAME"'" }, "name":  "'"$OS_PROJECT_NAME"'" } } }}'
```

results in...

```
HTTP/1.1 201 Created
X-Subject-Token: gAAAAABaKUWjuFUrWaB9elQBwJLcpzil9qNFDxux6TRDS6u7SP4hIMbUGJHxL5RKOMFSdwlMtdJDZe0eE6JBC5tZQPFWrLCm3lVa1Z8j2tpFD9Dpnrtou8M1LqJw45z2Cy7nJqEWhyBTGvxPpeV-R9Xkl5nZlstXlzcytVaev6ym86N1SaLynbs
Vary: X-Auth-Token
Content-Type: application/json
Content-Length: 524
x-openstack-request-id: req-252f2f9b-acde-416f-ab1e-1f735bd56e57

{"token": {"is_domain": false, "methods": ["password"], "roles": [{"id": "43acc75c52c4482ab5e9490c219ebc2a", "name": "admin"}], "expires_at": "2017-12-14T13:44:03.000000Z", "project": {"domain": {"id": "default", "name": "Default"}, "id": "23212c242ea047ae8c2f3e6347ad30c0", "name": "admin"}, "user": {"password_expires_at": null, "domain": {"id": "default", "name": "Default"}, "id": "9361f84a38ff4a04a4a7a40e7a484bce", "name": "admin"}, "audit_ids": ["WPcgPzhaRwWjNC1yHRewmA"], "issued_at": "2017-12-07T13:44:03.000000Z"}}
```

`X-Subject-Token` has your token value.
