module Helper
  # Hash record printer
  class Record
    def self.call(rec)
      fail ":rec must be Hash" unless rec.is_a?(Hash)
      return '' unless rec.any?
      size = rec.keys.map{|k| k.to_s.size}.max
      injf = proc{|acc, (k, v)|
        acc << "#{k.to_s.capitalize.ljust(size)} #{v}"
      }
      [].tap{|txt|
        txt << "#{?- * size} #{?- * size}"
        rec.inject(txt, &injf)
        txt << "#{?- * size} #{?- * size}"
      }.join(?\n)
    end
  end

  # Table printer column
  class Column
    attr_reader :prop, :key, :size, :just, :decor
    def initialize(prop, key:
      prop.downcase.to_sym,
      size: prop.size,
      just: :left,
      decor: proc{|v| v}
    )
      @prop, @key, @size, @just, @decor = prop, key, size, just, decor
    end
  end

  # Table printer
  #
  # @example
  #   cols = [
  #     Column.new('Date', size: 10),
  #     Column.new('Project'),
  #     Column.new('Contributor'),
  #     Column.new('Spent', size: 10, just: :right),
  #     Column.new('Rate',  size: 10, just: :right),
  #     Column.new('Total', size: 10, just: :right)
  #   ]
  #
  #   require 'date'
  #   Row = Struct.new(:date, :project, :contributor, :spent, :rate, :total)
  #   rows = [
  #     Row.new(Date.today.prev_day(2), 'Dummy', 'John', 60.0, 10.0, 600.0),
  #     Row.new(Date.today.prev_day, 'Dummy', 'Jane', 60.0, 10.0, 600.0),
  #     Row.new(Date.today, 'Dummy', 'John', 8 * 60.0, 200.0, 16000.0),
  #   ]
  #   Table.(cols, rows)
  #
  class Table
    def self.call(cols, rows)
      new(*cols).print(*rows)
    end

    def initialize(*column)
      @columns = column
    end

    def print(*row)
      [head, rows(row)].join(?\n)
    end

    def head
      colfu = proc{|acc, col|
        just = col.just == :right ? :rjust : :ljust
        acc << col.prop[0..col.size].send(just, col.size) if col.size > 0
        acc << col.prop unless col.size > 0
        acc
      }
      linfu = proc{|acc, col|
        acc << ?- * (col.size > 0 ? col.size : col.prop.size)
      }
      cols = @columns.inject([], &colfu).join(?\s)
      lins = @columns.inject([], &linfu).join(?\s)
      cols + ?\n + lins
    end

    def jstfy(val, size)
      case val
      when Integer
        "%#{size}d" % val
      when Float
        # %[flags][width][.precision]type
        "%#{size}.2f" % val
      when String
        size == 0 ? val.gsub(?\n, '<br />') : val[0..size].ljust(size)
        # val[0..size].ljust(size)
      else
        val.to_s.ljust(size)
      end
    end

    def rows(rows)
      rows.map{|o|
        @columns.map{|col|
          val = col.decor.(o.send(col.key))
          jstfy(val, col.size)
        }.join(?\s)
      }.join(?\n)
    end
  end
end
