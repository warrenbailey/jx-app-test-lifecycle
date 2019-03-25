# jx-app-test-lifecycle

jx-app-test-lifecycle provides a means for BDD testing of [Jenkins X](https://jenkins-x.github.io/jenkins-x-website/) app commands.

You must have a Jenkins X cluster to install and use the jx-app-test-lifecycle app.
If you do not have a Jenkins X cluster and you would like to try it out, the [Jenkins X Google Cloud Tutorials](https://jenkins-x.io/getting-started/tutorials/) is a great place to start.

## Installation

Using the [jx command line tool](https://jenkins-x.io/getting-started/install/), run the following command:

```bash
$ jx add app jx-app-test-lifecycle --repository "http://chartmuseum.jenkins-x.io"
```

After the installation, you can view the status of jx-app-test-lifecycle via:

```bash
$ helm status jx-app-test-lifecycle
```

The jx-app-test-lifecycle shows also in the list of running pods via `kubectl get pods`.
                                                                                                        
