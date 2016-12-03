require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = params.keys.map { |k| "#{k} = ?"}.join(" AND ")
    data = DBConnection.instance.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where_line}
    SQL

    return [] if data.empty?
    data.map { |datum| self.new(datum) }
  end
end

class SQLObject
  extend Searchable
end
