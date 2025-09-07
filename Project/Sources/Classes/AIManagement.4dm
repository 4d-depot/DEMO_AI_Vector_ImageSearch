property clientAI : Object

// Constructor that initializes the OpenAI client with the provided API key
Class constructor($openAIKey : Text)
	
	This.clientAI:=cs.AIKit.OpenAI.new($openAIKey)
	
	
	// Function that generates a vector representation of the input text using OpenAI embeddings
Function generateVector($text : Text) : 4D.Vector
	
	// Name of the embedding model to use
	var $model:="text-embedding-ada-002"
	
	// Call the OpenAI embeddings API to generate the vector for the input text
	var $result:=This.clientAI.embeddings.create($text; $model)
	
	// Convert the embedding collection into a 4D.Vector object and return it
	return $result.vector