Necessary Packages:
● PyCall
● CSV
● DataFrames
● ScikitLearn
● MLJ (Only if running the KddFullModel() function)
All of the necessary Packages can be downloaded inside the program, just uncomment the necessary
packages at the beginning of the code.

I created a function that would run the Kddcup Full Data Set but it takes a lot of time to run, as
commented at the end of the code, just run if there is extra time to spare.

My code assumes that the Data Sets are in the same main folder as the code, inside another folder
called “Datasets” each dataset being inside a folder with its respective name: “Car”, “Abalone”,
“Madelon” and “Kddcup”
For example, Car Dataset files are in "Datasets/Car” (Im leaving the empty folders on the zip file)

My code was run using seed: 100 when splitting the data, the seed is not necessary and can be
erased but I used it to get consistent values.