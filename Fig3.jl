
using Markdown
using InteractiveUtils

using Pkg

Pkg.add(url="https://github.com/JuliaTelecom/Rifyfi.jl")
using RiFyFi
using RiFyFi.RiFyFi_IdF
using RiFyFi.RiFyFi_VDG
using RiFyFi.Experiment_Database
using RiFyFi.Results
using Infiltrator
using DataFrames
Tab_3 = zeros(4,3)
Tab_3[:,1]= [10000,50000,10000,200000]
	

########### Experiment Data struct ###########
nbRadioTx = 5
Chunksize = 256
features = "IQsamples"
pourcentTrain =0.9

	
########### Args Network struct ###########
η = 1e-4           # learning rate e-5
dr = 0.5
#λ = 0               # L2 regularizer param, implemented as weight decay
batchsize = 64     # batch size
epochs = 1000    # number of epochs
seed = 12           # set seed > 0 for reproducibility
use_cuda = true     # if true use cuda (if available)



########### Network struct ###########
Networkname = "AlexNet"
NbClass = nbRadioTx
#Chunksize = 256
#NbSignals = nbSignals
Seed_Network = 11
#Train_args =  Args()
#model  = initAlexNet(256,4,Train_args.dr)[1]
#loss = initAlexNet(256,4,Train_args.dr)[2]
Train_args = RiFyFi_IdF.Args(η = η ,dr=dr, epochs= epochs,batchsize=batchsize,use_cuda=use_cuda)

# ---------------------------------------------------------------------------------------------
savepathbson=""

Type_of_sig = "Preamble"
for (i, NbSignals) in enumerate([10000,50000])
	# Creation of the data structure with the information of the training dataset
	Param_Data = Experiment_Database.Data_Exp(;run="1",nbTx=5,nbSignals=NbSignals,Chunksize=Chunksize,Type_of_sig=Type_of_sig)
	# Creation of the Network structure with the information of the network
	Param_Network = Param_Network = RiFyFi_IdF.Network_struct(;Networkname,NbClass,Chunksize,NbSignals,Seed_Network,Train_args) 
	# Train the network and save it 
	RiFyFi.main(Param_Data,Param_Network)  

	# Creation of the data structure with the information of the testin dataset - different scenario 
	Param_Data_test = Experiment_Database.Data_Exp(;run="5",nbTx=5,nbSignals=NbSignals,Chunksize=Chunksize,Type_of_sig=Type_of_sig)

	# Testing Dataset is created and saved in CSV files
	Tab_3[i,2]=Results.main(Param_Data,Param_Network,"Confusion_Matrix",savepathbson,Param_Data,Seed_Network)

	Tab_3[i,3]=Results.main(Param_Data,Param_Network,"Confusion_Matrix",savepathbson,Param_Data_test,Seed_Network)
end 


Type_of_sig="Payload"
for (i, NbSignals) in enumerate([10000,200000])

	# Creation of the data structure with the information of the training dataset
	Param_Data = Experiment_Database.Data_Exp(;run="1",nbTx=5,nbSignals=NbSignals,Chunksize=Chunksize,Type_of_sig=Type_of_sig)
	# Creation of the Network structure with the information of the network
	Param_Network = Param_Network = RiFyFi_IdF.Network_struct(;Networkname,NbClass,Chunksize,NbSignals,Seed_Network,Train_args) 
	# Train the network and save it 

	RiFyFi.main(Param_Data,Param_Network)  
	# Creation of the data structure with the information of the testin dataset - different scenario 
	Param_Data_test = Experiment_Database.Data_Exp(;run="5",nbTx=5,nbSignals=NbSignals,Chunksize=Chunksize,Type_of_sig=Type_of_sig)

	# Testing Dataset is created and saved in CSV files
	Tab_3[2+i,2]=Results.main(Param_Data,Param_Network,"Confusion_Matrix",savepathbson,Param_Data,Seed_Network)

	Tab_3[2+i,3]=Results.main(Param_Data,Param_Network,"Confusion_Matrix",savepathbson,Param_Data_test,Seed_Network)
end 


Tab_3[:,1]=[9000,45000,9000,180000]


Preambule=DataFrame(nbsig=Tab_3[1:2,1],Scenario_Preambule_1=Tab_3[1:2,2],Scenario_Preambule_4=Tab_3[1:2,3])


Payload=DataFrame(nbsig=Tab_3[3:4,1],Scenario_Payload_1=Tab_3[3:4,2],Scenario_Payload_4=Tab_3[3:4,3])
show(Preambule)


show(Payload)
