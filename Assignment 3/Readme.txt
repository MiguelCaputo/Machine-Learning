~ Required Packages: All packages can be download as Pkg.add("packageName")
    - similar.jl:
        - DataFrames
        - SQLite
        - LinearAlgebra
	- DataStructures

~ How to run the program: 
	- Use the command: julia similar.jl (Not using threads)
	- Use the command: julia --threads X similar.jl (Using threads)
		- X being a number aka the number of threads you want to use.

~ The program is using Float32 precision.
~ The max distance found is 1.0000002 and it's found for multiple couples.
~ The program displays the first couple that contains that value.
~ Then the program displays the top 1000 couples with their names, indexes, and values
~ At the beginning of the code, there is an example of how to add the packages in the program if some packages are missing.
~ The DB is also being zipped here.