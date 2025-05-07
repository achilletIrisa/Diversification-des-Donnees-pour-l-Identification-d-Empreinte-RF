using Pkg
Pkg.add(url="https://github.com/JuliaTelecom/Rifyfi.jl")
using RiFyFi
using RiFyFi.RiFyFi_IdF
using RiFyFi.RiFyFi_VDG

using ColorSchemes
using PGFPlotsX

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
	seed_data = 1234
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

    ########### Args Network struct ###########
	η = 1e-5           # learning rate e-5
	dr = 0.25
	batchsize = 64     # batch size
	epochs = 1000    # number of epochs
	use_cuda = true     # if true use cuda (if available)


    ########### Network struct ###########
	Networkname = "AlexNet"
	NbClass = nbTx
	#Chunksize = 256
	NbSignals = nbSignals
	Seed_Network = 1234
	Train_args = RiFyFi_IdF.Args(η = η ,dr=dr, epochs= epochs,batchsize=batchsize,use_cuda=use_cuda)



    Score_pourcent=zeros(5,4)
    Score_pourcent[:,1] = [10,20,50,100,150]

	########### Augmentation struct (channel) ###########
	augmentationType = "augment"
	Channel = "etu"
	Channel_Test = "etu"


###### Génération des données, entrainement et réccupération de la valeur finale de test #####    

nb_Augment = 10
Augmentation_Value = RiFyFi_VDG.Data_Augmented(;augmentationType,Channel,Channel_Test,nb_Augment)
Param_Data = RiFyFi_VDG.Data_Synth(name,nameModel,nbTx, NbSignals, Chunksize,features,S,E,C,RFF,Normalisation,pourcentTrain,configuration,seed_data,seed_model,seed_dataTest,seed_modelTest,Augmentation_Value)

# Train and test Datasets are created and saved in CSV files
RiFyFi_VDG.setSynthetiquecsv(Param_Data)

# Creation of the Network structure with the information of the network
Param_Network = RiFyFi_IdF.Network_struct(;Networkname,NbClass,Chunksize,NbSignals,Seed_Network,Train_args) 

# Train the network and save it 
RiFyFi.main(Param_Data,Param_Network)   

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

Score_pourcent[1,2] = matrice_5[end,3] 


nb_Augment = 20

Augmentation_Value = RiFyFi_VDG.Data_Augmented(;augmentationType,Channel,Channel_Test,nb_Augment)

# Creation of the data structure with the information of the dataset
Param_Data = RiFyFi_VDG.Data_Synth(name,nameModel,nbTx, NbSignals, Chunksize,features,S,E,C,RFF,Normalisation,pourcentTrain,configuration,seed_data,seed_model,seed_dataTest,seed_modelTest,Augmentation_Value)
# Train and test Datasets are created and saved in CSV files
RiFyFi_VDG.setSynthetiquecsv(Param_Data)

# Creation of the Network structure with the information of the network
Param_Network = RiFyFi_IdF.Network_struct(;Networkname,NbClass,Chunksize,NbSignals,Seed_Network,Train_args) 

# Train the network and save it 
RiFyFi.main(Param_Data,Param_Network)   


savepathbson = "run/Synth/$(Param_Data.Augmentation_Value.augmentationType)_$(Param_Data.nbTx)_$(Param_Data.Chunksize)_$(Param_Network.Networkname)/$(Param_Data.E)_$(Param_Data.S)/$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.nameModel)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)/$(hardware1)"
    
savename ="$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.name)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)"
Scenario ="$(savepathbson)/F1_Score_$(hardware1)_seed_$(Param_Network.Seed_Network)_dr$(Param_Network.Train_args.dr).csv"
delim=';'
nameBase = split(Scenario,".")[1]

matrice_5 = Matrix(DataFrame(CSV.File(Scenario;delim,types=Float64,header=false)))
Score_pourcent[2,1] = matrice_5[end,3] 




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


savepathbson = "run/Synth/$(Param_Data.Augmentation_Value.augmentationType)_$(Param_Data.nbTx)_$(Param_Data.Chunksize)_$(Param_Network.Networkname)/$(Param_Data.E)_$(Param_Data.S)/$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.nameModel)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)/$(hardware1)"
    
