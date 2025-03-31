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
	#λ = 0               # L2 regularizer param, implemented as weight decay
	batchsize = 64     # batch size
	epochs = 1000    # number of epochs
	#seed = 12           # set seed > 0 for reproducibility
	use_cuda = true     # if true use cuda (if available)
	#infotime = 1 	    # report every `infotime` epochs
	#checktime = 0       # Save the model every `checktime` epochs. Set to 0 for no checkpoints.
	#tblogger = true     # log training with tensorboard
	#tInit       = 0.0 
	#timings    = zeros(epochs) # Store timings of train 
	
	
end

# ╔═╡ 6fd4408f-679b-471c-ac72-b705b231c6b0
begin
	
	
	########### Network struct ###########
	Networkname = "AlexNet"
	NbClass = nbTx
	#Chunksize = 256
	NbSignals = nbSignals
	Seed_Network = 14
	#Train_args =  Args()
	#model  = initAlexNet(256,4,Train_args.dr)[1]
	#loss = initAlexNet(256,4,Train_args.dr)[2]
	Train_args = RiFyFi_IdF.Args(η = η ,dr=dr, epochs= epochs,batchsize=batchsize,use_cuda=use_cuda)
	# ---------------------------------------------------------------------------------------------
	savepathbson=""
	
end

# ╔═╡ 28a0811b-30f9-4beb-80f7-692b10767176
begin
	
	########### Augmentation struct ###########
	augmentationType = "augment"
	Channel = "etu"
	Channel_Test = "etu"
	nb_Augment = 1
	#seed_channel = 12
	#seed_channel_test = 12
	#burstSize =64
	
	Augmentation_Value = RiFyFi_VDG.Data_Augmented(;augmentationType,Channel,Channel_Test,nb_Augment)
	
	
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
# ╠═28a0811b-30f9-4beb-80f7-692b10767176
