<p align="center"><h1 align="center">
  TrustTrees
</h1>

<p align="center"><h2 align="center">
  <i>A Tool for DNS Delegation Trust Graphing</i>
</h2>

<p align="center">
  <a href="https://badge.fury.io/py/TrustTrees"><img src="https://badge.fury.io/py/TrustTrees.svg" alt="PyPI version"/></a>
  <a href="https://github.com/mandatoryprogrammer/TrustTrees/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22+"><img src="https://img.shields.io/badge/PRs-welcome-ff69b4.svg" alt="PRs Welcome"/></a>
  <a href="https://donate.torproject.org/"><img src="https://img.shields.io/badge/Donate-Tor-orange" alt="Tor"/></a>
  <a href="https://pypi.org/project/TrustTrees/"><img src="https://img.shields.io/badge/python-v3.8-blue.svg" alt="Python 3.8"/></a>
</p>
</p>


## Summary
TrustTrees is a script to recursively follow all the possible delegation paths for a target domain and graph the relationships between various nameservers along the way. TrustTrees also allows you to view where errors occurred in this chain such as DNS `REFUSED`, `NXDOMAIN`, and other errors. Finally, the tool also comes with the ability to scan enumerated nameservers for expired base-domains which may allow for domain takeovers and hijacking of the target domain.

The purpose of this tool is to allow domain owners to verify that their domain's DNS is set up properly and is not vulnerable.

Installation
------------
In a Python 3 environment do:
``` {.sourceCode .bash}
$ pip install TrustTrees
✨🍰✨
```

## Example Usage:
```
(env)bash-3.2$ trusttrees --target example.com --open

  ______                __ ______
 /_  __/______  _______/ //_  __/_______  ___  _____
  / / / ___/ / / / ___/ __// / / ___/ _ \/ _ \/ ___/
 / / / /  / /_/ (__  ) /_ / / / /  /  __/  __(__  )
/_/ /_/   \__,_/____/\__//_/ /_/   \___/\___/____/
          Graphing & Scanning DNS Delegation Trees

[ STATUS ] Querying nameserver '192.203.230.10/e.root-servers.net.' for NS of 'example.com.'
[ STATUS ] Querying nameserver '192.5.6.30/a.gtld-servers.net.' for NS of 'example.com.'
[ STATUS ] Querying nameserver '199.43.135.53/a.iana-servers.net.' for NS of 'example.com.'
[ STATUS ] Querying nameserver '199.43.133.53/b.iana-servers.net.' for NS of 'example.com.'
[ STATUS ] Querying nameserver '192.33.14.30/b.gtld-servers.net.' for NS of 'example.com.'
[ STATUS ] Querying nameserver '192.26.92.30/c.gtld-servers.net.' for NS of 'example.com.'
[ STATUS ] Querying nameserver '192.31.80.30/d.gtld-servers.net.' for NS of 'example.com.'
[ STATUS ] Querying nameserver '192.12.94.30/e.gtld-servers.net.' for NS of 'example.com.'
[ STATUS ] Querying nameserver '192.35.51.30/f.gtld-servers.net.' for NS of 'example.com.'
[ STATUS ] Querying nameserver '192.42.93.30/g.gtld-servers.net.' for NS of 'example.com.'
[ STATUS ] Querying nameserver '192.54.112.30/h.gtld-servers.net.' for NS of 'example.com.'
[ STATUS ] Querying nameserver '192.43.172.30/i.gtld-servers.net.' for NS of 'example.com.'
[ STATUS ] Querying nameserver '192.48.79.30/j.gtld-servers.net.' for NS of 'example.com.'
[ STATUS ] Querying nameserver '192.52.178.30/k.gtld-servers.net.' for NS of 'example.com.'
[ STATUS ] Querying nameserver '192.41.162.30/l.gtld-servers.net.' for NS of 'example.com.'
[ STATUS ] Querying nameserver '192.55.83.30/m.gtld-servers.net.' for NS of 'example.com.'
[ STATUS ] Building 'example.com.|ns|192.42.93.30|g.gtld-servers.net.'...
[ STATUS ] Building 'example.com.|ns|192.55.83.30|m.gtld-servers.net.'...
[ STATUS ] Building 'example.com.|ns|199.43.135.53|a.iana-servers.net.'...
[ STATUS ] Building 'example.com.|ns|192.26.92.30|c.gtld-servers.net.'...
[ STATUS ] Building 'example.com.|ns|192.52.178.30|k.gtld-servers.net.'...
[ STATUS ] Building 'example.com.|ns|192.35.51.30|f.gtld-servers.net.'...
[ STATUS ] Building 'example.com.|ns|192.31.80.30|d.gtld-servers.net.'...
[ STATUS ] Building 'example.com.|ns|192.43.172.30|i.gtld-servers.net.'...
[ STATUS ] Building 'example.com.|ns|199.43.133.53|b.iana-servers.net.'...
[ STATUS ] Building 'example.com.|ns|192.12.94.30|e.gtld-servers.net.'...
[ STATUS ] Building 'example.com.|ns|192.203.230.10|e.root-servers.net.'...
[ STATUS ] Building 'example.com.|ns|192.48.79.30|j.gtld-servers.net.'...
[ STATUS ] Building 'example.com.|ns|192.54.112.30|h.gtld-servers.net.'...
[ STATUS ] Building 'example.com.|ns|192.41.162.30|l.gtld-servers.net.'...
[ STATUS ] Building 'example.com.|ns|192.5.6.30|a.gtld-servers.net.'...
[ STATUS ] Building 'example.com.|ns|192.33.14.30|b.gtld-servers.net.'...
[ STATUS ] Opening final graph...
[ SUCCESS ] Finished generating graph!
```

