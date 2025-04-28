### A Pluto.jl notebook ###
# v0.19.47

using Markdown
using InteractiveUtils

# ╔═╡ 1a09080b-f42c-40e8-a0e7-30144d703b61
using Pkg

# ╔═╡ a638f715-8ec3-4be9-b184-e6a0b9f0b913
Pkg.add(url="https://github.com/JuliaTelecom/Rifyfi.jl")

# ╔═╡ 755ebedb-6f8e-4147-abe8-0ab607106171
using RiFyFi

# ╔═╡ 04317443-7b56-481c-bf46-1459ce8d2c03
using RiFyFi.RiFyFi_IdF

# ╔═╡ 27adbf29-7b5a-4e39-9e87-43eee4088b59
using RiFyFi.RiFyFi_VDG

# ╔═╡ 1af782b1-41d9-43e6-bb89-66dee1dc3145
begin
	name = "10_pourcent"
	nameModel = name
	nbTx = 5            # Number of transmitters
	nbSignals = 2000   # number of signals per transmitters
	Chunksize = 256     # number of IQ samples per signals
	features= "IQsamples"
	S = "S1"            # Use S1 for modelling a Preamble mode, S2 for MAC address and S3 for payload mode
	E = "E3"            # Use E3 for adding fingerprint 
	C = "C2"       # Use C1 for perfect SNR, C2_0dB - C2_30dB to add Gaussian noise
	RFF = "all_impairments"     # Use all_impairments to modeled the complete chaine, or use PA to model only the Power Amplifier, PN for Phase Noise, imbalance for IQ imbalance or cfo for carrier frequency offset.
	Normalisation = true        # Use true to normalize the database 
	pourcentTrain =0.9          # 90 % for train and 10% for test 
	configuration  = "scenario" # Use nothing to create random scenario, or use "scenario" to load a pre create scenario 
	seed_data = 1235
	seed_model = 2343
	if E == "E1" || E == "E2"
	    seed_modelTest = seed_model 
	else 
	    seed_modelTest = 1598765432 * 100000000
	end 
	if S == "S1" || S == "S2"
	    seed_dataTest = seed_data 
	else 
	    seed_dataTest = 999924691 * 100000000
	end 
	
end

# ╔═╡ 62349cd9-2ece-4e06-895e-5ddadcf6f1c1
begin
	
	########### Args Network struct ###########
	η = 1e-5           # learning rate e-5
	dr = 0.25
	batchsize = 64     # batch size
	epochs = 1000    # number of epochs
	use_cuda = true     # if true use cuda (if available)
	
end

# ╔═╡ 6fd4408f-679b-471c-ac72-b705b231c6b0
begin
		
	########### Network struct ###########
	Networkname = "AlexNet"
	NbClass = nbTx
	#Chunksize = 256
	NbSignals = nbSignals
	#Seed_Network = 14
	Train_args = RiFyFi_IdF.Args(η = η ,dr=dr, epochs= epochs,batchsize=batchsize,use_cuda=use_cuda)
	#savepathbson=""
		
	
end

# ╔═╡ 5d48e305-1e45-4ffa-973a-c52ed0e76623
begin
	augmentationType = "augment"
	Channel = "etu"
	Channel_Test = "etu"
	nb_Augment = 10
	#seed_channel = 12
	#seed_channel_test = 12
	#burstSize =64
	
	Augmentation_Value = RiFyFi_VDG.Data_Augmented(;augmentationType,Channel,Channel_Test,nb_Augment)
	
	Seed_Network = 1234

	Param_Data = RiFyFi_VDG.Data_Synth(name,nameModel,nbTx, NbSignals, Chunksize,features,S,E,C,RFF,Normalisation,pourcentTrain,configuration,seed_data,seed_model,seed_dataTest,seed_modelTest,Augmentation_Value)

# Train and test Datasets are created and saved in CSV files
RiFyFi_VDG.setSynthetiquecsv(Param_Data)

