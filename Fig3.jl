### A Pluto.jl notebook ###
# v0.19.47

using Markdown
using InteractiveUtils

# ╔═╡ 7e033d42-3e48-4b51-983f-096366038b27
using Pkg

# ╔═╡ 9bd437de-24cc-11f0-3d65-052dc010e9b1
Pkg.add(url="https://github.com/JuliaTelecom/Rifyfi.jl")


# ╔═╡ 5f8e1437-31bb-40a2-b136-cfd65fbba8a6
using RiFyFi


# ╔═╡ 5809499b-ea61-4866-9161-53336473129b
using RiFyFi.RiFyFi_IdF


# ╔═╡ ffd7c330-5a43-4155-8f6b-67462cf64ccf
using RiFyFi.RiFyFi_VDG


# ╔═╡ 91dcb6c4-fff5-4411-9725-7ce9ae68c0d8
using RiFyFi.Experiment_Database

# ╔═╡ 9020bd9c-e75b-4369-b6f0-ef49168dfe22
begin
	Tab_3 = zeros(4,3)
	Tab_3[:,1]= [10000,50000,10000,200000]
	
end

# ╔═╡ 255d49bf-076c-46c5-87e9-f8767cabb149
begin
	########### Experiment Data struct ###########
	#Type_of_sig = "Preamble"
	File_Path = "/media/redinblack/ANR_RedInBlack/rffExperiment/"
	nbRadioTx = 5
	#nbSignals = 10000
	Chunksize = 256
	features = "IQsamples"
	pourcentTrain =0.9
end

# ╔═╡ 34920e87-c4a3-4efd-9497-59b1ac6f333f
begin
	########### Args Network struct ###########
	η = 1e-4           # learning rate e-5
	dr = 0.5
	#λ = 0               # L2 regularizer param, implemented as weight decay
	batchsize = 64     # batch size
	epochs = 1    # number of epochs
	#seed = 12           # set seed > 0 for reproducibility
	use_cuda = true     # if true use cuda (if available)
end

# ╔═╡ 2b21ffa8-a726-4c2a-a0f1-ade929c46d75
begin
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
	
end

# ╔═╡ 5128a9f5-be5a-4b3e-bc38-2285c36ed74c
begin
	Type_of_sig="Preamble"
	NbSignals= 10000
	# Creation of the data structure with the information of the training dataset
	Param_Data=Experiment_Database.Data_Exp(;run="1",nbTx=5,nbSignals=NbSignals,Chunksize=Chunksize,Type_of_sig=Type_of_sig)
	
	# Train Datasets are created and saved in CSV files
	# Ici les fichiers CSV à utiliser sont fournit et à télécharger sur RedInBlack (voir Readme). 
	#Experiment_Database.setExpcsv(Param_Data)
	
	# Creation of the Network structure with the information of the network
	Param_Network = Param_Network = RiFyFi_IdF.Network_struct(;Networkname,NbClass,Chunksize,NbSignals,Seed_Network,Train_args) 

	
	# Train the network and save it 
	RiFyFi.main(Param_Data,Param_Network)  
	
	# Creation of the data structure with the information of the testin dataset - different scenario 
	Param_Data_test=Experiment_Database.Data_Exp(;run="5",nbTx=5,nbSignals=NbSignals,Chunksize=Chunksize,Type_of_sig=Type_of_sig)
	
	# Testing Dataset is created and saved in CSV files
	#Experiment_Database.setExpcsv(Param_Data_test)
	Tab_3[1,2]=Results.main(Param_Data,Param_Network,"Confusion_Matrix",savepathbson,Param_Data,Seed_Network)

	Tab_3[1,3]=Results.main(Param_Data,Param_Network,"Confusion_Matrix",savepathbson,Param_Data_test,Seed_Network)
	
end

# ╔═╡ 2da63d9b-9790-48b2-9ff2-d814d0cd22c5

Type_of_sig="Preamble"
NbSignals= 50000
# Creation of the data structure with the information of the dataset
Param_Data=Experiment_Database.Data_Exp(;run="1",nbTx=5,nbSignals=NbSignals,Chunksize=Chunksize,Type_of_sig=Type_of_sig)

# Train and test Datasets are created and saved in CSV files
# Experiment_Database.setExpcsv(Param_Data)

# Creation of the Network structure with the information of the network
Param_Network = RiFyFi_IdF.Network_struct(;Networkname,NbClass,Chunksize,NbSignals,Seed_Network,Train_args) 

# Train the network and save it 
RiFyFi.main(Param_Data,Param_Network)  

# Create a figure to show the evolution of the F1-score during the training 
Param_Data_test=Experiment_Database.Data_Exp(;run="5",nbTx=5,nbSignals=NbSignals,Chunksize=Chunksize,Type_of_sig=Type_of_sig)

