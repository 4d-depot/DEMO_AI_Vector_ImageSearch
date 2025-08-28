# DEMO_AI_Vector_ImageSearch

Semantic Image Similarity Search with [4D.Vector](https://developer.4d.com/docs/API/VectorClass) and [4D AI Kit](https://developer.4d.com/docs/aikit/overview) (4D 20 R10).

This demo illustrates how to:

* Generate embeddings (vectors) from text prompts and image descriptions.
* Compare vectors using cosine similarity, dot product, and Euclidean distance.
* Search images by **meaning**, not by filenames or metadata.

👉 Full explanation available in the [blog post](https://blog.4d.com/semantic-image-search-with-ai-and-vector-embeddings).

## Installing and Using a 4D Project

### 📦 Pre-requisites

#### **4D Software**

* Download the latest **Release** version of 4D: [Product Download](https://us.4d.com/product-download)
* Or the latest **Beta** version: [Beta Program](https://discuss.4d.com)
* Follow activation steps: [Installation Guide](https://developer.4d.com/docs/GettingStarted/installation)

#### **OpenAI API Key** (required for AI-powered semantic search)

* Generate one here: [OpenAI API Keys](https://platform.openai.com/account/api-keys)
* Best practices:
  * Never share your key publicly (e.g., in GitHub).
  * Store securely (environment variables, config files outside version control).
  * Monitor usage in the OpenAI dashboard.
  * Set limits or alerts to avoid unexpected costs.

#### **Qodly Studio**

* Enable Qodly Studio: [Qodly Studio Setup](https://developer.4d.com/docs/WebServer/qodly-studio)


### ▶️ Steps to Run the Project

#### Standard 4D Usage

1. Clone or download this repository to your local machine.
   * Need help? See [Using GitHub with 4D](https://blog.4d.com/github-4d-depot/).
2. Open the project in 4D:
   * Go to **File > Open Project** (More details here: [Open a Project](https://developer.4d.com/docs/GettingStarted/creating#opening-a-project))
3. Go to **Design > Qodly Studio… > Preview**.
3. Enter your OpenAI API Key:
   * Go to the **API Key** input field in the **Info tab** and fill it.
   * If you forget, the demo will prompt you with a modal before proceeding.
5. Play with the demo:
   * Type or select a prompt → The app compares it with stored vectors and returns ranked images.
   * Upload images → The app generates a caption & description, then embeds them as vectors.
6. Inspect the code:
   * Switch to design mode: **Mode > Return to Design Mode**.