savename ="$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.name)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)"
Scenario ="$(savepathbson)/F1_Score_$(hardware1)_seed_$(Param_Network.Seed_Network)_dr$(Param_Network.Train_args.dr).csv"
delim=';'
nameBase = split(Scenario,".")[1]

matrice_5 = Matrix(DataFrame(CSV.File(Scenario;delim,types=Float64,header=false)))
Score_pourcent[3,1] = matrice_5[end,3] 




nb_Augment = 100

Augmentation_Value = RiFyFi_VDG.Data_Augmented(;augmentationType,Channel,Channel_Test,nb_Augment)

# Creation of the data structure with the information of the dataset
Param_Data = RiFyFi_VDG.Data_Synth(name,nameModel,nbTx, NbSignals, Chunksize,features,S,E,C,RFF,Normalisation,pourcentTrain,configuration,seed_data,seed_model,seed_dataTest,seed_modelTest,Augmentation_Value)
# Train and test Datasets are created and saved in CSV files
RiFyFi_VDG.setSynthetiquecsv(Param_Data)

# Creation of the Network structure with the information of the network
Param_Network = RiFyFi_IdF.Network_struct(;Networkname,NbClass,Chunksize,NbSignals,Seed_Network,Train_args) 

# Train the network and save it 
RiFyFi.main(Param_Data,Param_Network)   


savepathbson = "run/Synth/$(Param_Data.Augmentation_Value.augmentationType)_$(Param_Data.nbTx)_$(Param_Data.Chunksize)_$(Param_Network.Networkname)/$(Param_Data.E)_$(Param_Data.S)/$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.nameModel)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)/$(hardware1)"
    
savename ="$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.name)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)"
Scenario ="$(savepathbson)/F1_Score_$(hardware1)_seed_$(Param_Network.Seed_Network)_dr$(Param_Network.Train_args.dr).csv"
delim=';'
nameBase = split(Scenario,".")[1]
#  ----------------------------------------------------
# --- Loading the matrix 
# ----------------------------------------------------- 
matrice_5 = Matrix(DataFrame(CSV.File(Scenario;delim,types=Float64,header=false)))
Score_pourcent[4,1] = matrice_5[end,3] 




nb_Augment = 150

Augmentation_Value = RiFyFi_VDG.Data_Augmented(;augmentationType,Channel,Channel_Test,nb_Augment)

# Creation of the data structure with the information of the dataset
Param_Data = RiFyFi_VDG.Data_Synth(name,nameModel,nbTx, NbSignals, Chunksize,features,S,E,C,RFF,Normalisation,pourcentTrain,configuration,seed_data,seed_model,seed_dataTest,seed_modelTest,Augmentation_Value)
# Train and test Datasets are created and saved in CSV files
RiFyFi_VDG.setSynthetiquecsv(Param_Data)

# Creation of the Network structure with the information of the network
Param_Network = RiFyFi_IdF.Network_struct(;Networkname,NbClass,Chunksize,NbSignals,Seed_Network,Train_args) 

# Train the network and save it 
RiFyFi.main(Param_Data,Param_Network)   

savepathbson = "run/Synth/$(Param_Data.Augmentation_Value.augmentationType)_$(Param_Data.nbTx)_$(Param_Data.Chunksize)_$(Param_Network.Networkname)/$(Param_Data.E)_$(Param_Data.S)/$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.nameModel)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)/$(hardware1)"
    
savename ="$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.name)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)"
Scenario ="$(savepathbson)/F1_Score_$(hardware1)_seed_$(Param_Network.Seed_Network)_dr$(Param_Network.Train_args.dr).csv"
delim=';'
nameBase = split(Scenario,".")[1]

matrice_5 = Matrix(DataFrame(CSV.File(Scenario;delim,types=Float64,header=false)))
Score_pourcent[5,1] = matrice_5[end,3] 



############################################################################################################################################
############################################################################################################################################

name = "7_pourcent"