#Experiment_Database.setExpcsv(Param_Data_test)
Tab_3[2,2]=Results.main(Param_Data,Param_Network,"Confusion_Matrix",savepathbson,Param_Data,Seed_Network)

Tab_3[2,3]=Results.main(Param_Data,Param_Network,"Confusion_Matrix",savepathbson,Param_Data_test,Seed_Network)



# ╔═╡ d0403786-9029-4a1c-8652-6996a8c2699c


Type_of_sig="Payload"
NbSignals= 10000
# Creation of the data structure with the information of the dataset
Param_Data=Experiment_Database.Data_Exp(;run="1",nbTx=5,nbSignals=NbSignals,Chunksize=Chunksize,Type_of_sig=Type_of_sig)

# Train and test Datasets are created and saved in CSV files
# Experiment_Database.setExpcsv(Param_Data)

# Creation of the Network structure with the information of the network
Param_Network = RiFyFi_IdF.Network_struct(;Networkname,NbClass,Chunksize,NbSignals,Seed_Network,Train_args) 

# Train the network and save it 
RiFyFi.main(Param_Data,Param_Network)  

# Create a figure to show the evolution of the F1-score during the training 
Param_Data_test=Experiment_Database.Data_Exp(;run="5",nbTx=5,nbSignals=NbSignals,Chunksize=Chunksize,Type_of_sig=Type_of_sig)

#Experiment_Database.setExpcsv(Param_Data_test)
Tab_3[3,2]=Results.main(Param_Data,Param_Network,"Confusion_Matrix",savepathbson,Param_Data,Seed_Network)

Tab_3[3,3]=Results.main(Param_Data,Param_Network,"Confusion_Matrix",savepathbson,Param_Data_test,Seed_Network)


# ╔═╡ a1233a53-6b59-461a-affd-63635a0c9a0d

Type_of_sig="Payload"
NbSignals= 200000
# Creation of the data structure with the information of the dataset
Param_Data=Experiment_Database.Data_Exp(;run="1",nbTx=5,nbSignals=NbSignals,Chunksize=Chunksize,Type_of_sig=Type_of_sig)

# Train and test Datasets are created and saved in CSV files
Experiment_Database.setExpcsv(Param_Data)

# Creation of the Network structure with the information of the network
Param_Network = RiFyFi_IdF.Network_struct(;Networkname,NbClass,Chunksize,NbSignals,Seed_Network,Train_args) 

# Train the network and save it 
RiFyFi.main(Param_Data,Param_Network)  

# Create a figure to show the evolution of the F1-score during the training 
Param_Data_test=Experiment_Database.Data_Exp(;run="5",nbTx=5,nbSignals=NbSignals,Chunksize=Chunksize,Type_of_sig=Type_of_sig)
Experiment_Database.setExpcsv(Param_Data_test)


#Experiment_Database.setExpcsv(Param_Data_test)
Tab_3[4,2]=Results.main(Param_Data,Param_Network,"Confusion_Matrix",savepathbson,Param_Data,Seed_Network)

Tab_3[4,3]=Results.main(Param_Data,Param_Network,"Confusion_Matrix",savepathbson,Param_Data_test,Seed_Network)


# ╔═╡ 3092e3a2-eb21-4d9a-8125-fe19021fd27e

Tab_3[:,1]=[9000,45000,9000,180000]


Preambule=DataFrame(nbsig=Tab_3[1:2,1],Scenario_Preambule_1=Tab_3[1:2,2],Scenario_Preambule_4=Tab_3[1:2,3])


Payload=DataFrame(nbsig=Tab_3[3:4,1],Scenario_Payload_1=Tab_3[3:4,2],Scenario_Payload_4=Tab_3[3:4,3])
show(Preambule)


show(Payload)


# ╔═╡ Cell order:
# ╠═7e033d42-3e48-4b51-983f-096366038b27
# ╠═9bd437de-24cc-11f0-3d65-052dc010e9b1
# ╠═5f8e1437-31bb-40a2-b136-cfd65fbba8a6
# ╠═5809499b-ea61-4866-9161-53336473129b
# ╠═ffd7c330-5a43-4155-8f6b-67462cf64ccf
# ╠═91dcb6c4-fff5-4411-9725-7ce9ae68c0d8
# ╠═9020bd9c-e75b-4369-b6f0-ef49168dfe22
# ╠═255d49bf-076c-46c5-87e9-f8767cabb149
# ╠═34920e87-c4a3-4efd-9497-59b1ac6f333f
# ╠═2b21ffa8-a726-4c2a-a0f1-ade929c46d75
# ╠═5128a9f5-be5a-4b3e-bc38-2285c36ed74c
# ╠═2da63d9b-9790-48b2-9ff2-d814d0cd22c5
# ╠═d0403786-9029-4a1c-8652-6996a8c2699c
# ╠═a1233a53-6b59-461a-affd-63635a0c9a0d
# ╠═3092e3a2-eb21-4d9a-8125-fe19021fd27e
