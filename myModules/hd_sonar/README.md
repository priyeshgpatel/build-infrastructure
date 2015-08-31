# Sonar server

Just provides a naive implementation of a sonar service. The database lives on the same host, and there's no other
management of the service, except to ensure that it's running. 

Currently, there's not even backups of the sonar database. If the box the service is running on is deleted and restored
it will be from a fresh state, with no historical data.