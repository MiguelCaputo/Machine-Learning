using SQLite, Gadfly, DataFrames

if length(ARGS) === 3
    # Get the values
    dbName = ARGS[1]
    name = ARGS[2]
    sex = ARGS[3]

    if isfile(dbName)
        # Load DB
        db = SQLite.DB(dbName)

        # Put the query info into a DataFrame
        df = DBInterface.execute(db, 
        "SELECT BN.year, BN.num, (BN.num * 1.0 / totBabys) * 100 AS math
        FROM 
            (SELECT year, num, SUM(num) AS totBabys
            FROM BabyNames
            GROUP BY year) as TB, BabyNames as BN
        WHERE name = \'$(name)\' COLLATE NOCASE AND sex = \'$(sex)\' COLLATE NOCASE AND TB.year = BN.year
        ORDER BY BN.year") |> DataFrame

        if nrow(df) !== 0 
            # Plot the dataframe
            Gadfly.push_theme(:dark)
            p1 = plot(df, x=:year, y=:num, Guide.xlabel("Year"), Guide.ylabel("Number"),
                Guide.title("Population Number For \"$(name)\" $(sex)"), Geom.point,  Geom.line,
                Scale.x_continuous(format=:plain), Scale.y_continuous(format=:plain))

            p2 = plot(df, x=:year, y=:math, Guide.xlabel("Year"), Guide.ylabel("% of Frequency"),
                Guide.title("Population Frequency For \"$(name)\" $(sex)"), Geom.point,  Geom.line,
                Scale.x_continuous(format=:plain), Scale.y_continuous(format=:plain))

            p = Gadfly.hstack(p1, p2)
          
            draw(SVG("plot.svg", 20cm, 10cm), p)
        else
            println("No result returned for name = \'$(name)\' and sex = \'$(sex)\'")
        end
    else 
        println("$(dbName) does not exist")
    end
else 
    println("3 Arguments expected $(length(ARGS)) given.")
end