# Creation of the Network structure with the information of the network
Param_Network = RiFyFi_IdF.Network_struct(;Networkname,NbClass,Chunksize,NbSignals,Seed_Network,Train_args) 

# Train the network and save it 
RiFyFi.main(Param_Data,Param_Network)   

# Create a figure to show the evolution of the F1-score during the training 
Results.main(Param_Data,Param_Network,"F1_score",savepathbson,Param_Data,[Seed_Network])

	
if Param_Network.Train_args.use_cuda == true 
    hardware1 = "GPU"
else 
    hardware1 ="CPU"
end 

savepathbson = "run/Synth/$(Param_Data.Augmentation_Value.augmentationType)_$(Param_Data.nbTx)_$(Param_Data.Chunksize)_$(Param_Network.Networkname)/$(Param_Data.E)_$(Param_Data.S)/$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.nameModel)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)/$(hardware1)"
    
savename ="$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.name)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)"
Scenario ="$(savepathbson)/F1_Score_$(hardware1)_seed_$(Param_Network.Seed_Network)_dr$(Param_Network.Train_args.dr).csv"
delim=';'
nameBase = split(Scenario,".")[1]


matrice_5 = Matrix(DataFrame(CSV.File(Scenario;delim,types=Float64,header=false)))
Score_pourcent=zeros(4,3)
Score_pourcent[1,1] = matrice_5[end,3] 


nb_Augment = 50

Augmentation_Value = RiFyFi_VDG.Data_Augmented(;augmentationType,Channel,Channel_Test,nb_Augment)

# Creation of the data structure with the information of the dataset
Param_Data = RiFyFi_VDG.Data_Synth(name,nameModel,nbTx, NbSignals, Chunksize,features,S,E,C,RFF,Normalisation,pourcentTrain,configuration,seed_data,seed_model,seed_dataTest,seed_modelTest,Augmentation_Value)
# Train and test Datasets are created and saved in CSV files
RiFyFi_VDG.setSynthetiquecsv(Param_Data)

# Creation of the Network structure with the information of the network
Param_Network = RiFyFi_IdF.Network_struct(;Networkname,NbClass,Chunksize,NbSignals,Seed_Network,Train_args) 

# Train the network and save it 
RiFyFi.main(Param_Data,Param_Network)   

# Create a figure to show the evolution of the F1-score during the training 
Results.main(Param_Data,Param_Network,"F1_score",savepathbson,Param_Data,[Seed_Network])


savepathbson = "run/Synth/$(Param_Data.Augmentation_Value.augmentationType)_$(Param_Data.nbTx)_$(Param_Data.Chunksize)_$(Param_Network.Networkname)/$(Param_Data.E)_$(Param_Data.S)/$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.nameModel)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)/$(hardware1)"
    
savename ="$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.name)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)"
Scenario ="$(savepathbson)/F1_Score_$(hardware1)_seed_$(Param_Network.Seed_Network)_dr$(Param_Network.Train_args.dr).csv"
delim=';'
nameBase = split(Scenario,".")[1]
#  ----------------------------------------------------
# --- Loading the matrix 
# ----------------------------------------------------- 
matrice_5 = Matrix(DataFrame(CSV.File(Scenario;delim,types=Float64,header=false)))
Score_pourcent[2,1] = matrice_5[end,3] 

	
	
end

# ╔═╡ Cell order:
# ╠═1a09080b-f42c-40e8-a0e7-30144d703b61
# ╠═a638f715-8ec3-4be9-b184-e6a0b9f0b913
# ╠═755ebedb-6f8e-4147-abe8-0ab607106171
# ╠═04317443-7b56-481c-bf46-1459ce8d2c03
# ╠═27adbf29-7b5a-4e39-9e87-43eee4088b59
# ╠═1af782b1-41d9-43e6-bb89-66dee1dc3145
# ╠═62349cd9-2ece-4e06-895e-5ddadcf6f1c1
# ╠═6fd4408f-679b-471c-ac72-b705b231c6b0
# ╠═5d48e305-1e45-4ffa-973a-c52ed0e76623