## Example Generated Graph:
[![example.com](https://i.imgur.com/K6FBvQv.png)](https://i.imgur.com/K6FBvQv.png)

## Example Generated Graph With Errors in DNS Chain
[![ticonsultores.biz.ni](https://i.imgur.com/MRcSaie.png)](https://i.imgur.com/MRcSaie.png)

The above graph is a good example of a domain with many DNS errors in its delegation chain. Some of these issues are not even the fault of the domain owner but rather are issues with the upstream TLD. Depending on the configuration of the DNS resolver, the round robin order, and the error tolerance of the DNS resolver, resolution of this domain may or may not succeed.

## Command-Line Options
```sh
(env)bash-3.2$ trusttrees --help
usage: trusttrees (-t TARGET_HOSTNAME | -l TARGET_HOSTNAMES_LIST) [-o]
                  [--only-problematic] [--no-graphing] [-x EXPORT_FORMATS]
                  [-u PREFIX,BUCKET] [--resolvers RESOLVERS_FILE]
                  [--aws-credentials AWS_CREDS_FILE]
                  [--gandi-api-v4-key GANDI_API_V4_KEY]
                  [--gandi-api-v5-key GANDI_API_V5_KEY]
                  [--dnsimple-api-v2-token DNSIMPLE_ACCESS_TOKEN]

Graph out a domain's DNS delegation chain and trust trees!

mutually exclusive required arguments:
  -t TARGET_HOSTNAME, --target TARGET_HOSTNAME
                        Target hostname to generate delegation graph from.
  -l TARGET_HOSTNAMES_LIST, --target-list TARGET_HOSTNAMES_LIST
                        Text file with a list of target hostnames.

optional arguments:
  -o, --open            Open the generated graph(s) once run.
  --only-problematic    Open generate graphs that are likely to be vulnerable.
  --no-graphing         Do not generate any graphs.
  -x EXPORT_FORMATS, --export-formats EXPORT_FORMATS
                        Comma-separated export formats, e.g: -x png,pdf
  -u PREFIX,BUCKET, --upload-graph PREFIX,BUCKET
                        Comma-separated AWS args, e.g: -u graphs,mybucket
  --resolvers RESOLVERS_FILE
                        Text file containing DNS resolvers to use.

optional arguments for domain-checking:
  --aws-credentials       AWS_CREDS_FILE
                             AWS credentials JSON file for checking if nameserver
                             base domains are registerable.
  --gandi-api-v4-key      GANDI_API_V4_KEY
                             Gandi API V4 key for checking if nameserver base
                             domains are registerable.
  --gandi-api-v5-key      GANDI_API_V5_KEY
                             Gandi API V5 key for checking if nameserver base
                             domains are registerable.
  --dnsimple-api-v2-token DNSIMPLE_ACCESS_TOKEN
                             DNSimple API V2 access token for checking if nameserver
                             base domains are registerable.
```

In order to use the domain-check functionality to look for domain takeovers via expired-domain registration you must have a Gandi production API key, AWS keys with the `route53domains:CheckDomainAvailability` IAM permission, or a DNSimple access token. AWS uses Gandi behind the scenes. [Click here to sign up for a Gandi account.](https://www.gandi.net/)

## Graph Nodes/Edges Documentation
### Nodes
* *White Nameserver Nodes*: These are nameservers which have delegated the query to another nameserver and have not responded authoritatively to the query.
* *Blue Nameserver Nodes*: These are nameservers which have answered authoritatively to the query.
* *Red Nameserver Nodes*: These are nameservers which were found to have no IP address associated with them. They are essentially dead-ends because the resolver has no way to send queries to them.
* *Yellow DNS Error Nodes*: These are DNS errors which occurred while recursing the DNS chain.
* *Orange Domain Unregistered Nodes*: These nodes indicate that the base domain for the nameserver is reported by Gandi to be unregistered. This can mean the domain can be registered and the DNS hijacked!

### Edges
* *Dashed gray lines*: This means that the query response was not authoritative.
* *Solid blue lines*: This means the query response was authoritative.
* *Solid black lines*: (or it links to an error/domain registered node).

## License

This project is licensed via [Apache License 2.0](LICENSE)
