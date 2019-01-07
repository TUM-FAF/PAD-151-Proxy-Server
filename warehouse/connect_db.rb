require 'cassandra'
require 'json'

# ConnectDB
class ConnectDB
  def initialize(keyspace)
    @counter = 0
    @keyspace = keyspace
    @cluster = Cassandra.cluster(
      hosts: %w[cassandra1 cassandra2]
    )
    @session = @cluster.connect # create session, optionally scoped to a keyspace, to execute queries
    @session.execute("CREATE KEYSPACE IF NOT EXISTS #{@keyspace} WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 2}")
    @session.execute("USE #{@keyspace}")
    @session.execute("CREATE TABLE IF NOT EXISTS jokes(
      joke_id int PRIMARY KEY,
      author text,
      text text,
      joke_rating int)")
  end

  def all
    response = {}
    hosts = []
    @cluster.each_host do |host| # automatically discovers all peers
      hosts << "Host #{host.ip}: id=#{host.id} datacenter=#{host.datacenter} rack=#{host.rack}"
    end
    response[:hosts] = hosts
    result = []
    future = @session.execute_async('SELECT * FROM jokes')
    future.on_success do |rows|
      rows.each do |row|
        result << row
      end
    end
    future.join
    response[:result] = result
    response
  end

  private

  def create(json)
    joke = JSON.parse(json)
    @session.execute("INSERT INTO jokes (joke_id, author, text, joke_rating) VALUES (#{@counter}, '#{joke[:author]}', '#{joke[:text]}', 0) IF NOT EXISTS")
    @counter += 1
  end

  # def self.query
  #   @cluster.each_host do |host| # automatically discovers all peers
  #     puts "Host #{host.ip}: id=#{host.id} datacenter=#{host.datacenter} rack=#{host.rack}"
  #   end
  #   response = []
  #   future = @session.execute_async('SELECT keyspace_name, table_name FROM tables') # fully asynchronous api
  #   future.on_success do |rows|
  #     rows.each do |row|
  #       response.push("The keyspace #{row['keyspace_name']} has a table called #{row['table_name']}")
  #     end
  #   end
  #   future.join
  #   response
  # end
end
