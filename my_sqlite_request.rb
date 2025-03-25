require 'csv'

class MySqliteRequest
    def initialize
        @type_of_request = :none
        @select_columns = []
        @table_name = nil
        @order_params = nil
        @where_params = []
        @join_params = nil
        @insert_attributes = nil
    end

    def from(table_name)
        @table_name = table_name
        self
    end

    def select(column_name)
        @type_of_request = :select
        @select_columns += Array(column_name).map(&:to_s)
        self
    end

    def where(column_name, criteria)
        @where_params << [column_name, criteria]
        self
    end

    def join(column_on_db_a, filename_db_b, column_on_db_b)
        validate_query_type(:select, :join)
        @join_params = { 'table' => filename_db_b, 'col_a' => column_on_db_a, 'col_b' => column_on_db_b }
        self
    end

    def order(order, column_name)
        validate_query_type(:select, :order)
        @order_params = { 'dir' => order, 'column' => column_name }
        self
    end

    def insert(table_name)
        @type_of_request = :insert
        @table_name = table_name
        self
    end

    def values(data)
        validate_query_type(:insert, :update)
        @insert_attributes = data
        self
    end

    def set(data)
        values(data)
    end

    def update(table_name)
        @type_of_request = :update
        @table_name = table_name
        self
    end

    def delete
        @type_of_request = :delete
        self
    end

    def run
        validate_query
        case @type_of_request
        when :select then run_select
        when :insert then run_insert
        when :update then run_update
        when :delete then run_delete
        end
    end

    private

    def validate_query_type(*valid_types)
        raise "Invalid query type to use #{caller_locations(1,1)[0].label}()" unless valid_types.include?(@type_of_request)
    end

    def validate_query
        raise "Invalid query" if @type_of_request == :none
        raise "Table name has not been provided" if @table_name.nil?
        raise "Table #{@table_name} doesn't exist" unless File.exist?(@table_name)

        validate_select_query if @type_of_request == :select
        validate_data_query if [:insert, :update].include?(@type_of_request)
    end

    def validate_select_query
        if @order_params && !@select_columns.include?('*') && !@select_columns.include?(@order_params['column'])
            raise "To order the result by #{@order_params['column']}, add this column to selection"
        end

        if @join_params
            raise "Joined table name has not been provided" if @join_params['table'].nil?
            raise "Joined table #{@join_params['table']} doesn't exist" unless File.exist?(@join_params['table'])
        end
    end

    def validate_data_query
        raise "No data to #{@type_of_request}" if @insert_attributes.nil?
    end

    def run_select
        data = CSV.read(@table_name, headers: true)
        result = filter_data(data)
        result = join_data(result) if @join_params
        result = order_data(result) if @order_params

        print_output(result)
    end

    def filter_data(data)
        data.select do |row|
            @where_params.all? { |col, crit| row[col] == crit }
        end.map do |row|
            @select_columns.include?('*') ? row.to_h : row.to_h.slice(*@select_columns)
        end
    end

    def join_data(result)
        join_data = CSV.read(@join_params['table'], headers: true)
        result.map do |row|
            match = join_data.find { |jr| jr[@join_params['col_b']] == row[@join_params['col_a']] }
            match ? row.to_h.merge(match.to_h.except(@join_params['col_b'])) : row
        end
    end

    def order_data(result)
        result.sort_by! { |row| row[@order_params['column']] }
        @order_params['dir'] == :desc ? result.reverse : result
    end

    def run_insert
        data = CSV.read(@table_name, headers: true)
        data << @insert_attributes
        write_csv(data)
    end

    def run_update
        data = CSV.read(@table_name, headers: true)
        data.each do |row|
            next unless @where_params.all? { |col, crit| row[col] == crit }
            @insert_attributes.each { |col, val| row[col] = val }
        end
        write_csv(data)
    end

    def run_delete
        data = CSV.read(@table_name, headers: true)
        filtered_data = data.delete_if do |row|
            @where_params.any? { |col, crit| row[col] == crit }
        end
        write_csv(filtered_data, data.headers)
    end

    def print_output(output)
        output.each { |row| puts row.values.join("|") }
    end

    def write_csv(data, headers = data.headers)
        CSV.open(@table_name, 'w', write_headers: true, headers: headers) do |csv|
            data.each { |row| csv << row }
        end
    end
end
