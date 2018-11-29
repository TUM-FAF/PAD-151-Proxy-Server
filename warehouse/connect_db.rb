require 'cassandra'

class ConnectDB
    @@cluster = Cassandra.cluster(
        hosts: ['cassandra']
    )
    @@keyspace = 'system_schema'
    @@session = @@cluster.connect(@@keyspace) # create session, optionally scoped to a keyspace, to execute queries
    
    def self.query
        @@cluster.each_host do |host| # automatically discovers all peers
            puts "Host #{host.ip}: id=#{host.id} datacenter=#{host.datacenter} rack=#{host.rack}"
        end

        response = []
        future = @@session.execute_async('SELECT keyspace_name, table_name FROM tables') # fully asynchronous api
        future.on_success do |rows|
        rows.each do |row|
            response.push("The keyspace #{row['keyspace_name']} has a table called #{row['table_name']}")
        end
        end
        future.join
        return response
    end
end