nb_Augment = 10

# Train and test Datasets are created and saved in CSV files
RiFyFi_VDG.setSynthetiquecsv(Param_Data)

# Creation of the Network structure with the information of the network
Param_Network = RiFyFi_IdF.Network_struct(;Networkname,NbClass,Chunksize,NbSignals,Seed_Network,Train_args) 

# Train the network and save it 
RiFyFi.main(Param_Data,Param_Network)   

savepathbson = "run/Synth/$(Param_Data.Augmentation_Value.augmentationType)_$(Param_Data.nbTx)_$(Param_Data.Chunksize)_$(Param_Network.Networkname)/$(Param_Data.E)_$(Param_Data.S)/$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.nameModel)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)/$(hardware1)"
    
savename ="$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.name)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)"
Scenario ="$(savepathbson)/F1_Score_$(hardware1)_seed_$(Param_Network.Seed_Network)_dr$(Param_Network.Train_args.dr).csv"
delim=';'
nameBase = split(Scenario,".")[1]


matrice_5 = Matrix(DataFrame(CSV.File(Scenario;delim,types=Float64,header=false)))

Score_pourcent[1,3] = matrice_5[end,3] 




nb_Augment = 20

Augmentation_Value = RiFyFi_VDG.Data_Augmented(;augmentationType,Channel,Channel_Test,nb_Augment)

# Creation of the data structure with the information of the dataset
Param_Data = RiFyFi_VDG.Data_Synth(name,nameModel,nbTx, NbSignals, Chunksize,features,S,E,C,RFF,Normalisation,pourcentTrain,configuration,seed_data,seed_model,seed_dataTest,seed_modelTest,Augmentation_Value)
# Train and test Datasets are created and saved in CSV files
RiFyFi_VDG.setSynthetiquecsv(Param_Data)

# Creation of the Network structure with the information of the network
Param_Network = RiFyFi_IdF.Network_struct(;Networkname,NbClass,Chunksize,NbSignals,Seed_Network,Train_args) 

# Train the network and save it 
RiFyFi.main(Param_Data,Param_Network)   


savepathbson = "run/Synth/$(Param_Data.Augmentation_Value.augmentationType)_$(Param_Data.nbTx)_$(Param_Data.Chunksize)_$(Param_Network.Networkname)/$(Param_Data.E)_$(Param_Data.S)/$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.nameModel)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)/$(hardware1)"
    
savename ="$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.name)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)"
Scenario ="$(savepathbson)/F1_Score_$(hardware1)_seed_$(Param_Network.Seed_Network)_dr$(Param_Network.Train_args.dr).csv"
delim=';'
nameBase = split(Scenario,".")[1]
#  ----------------------------------------------------
# --- Loading the matrix 
# ----------------------------------------------------- 
matrice_5 = Matrix(DataFrame(CSV.File(Scenario;delim,types=Float64,header=false)))
Score_pourcent[2,3] = matrice_5[end,3] 



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


savepathbson = "run/Synth/$(Param_Data.Augmentation_Value.augmentationType)_$(Param_Data.nbTx)_$(Param_Data.Chunksize)_$(Param_Network.Networkname)/$(Param_Data.E)_$(Param_Data.S)/$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.nameModel)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)/$(hardware1)"
    
savename ="$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.name)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)"
Scenario ="$(savepathbson)/F1_Score_$(hardware1)_seed_$(Param_Network.Seed_Network)_dr$(Param_Network.Train_args.dr).csv"
delim=';'
nameBase = split(Scenario,".")[1]

matrice_5 = Matrix(DataFrame(CSV.File(Scenario;delim,types=Float64,header=false)))
Score_pourcent[3,3] = matrice_5[end,3] 



nb_Augment = 100

Augmentation_Value = RiFyFi_VDG.Data_Augmented(;augmentationType,Channel,Channel_Test,nb_Augment)

