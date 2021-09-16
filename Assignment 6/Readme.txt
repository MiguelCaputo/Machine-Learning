- If you run again the code might have different results due to randomness
- My code assumes that the Data Set is  in the same main folder as the code
- Necessary Packages:
	- CSV
	- DataFrames
	- MultivariateStats
	- Plots
	- ScikitLearn
		- fit!
		- predict 
		- CrossValidation
		- @sk_import
			- naive_bayes : GaussianNB
			- preprocessing : LabelEncoder
			- metrics : accuracy_score
- All of the necessary Packages can be downloaded inside the program, just uncomment the necessary packages at the beginning of the code.
- According to my assumptions of the instructions:
	- We need to perform PCA transformation on the 10 floating point columns on the data, also the columns were normalized before in order
	  to be fittable in the PCA model
	- We are adding the rest of the data set after the transformation, the other 16 columns would be encoded using Label Encoder if they are
	  categorical
	- We record the time for the whole PCA fitting, modeling and the whole Machine Learning model process for each iteration.
	- The column that refers to "Cancer type" is "CancerStage"
- I decided to use GaussianNB for my model because it was the one that presented the better results
- I decided to do linear plots for both of my graphs because they are easier to read and see.
	- The graphs show the difference in the results when using 1-10 columns on the PCA transformation.


