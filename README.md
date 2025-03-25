# Welcome to My Sqlite
***

## Task
The challenge is to implement the 'sqlite' engine that can perform basic SQL operations such as `SELECT`, `INSERT`, `UPDATE`, `DELETE`, `FROM`, `WHERE`, and `JOIN ON`. 
This engine reads and writes data from CSV files, simulating a simple database.

## Description
This project provides a simple implementation of a SQLite-like database engine using Ruby. 
It allows you to execute basic SQL queries on CSV files. 
The main functionalities include:

- `SELECT` statements to retrieve data.
- `INSERT` statements to add new records.
- `UPDATE` statements to modify existing records.
- `DELETE` statements to remove records.
- Support for `WHERE` clauses to filter data.
- Support for `JOIN ON` clauses to combine data from two CSV files.

The core functionality is encapsulated in the `MySqliteRequest` class, and a CLI interface is provided to interact with the engine.

## Installation
You can install this project by running on ruby (Ensure you have Ruby installed).

### Files
my_sqlite_request.rb: Contains the core logic for the MySqlite engine.
my_sqlite_query_cli.rb: CLI interface to interact with the engine.
test.rb: Script to run tests and verify the functionality.

## Usage
To use the MySqlite CLI, you can run the script and enter SQL commands interactively:

```
ruby my_sqlite_query_cli.rb
```
After running the script you can Enter ".help" for usage hints.

### Running Tests
To verify the functionality of the SQL engine, you can run the provided test script:
```
ruby test.rb
```

### The Core Team
Selcuk Aksoy

<span><i>Made at <a href='https://qwasar.io'>Qwasar SV -- Software Engineering School</a></i></span>
<span><img alt='Qwasar SV -- Software Engineering School's Logo' src='https://storage.googleapis.com/qwasar-public/qwasar-logo_50x50.png' width='20px' /></span>