# Creation of the data structure with the information of the dataset
Param_Data = RiFyFi_VDG.Data_Synth(name,nameModel,nbTx, NbSignals, Chunksize,features,S,E,C,RFF,Normalisation,pourcentTrain,configuration,seed_data,seed_model,seed_dataTest,seed_modelTest,Augmentation_Value)
# Train and test Datasets are created and saved in CSV files
RiFyFi_VDG.setSynthetiquecsv(Param_Data)

# Creation of the Network structure with the information of the network
Param_Network = RiFyFi_IdF.Network_struct(;Networkname,NbClass,Chunksize,NbSignals,Seed_Network,Train_args) 

# Train the network and save it 
RiFyFi.main(Param_Data,Param_Network)   


savepathbson = "run/Synth/$(Param_Data.Augmentation_Value.augmentationType)_$(Param_Data.nbTx)_$(Param_Data.Chunksize)_$(Param_Network.Networkname)/$(Param_Data.E)_$(Param_Data.S)/$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.nameModel)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)/$(hardware1)"
    
savename ="$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.name)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)"
Scenario ="$(savepathbson)/F1_Score_$(hardware1)_seed_$(Param_Network.Seed_Network)_dr$(Param_Network.Train_args.dr).csv"
delim=';'
nameBase = split(Scenario,".")[1]

matrice_5 = Matrix(DataFrame(CSV.File(Scenario;delim,types=Float64,header=false)))
Score_pourcent[4,3] = matrice_5[end,3] 




nb_Augment = 150

Augmentation_Value = RiFyFi_VDG.Data_Augmented(;augmentationType,Channel,Channel_Test,nb_Augment)

# Creation of the data structure with the information of the dataset
Param_Data = RiFyFi_VDG.Data_Synth(name,nameModel,nbTx, NbSignals, Chunksize,features,S,E,C,RFF,Normalisation,pourcentTrain,configuration,seed_data,seed_model,seed_dataTest,seed_modelTest,Augmentation_Value)
# Train and test Datasets are created and saved in CSV files
RiFyFi_VDG.setSynthetiquecsv(Param_Data)

# Creation of the Network structure with the information of the network
Param_Network = RiFyFi_IdF.Network_struct(;Networkname,NbClass,Chunksize,NbSignals,Seed_Network,Train_args) 

# Train the network and save it 
RiFyFi.main(Param_Data,Param_Network)   


savepathbson = "run/Synth/$(Param_Data.Augmentation_Value.augmentationType)_$(Param_Data.nbTx)_$(Param_Data.Chunksize)_$(Param_Network.Networkname)/$(Param_Data.E)_$(Param_Data.S)/$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.nameModel)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)/$(hardware1)"
    
savename ="$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.name)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)"
Scenario ="$(savepathbson)/F1_Score_$(hardware1)_seed_$(Param_Network.Seed_Network)_dr$(Param_Network.Train_args.dr).csv"
delim=';'
nameBase = split(Scenario,".")[1]

matrice_5 = Matrix(DataFrame(CSV.File(Scenario;delim,types=Float64,header=false)))
Score_pourcent[5,3] = matrice_5[end,3]


############################################################################################################################################
############################################################################################################################################


name = "5_pourcent"

nb_Augment = 10

# Train and test Datasets are created and saved in CSV files
RiFyFi_VDG.setSynthetiquecsv(Param_Data)

# Creation of the Network structure with the information of the network
Param_Network = RiFyFi_IdF.Network_struct(;Networkname,NbClass,Chunksize,NbSignals,Seed_Network,Train_args) 

# Train the network and save it 
RiFyFi.main(Param_Data,Param_Network)   


savepathbson = "run/Synth/$(Param_Data.Augmentation_Value.augmentationType)_$(Param_Data.nbTx)_$(Param_Data.Chunksize)_$(Param_Network.Networkname)/$(Param_Data.E)_$(Param_Data.S)/$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.nameModel)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)/$(hardware1)"
    
savename ="$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.name)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)"
Scenario ="$(savepathbson)/F1_Score_$(hardware1)_seed_$(Param_Network.Seed_Network)_dr$(Param_Network.Train_args.dr).csv"
delim=';'
nameBase = split(Scenario,".")[1]


