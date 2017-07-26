class Dog
	attr_accessor :id, :name, :breed

	def initialize(id: nil, name:, breed:)
		@id = id
		@name = name
		@breed = breed
	end

	def self.create_table
		create_sql = <<-SQL 
			CREATE TABLE IF NOT EXISTS dogs(
				id INTEGER PRIMARY KEY,
				name TEXT,
				breed TEXT
			)
		SQL
		DB[:conn].execute(create_sql)
	end

	def self.drop_table
		drop_sql = <<-SQL 
			DROP TABLE dogs 
		SQL
		DB[:conn].execute(drop_sql)
	end

	def save
		save_sql = <<-SQL 
			INSERT INTO dogs (
			name, breed) VALUES (?, ?) 
		SQL
		DB[:conn].execute(save_sql, self.name, 
			self.breed)
		@id = DB[:conn].execute("SELECT last_insert_rowid()
			FROM dogs").flatten.first
		self
	end

	def self.new_from_db(row)
		Dog.new(id: row[0], name: row[1], breed: row[2])
	end

	def self.create(name:, breed:)
		dog_obj = Dog.new(name: name, breed: breed)
		dog_obj.save
		dog_obj
	end

	def self.find_by_name(name)
		find_name_sql = <<-SQL 
			SELECT * FROM dogs WHERE name = ?
		SQL
		find_name = DB[:conn].execute(find_name_sql, name)
		find_name.map {|row| self.new_from_db(row)}.first
	end

	def self.find_by_id(id)
		find_id_sql = <<-SQL 
			SELECT * FROM dogs WHERE id = ?
		SQL
		find_id = DB[:conn].execute(find_id_sql, id)
		find_id.map {|row| self.new_from_db(row)}.first
	end

	def update 
		DB[:conn].execute("UPDATE dogs SET name = ?, 
			BREED = ? WHERE id = ?", 
			self.name, self.breed, self.id)
	end

	def self.find_or_create_by(name:, breed:)
		dogs_arr = DB[:conn].execute("SELECT * FROM dogs where 
			name = ? AND breed = ?", name, breed)
		!dogs_arr.empty? ? new_dog = Dog.new(id: dogs_arr[0][0], name: dogs_arr[0][1], 
			breed: dogs_arr[0][2]) : new_dog = self.create(name: name, breed: breed)
		new_dog
	end


end


