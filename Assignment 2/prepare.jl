using ZipFile, SQLite, CSV

if length(ARGS) === 2
    # Get the names
    zipName = ARGS[1]
    outputName = ARGS[2]

    if isfile(zipName)
        # load the zip reader and the db
        r = ZipFile.Reader(zipName)  
        db = SQLite.DB(outputName)

        # Create the BabyNames Table
        SQLite.execute(db, "CREATE TABLE IF NOT EXISTS BabyNames(
            year INTEGER,
            name TEXT,
            sex TEXT,
            num INTEGER
        )") 

        stmt = DBInterface.prepare(db, "INSERT INTO BabyNames (year, name, sex, num) VALUES(?,?,?,?);")
        # Read zip and insert info into BabyNames table
        SQLite.execute(db, "BEGIN TRANSACTION")
        for f in r.files
            year = replace(f.name, r"yob|.txt" => "")
            if occursin(r"^yob....\.txt$", f.name)
                file = CSV.File(read(f); header=["name","sex","num"])    
                for row in file
                    DBInterface.execute(stmt, [year, row.name, row.sex, row.num])
                end
            end
        end
        SQLite.execute(db, "COMMIT TRANSACTION")
        # Close the zip file, the db closes by itself
        close(r)
    else 
        println("$(zipName) does not exist.")
    end
else
    println("2 Arguments expected but $(length(ARGS)) given.")
end