matrice_5 = Matrix(DataFrame(CSV.File(Scenario;delim,types=Float64,header=false)))

Score_pourcent[1,4] = matrice_5[end,3] 



nb_Augment = 20

Augmentation_Value = RiFyFi_VDG.Data_Augmented(;augmentationType,Channel,Channel_Test,nb_Augment)

# Creation of the data structure with the information of the dataset
Param_Data = RiFyFi_VDG.Data_Synth(name,nameModel,nbTx, NbSignals, Chunksize,features,S,E,C,RFF,Normalisation,pourcentTrain,configuration,seed_data,seed_model,seed_dataTest,seed_modelTest,Augmentation_Value)
# Train and test Datasets are created and saved in CSV files
RiFyFi_VDG.setSynthetiquecsv(Param_Data)

# Creation of the Network structure with the information of the network
Param_Network = RiFyFi_IdF.Network_struct(;Networkname,NbClass,Chunksize,NbSignals,Seed_Network,Train_args) 

# Train the network and save it 
RiFyFi.main(Param_Data,Param_Network)   


savepathbson = "run/Synth/$(Param_Data.Augmentation_Value.augmentationType)_$(Param_Data.nbTx)_$(Param_Data.Chunksize)_$(Param_Network.Networkname)/$(Param_Data.E)_$(Param_Data.S)/$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.nameModel)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)/$(hardware1)"
    
savename ="$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.name)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)"
Scenario ="$(savepathbson)/F1_Score_$(hardware1)_seed_$(Param_Network.Seed_Network)_dr$(Param_Network.Train_args.dr).csv"
delim=';'
nameBase = split(Scenario,".")[1]
#  ----------------------------------------------------
# --- Loading the matrix 
# ----------------------------------------------------- 
matrice_5 = Matrix(DataFrame(CSV.File(Scenario;delim,types=Float64,header=false)))
Score_pourcent[2,4] = matrice_5[end,3] 



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


savepathbson = "run/Synth/$(Param_Data.Augmentation_Value.augmentationType)_$(Param_Data.nbTx)_$(Param_Data.Chunksize)_$(Param_Network.Networkname)/$(Param_Data.E)_$(Param_Data.S)/$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.nameModel)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)/$(hardware1)"
    
savename ="$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.name)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)"
Scenario ="$(savepathbson)/F1_Score_$(hardware1)_seed_$(Param_Network.Seed_Network)_dr$(Param_Network.Train_args.dr).csv"
delim=';'
nameBase = split(Scenario,".")[1]
#  ----------------------------------------------------
# --- Loading the matrix 
# ----------------------------------------------------- 
matrice_5 = Matrix(DataFrame(CSV.File(Scenario;delim,types=Float64,header=false)))
Score_pourcent[3,4] = matrice_5[end,3] 




nb_Augment = 100

Augmentation_Value = RiFyFi_VDG.Data_Augmented(;augmentationType,Channel,Channel_Test,nb_Augment)

# Creation of the data structure with the information of the dataset
Param_Data = RiFyFi_VDG.Data_Synth(name,nameModel,nbTx, NbSignals, Chunksize,features,S,E,C,RFF,Normalisation,pourcentTrain,configuration,seed_data,seed_model,seed_dataTest,seed_modelTest,Augmentation_Value)
# Train and test Datasets are created and saved in CSV files
RiFyFi_VDG.setSynthetiquecsv(Param_Data)

# Creation of the Network structure with the information of the network
Param_Network = RiFyFi_IdF.Network_struct(;Networkname,NbClass,Chunksize,NbSignals,Seed_Network,Train_args) 

# Train the network and save it 
RiFyFi.main(Param_Data,Param_Network)   


savepathbson = "run/Synth/$(Param_Data.Augmentation_Value.augmentationType)_$(Param_Data.nbTx)_$(Param_Data.Chunksize)_$(Param_Network.Networkname)/$(Param_Data.E)_$(Param_Data.S)/$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.nameModel)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)/$(hardware1)"
    
