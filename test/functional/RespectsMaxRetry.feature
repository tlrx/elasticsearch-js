# Licensed to Elasticsearch B.V under one or more agreements.
# Elasticsearch B.V licenses this file to you under the Apache 2.0 License.
# See the LICENSE file in the project root for more information

Feature: First usage

	By default, a client will retry a request as many times as there are known nodes in the cluster.

	Retries will respect the request timeout; for example, if you have a 100 node cluster and a request timeout of 20 seconds,
	the client will retry as many times as it can within 20 seconds.

	Scenario: Retry for every known node in the cluster, the client will automatically fail over to each node for a single API call.

		# Cluster configuration
		Given a cluster with 5 nodes
		And nodes 1 to 4 are unhealthy
		And node 5 is healthy

		# Client configuration
		Given client configuration specifies 5 nodes
		And pings are disabled

		When the client is created
		And client makes an API call

		Then an API request is made to node 1
		And an unhealthy API response is received from node 1
		And node 1 is removed from the connection pool
		And an API request is made to node 2
		And an unhealthy API response is received from node 2
		And node 2 is removed from the connection pool
		And an API request is made to node 3
		And an unhealthy API response is received from node 3
		And node 3 is removed from the connection pool
		And an API request is made to node 4
		And an unhealthy API response is received from node 4
		And node 4 is removed from the connection pool
		And an API request is made to node 5
		And a healthy API response is received from node 5

	Scenario: A maxiumum number of retries can be specified to limit the number of nodes that can be failed over. The total number of requests will be the initial attempt + number of retries.

		# Cluster configuration
		Given a cluster with 5 nodes
		And nodes 1 to 4 are unhealthy
		And node 5 is healthy

		# Client configuration
		Given client configuration specifies 5 nodes
		And pings are disabled
		And 3 maximum retries

		When the client is created
		And client makes an API call

		Then an API request is made to node 1
		And an unhealthy API response is received from node 1
		And node 1 is removed from the connection pool
		And an API request is made to node 2
		And an unhealthy API response is received from node 2
		And node 2 is removed from the connection pool
		And an API request is made to node 3
		And an unhealthy API response is received from node 3
		And node 3 is removed from the connection pool
		And an API request is made to node 4
		And an unhealthy API response is received from node 4
		And node 4 is removed from the connection pool
		And the client indicates maximum retries reached

	# Scenario: Overall request timeout is respected when attempting retries across nodes that are slow to respond.

	# 	# Cluster configuration
	# 	Given a cluster with 5 nodes
	# 	And nodes 1 to 4 are unhealthy and respond to requests after 10 seconds
	# 	And node 5 is healthy

	# 	# Client configuration
	# 	Given client configuration specifies 5 nodes
	# 	And pings are disabled
	# 	And requests timeout after 20 seconds

	# 	When the client is created
	# 	And client makes an API call

	# 	Then an API request is made to node 1
	# 	And an unhealthy API response is received from node 1
	# 	And node 1 is removed from the connection pool
	# 	And an API request is made to node 2
	# 	And an unhealthy API response is received from node 2
	# 	And node 2 is removed from the connection pool
	# 	And the client indicates maximum timeout reached

	# Scenario: An overall retry timeout can be specified to help contain individual request timeouts.

	# 	# Cluster configuration
	# 	Given a cluster with 10 nodes
	# 	And all nodes are unhealthy and respond to requests after 10 seconds

	# 	# Client configuration
	# 	Given client configuration specifies 10 nodes
	# 	And pings are disabled
	# 	And requests timeout after 2 seconds
	# 	And total request timeout after 10 seconds

	# 	When the client is created
	# 	And client makes an API call

	# 	Then an API request is made to node 1
	# 	And an unhealthy API response is received from node 1
	# 	And node 1 is removed from the connection pool
	# 	And an API request is made to node 2
	# 	And an unhealthy API response is received from node 2
	# 	And node 2 is removed from the connection pool
	# 	And an API request is made to node 3
	# 	And an unhealthy API response is received from node 3
	# 	And node 3 is removed from the connection pool
	# 	And an API request is made to node 4
	# 	And an unhealthy API response is received from node 4
	# 	And node 4 is removed from the connection pool
	# 	And an API request is made to node 5
	# 	And an unhealthy API response is received from node 5
	# 	And node 5 is removed from the connection pool
	# 	And the client indicates maximum timeout reached

	# Scenario: The client will not retry the same node twice.

	# 	# Cluster configuration
	# 	Given a cluster with 2 nodes
	# 	And all nodes are unhealthy and respond to requests after 3 seconds

	# 	# Client configuration
	# 	Given client configuration specifies 2 nodes
	# 	And pings are disabled
	# 	And requests timeout after 2 seconds
	# 	And total request timeout after 10 seconds

	# 	When the client is created
	# 	And client makes an API call

	# 	Then an API request is made to node 1
	# 	And an unhealthy API response is received from node 1
	# 	And node 1 is removed from the connection pool
	# 	And an API request is made to node 2
	# 	And an unhealthy API response is received from node 2
	# 	And node 2 is removed from the connection pool
	# 	And the client indicates maximum timeout reached
	# 	And the client indicates all nodes failed