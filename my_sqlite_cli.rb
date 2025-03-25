require_relative 'my_sqlite_request'
require 'readline'
require 'csv'

class MySqliteQueryCli

    def request(arguments)
        arguments[-1] = arguments[-1].chomp(";") if arguments[-1].end_with?(";")
        
        command = arguments.join(' ')
        
        case command
        when /SELECT/
            request_select(command)
        when /INSERT/
            request_insert(command)
        when /UPDATE/
            request_update(command)
        when /DELETE/
            request_delete(command)
        else
            puts "Invalid command"
        end
    end

    def request_select(command)
        request = MySqliteRequest.new
        select_columns = command.match(/SELECT\s+(.+?)\s+FROM/)[1].split(/[\s,]+/).map(&:strip)
        table = extract_table_name(command, /FROM\s+(\S+)/)

        request = request.from(table)
        request = request.select(select_columns)

        if command.include?("WHERE")
            where_params = parse_where(command)
            request = request.where(where_params[0], where_params[1])
        end

        request.run
    end

    def request_insert(command)
        request = MySqliteRequest.new
        table = extract_table_name(command, /INTO\s+(\S+)/)
        values = command.match(/VALUES\s+\((.+?)\)/)[1].split(',').map(&:strip)

        file_columns = CSV.read(table, headers: true).headers
        hash_values = file_columns.zip(values).to_h

        request = request.insert(table)
        request = request.values(hash_values)
        request.run
    end

    def request_update(command)
        request = MySqliteRequest.new
        table = extract_table_name(command, /UPDATE\s+(\S+)/)
        set_values = command.match(/SET\s+(.+?)\s+WHERE/)[1].split(',').map { |pair| pair.split('=').map(&:strip) }.to_h
        where_params = parse_where(command)

        request = request.update(table)
        request = request.set(set_values)
        request = request.where(where_params[0], where_params[1])
        request.run
    end

    def request_delete(command)
        request = MySqliteRequest.new
        table = extract_table_name(command, /FROM\s+(\S+)/)
        where_params = parse_where(command)

        request = request.delete
        request = request.from(table)
        request = request.where(where_params[0], where_params[1])
        request.run
    end

    def get_input
        line = Readline.readline("my_sqlite_cli> ", true)
        puts Readline::HISTORY.to_a if line.nil?
        line
    end
    
    def parse_where(command)
        col, _, criteria = command.split('WHERE')[1].strip.split(' ', 3)
        [col, criteria.delete('"\'' )]
    end

    def extract_table_name(command, regex)
        table = command.match(regex)[1].gsub(';', '')
        table += ".csv" unless table.end_with?(".csv")
        table
    end

    def run
        puts "MySQLite version 0.1 #{Time.now.strftime('%Y-%m-%d')}"
        puts 'Enter ".help" for usage hints.'
        while (query = get_input)
            case query
            when 'quit'
                break
            when ".help"
                print_help
            else
                request(query.split)
            end
        end
    end

    def print_help
        puts "********************  REQUEST   *************************"
        puts "> SELECT * FROM students;"
        puts "> INSERT INTO students VALUES (John, john@johndoe.com, A, https://blog.johndoe.com);"
        puts "> UPDATE students SET email = 'jane@janedoe.com', blog = 'https://blog.janedoe.com' WHERE name = 'Jane';"
        puts "> DELETE FROM students WHERE name = 'John';"
        puts "> quit"
    end
end

MySqliteQueryCli.new.run