savename ="$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.name)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)"
Scenario ="$(savepathbson)/F1_Score_$(hardware1)_seed_$(Param_Network.Seed_Network)_dr$(Param_Network.Train_args.dr).csv"
delim=';'
nameBase = split(Scenario,".")[1]
#  ----------------------------------------------------
# --- Loading the matrix 
# ----------------------------------------------------- 
matrice_5 = Matrix(DataFrame(CSV.File(Scenario;delim,types=Float64,header=false)))
Score_pourcent[4,4] = matrice_5[end,3] 



nb_Augment = 150

Augmentation_Value = RiFyFi_VDG.Data_Augmented(;augmentationType,Channel,Channel_Test,nb_Augment)

# Creation of the data structure with the information of the dataset
Param_Data = RiFyFi_VDG.Data_Synth(name,nameModel,nbTx, NbSignals, Chunksize,features,S,E,C,RFF,Normalisation,pourcentTrain,configuration,seed_data,seed_model,seed_dataTest,seed_modelTest,Augmentation_Value)
# Train and test Datasets are created and saved in CSV files
RiFyFi_VDG.setSynthetiquecsv(Param_Data)

# Creation of the Network structure with the information of the network
Param_Network = RiFyFi_IdF.Network_struct(;Networkname,NbClass,Chunksize,NbSignals,Seed_Network,Train_args) 

# Train the network and save it 
RiFyFi.main(Param_Data,Param_Network)   


savepathbson = "run/Synth/$(Param_Data.Augmentation_Value.augmentationType)_$(Param_Data.nbTx)_$(Param_Data.Chunksize)_$(Param_Network.Networkname)/$(Param_Data.E)_$(Param_Data.S)/$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.nameModel)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)/$(hardware1)"
    
savename ="$(Param_Data.E)_$(Param_Data.S)_$(Param_Data.C)_$(Param_Data.RFF)_$(Param_Data.nbSignals)_$(Param_Data.name)_$(Param_Data.Augmentation_Value.Channel)_$(Param_Data.Augmentation_Value.Channel_Test)_nbAugment_$(Param_Data.Augmentation_Value.nb_Augment)"
Scenario ="$(savepathbson)/F1_Score_$(hardware1)_seed_$(Param_Network.Seed_Network)_dr$(Param_Network.Train_args.dr).csv"
delim=';'
nameBase = split(Scenario,".")[1]
#  ----------------------------------------------------
# --- Loading the matrix 
# ----------------------------------------------------- 
matrice_5 = Matrix(DataFrame(CSV.File(Scenario;delim,types=Float64,header=false)))
Score_pourcent[5,4] = matrice_5[end,3] 



dictMarker  = ["square*","triangle*","diamond*","*","pentagon*","rect","otimes","triangle*"];
	# --- Dictionnary for colors 
	dictColor   = ColorSchemes.tableau_superfishel_stone
	@pgf a = Axis({
				height      ="3in",             # Size of Latex object, adapted to IEEE papers 
				width       ="4in",
				grid,
				xlabel      = "Time [s]",       # X axis name 
				ylabel      = "F1 score",       # Y axis name  
				legend_style="{at={(1,0)},anchor=south east,legend cell align=left,align=left,draw=white!15!black}"         # Legend, 2 first parameters are important: we anchor the legend in bottom right (south east) and locate it in bottom right of the figure (1,0)
				},
	);
	
	
	@pgf push!(a,Plot({color=dictColor[1],mark=dictMarker[1]},Table([(Score_pourcent[:,1]),(Score_pourcent[:,2])])))
	@pgf push!(a, LegendEntry("10\\%")) 
	
	
	@pgf push!(a,Plot({color=dictColor[2],mark=dictMarker[1]},Table([(Score_pourcent[:,1]),(Score_pourcent[:,3])])))
	@pgf push!(a, LegendEntry("7\\%")) 
	
	
	@pgf push!(a,Plot({color=dictColor[3],mark=dictMarker[1]},Table([(Score_pourcent[:,1]),(Score_pourcent[:,4])])))
	@pgf push!(a, LegendEntry("5\\%")) 
	
	
	
	pgfsave("./F1_Score_.tex",a)