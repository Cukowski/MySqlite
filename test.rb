require_relative 'my_sqlite_request'

def run_tests
  # Setup: Create a test CSV file
  test_csv = 'test_db.csv'
  test_csv_join = 'test_join_db.csv'
  
  # Writing initial data to test CSV files
  CSV.open(test_csv, 'w', write_headers: true, headers: ['id', 'name', 'age', 'city']) do |csv|
    csv << ['1', 'Alice', '30', 'New York']
    csv << ['2', 'Bob', '25', 'Los Angeles']
    csv << ['3', 'Charlie', '35', 'Chicago']
  end

  CSV.open(test_csv_join, 'w', write_headers: true, headers: ['id', 'name', 'country']) do |csv|
    csv << ['1', 'Alice', 'USA']
    csv << ['2', 'Bob', 'USA']
    csv << ['3', 'Charlie', 'Canada']
  end

  # Test SELECT
  puts "Test SELECT * FROM test_db.csv WHERE city = 'New York'"
  MySqliteRequest.new.from(test_csv).select('*').where('city', 'New York').run
  puts

  # Test INSERT
  puts "Test INSERT INTO test_db.csv VALUES ('4', 'David', '40', 'Miami')"
  MySqliteRequest.new.insert(test_csv).values('id' => '4', 'name' => 'David', 'age' => '40', 'city' => 'Miami').run
  puts "After INSERT, SELECT * FROM test_db.csv"
  MySqliteRequest.new.from(test_csv).select('*').run
  puts

  # Test UPDATE
  puts "Test UPDATE test_db.csv SET age = '32' WHERE name = 'Alice'"
  MySqliteRequest.new.update(test_csv).set('age' => '32').where('name', 'Alice').run
  puts "After UPDATE, SELECT * FROM test_db.csv"
  MySqliteRequest.new.from(test_csv).select('*').run
  puts

  # Test DELETE
  puts "Test DELETE FROM test_db.csv WHERE name = 'Bob'"
  MySqliteRequest.new.delete.from(test_csv).where('name', 'Bob').run
  puts "After DELETE, SELECT * FROM test_db.csv"
  MySqliteRequest.new.from(test_csv).select('*').run
  puts

  # Test JOIN ON
  puts "Test SELECT test_db.csv.id, test_db.csv.name, test_join_db.csv.country FROM test_db.csv JOIN test_join_db.csv ON test_db.csv.id = test_join_db.csv.id WHERE country = 'USA'"
  MySqliteRequest.new.from(test_csv).select(['id', 'name']).join('id', test_csv_join, 'id').where('country', 'USA').run
  puts

  # Cleanup: Remove the test CSV files
  File.delete(test_csv) if File.exist?(test_csv)
  File.delete(test_csv_join) if File.exist?(test_csv_join)
end

run_tests
