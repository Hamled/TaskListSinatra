require "sqlite3"

module TaskList
  Task = Struct.new(:id, :name, :description, :completed) do
    def self.create_from_row(row)
      return Task.new(row[0], row[1], row[2],
                      row[3].nil? ? nil : Time.parse(row[3]))
    end
  end

  class Database
    def initialize(name)
      @db = SQLite3::Database.new(db_name(name))
    end

    def db_name(name)
      return "./db/#{name}"
    end

    def create_schema
      @db.execute('
        CREATE TABLE tasks(
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT,
          completed TEXT
        );
      ')
    end

    def find_all_tasks
      (@db.execute('SELECT * FROM tasks;')).map do |row|
        Task.create_from_row(row)
      end
    end

    def create_task(task)
      @db.execute('
          INSERT INTO tasks (name, description, completed)
          VALUES (?, ?, NULL);
      ', task.name, task.description)
    end

    def find_task(task_id)
      row = @db.execute('SELECT * FROM tasks WHERE id = ?;', task_id).first
      return Task.create_from_row(row)
    end

    def complete_task(task)
      @db.execute('
          UPDATE tasks SET completed = ? WHERE id = ?;
      ', Time.now.iso8601, task.id)
    end

    def delete_task(task)
      @db.execute('
          DELETE FROM tasks WHERE id = ?;
      ', task.id)
    end
  end
end
