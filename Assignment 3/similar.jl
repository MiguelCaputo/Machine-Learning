# import Pkg; Pkg.add("DataStructures"); Pkg.add("LinearAlgebra")
using DataFrames, SQLite, LinearAlgebra, DataStructures

# Load the DB
db = SQLite.DB("names.db") 

# Load the DB Table into a DataFrame
df = DBInterface.execute(db, "SELECT * FROM BabyNames") |> DataFrame

# Get the total number ot all unique names for boys, girls and also all the years
Nb = combine(groupby(df, :sex), :name => length ∘ unique)[!,2][2]
Ng = combine(groupby(df, :sex), :name => length ∘ unique)[!,2][1]
Ny = combine(groupby(df, :sex), :year => length ∘ unique)[!,2][2]

# Dataframe with all the unique names for boys and girls
gn = unique(df[df[!,:sex] .== "F", :], :name)
bn = unique(df[df[!,:sex] .== "M", :], :name)

# Create a dictionary for boys and girls with all unique names and indexes
girls = Dict{String,Int32}()
boys = Dict{String,Int32}()
for i = 1:size(gn, 1)
    if i <= size(bn, 1)
        boys[bn[i,:name]] = i
    end
    girls[gn[i,:name]] = i
end

# Invert the dictionaries
invgirls = Dict(value => key for (key, value) in girls)
invboys =  Dict(value => key for (key, value) in boys)

# Merge both dictionaries
girls = merge(girls, invgirls)
boys = merge(boys, invboys)

# Populate two matrices with the total count of boys and girls for every year
Fb = zeros(Int32, Nb, Ny)
Fg = zeros(Int32, Ng, Ny)

for i = 1:size(df, 1)
    if df[i,:sex] == "M"
        name = df[i,:name]
        year = df[i,:year] - 1879
        count = df[i,:num]
        if name in keys(boys)
            Fb[boys[name],year] = count
        end    
    elseif df[i,:sex] == "F"
        name = df[i,:name]
        year = df[i,:year] - 1879
        count = df[i,:num]
        if name in keys(girls)
            Fg[girls[name],year] = count
        end
    end
end

# Total number of names for each year 
totNames = combine(groupby(df, :year), :num .=> sum)
Ty = replace(totNames[!,:num_sum], missing => NaN)

# Populate two matrices with the frequence for each name
Pb = zeros(Float32, Nb, Ny)
Pg = zeros(Float32, Ng, Ny)

for i = 1:Ny
    Pb[:,i] = Fb[:,i] / Ty[i]
    Pg[:,i] = Fg[:,i] / Ty[i]
end

# Normalize the two matrices
Qb = zeros(Float32, Nb, Ny)
Qg = zeros(Float32, Ng, Ny)

for i = 1:Ng
    if i <= Nb
        Qb[i,:] = normalize(Pb[i,:])
    end
    Qg[i,:] = normalize(Pg[i,:])
end

# Dot product, max and top k process
global max = 0.0
global topindex = []
global partb = Nb ÷ 10
global partg = Ng ÷ 10
global girl = 0
global boy = 0
for i = 1:partb:Nb
    x = i + partb
    if x + partb > Nb 
        x = Nb
    end
    # partition the boy matrix
    A = (@view Qb[i:x,:])
    # using threads for this loop
    Threads.@threads for j = 1:partg:Ng
        y = j + partg

        if y + partg > Ng 
            y = Ng
        end
        # dot product the partitioned boy matrix with the partitiones girl matrix
        C = A * (@view Qg[j:y,:])'
        # find the indexes for the top 1000 values in the partition
        b = partialsortperm(vec(C), 1:1000, rev=true)
        # Save the top 1000 values, boy index and girl index in a new array where the indexes correspond to the parent matrix 
        collection = collect(zip(C[b], (b .% size(C)[1]) .- 1 .+ i, (b .÷ size(C)[1]) .+ j))
        # Push the array into a list
        global topindex = push!(topindex, collection)
        
        # Find the max value on the dot product matrix
        newmax = collection[1]
        # Save the value and indexes if all time max
        if max < newmax[1]
            global max = newmax[1]
            global girl = newmax[3]
            global boy = newmax[2]
        end

        if y == Ng
            break
        end

    end

    if x == Nb
        break
    end

end

println("----------------------------------------------------------------------------------")
println("Max Pair:")
println("The pair (Boy = \"$(boys[boy])\" index = $boy and Girl = \"$(girls[girl])\" index = $girl) have the greatest cosine distance with a value of \"$max\".")
println("----------------------------------------------------------------------------------")
println("Finding Top 1000")

# Save top 1000 values in a heap
h = BinaryHeap{Tuple{Float32,Int64,Int64},DataStructures.FasterForward}()
print()
for i = 1:size(topindex)[1]
    for j = 1:size(topindex[i])[1]
        if length(h) < 1000
            push!(h, topindex[i][j])
        else
            if first(h)[1] < topindex[i][j][1]
                pop!(h)
                push!(h, topindex[i][j])
            end
        end
    end
end
println("----------------------------------------------------------------------------------")
println("Top 100 Pairs:")
# Print top 1000 values with names and indexes.
names = extract_all_rev!(h)
for i = 1:size(names)[1]
    println("$i) Boy = $(boys[names[i][2]]) index = $(names[i][2]) and Girl = $(girls[names[i][3]]) index = $(names[i][3]), Distance = $(names[i][1])")
end
