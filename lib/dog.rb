attr_accessor :name, :breed, :id
    
def initialize(name:, breed:, id: nil) #This creates a new doggo instance
    @id = id
    @name = name 
    @breed = breed
end 

def self.create_table #This creates a table and executes the code if it does not exist
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
end 

def self.drop_table #This drops the table if it exists
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs 
    SQL


    DB[:conn].execute(sql)
end 

def save #Save checks to see if theres an ID already, If there is it just updates the dog

    if self.id
        self.update
    else #Over here, it inserts the dog into the database, and sets the instance ID to what the database has
        sql = <<-SQL 
        INSERT INTO dogs(name,breed)
        VALUES (?,?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() from dogs")[0][0]
    end
    
    self #It returns the self doggo instance
end 


def self.create(name:, breed:) #This creates a new dog and also saves them
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
end 

def self.new_from_db(row) #This creates a new dog instance from the database
    id = row[0]
    name = row[1]
    breed = row[2]

    self.new(id: id, name: name, breed: breed)
end 

def self.find_by_id(id) #This finds the ID of a certain dog and returns it as an array

    sql = <<-SQL
    SELECT * FROM dogs
    WHERE id = ?
    SQL

#What this code does is that it executes the SQL query and returns an array with a dog instance that has the detail
    DB[:conn].execute(sql, id).map do |row|
        self.new_from_db(row)
    end.first #We need first because it returns an array, we want the first instance in the array.
end #We then create dog instances from ALL the rows found and then return the first dog instance


def self.find_by_name(name)

    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ?
    SQL

    DB[:conn].execute(sql, name).map do |row| 
        self.new_from_db(row)
    end.first #Same as above.
end 


def self.find_or_create_by(name:, breed:)
#This selects all the dogs that match the name and breed
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ? 
    AND breed = ?
    LIMIT 1
    SQL
#This stores that dog data from the SQL into an array
    doggo = DB[:conn].execute(sql, name, breed)
#This checks to see if its empty, if it isn't it makes the instance for our Ruby class
    if !doggo.empty?
        dog_data = doggo[0]
        doggo = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
      else #If it is empty, we'll create a new dog instance and save it to the DB too 
        doggo = self.create(name: name, breed: breed)
      end
      doggo
end 

def update
    sql = <<-SQL
    UPDATE dogs
     SET name = ?, 
     breed = ?  
     WHERE id = ?
     SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
end
#This looks for the dog in the DB and executes the update.

 