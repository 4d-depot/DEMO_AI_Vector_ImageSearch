property _trace : Boolean  // Controls debug mode (TRACE on/off)

session singleton Class constructor()
	
	
	//****************************************************************
	// 
exposed Function initOpenAIStorage()
	Use (Storage)
		Storage.OpenAI:=New shared object
		Use (Storage.OpenAI)
			Storage.OpenAI.key:=""
		End use 
	End use 
	
	//****************************************************************
	// 
exposed Function saveOpenAIKey($openAIKey : Text)
	Use (Storage)
		Use (Storage.OpenAI)
			Storage.OpenAI.key:=$openAIKey
		End use 
	End use 
	
	//****************************************************************
	// Returns the complete list of images from the Pictures data class
shared Function pictureList() : cs.PicturesSelection
	
	return ds.Pictures.all()
	
	//****************************************************************
	// Initializes the trace mode to false
exposed shared Function initTrace() : Boolean
	This._trace:=False
	return This._trace
	
	//****************************************************************
	// Toggles trace mode (on/off) and returns the new state
exposed shared Function trace() : Boolean
	This._trace:=Not(This._trace)
	return This._trace
	
	//****************************************************************
	// Function to calculate image similarities based on the custom prompt
exposed shared Function calculate($prompt : Text) : cs.PicturesSelection
	var $apiModal : 4D.WebFormItem
	var $apiKey:=""
	
	// If no key is found, alert the user
	If (Storage.OpenAI.key#"")
		$apiKey:=Storage.OpenAI.key
	Else 
		$apiModal:=Web Form.setApiKeyModal
		$apiModal.show()
	End if 
	
	// If trace mode is on, start 4D's TRACE debugger
	If (This._trace)
		TRACE
	End if 
	
	// Proceed only if both prompt and API key are available
	If (($prompt#"") && ($apiKey#""))
		
		// Generate a vector from the custom prompt using the AIManagement class
		var $vector:=cs.AIManagement.new($apiKey).generateVector($prompt)
		
		// Calculate similarities between the prompt vector and all image vectors
		var $pictureList:=This._calculateVectors($vector)
		
		// Return the images ordered by cosine similarity (most similar first)
		return $pictureList.orderBy("cosineSimilarity desc")
		
	Else 
		// If no prompt, return all pictures unfiltered
		return This.pictureList()
		
	End if 
	
	
	//****************************************************************
	// Calculates image similarity based on a selected prompt object
exposed shared Function calculateWithSelectedPrompt($prompt : cs.PromptsEntity) : cs.PicturesSelection
	// If trace mode is on, start 4D's TRACE debugger
	If (This._trace)
		TRACE
	End if 
	
	// Use precalculated vector from the selected prompt and calculate similarities
	var $pictureList:=This._calculateVectors($prompt.Vector)
	
	// Return the images ordered by cosine similarity (most similar first)
	return $pictureList.orderBy("cosineSimilarity desc")
	
	
	//****************************************************************
	// Returns the first prompt stored in the database to init the select box
exposed shared Function selectedPromptInit() : cs.PromptsEntity
	return ds.Prompts.get(1)
	
	
	//****************************************************************
	// Returns all stored prompts  to init the select box
exposed shared Function promptList() : cs.PromptsSelection
	return ds.Prompts.all()
	
	
	//****************************************************************
	// Calculate and store similarity metrics for all images
shared Function _calculateVectors($vector : 4D.Vector) : cs.PicturesSelection
	var $picture : cs.PicturesEntity
	var $pictureList:=This.pictureList()
	
	// Iterate over each picture and calculate similarity scores
	For each ($picture; $pictureList)
		
		$picture.cosineSimilarity:=$vector.cosineSimilarity($picture.vector)
		$picture.dotSimilarity:=$vector.dotSimilarity($picture.vector)
		$picture.euclideanDistance:=$vector.euclideanDistance($picture.vector)
		$picture.save()
		
	End for each 
	
	// Return the updated picture list
	return $pictureList
	
	
	
	//****************************************************************
	// Image → Description → Embedding (store vector for semantic search)
exposed Function vectorizeImageDescription($imageToUpload : cs.PicturesEntity) : cs.PicturesEntity
	
	// --- Vars ---
	var $apiKey; $caption; $description; $captionPrompt; $descriptionPrompt; $base64Encoded; $imageData : Text
	var $client : Object
	var $picture : Picture
	var $pictureEntity : cs.PicturesEntity
	var $apiModal : 4D.WebFormItem
	
	// If no key is found, alert the user
	If (Storage.OpenAI.key#"")
		$apiKey:=Storage.OpenAI.key
	Else 
		$apiModal:=Web Form.setApiKeyModal
		$apiModal.show()
	End if 
	
	// Optional: trace
	If (This._trace)
		TRACE
	End if 
	
	// --- OpenAI client ---
	$client:=cs.AIKit.OpenAI.new($apiKey)
	
	// --- Encode image as Base64
	var $blob:=$imageToUpload.picture
	BASE64 ENCODE($blob; $base64Encoded)
	$imageData:="data:image/jpeg;base64,"+$base64Encoded

	// --- Prompts (single, fluent, embedding-friendly) ---
	$captionPrompt:="You are a precise visual captioner. "+\
		"Write one fluent English sentence, 20–30 words long, that vividly describes the main subject, context, and atmosphere of the image. "+\
		"Avoid lists, keywords, or extra commentary. Output only the sentence."

	$descriptionPrompt:="Describe the image in one clear and complete English sentence, between 20 and 40 words. "+\
		"Focus on the main subject, its setting, and any notable details or atmosphere. "+\
		"Do not provide lists, keywords, or multiple sentences. Return only the description."
	
	// --- Get caption ---
	$caption:=$client.chat.vision.create($imageData).prompt($captionPrompt).choice.message.text
	
	// --- Get description ---
	$description:=$client.chat.vision.create($imageData).prompt($descriptionPrompt).choice.message.text
	
	// --- Save entity ---
	$pictureEntity:=ds.Pictures.new()
	$pictureEntity.picture:=$imageToUpload.picture
	$pictureEntity.prompt:=$caption
	$pictureEntity.description:=$description
	$pictureEntity.vector:=cs.AIManagement.new($apiKey).generateVector($description+$caption)
	
	$status := $pictureEntity.save()
	
	If ($status.success)
		$apiModal:=Web Form.uploadImage
		$apiModal.hide()	
		Web Form.setMessage("Image uploaded successfully. The description has been vectorized and added to the database.")
	Else
		Web Form.setError("Upload failed. The image or its description could not be processed and saved.")
	End if
	
	return $pictureEntity
